#!/usr/bin/env python3
"""Incremental TMDB movie sync using /movie/changes (14-day window aware)."""

from __future__ import annotations

import argparse
import datetime as dt
import sqlite3
import tempfile
import time
from pathlib import Path

from tmdb_sync_common import (
    LOGGER,
    MOVIE_HEADERS,
    TMDBClient,
    configure_logging,
    date_range,
    export_sqlite_to_csv,
    format_duration,
    load_checkpoint,
    load_config,
    load_csv_to_sqlite,
    latest_date_from_csv,
    parse_date,
    progress_line,
    save_checkpoint,
    today_utc,
    upsert_row_sqlite,
    movie_row_from_details,
)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--csv", default="TMDB_movie_dataset.csv")
    parser.add_argument("--in-place", action="store_true")
    parser.add_argument(
        "--insert-only",
        action="store_true",
        help="Only insert new IDs; skip updates for IDs already present in the existing CSV.",
    )
    parser.add_argument("--output-csv", default="")
    parser.add_argument("--checkpoint-file", default=".local/tmdb_incremental_movies_checkpoint.json")
    parser.add_argument("--start-date", default="")
    parser.add_argument("--end-date", default="")
    parser.add_argument("--window-buffer-days", type=int, default=7)
    parser.add_argument(
        "--window-from-latest-release",
        dest="window_from_latest_release",
        action="store_true",
        default=True,
        help="Auto-derive start date from latest release_date in existing dataset (minus buffer days).",
    )
    parser.add_argument(
        "--no-window-from-latest-release",
        dest="window_from_latest_release",
        action="store_false",
        help="Disable latest-release-based window inference.",
    )
    parser.add_argument("--max-rps", type=float, default=12.0)
    parser.add_argument("--timeout-seconds", type=float, default=25.0)
    parser.add_argument("--retries", type=int, default=6)
    parser.add_argument("--log-every", type=int, default=50)
    parser.add_argument("--language", default="en-US")
    parser.add_argument("--log-level", default="INFO")
    parser.add_argument("--tmdb-base-url", default="")
    parser.add_argument("--tmdb-api-key", default="")
    parser.add_argument("--tmdb-bearer-token", default="")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    configure_logging(args.log_level)
    config = load_config()
    checkpoint_path = Path(args.checkpoint_file)
    checkpoint = load_checkpoint(checkpoint_path)

    base_url = (
        args.tmdb_base_url
        or (config.get("MOVIE_PROXY_BASE_URL") or "").strip()
        or "https://api.themoviedb.org/3"
    )
    api_key = (args.tmdb_api_key or "").strip()
    bearer_token = (args.tmdb_bearer_token or "").strip()

    client = TMDBClient(
        base_url=base_url,
        api_key=api_key,
        bearer_token=bearer_token,
        max_rps=args.max_rps,
        timeout_seconds=args.timeout_seconds,
        retries=args.retries,
    )

    today = today_utc()
    end_date = parse_date(args.end_date) if args.end_date else today
    if args.start_date:
        start_date = parse_date(args.start_date)
    else:
        candidates: list[dt.date] = []
        if checkpoint.get("last_completed_date"):
            candidates.append(parse_date(checkpoint["last_completed_date"]) + dt.timedelta(days=1))
        if args.window_from_latest_release:
            latest_release = latest_date_from_csv(
                csv_path=Path(args.csv),
                date_columns=["release_date"],
            )
            if latest_release is not None:
                if latest_release > today:
                    latest_release = today
                anchor = latest_release - dt.timedelta(days=max(0, args.window_buffer_days))
                candidates.append(anchor)
                LOGGER.info(
                    "Derived movie window anchor from latest release_date=%s with buffer=%s day(s) -> %s",
                    latest_release,
                    args.window_buffer_days,
                    anchor,
                )
        start_date = min(candidates) if candidates else (today - dt.timedelta(days=1))

    if start_date > end_date:
        LOGGER.info("No sync needed. start_date=%s end_date=%s", start_date, end_date)
        return

    started = time.time()
    changed_ids: set[int] = set()

    discovery_days = list(date_range(start_date, end_date))
    LOGGER.info("Discovering changed movie IDs from %s to %s", start_date, end_date)
    discovery_started = time.time()
    for day_index, day in enumerate(discovery_days, start=1):
        page = 1
        total_pages = 1
        day_text = day.strftime("%Y-%m-%d")
        while page <= total_pages:
            try:
                payload = client.get_json(
                    "/movie/changes",
                    params={
                        "start_date": day_text,
                        "end_date": day_text,
                        "page": page,
                    },
                )
            except Exception as error:
                if "Unsupported proxy route" in str(error):
                    raise
                LOGGER.warning(
                    "Failed fetching movie changes for %s page %s: %s",
                    day_text,
                    page,
                    error,
                )
                page += 1
                continue
            if payload is None:
                break
            total_pages = int(payload.get("total_pages") or 1)
            results = payload.get("results") or []
            for item in results:
                try:
                    raw_id = int(item.get("id"))
                except Exception:
                    continue
                if raw_id > 0:
                    changed_ids.add(raw_id)
            if page % 10 == 0 or page == total_pages:
                LOGGER.info(
                    "%s | %s page %s/%s | unique_ids=%s",
                    progress_line(
                        processed=day_index,
                        total=len(discovery_days),
                        started_at=discovery_started,
                        prefix="Movie changes discovery",
                    ),
                    day_text,
                    page,
                    total_pages,
                    len(changed_ids),
                )
            page += 1

    if not changed_ids:
        LOGGER.info("No changed movie IDs found for requested range.")
        save_checkpoint(
            checkpoint_path,
            {
                "last_completed_date": end_date.strftime("%Y-%m-%d"),
                "updated_at": int(time.time()),
                "changed_ids": 0,
            },
        )
        return

    changed_list = sorted(changed_ids)
    LOGGER.info("Total unique changed movie IDs: %s", len(changed_list))

    csv_path = Path(args.csv)
    with tempfile.TemporaryDirectory(prefix="tmdb_movie_incremental_") as tmp_dir:
        db_path = Path(tmp_dir) / "movies.sqlite"
        conn = sqlite3.connect(db_path)
        try:
            conn.execute(
                "CREATE TABLE IF NOT EXISTS rows (id INTEGER PRIMARY KEY, row_json TEXT NOT NULL)"
            )
            conn.commit()
            existing_ids = load_csv_to_sqlite(
                csv_path=csv_path,
                headers=MOVIE_HEADERS,
                conn=conn,
                table_name="rows",
            )
            processed = 0
            updated = 0
            created = 0
            not_found = 0
            failed = 0
            skipped_existing = 0
            for movie_id in changed_list:
                processed += 1
                if args.insert_only and movie_id in existing_ids:
                    skipped_existing += 1
                    continue
                try:
                    details = client.get_json(
                        f"/movie/{movie_id}",
                        params={"append_to_response": "keywords", "language": args.language},
                    )
                except Exception as error:
                    failed += 1
                    LOGGER.warning("Failed movie id=%s: %s", movie_id, error)
                    continue
                if details is None:
                    not_found += 1
                    continue
                row = movie_row_from_details(details)
                if not row.get("id"):
                    not_found += 1
                    continue
                upsert_row_sqlite(
                    conn=conn,
                    table_name="rows",
                    row_id=movie_id,
                    row=row,
                )
                if movie_id in existing_ids:
                    updated += 1
                else:
                    existing_ids.add(movie_id)
                    created += 1

                if processed % max(1, args.log_every) == 0:
                    LOGGER.info(
                        "%s | updated=%s created=%s not_found=%s failed=%s skipped_existing=%s",
                        progress_line(
                            processed=processed,
                            total=len(changed_list),
                            started_at=started,
                            prefix="Movie incremental",
                        ),
                        updated,
                        created,
                        not_found,
                        failed,
                        skipped_existing,
                    )

            conn.commit()
            output_csv = Path(args.output_csv) if args.output_csv else csv_path.with_suffix(".incremental_tmp.csv")
            exported = export_sqlite_to_csv(
                conn=conn,
                table_name="rows",
                headers=MOVIE_HEADERS,
                output_csv=output_csv,
            )
            if args.in_place:
                backup = csv_path.with_suffix(".pre_incremental.bak.csv")
                if csv_path.exists():
                    backup.write_bytes(csv_path.read_bytes())
                output_csv.replace(csv_path)
                LOGGER.info("Incremental movie sync replaced %s (%s rows)", csv_path, exported)
                LOGGER.info("Backup created at %s", backup)
            else:
                LOGGER.info("Incremental movie sync wrote %s rows to %s", exported, output_csv)

            save_checkpoint(
                checkpoint_path,
                {
                    "last_completed_date": end_date.strftime("%Y-%m-%d"),
                    "updated_at": int(time.time()),
                    "changed_ids": len(changed_list),
                    "processed_ids": processed,
                    "updated_rows": updated,
                    "created_rows": created,
                    "not_found": not_found,
                    "failed": failed,
                    "skipped_existing": skipped_existing,
                    "elapsed_seconds": int(time.time() - started),
                },
            )
            LOGGER.info("Movie incremental sync finished in %s", format_duration(int(time.time() - started)))
        finally:
            conn.close()


if __name__ == "__main__":
    main()
