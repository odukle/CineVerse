#!/usr/bin/env python3
"""Build a local Tonight recommendation index from a Kaggle TMDB dataset.

Usage:
  python scripts/build_tonight_kaggle_index.py

Notes:
  - Reads Kaggle credentials from config/api_keys.json when available.
  - Requires the kaggle Python package:
      pip install kaggle
  - Output is written to assets/data/tonight_kaggle_index.json
"""

from __future__ import annotations

import argparse
import csv
import json
import os
import re
from datetime import datetime, timezone
from pathlib import Path
from typing import Dict, Iterable, List, Optional, Sequence, Set, Tuple


DEFAULT_DATASET = "alanvourch/tmdb-movies-daily-updates"
DEFAULT_OUTPUT = Path("assets/data/tonight_kaggle_index.json")
DEFAULT_DOWNLOAD_DIR = Path(".tmp/kaggle_tmdb_daily")
CONFIG_PATH = Path("config/api_keys.json")

# Keep keys aligned to MovieMood enum names in Dart.
MOOD_TERMS: Dict[str, Sequence[str]] = {
    "mindBending": (
        "mind-bending",
        "mind bending",
        "psychological",
        "surreal",
        "time loop",
        "simulation",
        "sci-fi",
        "science fiction",
    ),
    "feelGood": (
        "feel-good",
        "feel good",
        "heartwarming",
        "uplifting",
        "joy",
        "cheerful",
        "family",
        "hopeful",
    ),
    "dark": (
        "dark",
        "gritty",
        "noir",
        "bleak",
        "brooding",
        "atmospheric",
        "crime drama",
    ),
    "fastPaced": (
        "fast-paced",
        "fast paced",
        "action",
        "adrenaline",
        "chase",
        "high speed",
    ),
    "edgeOfYourSeat": (
        "edge-of-your-seat",
        "edge of your seat",
        "thriller",
        "suspense",
        "intense",
        "tense",
    ),
    "cinematic": (
        "cinematic",
        "epic",
        "visual",
        "masterpiece",
        "spectacle",
        "auteur",
    ),
    "indie": (
        "indie",
        "independent",
        "art house",
        "arthouse",
        "festival",
        "low budget",
    ),
}


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--dataset", default=DEFAULT_DATASET)
    parser.add_argument(
        "--output",
        default=str(DEFAULT_OUTPUT),
        help="Path to output JSON index file.",
    )
    parser.add_argument(
        "--download-dir",
        default=str(DEFAULT_DOWNLOAD_DIR),
        help="Directory where Kaggle files are downloaded/unzipped.",
    )
    parser.add_argument(
        "--csv-path",
        default="",
        help="Optional explicit CSV path. If omitted, the largest CSV is used.",
    )
    parser.add_argument(
        "--max-rows",
        type=int,
        default=0,
        help="Optional row processing cap for quick local iteration.",
    )
    args = parser.parse_args()

    output_path = Path(args.output)
    download_dir = Path(args.download_dir)
    csv_path = Path(args.csv_path) if args.csv_path else None

    download_dir.mkdir(parents=True, exist_ok=True)
    if csv_path is None:
        _configure_kaggle_credentials()
        _download_dataset(args.dataset, download_dir)
        csv_path = _pick_dataset_csv(download_dir)
    elif not csv_path.exists():
        raise FileNotFoundError(f"CSV path does not exist: {csv_path}")

    print(f"Using CSV: {csv_path}")
    entries = _build_entries(csv_path, max_rows=args.max_rows)

    output_path.parent.mkdir(parents=True, exist_ok=True)
    payload = {
        "version": 1,
        "dataset": args.dataset,
        "generatedAt": datetime.now(timezone.utc).isoformat(),
        "entries": entries,
    }
    output_path.write_text(
        json.dumps(payload, ensure_ascii=True, separators=(",", ":")),
        encoding="utf-8",
    )

    print(f"Wrote {len(entries)} entries to {output_path}")


def _configure_kaggle_credentials() -> None:
    config = {}
    if CONFIG_PATH.exists():
        try:
            config = json.loads(CONFIG_PATH.read_text(encoding="utf-8"))
        except Exception:
            config = {}

    configured_username = str(config.get("KAGGLE_USERNAME", "")).strip()
    configured_key = str(config.get("KAGGLE_API_KEY", "")).strip()

    username = os.environ.get("KAGGLE_USERNAME", "").strip() or configured_username
    key = os.environ.get("KAGGLE_KEY", "").strip()

    # Supports "username:key" format too.
    if not key and ":" in configured_key:
        maybe_user, maybe_key = configured_key.split(":", 1)
        if not username:
            username = maybe_user.strip()
        key = maybe_key.strip()
    elif not key:
        key = configured_key

    if username:
        os.environ["KAGGLE_USERNAME"] = username
    if key:
        os.environ["KAGGLE_KEY"] = key

    if not os.environ.get("KAGGLE_USERNAME") or not os.environ.get("KAGGLE_KEY"):
        raise RuntimeError(
            "Missing Kaggle credentials. Set KAGGLE_USERNAME/KAGGLE_KEY env vars "
            "or add KAGGLE_USERNAME and KAGGLE_API_KEY in config/api_keys.json."
        )


def _download_dataset(dataset: str, target_dir: Path) -> None:
    try:
        from kaggle.api.kaggle_api_extended import KaggleApi
    except Exception as exc:
        raise RuntimeError(
            "Kaggle Python package is required. Install with: pip install kaggle"
        ) from exc

    api = KaggleApi()
    api.authenticate()
    api.dataset_download_files(dataset, path=str(target_dir), unzip=True, quiet=False)


def _pick_dataset_csv(download_dir: Path) -> Path:
    csv_files = list(download_dir.rglob("*.csv"))
    if not csv_files:
        raise FileNotFoundError(
            f"No CSV files found under downloaded dataset path: {download_dir}"
        )
    # Pick the largest CSV as the primary table.
    csv_files.sort(key=lambda p: p.stat().st_size, reverse=True)
    return csv_files[0]


def _build_entries(csv_path: Path, *, max_rows: int = 0) -> List[dict]:
    entries: List[dict] = []
    seen_ids: Set[Tuple[int, str]] = set()

    with csv_path.open("r", encoding="utf-8", newline="") as handle:
        reader = csv.DictReader(handle)
        if reader.fieldnames is None:
            raise RuntimeError("CSV has no header row.")

        for row_index, row in enumerate(reader, start=1):
            if max_rows > 0 and row_index > max_rows:
                break

            parsed = _parse_row(row)
            if parsed is None:
                continue
            unique_key = (parsed["id"], parsed["mediaType"])
            if unique_key in seen_ids:
                continue
            seen_ids.add(unique_key)
            entries.append(parsed)

            if row_index % 100000 == 0:
                print(f"Processed {row_index} rows, kept {len(entries)} titles")

    return entries


def _parse_row(row: dict) -> Optional[dict]:
    row_id = _first_non_empty(row, ("id", "tmdb_id", "movie_id", "series_id"))
    media_id = _to_int(row_id)
    if media_id is None or media_id <= 0:
        return None

    media_type = _detect_media_type(row)
    title = _first_non_empty(
        row,
        ("title", "name", "original_title", "original_name"),
    )
    if not title:
        return None

    original_language = (
        _first_non_empty(
            row,
            ("original_language", "language"),
        ).lower()
        or None
    )

    runtime = _extract_runtime_minutes(row)

    vote_average = _to_float(_first_non_empty(row, ("vote_average", "rating"))) or 0.0
    vote_count = _to_int(_first_non_empty(row, ("vote_count", "votes"))) or 0
    popularity = _to_float(_first_non_empty(row, ("popularity",))) or 0.0

    tags = " ".join(
        part
        for part in (
            _first_non_empty(row, ("title", "name", "original_title", "original_name")),
            _first_non_empty(row, ("overview", "description", "plot")),
            _first_non_empty(row, ("tagline",)),
            _first_non_empty(row, ("keywords", "keyword_names")),
            _first_non_empty(row, ("genres", "genre_names")),
        )
        if part
    )
    moods = sorted(_classify_moods(tags))
    release_date = _first_non_empty(row, ("release_date", "first_air_date")) or None

    return {
        "id": media_id,
        "title": title,
        "mediaType": media_type,
        "originalLanguage": original_language,
        "runtimeMinutes": runtime,
        "voteAverage": round(vote_average, 3),
        "voteCount": vote_count,
        "popularity": round(popularity, 3),
        "moods": moods,
        "releaseDate": release_date,
    }


def _detect_media_type(row: dict) -> str:
    explicit = _first_non_empty(row, ("media_type", "type")).lower()
    if explicit in {"tv", "show", "series"}:
        return "tv"
    if explicit in {"movie", "film"}:
        return "movie"

    first_air_date = _first_non_empty(row, ("first_air_date", "first_air_year"))
    if first_air_date:
        return "tv"
    return "movie"


def _extract_runtime_minutes(row: dict) -> Optional[int]:
    for key in (
        "runtime",
        "runtime_minutes",
        "duration",
        "run_time",
        "episode_run_time",
    ):
        value = _first_non_empty(row, (key,))
        if not value:
            continue
        minutes = _to_int(value)
        if minutes is not None and minutes > 0:
            return minutes

        # Handle serialized arrays: "[42, 44]" or "42,44"
        normalized = value.strip()
        if normalized.startswith("[") and normalized.endswith("]"):
            normalized = normalized[1:-1]
        for part in re.split(r"[,\s]+", normalized):
            m = _to_int(part)
            if m is not None and m > 0:
                return m
    return None


def _classify_moods(text: str) -> Set[str]:
    normalized = _normalize_text(text)
    if not normalized:
        return set()

    matches: Set[str] = set()
    for mood_name, terms in MOOD_TERMS.items():
        for term in terms:
            if _normalize_text(term) in normalized:
                matches.add(mood_name)
                break
    return matches


def _normalize_text(value: str) -> str:
    lowered = value.lower()
    # Keep spaces to support phrase checks.
    collapsed = re.sub(r"[^a-z0-9\s]+", " ", lowered)
    collapsed = re.sub(r"\s+", " ", collapsed).strip()
    return f" {collapsed} " if collapsed else ""


def _first_non_empty(row: dict, keys: Iterable[str]) -> str:
    for key in keys:
        raw = row.get(key)
        if raw is None:
            continue
        text = str(raw).strip()
        if text and text.lower() not in {"nan", "none", "null"}:
            return text
    return ""


def _to_int(value: object) -> Optional[int]:
    if isinstance(value, int):
        return value
    if isinstance(value, float):
        return int(value)
    text = str(value).strip()
    if not text:
        return None
    try:
        return int(float(text))
    except Exception:
        return None


def _to_float(value: object) -> Optional[float]:
    if isinstance(value, float):
        return value
    if isinstance(value, int):
        return float(value)
    text = str(value).strip()
    if not text:
        return None
    try:
        return float(text)
    except Exception:
        return None


if __name__ == "__main__":
    main()
