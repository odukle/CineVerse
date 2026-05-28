#!/usr/bin/env python3
"""Incrementally merge a new TMDB-like CSV into the canonical dataset and upsert only new vectors.

Flow:
1) Read `TMDB_movie_dataset.csv` (canonical schema).
2) Read `new_dataset.csv` with flexible column mapping (alias + fuzzy + optional LLM mapping).
3) Merge rows by TMDB movie id:
   - existing ids: update canonical dataset based on merge strategy
   - new ids: append to canonical dataset and export to a delta CSV
4) Upsert only new ids to vector DB using existing uploader scripts.
"""

from __future__ import annotations

import argparse
import csv
import datetime as dt
import difflib
import json
import logging
import os
import re
import shlex
import sqlite3
import subprocess
import sys
import tempfile
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, Iterable, List, Optional, Tuple

import requests

LOGGER = logging.getLogger("tmdb_dataset_updater")
CONFIG_PATH = Path("config/api_keys.json")
DEFAULT_BASE_CSV = Path("TMDB_movie_dataset.csv")
DEFAULT_NEW_CSV = Path("new_dataset.csv")
DEFAULT_REPORT_DIR = Path(".local/dataset_merge_reports")
DEFAULT_BACKUP_DIR = Path(".local/dataset_backups")
DEFAULT_DELTA_DIR = Path(".local/dataset_deltas")

LIST_FIELDS = {
    "genres",
    "production_companies",
    "production_countries",
    "spoken_languages",
    "keywords",
}

# Normalize known variants to canonical TMDB_movie_dataset.csv headers.
HEADER_ALIASES = {
    "tmdb_id": "id",
    "movie_id": "id",
    "film_id": "id",
    "series_id": "id",
    "name": "title",
    "movie_title": "title",
    "film_title": "title",
    "rating": "vote_average",
    "avg_rating": "vote_average",
    "average_rating": "vote_average",
    "score": "vote_average",
    "votes": "vote_count",
    "num_votes": "vote_count",
    "total_votes": "vote_count",
    "state": "status",
    "release_status": "status",
    "date_released": "release_date",
    "release": "release_date",
    "released_on": "release_date",
    "income": "revenue",
    "gross": "revenue",
    "duration": "runtime",
    "runtime_minutes": "runtime",
    "run_time": "runtime",
    "is_adult": "adult",
    "nsfw": "adult",
    "background_path": "backdrop_path",
    "backdrop": "backdrop_path",
    "cost": "budget",
    "website": "homepage",
    "url": "homepage",
    "imdb": "imdb_id",
    "imdbid": "imdb_id",
    "language": "original_language",
    "lang": "original_language",
    "original_name": "original_title",
    "description": "overview",
    "plot": "overview",
    "summary": "overview",
    "tmdb_popularity": "popularity",
    "poster": "poster_path",
    "poster_url": "poster_path",
    "slogan": "tagline",
    "genre": "genres",
    "genre_names": "genres",
    "companies": "production_companies",
    "production_company": "production_companies",
    "countries": "production_countries",
    "country": "production_countries",
    "languages": "spoken_languages",
    "spoken_language": "spoken_languages",
    "keyword": "keywords",
    "keyword_names": "keywords",
}

REQUIRED_HEADERS = {
    "id",
    "title",
    "overview",
}


@dataclass
class MergeStats:
    existing_rows_scanned: int = 0
    new_rows_scanned: int = 0
    new_rows_with_valid_id: int = 0
    existing_rows_updated: int = 0
    existing_rows_unchanged: int = 0
    new_rows_appended: int = 0
    new_rows_rejected: int = 0


def main() -> None:
    args = _parse_args()
    _configure_logging(args.log_level)
    csv.field_size_limit(sys.maxsize)

    base_csv = Path(args.base_csv)
    new_csv = Path(args.new_csv)
    if not base_csv.exists():
        raise FileNotFoundError(f"Base dataset not found: {base_csv}")
    if not new_csv.exists():
        raise FileNotFoundError(f"New dataset not found: {new_csv}")

    timestamp = dt.datetime.now().strftime("%Y%m%d_%H%M%S")
    report_dir = Path(args.report_dir)
    backup_dir = Path(args.backup_dir)
    delta_dir = Path(args.delta_dir)
    report_dir.mkdir(parents=True, exist_ok=True)
    backup_dir.mkdir(parents=True, exist_ok=True)
    delta_dir.mkdir(parents=True, exist_ok=True)

    canonical_headers = _read_headers(base_csv)
    if not canonical_headers:
        raise RuntimeError(f"Could not read CSV header from {base_csv}")

    _assert_headers(canonical_headers)
    new_headers = _read_headers(new_csv)
    if not new_headers:
        raise RuntimeError(f"Could not read CSV header from {new_csv}")

    config = _load_config()
    mapping = _build_header_mapping(
        canonical_headers=canonical_headers,
        new_headers=new_headers,
        enable_llm=args.enable_llm_column_map,
        openrouter_key=_openrouter_key_from_env_or_config(config),
        llm_model=args.llm_model,
        llm_timeout=args.llm_timeout,
    )

    report_path = report_dir / f"merge_report_{timestamp}.json"
    _write_mapping_report(
        path=report_path,
        canonical_headers=canonical_headers,
        new_headers=new_headers,
        mapping=mapping,
    )

    LOGGER.info("Mapping report written: %s", report_path)

    with tempfile.TemporaryDirectory(prefix="tmdb_merge_") as tmp_dir:
        tmp_db_path = Path(tmp_dir) / "incoming_rows.sqlite"
        conn = sqlite3.connect(tmp_db_path)
        try:
            stats = MergeStats()
            _init_sqlite(conn)
            _load_new_rows_into_sqlite(
                conn=conn,
                new_csv=new_csv,
                canonical_headers=canonical_headers,
                mapping=mapping,
                stats=stats,
            )

            if stats.new_rows_with_valid_id == 0:
                LOGGER.warning(
                    "No valid rows with `id` found in %s. Nothing to merge.", new_csv
                )
                return

            output_csv = (
                Path(args.output_csv)
                if args.output_csv
                else base_csv.with_suffix(f".merged_{timestamp}.csv")
            )
            in_place = bool(args.in_place)
            if in_place and args.output_csv:
                raise RuntimeError("Use either --in-place or --output-csv, not both.")
            if in_place:
                output_csv = base_csv.with_suffix(f".tmp_merge_{timestamp}.csv")

            delta_csv = (
                Path(args.delta_csv)
                if args.delta_csv
                else delta_dir / f"tmdb_new_entries_{timestamp}.csv"
            )

            _merge_existing_with_new(
                conn=conn,
                base_csv=base_csv,
                output_csv=output_csv,
                delta_csv=delta_csv,
                canonical_headers=canonical_headers,
                merge_strategy=args.merge_strategy,
                insert_only=args.insert_only,
                stats=stats,
            )

            if args.dry_run:
                LOGGER.info("Dry run complete. No files were modified.")
                return

            if in_place:
                backup_path = backup_dir / f"{base_csv.stem}_{timestamp}.bak.csv"
                backup_path.write_bytes(base_csv.read_bytes())
                output_csv.replace(base_csv)
                LOGGER.info("Backed up base dataset to: %s", backup_path)
                LOGGER.info("Updated canonical dataset in-place: %s", base_csv)
            else:
                LOGGER.info("Merged dataset written to: %s", output_csv)

            LOGGER.info(
                "Merge summary: existing_scanned=%s updated=%s inserted=%s unchanged=%s rejected=%s",
                stats.existing_rows_scanned,
                stats.existing_rows_updated,
                stats.new_rows_appended,
                stats.existing_rows_unchanged,
                stats.new_rows_rejected,
            )

            if stats.new_rows_appended <= 0:
                LOGGER.info("No new rows to upsert to vector DB. Done.")
                return

            LOGGER.info("Delta CSV for vector upsert: %s", delta_csv)
            if args.skip_vector_upsert:
                LOGGER.info("Skipping vector upsert because --skip-vector-upsert was set.")
                return

            _run_vector_upsert(
                backend=args.vector_backend,
                delta_csv=delta_csv,
                uploader_extra_args=args.uploader_extra_args,
            )
        finally:
            conn.close()


def _parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Merge new_dataset.csv into TMDB_movie_dataset.csv and upsert only new vectors."
    )
    parser.add_argument("--base-csv", default=str(DEFAULT_BASE_CSV))
    parser.add_argument("--new-csv", default=str(DEFAULT_NEW_CSV))
    parser.add_argument(
        "--output-csv",
        default="",
        help="Write merged output to this path. If omitted, use --in-place or a timestamped output file.",
    )
    parser.add_argument(
        "--in-place",
        action="store_true",
        help="Replace base CSV after successful merge (with backup).",
    )
    parser.add_argument("--delta-csv", default="")
    parser.add_argument("--report-dir", default=str(DEFAULT_REPORT_DIR))
    parser.add_argument("--backup-dir", default=str(DEFAULT_BACKUP_DIR))
    parser.add_argument("--delta-dir", default=str(DEFAULT_DELTA_DIR))
    parser.add_argument(
        "--merge-strategy",
        choices=("fill-missing", "prefer-existing", "prefer-new"),
        default="fill-missing",
    )
    parser.add_argument(
        "--insert-only",
        action="store_true",
        help="Only append brand-new IDs; skip updates for IDs already present in base CSV.",
    )
    parser.add_argument("--enable-llm-column-map", action="store_true")
    parser.add_argument("--llm-model", default="deepseek/deepseek-v4-flash:free")
    parser.add_argument("--llm-timeout", type=float, default=30.0)
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--skip-vector-upsert", action="store_true")
    parser.add_argument(
        "--vector-backend",
        choices=("zilliz", "qdrant", "firestore"),
        default="zilliz",
    )
    parser.add_argument(
        "--uploader-extra-args",
        default="",
        help='Pass-through args for uploader script, e.g. "--collection tmdb_movie_vectors_v3 --vector-dim 1024".',
    )
    parser.add_argument("--log-level", default="INFO")
    return parser.parse_args()


def _configure_logging(level_name: str) -> None:
    level = getattr(logging, level_name.upper(), logging.INFO)
    logging.basicConfig(
        level=level,
        format="%(asctime)s %(levelname)s %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S",
    )


def _assert_headers(headers: List[str]) -> None:
    missing = sorted(REQUIRED_HEADERS - set(headers))
    if missing:
        raise RuntimeError(
            f"Base CSV schema is missing required columns: {', '.join(missing)}"
        )


def _read_headers(path: Path) -> List[str]:
    with path.open("r", encoding="utf-8", errors="replace", newline="") as handle:
        reader = csv.reader(handle)
        try:
            return next(reader)
        except StopIteration:
            return []


def _normalize_header(name: str) -> str:
    return re.sub(r"[^a-z0-9]+", "_", (name or "").strip().lower()).strip("_")


def _build_header_mapping(
    *,
    canonical_headers: List[str],
    new_headers: List[str],
    enable_llm: bool,
    openrouter_key: str,
    llm_model: str,
    llm_timeout: float,
) -> Dict[str, List[str]]:
    canonical_norm = {_normalize_header(h): h for h in canonical_headers}
    mapping: Dict[str, List[str]] = {h: [] for h in canonical_headers}
    unmatched: List[str] = []

    for new_h in new_headers:
        normalized = _normalize_header(new_h)
        mapped_to = None

        if normalized in canonical_norm:
            mapped_to = canonical_norm[normalized]
        elif normalized in HEADER_ALIASES:
            alias_target = HEADER_ALIASES[normalized]
            if alias_target in mapping:
                mapped_to = alias_target
        else:
            mapped_to = _fuzzy_match_header(normalized, canonical_headers)

        if mapped_to:
            mapping[mapped_to].append(new_h)
        else:
            unmatched.append(new_h)

    if unmatched and enable_llm and openrouter_key:
        llm_map = _llm_map_headers(
            unmatched_headers=unmatched,
            canonical_headers=canonical_headers,
            model=llm_model,
            api_key=openrouter_key,
            timeout=llm_timeout,
        )
        for src, dst in llm_map.items():
            if dst in mapping and src in unmatched:
                mapping[dst].append(src)

    # prioritize exact/alias-like headers first.
    for canonical, sources in mapping.items():
        mapping[canonical] = sorted(
            set(sources),
            key=lambda x: (
                0
                if _normalize_header(x) == _normalize_header(canonical)
                else 1,
                len(x),
                x.lower(),
            ),
        )
    return mapping


def _fuzzy_match_header(normalized_new: str, canonical_headers: List[str]) -> Optional[str]:
    if not normalized_new:
        return None
    canonical_norms = [_normalize_header(h) for h in canonical_headers]
    best = difflib.get_close_matches(
        normalized_new, canonical_norms, n=1, cutoff=0.84
    )
    if not best:
        return None
    best_norm = best[0]
    for header in canonical_headers:
        if _normalize_header(header) == best_norm:
            return header
    return None


def _llm_map_headers(
    *,
    unmatched_headers: List[str],
    canonical_headers: List[str],
    model: str,
    api_key: str,
    timeout: float,
) -> Dict[str, str]:
    prompt = (
        "Map source CSV headers to canonical TMDB headers.\n"
        "Return ONLY JSON object: {\"<source_header>\": \"<canonical_header>|null\"}.\n"
        "Rules:\n"
        "- Use null when no confident match.\n"
        "- Do not invent headers.\n"
        "- Keep semantics strict.\n"
        f"Canonical headers: {json.dumps(canonical_headers)}\n"
        f"Source headers to map: {json.dumps(unmatched_headers)}"
    )
    payload = {
        "model": model,
        "temperature": 0,
        "messages": [
            {"role": "system", "content": "You are a strict JSON mapper."},
            {"role": "user", "content": prompt},
        ],
    }
    try:
        response = requests.post(
            "https://openrouter.ai/api/v1/chat/completions",
            headers={
                "Authorization": f"Bearer {api_key}",
                "Content-Type": "application/json",
                "HTTP-Referer": "https://cineverse.app",
                "X-Title": "CineVerse",
            },
            json=payload,
            timeout=timeout,
        )
        body = response.json()
        if response.status_code >= 400:
            LOGGER.warning("LLM header mapping failed: %s", body)
            return {}
        text = (
            body.get("choices", [{}])[0]
            .get("message", {})
            .get("content", "")
            .strip()
        )
        parsed = _extract_json_object(text)
        result: Dict[str, str] = {}
        for src, dst in parsed.items():
            if not isinstance(src, str):
                continue
            if isinstance(dst, str):
                result[src] = dst
        return result
    except Exception as error:
        LOGGER.warning("LLM header mapping unavailable: %s", error)
        return {}


def _extract_json_object(text: str) -> dict:
    content = text.strip()
    if content.startswith("```"):
        content = re.sub(r"^```(?:json)?\s*", "", content, flags=re.IGNORECASE)
        content = re.sub(r"\s*```$", "", content)
    start = content.find("{")
    end = content.rfind("}")
    if start == -1 or end == -1 or end <= start:
        return {}
    candidate = content[start : end + 1]
    try:
        parsed = json.loads(candidate)
        return parsed if isinstance(parsed, dict) else {}
    except Exception:
        return {}


def _write_mapping_report(
    *,
    path: Path,
    canonical_headers: List[str],
    new_headers: List[str],
    mapping: Dict[str, List[str]],
) -> None:
    mapped_sources = {src for sources in mapping.values() for src in sources}
    unmatched = [h for h in new_headers if h not in mapped_sources]
    payload = {
        "canonicalHeaders": canonical_headers,
        "newHeaders": new_headers,
        "mappingCanonicalToSource": mapping,
        "unmatchedSourceHeaders": unmatched,
    }
    path.write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8")


def _init_sqlite(conn: sqlite3.Connection) -> None:
    conn.execute("PRAGMA journal_mode=WAL")
    conn.execute("PRAGMA synchronous=NORMAL")
    conn.execute(
        """
        CREATE TABLE IF NOT EXISTS incoming_rows (
          id INTEGER PRIMARY KEY,
          row_json TEXT NOT NULL,
          matched_existing INTEGER NOT NULL DEFAULT 0
        )
        """
    )
    conn.commit()


def _load_new_rows_into_sqlite(
    *,
    conn: sqlite3.Connection,
    new_csv: Path,
    canonical_headers: List[str],
    mapping: Dict[str, List[str]],
    stats: MergeStats,
) -> None:
    insert_sql = """
        INSERT INTO incoming_rows (id, row_json, matched_existing)
        VALUES (?, ?, 0)
        ON CONFLICT(id) DO UPDATE SET row_json=excluded.row_json
    """
    buffered: List[Tuple[int, str]] = []
    batch_size = 1000

    with new_csv.open("r", encoding="utf-8", errors="replace", newline="") as handle:
        reader = csv.DictReader(handle)
        for row_idx, raw_row in enumerate(reader, start=1):
            stats.new_rows_scanned += 1
            normalized = _normalize_new_row(
                raw_row=raw_row,
                canonical_headers=canonical_headers,
                mapping=mapping,
            )
            movie_id = _to_int(normalized.get("id", ""))
            if movie_id is None or movie_id <= 0:
                stats.new_rows_rejected += 1
                continue
            normalized["id"] = str(movie_id)
            stats.new_rows_with_valid_id += 1
            buffered.append((movie_id, json.dumps(normalized, ensure_ascii=False)))
            if len(buffered) >= batch_size:
                conn.executemany(insert_sql, buffered)
                conn.commit()
                buffered = []
            if row_idx % 200000 == 0:
                LOGGER.info(
                    "Indexed new dataset rows=%s valid_ids=%s rejected=%s",
                    row_idx,
                    stats.new_rows_with_valid_id,
                    stats.new_rows_rejected,
                )

    if buffered:
        conn.executemany(insert_sql, buffered)
        conn.commit()


def _normalize_new_row(
    *,
    raw_row: dict,
    canonical_headers: List[str],
    mapping: Dict[str, List[str]],
) -> Dict[str, str]:
    row: Dict[str, str] = {}
    for canonical in canonical_headers:
        value = ""
        for src in mapping.get(canonical, []):
            candidate = _clean(raw_row.get(src))
            if candidate:
                value = candidate
                break
        row[canonical] = value

    if not row.get("title"):
        row["title"] = (
            _first_non_empty(raw_row, ("title", "name", "movie_title", "film_title"))
            or ""
        )
    if not row.get("original_title"):
        row["original_title"] = _first_non_empty(
            raw_row, ("original_title", "original_name", "title", "name")
        ) or row.get("title", "")
    if not row.get("overview"):
        row["overview"] = _first_non_empty(
            raw_row, ("overview", "description", "plot", "summary")
        ) or ""
    if not row.get("id"):
        row["id"] = _first_non_empty(raw_row, ("id", "tmdb_id", "movie_id", "film_id")) or ""
    if not row.get("release_date"):
        row["release_date"] = _first_non_empty(
            raw_row, ("release_date", "date_released", "released_on", "release")
        ) or ""

    # If status is missing but release date is in the past, default to Released.
    if not row.get("status"):
        date_value = row.get("release_date", "")
        if _is_past_or_today(date_value):
            row["status"] = "Released"

    for field in LIST_FIELDS:
        row[field] = _normalize_list_like(row.get(field, ""))

    return row


def _merge_existing_with_new(
    *,
    conn: sqlite3.Connection,
    base_csv: Path,
    output_csv: Path,
    delta_csv: Path,
    canonical_headers: List[str],
    merge_strategy: str,
    insert_only: bool,
    stats: MergeStats,
) -> None:
    select_sql = "SELECT row_json FROM incoming_rows WHERE id = ?"
    mark_matched_sql = "UPDATE incoming_rows SET matched_existing = 1 WHERE id = ?"

    output_csv.parent.mkdir(parents=True, exist_ok=True)
    delta_csv.parent.mkdir(parents=True, exist_ok=True)

    with (
        base_csv.open("r", encoding="utf-8", errors="replace", newline="") as base_handle,
        output_csv.open("w", encoding="utf-8", newline="") as out_handle,
        delta_csv.open("w", encoding="utf-8", newline="") as delta_handle,
    ):
        reader = csv.DictReader(base_handle)
        writer = csv.DictWriter(out_handle, fieldnames=canonical_headers, quoting=csv.QUOTE_MINIMAL)
        delta_writer = csv.DictWriter(delta_handle, fieldnames=canonical_headers, quoting=csv.QUOTE_MINIMAL)

        writer.writeheader()
        delta_writer.writeheader()

        for row_idx, existing in enumerate(reader, start=1):
            stats.existing_rows_scanned += 1
            existing_canonical = _canonicalize_existing_row(existing, canonical_headers)
            movie_id = _to_int(existing_canonical.get("id", ""))
            if movie_id is None:
                writer.writerow(existing_canonical)
                stats.existing_rows_unchanged += 1
                continue

            incoming_json = conn.execute(select_sql, (movie_id,)).fetchone()
            if incoming_json is None:
                writer.writerow(existing_canonical)
                stats.existing_rows_unchanged += 1
            else:
                conn.execute(mark_matched_sql, (movie_id,))
                if insert_only:
                    writer.writerow(existing_canonical)
                    stats.existing_rows_unchanged += 1
                else:
                    incoming = json.loads(incoming_json[0])
                    merged = _merge_rows(
                        existing=existing_canonical,
                        incoming=incoming,
                        canonical_headers=canonical_headers,
                        strategy=merge_strategy,
                    )
                    writer.writerow(merged)
                    stats.existing_rows_updated += 1

            if row_idx % 200000 == 0:
                conn.commit()
                LOGGER.info(
                    "Merged existing rows=%s updated=%s inserted=%s unchanged=%s",
                    row_idx,
                    stats.existing_rows_updated,
                    stats.new_rows_appended,
                    stats.existing_rows_unchanged,
                )

        conn.commit()

        # Append brand-new rows and write them to delta CSV for vector upsert.
        cursor = conn.execute(
            "SELECT row_json FROM incoming_rows WHERE matched_existing = 0 ORDER BY id ASC"
        )
        for (row_json,) in cursor.fetchall():
            incoming = json.loads(row_json)
            canonical = _canonicalize_existing_row(incoming, canonical_headers)
            writer.writerow(canonical)
            delta_writer.writerow(canonical)
            stats.new_rows_appended += 1
            if stats.new_rows_appended % 50000 == 0:
                LOGGER.info(
                    "Appending new rows: inserted=%s updated=%s",
                    stats.new_rows_appended,
                    stats.existing_rows_updated,
                )


def _canonicalize_existing_row(row: dict, canonical_headers: List[str]) -> Dict[str, str]:
    normalized: Dict[str, str] = {}
    for header in canonical_headers:
        normalized[header] = _clean(row.get(header))
    for field in LIST_FIELDS:
        normalized[field] = _normalize_list_like(normalized.get(field, ""))
    if normalized.get("original_title") == "":
        normalized["original_title"] = normalized.get("title", "")
    return normalized


def _merge_rows(
    *,
    existing: Dict[str, str],
    incoming: Dict[str, str],
    canonical_headers: Iterable[str],
    strategy: str,
) -> Dict[str, str]:
    merged: Dict[str, str] = {}
    for header in canonical_headers:
        old_val = _clean(existing.get(header))
        new_val = _clean(incoming.get(header))

        if header == "id":
            merged[header] = old_val or new_val
            continue

        if strategy == "prefer-new":
            merged[header] = new_val if new_val else old_val
        elif strategy == "prefer-existing":
            merged[header] = old_val if old_val else new_val
        else:  # fill-missing
            merged[header] = old_val if old_val else new_val

    return _canonicalize_existing_row(merged, list(canonical_headers))


def _run_vector_upsert(
    *,
    backend: str,
    delta_csv: Path,
    uploader_extra_args: str,
) -> None:
    script_map = {
        "zilliz": "scripts/upload_tmdb_openrouter_vectors_to_zilliz.py",
        "qdrant": "scripts/upload_tmdb_openrouter_vectors_to_qdrant.py",
        "firestore": "scripts/upload_tmdb_openrouter_vectors_to_firestore.py",
    }
    script_path = Path(script_map[backend])
    if not script_path.exists():
        raise FileNotFoundError(f"Uploader script not found for backend={backend}: {script_path}")

    cmd = ["python3", str(script_path), "--csv", str(delta_csv)]
    if uploader_extra_args.strip():
        cmd.extend(shlex.split(uploader_extra_args))

    LOGGER.info("Running vector upsert: %s", " ".join(shlex.quote(part) for part in cmd))
    completed = subprocess.run(cmd, check=False)
    if completed.returncode != 0:
        raise RuntimeError(f"Vector upsert failed with exit code {completed.returncode}")


def _first_non_empty(row: dict, keys: Tuple[str, ...]) -> str:
    for key in keys:
        value = _clean(row.get(key))
        if value:
            return value
    return ""


def _to_int(value: str) -> Optional[int]:
    text = _clean(value)
    if not text:
        return None
    try:
        return int(float(text))
    except ValueError:
        return None


def _clean(value) -> str:
    if value is None:
        return ""
    return str(value).strip()


def _normalize_list_like(raw: str) -> str:
    text = _clean(raw)
    if not text:
        return ""
    if text.startswith("[") and text.endswith("]"):
        text = text[1:-1]
    parts = re.split(r"[|,;/]+", text)
    values: List[str] = []
    seen = set()
    for part in parts:
        normalized = " ".join(part.strip(" '\"\t\r\n").split())
        if not normalized:
            continue
        key = normalized.lower()
        if key in seen:
            continue
        seen.add(key)
        values.append(normalized)
    return ", ".join(values)


def _is_past_or_today(date_value: str) -> bool:
    text = _clean(date_value)
    if not re.match(r"^\d{4}-\d{2}-\d{2}$", text):
        return False
    try:
        parsed = dt.datetime.strptime(text, "%Y-%m-%d").date()
        return parsed <= dt.date.today()
    except ValueError:
        return False


def _load_config() -> dict:
    if not CONFIG_PATH.exists():
        return {}
    try:
        return json.loads(CONFIG_PATH.read_text(encoding="utf-8"))
    except Exception:
        return {}


def _openrouter_key_from_env_or_config(config: dict) -> str:
    env_key = os.environ.get("OPENROUTER_API_KEY", "").strip()
    if env_key:
        return env_key
    return str(config.get("OPENROUTER_API_KEY") or "").strip()


if __name__ == "__main__":
    main()
