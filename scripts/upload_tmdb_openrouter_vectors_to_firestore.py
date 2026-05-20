#!/usr/bin/env python3
"""Create OpenRouter embeddings from TMDB_movie_dataset.csv and upload to Firestore.

This is the production ingestion path for the Firebase recommendation endpoint.
It uses the same OpenRouter embedding model as the Cloud Function so query
vectors and document vectors live in the same embedding space.

Prerequisites:
  python3 -m pip install --target .local/firestore_vector_packages \
      -r requirements-tmdb-firestore-vector.txt
  export OPENROUTER_API_KEY=...
  gcloud auth login

Example:
  python3 scripts/upload_tmdb_openrouter_vectors_to_firestore.py \
      --project cineverse-flutter-591 \
      --collection tmdb_movie_vectors_v1 \
      --batch-size 8 \
      --commit-size 100 \
      --log-file .local/tmdb-upload.log
"""

from __future__ import annotations

import argparse
import csv
import json
import logging
import math
import os
import random
import re
import subprocess
import sys
import time
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Iterable, Iterator, List, Optional

DEFAULT_CSV = Path("TMDB_movie_dataset.csv")
DEFAULT_COLLECTION = "tmdb_movie_vectors_v1"
DEFAULT_MODEL = "nvidia/llama-nemotron-embed-vl-1b-v2:free"
CONFIG_PATH = Path("config/api_keys.json")
LOCAL_PACKAGE_DIR = (
    Path(__file__).resolve().parents[1] / ".local" / "firestore_vector_packages"
)
LOGGER = logging.getLogger("tmdb_firestore_upload")
REGIONAL_LANGUAGE_CODES = {
    "ar",
    "bn",
    "cn",
    "hi",
    "id",
    "ja",
    "kn",
    "ko",
    "ml",
    "mr",
    "ta",
    "te",
    "th",
    "tr",
    "ur",
    "zh",
}


@dataclass
class UploadStats:
    started_at: float
    max_items: int
    rows_scanned: int = 0
    eligible_rows: int = 0
    skipped_existing_rows: int = 0
    embedded_rows: int = 0
    uploaded_rows: int = 0
    embed_batches: int = 0
    commit_batches: int = 0

    def elapsed_seconds(self) -> float:
        return max(0.0, time.time() - self.started_at)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--csv", default=str(DEFAULT_CSV))
    parser.add_argument("--project", default="cineverse-flutter-591")
    parser.add_argument("--collection", default=DEFAULT_COLLECTION)
    parser.add_argument("--model", default=DEFAULT_MODEL)
    parser.add_argument("--batch-size", type=int, default=8)
    parser.add_argument("--commit-size", type=int, default=100)
    parser.add_argument("--max-rows", type=int, default=0)
    parser.add_argument("--max-items", type=int, default=0)
    parser.add_argument("--min-vote-count", type=int, default=5)
    parser.add_argument("--regional-min-vote-count", type=int, default=1)
    parser.add_argument("--min-vote-average", type=float, default=1.0)
    parser.add_argument("--scan-log-every", type=int, default=5000)
    parser.add_argument("--embed-retries", type=int, default=5)
    parser.add_argument("--firestore-retries", type=int, default=5)
    parser.add_argument("--retry-base-delay", type=float, default=2.0)
    parser.add_argument("--log-level", default="INFO")
    parser.add_argument("--log-file", default="")
    parser.add_argument("--resume", action="store_true")
    parser.add_argument(
        "--checkpoint-file",
        default=".local/tmdb-upload-progress.json",
    )
    parser.add_argument("--skip-existing", action="store_true")
    args = parser.parse_args()

    _configure_logging(level_name=args.log_level, log_file=args.log_file)

    csv_path = Path(args.csv)
    if not csv_path.exists():
        raise FileNotFoundError(f"CSV not found: {csv_path}")
    if args.batch_size <= 0:
        raise ValueError("--batch-size must be > 0")
    if args.commit_size <= 0:
        raise ValueError("--commit-size must be > 0")
    if args.commit_size < args.batch_size:
        raise ValueError("--commit-size must be >= --batch-size")
    if args.scan_log_every <= 0:
        raise ValueError("--scan-log-every must be > 0")

    api_key = _openrouter_api_key()
    requests = _load_requests()
    firestore_client = FirestoreRestClient(
        project=args.project,
        requests=requests,
        access_token=_google_access_token(),
        retries=args.firestore_retries,
        retry_base_delay=args.retry_base_delay,
    )
    stats = UploadStats(started_at=time.time(), max_items=args.max_items)
    checkpoint_path = Path(args.checkpoint_file)
    checkpoint = _load_checkpoint(
        checkpoint_path=checkpoint_path,
        enabled=args.resume,
        project=args.project,
        collection=args.collection,
        model=args.model,
        csv_path=csv_path,
    )
    resume_after_row = checkpoint["last_committed_row"] if checkpoint else 0
    if checkpoint:
        _apply_checkpoint_to_stats(stats, checkpoint)

    LOGGER.info(
        "Starting upload: csv=%s project=%s collection=%s model=%s batch_size=%s "
        "commit_size=%s max_rows=%s max_items=%s resume=%s resume_after_row=%s skip_existing=%s",
        csv_path,
        args.project,
        args.collection,
        args.model,
        args.batch_size,
        args.commit_size,
        args.max_rows or "all",
        args.max_items or "all",
        args.resume,
        resume_after_row or 0,
        args.skip_existing or args.resume,
    )

    rows = _iter_eligible_movies(
        csv_path=csv_path,
        max_rows=args.max_rows,
        max_items=args.max_items,
        min_vote_count=args.min_vote_count,
        regional_min_vote_count=args.regional_min_vote_count,
        min_vote_average=args.min_vote_average,
        stats=stats,
        scan_log_every=args.scan_log_every,
        resume_after_row=resume_after_row,
    )

    pending = []
    try:
        for chunk in _chunks(rows, args.batch_size):
            chunk = _filter_existing_rows(
                firestore_client=firestore_client,
                collection=args.collection,
                rows=chunk,
                stats=stats,
                enabled=args.skip_existing or args.resume,
            )
            if not chunk:
                continue
            stats.embed_batches += 1
            chunk_started = time.time()
            texts = [_embedding_text(row) for row in chunk]
            LOGGER.info(
                "Embedding batch %s with %s movies (eligible=%s uploaded=%s scanned=%s)",
                stats.embed_batches,
                len(chunk),
                stats.eligible_rows,
                stats.uploaded_rows,
                stats.rows_scanned,
            )
            embeddings = _embed_batch(
                texts=texts,
                model=args.model,
                api_key=api_key,
                retries=args.embed_retries,
                retry_base_delay=args.retry_base_delay,
            )
            stats.embedded_rows += len(embeddings)
            LOGGER.info(
                "Embedded batch %s in %.1fs",
                stats.embed_batches,
                time.time() - chunk_started,
            )
            for row, embedding in zip(chunk, embeddings):
                pending.append((row, embedding))
            while len(pending) >= args.commit_size:
                written = _commit_batch(
                    firestore_client,
                    args.collection,
                    pending[: args.commit_size],
                )
                last_committed_row = pending[args.commit_size - 1][0]["_csvRow"]
                pending = pending[args.commit_size :]
                _record_commit(
                    stats,
                    written,
                    checkpoint_path=checkpoint_path,
                    checkpoint_enabled=args.resume,
                    checkpoint_payload=_checkpoint_payload(
                        csv_path=csv_path,
                        project=args.project,
                        collection=args.collection,
                        model=args.model,
                        last_committed_row=last_committed_row,
                        stats=stats,
                    ),
                )
    except KeyboardInterrupt:
        LOGGER.warning(
            "Interrupted by user. Upload so far: uploaded=%s eligible=%s skipped_existing=%s scanned=%s elapsed=%s",
            stats.uploaded_rows,
            stats.eligible_rows,
            stats.skipped_existing_rows,
            stats.rows_scanned,
            _format_duration(stats.elapsed_seconds()),
        )
        raise

    if pending:
        last_committed_row = pending[-1][0]["_csvRow"]
        written = _commit_batch(firestore_client, args.collection, pending)
        _record_commit(
            stats,
            written,
            checkpoint_path=checkpoint_path,
            checkpoint_enabled=args.resume,
            checkpoint_payload=_checkpoint_payload(
                csv_path=csv_path,
                project=args.project,
                collection=args.collection,
                model=args.model,
                last_committed_row=last_committed_row,
                stats=stats,
            ),
        )

    _write_manifest(
        firestore_client=firestore_client,
        collection=args.collection,
        model=args.model,
        count=stats.uploaded_rows,
    )
    LOGGER.info(
        "Upload complete: uploaded=%s eligible=%s skipped_existing=%s scanned=%s batches(embed=%s commit=%s) elapsed=%s",
        stats.uploaded_rows,
        stats.eligible_rows,
        stats.skipped_existing_rows,
        stats.rows_scanned,
        stats.embed_batches,
        stats.commit_batches,
        _format_duration(stats.elapsed_seconds()),
    )
    if args.resume and checkpoint_path.exists():
        checkpoint_path.unlink()
        LOGGER.info("Removed checkpoint file after successful completion: %s", checkpoint_path)


def _configure_logging(*, level_name: str, log_file: str) -> None:
    level = getattr(logging, level_name.upper(), None)
    if not isinstance(level, int):
        raise ValueError(f"Unsupported --log-level: {level_name}")

    formatter = logging.Formatter(
        fmt="%(asctime)s %(levelname)s %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S",
    )
    formatter.converter = time.gmtime

    handlers: list[logging.Handler] = []
    console_handler = logging.StreamHandler(sys.stdout)
    console_handler.setFormatter(formatter)
    handlers.append(console_handler)

    if log_file:
        log_path = Path(log_file)
        log_path.parent.mkdir(parents=True, exist_ok=True)
        file_handler = logging.FileHandler(log_path, encoding="utf-8")
        file_handler.setFormatter(formatter)
        handlers.append(file_handler)

    logging.basicConfig(level=level, handlers=handlers, force=True)


def _load_requests():
    if LOCAL_PACKAGE_DIR.exists():
        sys.path.insert(0, str(LOCAL_PACKAGE_DIR))
    try:
        import requests
    except Exception as exc:
        raise RuntimeError(
            "Missing Firestore dependencies. Run: "
            "python3 -m pip install --target .local/firestore_vector_packages "
            "-r requirements-tmdb-firestore-vector.txt"
        ) from exc
    return requests


def _openrouter_api_key() -> str:
    value = os.environ.get("OPENROUTER_API_KEY", "").strip()
    if value:
        return value
    if CONFIG_PATH.exists():
        try:
            payload = json.loads(CONFIG_PATH.read_text(encoding="utf-8"))
            value = str(payload.get("OPENROUTER_API_KEY", "")).strip()
            if value:
                return value
        except Exception:
            pass
    raise RuntimeError("Set OPENROUTER_API_KEY or add it to config/api_keys.json.")


def _embed_batch(
    *,
    texts: List[str],
    model: str,
    api_key: str,
    retries: int,
    retry_base_delay: float,
) -> List[List[float]]:
    requests = _load_requests()

    def run():
        response = requests.post(
            "https://openrouter.ai/api/v1/embeddings",
            headers={
                "Authorization": f"Bearer {api_key}",
                "Content-Type": "application/json",
                "Accept": "application/json",
                "HTTP-Referer": "https://cineverse.app",
                "X-Title": "CineVerse",
            },
            json={"model": model, "input": texts},
            timeout=90,
        )
        payload = response.json()
        if response.status_code >= 400:
            raise RuntimeError(f"OpenRouter embedding failed: {payload}")
        data = payload.get("data")
        if not isinstance(data, list) or len(data) != len(texts):
            raise RuntimeError(f"Unexpected OpenRouter embedding response: {payload}")
        return [item["embedding"] for item in data]

    return _retry(
        operation_name=f"OpenRouter embeddings ({len(texts)} texts)",
        retries=retries,
        retry_base_delay=retry_base_delay,
        fn=run,
    )


def _commit_batch(firestore_client, collection: str, rows) -> int:
    writes = []
    now = datetime.now(timezone.utc)
    for row, embedding in rows:
        doc_id = f"movie_{row['id']}"
        document_row = {key: value for key, value in row.items() if not key.startswith("_")}
        writes.append(
            {
                "update": {
                    "name": firestore_client.document_name(collection, doc_id),
                    "fields": _document_fields(
                        {
                            **document_row,
                            "embedding": _firestore_vector(embedding),
                            "updatedAt": now,
                        }
                    ),
                }
            }
        )
    firestore_client.commit(writes)
    return len(rows)


def _write_manifest(*, firestore_client, collection: str, model: str, count: int) -> None:
    firestore_client.commit(
        [
            {
                "update": {
                    "name": firestore_client.document_name(
                        "tmdb_vector_manifest",
                        "current",
                    ),
                    "fields": _document_fields(
                        {
                            "collection": collection,
                            "model": model,
                            "count": count,
                            "updatedAt": datetime.now(timezone.utc),
                        }
                    ),
                }
            }
        ]
    )
    LOGGER.info(
        "Manifest updated: collection=%s count=%s model=%s",
        collection,
        count,
        model,
    )


class FirestoreRestClient:
    def __init__(
        self,
        *,
        project: str,
        requests,
        access_token: str,
        retries: int,
        retry_base_delay: float,
    ):
        self.project = project
        self._requests = requests
        self._access_token = access_token
        self._token_obtained_at = time.time()
        self._retries = retries
        self._retry_base_delay = retry_base_delay
        self._base_url = (
            f"https://firestore.googleapis.com/v1/projects/{project}"
            "/databases/(default)/documents"
        )

    def document_name(self, collection: str, doc_id: str) -> str:
        return (
            f"projects/{self.project}/databases/(default)/documents/"
            f"{collection}/{doc_id}"
        )

    def commit(self, writes: List[dict]) -> None:
        def run():
            self._refresh_access_token_if_needed()
            response = self._requests.post(
                f"{self._base_url}:commit",
                headers={
                    "Authorization": f"Bearer {self._access_token}",
                    "Content-Type": "application/json",
                },
                json={"writes": writes},
                timeout=120,
            )
            payload = response.json()
            if response.status_code >= 400:
                if response.status_code == 401:
                    LOGGER.warning(
                        "Firestore returned 401. Refreshing Google access token and retrying."
                    )
                    self._refresh_access_token(force=True)
                raise RuntimeError(f"Firestore commit failed: {payload}")
            return None

        _retry(
            operation_name=f"Firestore commit ({len(writes)} writes)",
            retries=self._retries,
            retry_base_delay=self._retry_base_delay,
            fn=run,
        )

    def existing_document_ids(self, collection: str, doc_ids: List[str]) -> set[str]:
        if not doc_ids:
            return set()

        def run():
            self._refresh_access_token_if_needed()
            response = self._requests.post(
                f"{self._base_url}:batchGet",
                headers={
                    "Authorization": f"Bearer {self._access_token}",
                    "Content-Type": "application/json",
                },
                json={
                    "documents": [
                        self.document_name(collection, doc_id) for doc_id in doc_ids
                    ],
                    "mask": {"fieldPaths": ["id"]},
                },
                timeout=120,
            )
            if response.status_code >= 400:
                payload = response.json()
                if response.status_code == 401:
                    LOGGER.warning(
                        "Firestore batchGet returned 401. Refreshing Google access token and retrying."
                    )
                    self._refresh_access_token(force=True)
                raise RuntimeError(f"Firestore batchGet failed: {payload}")

            found = set()
            for payload in _decode_json_stream(response.text):
                found_doc = payload.get("found")
                if not isinstance(found_doc, dict):
                    continue
                name = str(found_doc.get("name") or "")
                doc_id = name.rsplit("/", 1)[-1]
                if doc_id:
                    found.add(doc_id)
            return found

        return _retry(
            operation_name=f"Firestore batchGet ({len(doc_ids)} docs)",
            retries=self._retries,
            retry_base_delay=self._retry_base_delay,
            fn=run,
        )

    def _refresh_access_token_if_needed(self) -> None:
        token_age_seconds = time.time() - self._token_obtained_at
        if token_age_seconds >= 45 * 60:
            LOGGER.info(
                "Refreshing Google access token proactively after %s.",
                _format_duration(token_age_seconds),
            )
            self._refresh_access_token(force=True)

    def _refresh_access_token(self, *, force: bool = False) -> None:
        if not force:
            return
        self._access_token = _google_access_token()
        self._token_obtained_at = time.time()


def _google_access_token() -> str:
    token = os.environ.get("GOOGLE_OAUTH_ACCESS_TOKEN", "").strip()
    if token:
        return token
    result = subprocess.run(
        ["gcloud", "auth", "print-access-token"],
        check=False,
        capture_output=True,
        text=True,
    )
    token = result.stdout.strip()
    if result.returncode == 0 and token:
        return token
    raise RuntimeError(
        "Could not get a Google OAuth access token. "
        "Run `gcloud auth login` or set GOOGLE_OAUTH_ACCESS_TOKEN."
    )


def _document_fields(data: dict) -> dict:
    return {
        key: _firestore_value(value)
        for key, value in data.items()
        if value is not None
    }


def _firestore_value(value):
    if isinstance(value, dict):
        if set(value.keys()) == {"mapValue"}:
            return value
        return {"mapValue": {"fields": _document_fields(value)}}
    if isinstance(value, bool):
        return {"booleanValue": value}
    if isinstance(value, int) and not isinstance(value, bool):
        return {"integerValue": str(value)}
    if isinstance(value, float):
        return {"doubleValue": value}
    if isinstance(value, datetime):
        return {
            "timestampValue": value.astimezone(timezone.utc)
            .isoformat()
            .replace("+00:00", "Z")
        }
    if isinstance(value, list):
        return {"arrayValue": {"values": [_firestore_value(item) for item in value]}}
    return {"stringValue": str(value)}


def _firestore_vector(values: List[float]) -> dict:
    return {
        "mapValue": {
            "fields": {
                "__type__": {"stringValue": "__vector__"},
                "value": {
                    "arrayValue": {
                        "values": [{"doubleValue": float(value)} for value in values]
                    }
                },
            }
        }
    }


def _iter_eligible_movies(
    *,
    csv_path: Path,
    max_rows: int,
    max_items: int,
    min_vote_count: int,
    regional_min_vote_count: int,
    min_vote_average: float,
    stats: UploadStats,
    scan_log_every: int,
    resume_after_row: int,
) -> Iterator[dict]:
    seen_ids: set[int] = set()
    with csv_path.open("r", encoding="utf-8", errors="replace", newline="") as handle:
        reader = csv.DictReader(handle)
        for row_index, row in enumerate(reader, start=1):
            stats.rows_scanned = row_index
            if max_rows > 0 and row_index > max_rows:
                LOGGER.info("Reached max_rows=%s, stopping scan.", max_rows)
                break
            if resume_after_row > 0 and row_index <= resume_after_row:
                if row_index == resume_after_row:
                    LOGGER.info(
                        "Resume checkpoint reached at CSV row %s. Continuing from next row.",
                        resume_after_row,
                    )
                continue
            if row_index % scan_log_every == 0:
                LOGGER.info(
                    "Scan progress: scanned=%s eligible=%s skipped_existing=%s embedded=%s uploaded=%s elapsed=%s",
                    stats.rows_scanned,
                    stats.eligible_rows,
                    stats.skipped_existing_rows,
                    stats.embedded_rows,
                    stats.uploaded_rows,
                    _format_duration(stats.elapsed_seconds()),
                )
            parsed = _parse_movie(
                row,
                min_vote_count=min_vote_count,
                regional_min_vote_count=regional_min_vote_count,
                min_vote_average=min_vote_average,
            )
            if parsed is None or parsed["id"] in seen_ids:
                continue
            seen_ids.add(parsed["id"])
            stats.eligible_rows += 1
            parsed["_csvRow"] = row_index
            yield parsed
            if max_items > 0 and stats.eligible_rows >= max_items:
                LOGGER.info("Reached max_items=%s eligible movies, stopping scan.", max_items)
                break


def _parse_movie(
    row: dict,
    *,
    min_vote_count: int,
    regional_min_vote_count: int,
    min_vote_average: float,
) -> Optional[dict]:
    if _clean(row.get("status")).lower() != "released":
        return None
    if _clean(row.get("adult")).lower() == "true":
        return None
    movie_id = _to_int(row.get("id"))
    title = _clean(row.get("title"))
    overview = _clean(row.get("overview"))
    if movie_id is None or movie_id <= 0 or not title or not overview:
        return None

    vote_average = _to_float(row.get("vote_average")) or 0.0
    vote_count = _to_int(row.get("vote_count")) or 0
    original_language = _clean(row.get("original_language")).lower() or None
    required_votes = (
        regional_min_vote_count
        if original_language in REGIONAL_LANGUAGE_CODES
        else min_vote_count
    )
    if vote_average < min_vote_average or vote_count < required_votes:
        return None

    release_date = _clean(row.get("release_date")) or None
    return {
        "id": movie_id,
        "mediaType": "movie",
        "title": title,
        "originalTitle": _clean(row.get("original_title")) or title,
        "overview": overview,
        "tagline": _clean(row.get("tagline")) or None,
        "genres": _split_list(row.get("genres")),
        "keywords": _split_list(row.get("keywords")),
        "originalLanguage": original_language,
        "spokenLanguages": _split_list(row.get("spoken_languages")),
        "productionCountries": _split_list(row.get("production_countries")),
        "releaseDate": release_date,
        "releaseYear": _release_year(release_date),
        "runtimeMinutes": _to_int(row.get("runtime")),
        "voteAverage": round(vote_average, 3),
        "voteCount": vote_count,
        "popularity": round(_to_float(row.get("popularity")) or 0.0, 3),
        "posterPath": _clean(row.get("poster_path")) or None,
    }


def _embedding_text(row: dict) -> str:
    parts = [
        f"Title: {row['title']}",
        f"Original title: {row['originalTitle']}",
    ]
    if row["genres"]:
        parts.append("Genres: " + ", ".join(row["genres"]))
    if row["keywords"]:
        parts.append("Keywords: " + ", ".join(row["keywords"][:32]))
    if row["tagline"]:
        parts.append(f"Tagline: {row['tagline']}")
    parts.append(f"Overview: {row['overview']}")
    if row["originalLanguage"]:
        parts.append(f"Original language: {row['originalLanguage']}")
    if row["productionCountries"]:
        parts.append("Countries: " + ", ".join(row["productionCountries"][:6]))
    if row["runtimeMinutes"]:
        parts.append(f"Runtime: {row['runtimeMinutes']} minutes")
    if row["releaseYear"]:
        parts.append(f"Release year: {row['releaseYear']}")
    return "\n".join(parts)


def _chunks(items: Iterable[dict], size: int) -> Iterator[List[dict]]:
    chunk = []
    for item in items:
        chunk.append(item)
        if len(chunk) >= size:
            yield chunk
            chunk = []
    if chunk:
        yield chunk


def _filter_existing_rows(
    *,
    firestore_client,
    collection: str,
    rows: List[dict],
    stats: UploadStats,
    enabled: bool,
) -> List[dict]:
    if not enabled or not rows:
        return rows

    doc_ids = [f"movie_{row['id']}" for row in rows]
    existing_doc_ids = firestore_client.existing_document_ids(collection, doc_ids)
    if not existing_doc_ids:
        return rows

    filtered = [
        row for row in rows if f"movie_{row['id']}" not in existing_doc_ids
    ]
    skipped = len(rows) - len(filtered)
    if skipped > 0:
        stats.skipped_existing_rows += skipped
        LOGGER.info(
            "Skipped %s already-uploaded movies in current batch (total_skipped=%s)",
            skipped,
            stats.skipped_existing_rows,
        )
    return filtered


def _record_commit(
    stats: UploadStats,
    written: int,
    *,
    checkpoint_path: Path,
    checkpoint_enabled: bool,
    checkpoint_payload: dict,
) -> None:
    stats.commit_batches += 1
    stats.uploaded_rows += written
    elapsed = stats.elapsed_seconds()
    rate = stats.uploaded_rows / elapsed if elapsed > 0 else 0.0
    progress = ""
    if stats.max_items > 0:
        percent = (stats.uploaded_rows / stats.max_items) * 100.0
        remaining = max(0, stats.max_items - stats.uploaded_rows)
        eta_seconds = remaining / rate if rate > 0 else 0.0
        progress = f" progress={percent:.2f}% eta={_format_duration(eta_seconds)}"
    LOGGER.info(
        "Committed batch %s: wrote=%s total_uploaded=%s rate=%.2f docs/s elapsed=%s%s",
        stats.commit_batches,
        written,
        stats.uploaded_rows,
        rate,
        _format_duration(elapsed),
        progress,
    )
    if checkpoint_enabled:
        checkpoint_payload = {
            **checkpoint_payload,
            "rows_scanned": stats.rows_scanned,
            "eligible_rows": stats.eligible_rows,
            "skipped_existing_rows": stats.skipped_existing_rows,
            "embedded_rows": stats.embedded_rows,
            "uploaded_rows": stats.uploaded_rows,
            "embed_batches": stats.embed_batches,
            "commit_batches": stats.commit_batches,
        }
        _save_checkpoint(checkpoint_path, checkpoint_payload)


def _retry(*, operation_name: str, retries: int, retry_base_delay: float, fn):
    attempt = 0
    while True:
        attempt += 1
        try:
            return fn()
        except Exception as exc:
            if attempt >= retries:
                LOGGER.error(
                    "%s failed after %s attempts: %s",
                    operation_name,
                    attempt,
                    exc,
                )
                raise
            delay = retry_base_delay * (2 ** (attempt - 1)) + random.uniform(0, 0.5)
            LOGGER.warning(
                "%s failed on attempt %s/%s: %s. Retrying in %.1fs",
                operation_name,
                attempt,
                retries,
                exc,
                delay,
            )
            time.sleep(delay)


def _decode_json_stream(raw_text: str) -> List[dict]:
    text = (raw_text or "").strip()
    if not text:
        return []

    decoder = json.JSONDecoder()
    payloads = []
    index = 0
    length = len(text)

    while index < length:
        while index < length and text[index] in {" ", "\n", "\r", "\t", ","}:
            index += 1
        if index >= length:
            break
        try:
            payload, next_index = decoder.raw_decode(text, index)
        except json.JSONDecodeError as exc:
            snippet = text[index : min(length, index + 200)]
            raise RuntimeError(
                f"Could not parse Firestore batchGet response near: {snippet!r}"
            ) from exc

        if isinstance(payload, list):
            payloads.extend(item for item in payload if isinstance(item, dict))
        elif isinstance(payload, dict):
            payloads.append(payload)
        index = next_index

    return payloads


def _load_checkpoint(
    *,
    checkpoint_path: Path,
    enabled: bool,
    project: str,
    collection: str,
    model: str,
    csv_path: Path,
) -> Optional[dict]:
    if not enabled:
        return None
    if not checkpoint_path.exists():
        LOGGER.info("Resume enabled, but checkpoint file does not exist yet: %s", checkpoint_path)
        return None
    try:
        payload = json.loads(checkpoint_path.read_text(encoding="utf-8"))
    except Exception as exc:
        LOGGER.warning("Could not read checkpoint file %s: %s", checkpoint_path, exc)
        return None

    expected = {
        "project": project,
        "collection": collection,
        "model": model,
        "csv_path": str(csv_path.resolve()),
    }
    for key, expected_value in expected.items():
        actual_value = payload.get(key)
        if actual_value != expected_value:
            LOGGER.warning(
                "Ignoring checkpoint because %s does not match (expected=%s actual=%s)",
                key,
                expected_value,
                actual_value,
            )
            return None

    LOGGER.info(
        "Loaded checkpoint from %s (last_committed_row=%s uploaded_rows=%s)",
        checkpoint_path,
        payload.get("last_committed_row", 0),
        payload.get("uploaded_rows", 0),
    )
    return payload


def _save_checkpoint(checkpoint_path: Path, payload: dict) -> None:
    checkpoint_path.parent.mkdir(parents=True, exist_ok=True)
    checkpoint_path.write_text(
        json.dumps(payload, indent=2, sort_keys=True),
        encoding="utf-8",
    )
    LOGGER.info(
        "Checkpoint saved: file=%s last_committed_row=%s uploaded_rows=%s",
        checkpoint_path,
        payload.get("last_committed_row", 0),
        payload.get("uploaded_rows", 0),
    )


def _checkpoint_payload(
    *,
    csv_path: Path,
    project: str,
    collection: str,
    model: str,
    last_committed_row: int,
    stats: UploadStats,
) -> dict:
    return {
        "saved_at": datetime.now(timezone.utc)
        .isoformat()
        .replace("+00:00", "Z"),
        "csv_path": str(csv_path.resolve()),
        "project": project,
        "collection": collection,
        "model": model,
        "last_committed_row": last_committed_row,
    }


def _apply_checkpoint_to_stats(stats: UploadStats, checkpoint: dict) -> None:
    stats.rows_scanned = int(checkpoint.get("rows_scanned", 0) or 0)
    stats.eligible_rows = int(checkpoint.get("eligible_rows", 0) or 0)
    stats.skipped_existing_rows = int(checkpoint.get("skipped_existing_rows", 0) or 0)
    stats.embedded_rows = int(checkpoint.get("embedded_rows", 0) or 0)
    stats.uploaded_rows = int(checkpoint.get("uploaded_rows", 0) or 0)
    stats.embed_batches = int(checkpoint.get("embed_batches", 0) or 0)
    stats.commit_batches = int(checkpoint.get("commit_batches", 0) or 0)


def _format_duration(seconds: float) -> str:
    total = int(max(0, round(seconds)))
    hours, remainder = divmod(total, 3600)
    minutes, secs = divmod(remainder, 60)
    if hours > 0:
        return f"{hours}h {minutes:02d}m {secs:02d}s"
    if minutes > 0:
        return f"{minutes}m {secs:02d}s"
    return f"{secs}s"


def _split_list(value: object) -> List[str]:
    text = _clean(value)
    if not text:
        return []
    return [item.strip() for item in text.split(",") if item.strip()]


def _release_year(value: Optional[str]) -> Optional[int]:
    if not value or len(value) < 4:
        return None
    year = _to_int(value[:4])
    if year is None or year < 1870 or year > datetime.now().year + 3:
        return None
    return year


def _clean(value: object) -> str:
    if value is None:
        return ""
    text = str(value).strip()
    if text.lower() in {"", "nan", "none", "null"}:
        return ""
    return re.sub(r"\s+", " ", text)


def _to_int(value: object) -> Optional[int]:
    text = _clean(value)
    if not text:
        return None
    try:
        number = float(text)
    except Exception:
        return None
    if not math.isfinite(number):
        return None
    return int(number)


def _to_float(value: object) -> Optional[float]:
    text = _clean(value)
    if not text:
        return None
    try:
        number = float(text)
    except Exception:
        return None
    return number if math.isfinite(number) else None


if __name__ == "__main__":
    main()
