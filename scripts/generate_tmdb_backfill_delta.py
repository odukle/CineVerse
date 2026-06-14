#!/usr/bin/env python3
"""Generate a delta CSV of TMDB rows changed by a backfill run.

Compares a pre-backfill backup CSV against the current canonical CSV and writes:
1) brand-new rows whose `id` did not exist before, and
2) existing rows whose content changed for the same `id`.
"""

from __future__ import annotations

import argparse
import csv
import datetime as dt
from pathlib import Path


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Generate a CSV containing rows changed by a TMDB backfill, based "
            "on movie id and full row comparison."
        )
    )
    parser.add_argument(
        "--before-csv",
        default="TMDB_movie_dataset.pre_backfill.bak.csv",
        help="Backup CSV from before the backfill run.",
    )
    parser.add_argument(
        "--after-csv",
        default="TMDB_movie_dataset.csv",
        help="Current canonical CSV after the backfill run.",
    )
    parser.add_argument(
        "--delta-dir",
        default=".local/dataset_deltas",
        help=(
            "Directory used for auto-generated delta files when --output-csv is not set. "
            "Matches scripts/resume_zilliz_upload.sh --latest-delta."
        ),
    )
    parser.add_argument(
        "--output-csv",
        default="",
        help=(
            "Path to write the delta CSV. Defaults to "
            "<delta-dir>/tmdb_new_entries_<timestamp>.csv"
        ),
    )
    return parser.parse_args()


def read_rows_by_id(csv_path: Path) -> dict[int, dict[str, str]]:
    rows_by_id: dict[int, dict[str, str]] = {}
    with csv_path.open("r", encoding="utf-8", newline="") as handle:
        reader = csv.DictReader(handle)
        if "id" not in (reader.fieldnames or []):
            raise RuntimeError(f"CSV missing required 'id' header: {csv_path}")
        for row in reader:
            raw_id = (row.get("id") or "").strip()
            if not raw_id:
                continue
            try:
                row_id = int(float(raw_id))
            except ValueError:
                continue
            rows_by_id[row_id] = {
                key: (value if value is not None else "")
                for key, value in row.items()
            }
    return rows_by_id


def write_delta(
    *,
    before_csv: Path,
    after_csv: Path,
    output_csv: Path,
) -> tuple[int, int, int, int]:
    previous_rows = read_rows_by_id(before_csv)
    output_csv.parent.mkdir(parents=True, exist_ok=True)

    kept = 0
    scanned = 0
    new_rows = 0
    updated_rows = 0
    with after_csv.open("r", encoding="utf-8", newline="") as src_handle:
        reader = csv.DictReader(src_handle)
        headers = reader.fieldnames or []
        if "id" not in headers:
            raise RuntimeError(f"CSV missing required 'id' header: {after_csv}")
        with output_csv.open("w", encoding="utf-8", newline="") as dst_handle:
            writer = csv.DictWriter(dst_handle, fieldnames=headers)
            writer.writeheader()
            for row in reader:
                scanned += 1
                raw_id = (row.get("id") or "").strip()
                if not raw_id:
                    continue
                try:
                    row_id = int(float(raw_id))
                except ValueError:
                    continue
                normalized_row = {
                    key: (value if value is not None else "")
                    for key, value in row.items()
                }
                old_row = previous_rows.get(row_id)
                if old_row is None:
                    writer.writerow(row)
                    kept += 1
                    new_rows += 1
                    continue
                old_comparable = {key: old_row.get(key, "") for key in headers}
                new_comparable = {key: normalized_row.get(key, "") for key in headers}
                if old_comparable == new_comparable:
                    continue
                writer.writerow(row)
                kept += 1
                updated_rows += 1
    return scanned, kept, new_rows, updated_rows


def main() -> None:
    args = parse_args()
    before_csv = Path(args.before_csv)
    after_csv = Path(args.after_csv)

    if not before_csv.exists():
        raise FileNotFoundError(f"Before CSV not found: {before_csv}")
    if not after_csv.exists():
        raise FileNotFoundError(f"After CSV not found: {after_csv}")

    if args.output_csv:
        output_csv = Path(args.output_csv)
    else:
        timestamp = dt.datetime.now().strftime("%Y%m%d_%H%M%S")
        output_csv = Path(args.delta_dir) / f"tmdb_new_entries_{timestamp}.csv"

    scanned, kept, new_rows, updated_rows = write_delta(
        before_csv=before_csv,
        after_csv=after_csv,
        output_csv=output_csv,
    )

    print(f"Before CSV: {before_csv}")
    print(f"After CSV:  {after_csv}")
    print(f"Output CSV: {output_csv}")
    print(f"Scanned rows in current dataset: {scanned}")
    print(f"Changed rows written: {kept}")
    print(f"  New rows: {new_rows}")
    print(f"  Updated rows: {updated_rows}")
    print("Latest-delta compatible: yes")
    print("Next step: scripts/resume_zilliz_upload.sh --latest-delta")


if __name__ == "__main__":
    main()
