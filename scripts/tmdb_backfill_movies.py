#!/usr/bin/env python3
"""One-time movie backfill from TMDB exports + movie details.

Updates/upserts into existing TMDB_movie_dataset.csv.
"""

from __future__ import annotations

import argparse
import sqlite3
import tempfile
import time
from pathlib import Path

from tmdb_sync_common import (
    LOGGER,
    MOVIE_HEADERS,
    TMDBClient,
    configure_logging,
    export_sqlite_to_csv,
    fetch_tmdb_export_ids,
    format_duration,
    load_checkpoint,
    load_config,
    load_csv_to_sqlite,
    movie_row_from_details,
    progress_line,
    save_checkpoint,
    upsert_row_sqlite,
)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--csv", default="TMDB_movie_dataset.csv")
    parser.add_argument("--output-csv", default="")
    parser.add_argument("--in-place", action="store_true")
    parser.add_argument(
        "--insert-only",
        action="store_true",
        help="Only insert new IDs; skip updates for IDs already present in the existing CSV.",
    )
    parser.add_argument("--max-ids", type=int, default=0)
    parser.add_argument("--max-rps", type=float, default=12.0)
    parser.add_argument("--timeout-seconds", type=float, default=25.0)
    parser.add_argument("--retries", type=int, default=6)
    parser.add_argument("--lookback-days", type=int, default=21)
    parser.add_argument("--export-cache-dir", default=".local/tmdb_exports")
    parser.add_argument("--checkpoint-file", default=".local/tmdb_backfill_movies_checkpoint.json")
    parser.add_argument("--save-every", type=int, default=50)
    parser.add_argument("--log-every", type=int, default=100)
    parser.add_argument("--language", default="en-US")
    parser.add_argument(
        "--only-original-languages",
        default="",
        help="Comma-separated ISO 639-1 codes to keep (example: hi,ta,en). Empty means all languages.",
    )
    parser.add_argument("--log-level", default="INFO")
    parser.add_argument("--tmdb-base-url", default="")
    parser.add_argument("--tmdb-api-key", default="")
    parser.add_argument("--tmdb-bearer-token", default="")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    configure_logging(args.log_level)
    config = load_config()

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

    ids = fetch_tmdb_export_ids(
        media_type="movie",
        cache_dir=Path(args.export_cache_dir),
        lookback_days=args.lookback_days,
    )
    if args.max_ids > 0:
        ids = ids[: args.max_ids]
    total_ids = len(ids)
    if total_ids == 0:
        raise RuntimeError("No movie IDs found in export.")

    csv_path = Path(args.csv)
    checkpoint_path = Path(args.checkpoint_file)
    checkpoint = load_checkpoint(checkpoint_path)
    start_index = int(checkpoint.get("last_index", -1)) + 1
    if start_index >= total_ids:
        start_index = 0

    LOGGER.info("Backfill movies starting from index %s/%s", start_index, total_ids)
    allowed_languages = {
        token.strip().lower()
        for token in args.only_original_languages.split(",")
        if token.strip()
    }
    if allowed_languages:
        LOGGER.info(
            "Language filter enabled: only original_language in [%s]",
            ", ".join(sorted(allowed_languages)),
        )
    started = time.time()

    with tempfile.TemporaryDirectory(prefix="tmdb_movie_backfill_") as tmp_dir:
        db_path = Path(tmp_dir) / "movies.sqlite"
        conn = sqlite3.connect(db_path)
        try:
            conn.execute(
                "CREATE TABLE IF NOT EXISTS rows (id INTEGER PRIMARY KEY, row_json TEXT NOT NULL)"
            )
            conn.commit()

            LOGGER.info("Loading existing CSV into local DB: %s", csv_path)
            existing_ids = load_csv_to_sqlite(
                csv_path=csv_path,
                headers=MOVIE_HEADERS,
                conn=conn,
                table_name="rows",
            )
            LOGGER.info("Loaded %s existing movie IDs", len(existing_ids))

            processed = 0
            fetched = 0
            updated = 0
            created = 0
            not_found = 0
            failed = 0
            skipped_language = 0
            skipped_existing = 0

            for idx in range(start_index, total_ids):
                movie_id = ids[idx]
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
                else:
                    row = movie_row_from_details(details)
                    if not row.get("id"):
                        not_found += 1
                    else:
                        row_lang = (row.get("original_language") or "").strip().lower()
                        if allowed_languages and row_lang not in allowed_languages:
                            skipped_language += 1
                            continue
                        upsert_row_sqlite(
                            conn=conn,
                            table_name="rows",
                            row_id=movie_id,
                            row=row,
                        )
                        fetched += 1
                        if movie_id in existing_ids:
                            updated += 1
                        else:
                            existing_ids.add(movie_id)
                            created += 1

                if processed % max(1, args.save_every) == 0:
                    conn.commit()
                    save_checkpoint(
                        checkpoint_path,
                        {
                            "last_index": idx,
                            "processed": processed,
                            "fetched": fetched,
                            "updated": updated,
                            "created": created,
                            "not_found": not_found,
                            "failed": failed,
                            "skipped_language": skipped_language,
                            "skipped_existing": skipped_existing,
                            "updated_at": int(time.time()),
                        },
                    )
                if processed % max(1, args.log_every) == 0:
                    LOGGER.info(
                        "%s | fetched=%s updated=%s created=%s not_found=%s failed=%s skipped_language=%s skipped_existing=%s",
                        progress_line(
                            processed=idx + 1,
                            total=total_ids,
                            started_at=started,
                            prefix="Movie backfill",
                        ),
                        fetched,
                        updated,
                        created,
                        not_found,
                        failed,
                        skipped_language,
                        skipped_existing,
                    )

            conn.commit()
            output_csv = Path(args.output_csv) if args.output_csv else csv_path.with_suffix(".backfill_tmp.csv")
            exported = export_sqlite_to_csv(
                conn=conn,
                table_name="rows",
                headers=MOVIE_HEADERS,
                output_csv=output_csv,
            )
            if args.in_place:
                backup = csv_path.with_suffix(".pre_backfill.bak.csv")
                if csv_path.exists():
                    backup.write_bytes(csv_path.read_bytes())
                output_csv.replace(csv_path)
                LOGGER.info("Backfill wrote %s rows and replaced %s", exported, csv_path)
                LOGGER.info("Backup created at %s", backup)
            else:
                LOGGER.info("Backfill wrote %s rows to %s", exported, output_csv)

            save_checkpoint(
                checkpoint_path,
                {
                    "last_index": total_ids - 1,
                    "completed": True,
                    "processed": processed,
                    "fetched": fetched,
                    "updated": updated,
                    "created": created,
                    "not_found": not_found,
                    "failed": failed,
                    "skipped_language": skipped_language,
                    "skipped_existing": skipped_existing,
                    "elapsed_seconds": int(time.time() - started),
                    "updated_at": int(time.time()),
                },
            )
            LOGGER.info("Movie backfill finished in %s", format_duration(int(time.time() - started)))
        finally:
            conn.close()


if __name__ == "__main__":
    main()
