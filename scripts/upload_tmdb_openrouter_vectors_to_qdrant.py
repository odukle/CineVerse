#!/usr/bin/env python3
"""Create OpenRouter embeddings from TMDB_movie_dataset.csv and upsert into Qdrant.

This script mirrors the Firestore ingestion payload so `functions/recommendTonight`
can switch between Firestore and Qdrant without changing reranking logic.

Example:
  python3 scripts/upload_tmdb_openrouter_vectors_to_qdrant.py \
      --qdrant-url https://<cluster>.cloud.qdrant.io \
      --collection tmdb_movie_vectors_v2 \
      --embedding-profile movie_profile_v2 \
      --resume \
      --log-file .local/tmdb-qdrant-upload.log
"""

from __future__ import annotations

import argparse
import csv
import json
import logging
import os
import random
import sys
import time
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, Iterator, List, Optional

import requests

DEFAULT_CSV = Path("TMDB_movie_dataset.csv")
DEFAULT_COLLECTION = "tmdb_movie_vectors_v2"
DEFAULT_MODEL = "nvidia/llama-nemotron-embed-vl-1b-v2:free"
DEFAULT_EMBEDDING_PROFILE = "movie_profile_v2"
DEFAULT_VECTOR_DIM = 1024
CONFIG_PATH = Path("config/api_keys.json")
LOGGER = logging.getLogger("tmdb_qdrant_upload")
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
FRANCHISE_ALIASES = {
    "marvel": [
        "marvel",
        "mcu",
        "avengers",
        "x-men",
        "x men",
        "spider-man",
        "spiderman",
        "iron man",
        "captain america",
    ],
    "dc": [
        "dc",
        "dceu",
        "justice league",
        "batman",
        "superman",
        "wonder woman",
        "aquaman",
        "joker",
        "suicide squad",
    ],
    "star wars": [
        "star wars",
        "skywalker",
        "jedi",
        "sith",
    ],
}


@dataclass
class UploadStats:
    started_at: float
    max_items: int
    rows_scanned: int = 0
    eligible_rows: int = 0
    embedded_rows: int = 0
    uploaded_rows: int = 0
    skipped_existing_rows: int = 0
    embed_batches: int = 0
    upsert_batches: int = 0

    def elapsed_seconds(self) -> float:
        return max(0.0, time.time() - self.started_at)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--csv", default=str(DEFAULT_CSV))
    parser.add_argument("--qdrant-url", default=os.environ.get("QDRANT_URL", ""))
    parser.add_argument(
        "--qdrant-api-key", default=os.environ.get("QDRANT_API_KEY", "")
    )
    parser.add_argument("--collection", default=DEFAULT_COLLECTION)
    parser.add_argument("--model", default=DEFAULT_MODEL)
    parser.add_argument("--embedding-profile", default=DEFAULT_EMBEDDING_PROFILE)
    parser.add_argument("--vector-dim", type=int, default=DEFAULT_VECTOR_DIM)
    parser.add_argument("--batch-size", type=int, default=8)
    parser.add_argument("--upsert-size", type=int, default=128)
    parser.add_argument("--max-rows", type=int, default=0)
    parser.add_argument("--max-items", type=int, default=0)
    parser.add_argument("--min-vote-count", type=int, default=0)
    parser.add_argument("--regional-min-vote-count", type=int, default=0)
    parser.add_argument("--min-vote-average", type=float, default=0.0)
    parser.add_argument("--exclude-adult", action="store_true")
    parser.add_argument("--scan-log-every", type=int, default=5000)
    parser.add_argument("--embed-retries", type=int, default=5)
    parser.add_argument("--qdrant-retries", type=int, default=5)
    parser.add_argument("--retry-base-delay", type=float, default=2.0)
    parser.add_argument("--request-timeout", type=float, default=30.0)
    parser.add_argument("--log-level", default="INFO")
    parser.add_argument("--log-file", default="")
    parser.add_argument("--resume", action="store_true")
    parser.add_argument(
        "--checkpoint-file",
        default=".local/tmdb-qdrant-upload-progress.json",
    )
    args = parser.parse_args()

    _configure_logging(level_name=args.log_level, log_file=args.log_file)
    if not args.qdrant_url:
        raise RuntimeError(
            "Qdrant URL missing. Use --qdrant-url or export QDRANT_URL."
        )

    csv_path = Path(args.csv)
    if not csv_path.exists():
        raise FileNotFoundError(f"CSV not found: {csv_path}")
    if args.batch_size <= 0:
        raise ValueError("--batch-size must be > 0")
    if args.upsert_size <= 0:
        raise ValueError("--upsert-size must be > 0")
    if args.scan_log_every <= 0:
        raise ValueError("--scan-log-every must be > 0")
    if args.vector_dim <= 0:
        raise ValueError("--vector-dim must be > 0")

    api_key = _openrouter_api_key()
    stats = UploadStats(started_at=time.time(), max_items=args.max_items)
    checkpoint_path = Path(args.checkpoint_file)
    checkpoint = _load_checkpoint(
        checkpoint_path=checkpoint_path,
        enabled=args.resume,
        collection=args.collection,
        model=args.model,
        embedding_profile=args.embedding_profile,
        vector_dim=args.vector_dim,
        csv_path=csv_path,
    )
    resume_after_row = checkpoint.get("last_committed_row", 0) if checkpoint else 0
    if checkpoint:
        stats.rows_scanned = int(checkpoint.get("rows_scanned", 0))
        stats.eligible_rows = int(checkpoint.get("eligible_rows", 0))
        stats.embedded_rows = int(checkpoint.get("embedded_rows", 0))
        stats.uploaded_rows = int(checkpoint.get("uploaded_rows", 0))
        stats.embed_batches = int(checkpoint.get("embed_batches", 0))
        stats.upsert_batches = int(checkpoint.get("upsert_batches", 0))

    LOGGER.info(
        "Starting Qdrant upload: csv=%s collection=%s model=%s batch_size=%s upsert_size=%s "
        "max_rows=%s max_items=%s resume=%s resume_after_row=%s embedding_profile=%s vector_dim=%s "
        "exclude_adult=%s",
        csv_path,
        args.collection,
        args.model,
        args.batch_size,
        args.upsert_size,
        args.max_rows or "all",
        args.max_items or "all",
        args.resume,
        resume_after_row or 0,
        args.embedding_profile,
        args.vector_dim,
        args.exclude_adult,
    )

    rows = _iter_eligible_movies(
        csv_path=csv_path,
        max_rows=args.max_rows,
        max_items=args.max_items,
        min_vote_count=args.min_vote_count,
        regional_min_vote_count=args.regional_min_vote_count,
        min_vote_average=args.min_vote_average,
        exclude_adult=args.exclude_adult,
        stats=stats,
        scan_log_every=args.scan_log_every,
        resume_after_row=resume_after_row,
    )

    pending_points = []
    collection_ensured = False

    for chunk in _chunks(rows, args.batch_size):
        stats.embed_batches += 1
        texts = [_embedding_text(row, profile=args.embedding_profile) for row in chunk]
        LOGGER.info(
            "Embedding batch %s with %s rows (eligible=%s uploaded=%s scanned=%s)",
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
            request_timeout=args.request_timeout,
            target_dim=args.vector_dim,
        )
        stats.embedded_rows += len(embeddings)

        if not collection_ensured and embeddings:
            _ensure_qdrant_collection(
                qdrant_url=args.qdrant_url,
                qdrant_api_key=args.qdrant_api_key,
                collection=args.collection,
                vector_size=len(embeddings[0]),
                retries=args.qdrant_retries,
                retry_base_delay=args.retry_base_delay,
                request_timeout=args.request_timeout,
            )
            collection_ensured = True

        for row, embedding in zip(chunk, embeddings):
            pending_points.append(
                {
                    "id": int(row["id"]),
                    "vector": embedding,
                    "payload": row,
                }
            )

        while len(pending_points) >= args.upsert_size:
            batch = pending_points[: args.upsert_size]
            pending_points = pending_points[args.upsert_size :]
            _qdrant_upsert_points(
                qdrant_url=args.qdrant_url,
                qdrant_api_key=args.qdrant_api_key,
                collection=args.collection,
                points=batch,
                retries=args.qdrant_retries,
                retry_base_delay=args.retry_base_delay,
                request_timeout=args.request_timeout,
            )
            stats.upsert_batches += 1
            stats.uploaded_rows += len(batch)
            last_committed_row = int(batch[-1]["payload"]["_csvRow"])
            _write_checkpoint(
                checkpoint_path=checkpoint_path,
                enabled=args.resume,
                payload=_checkpoint_payload(
                    csv_path=csv_path,
                    collection=args.collection,
                    model=args.model,
                    embedding_profile=args.embedding_profile,
                    vector_dim=args.vector_dim,
                    last_committed_row=last_committed_row,
                    stats=stats,
                ),
            )
            LOGGER.info(
                "Upserted batch %s (rows=%s total_uploaded=%s elapsed=%s)",
                stats.upsert_batches,
                len(batch),
                stats.uploaded_rows,
                _format_duration(stats.elapsed_seconds()),
            )

    if pending_points:
        _qdrant_upsert_points(
            qdrant_url=args.qdrant_url,
            qdrant_api_key=args.qdrant_api_key,
            collection=args.collection,
            points=pending_points,
            retries=args.qdrant_retries,
            retry_base_delay=args.retry_base_delay,
            request_timeout=args.request_timeout,
        )
        stats.upsert_batches += 1
        stats.uploaded_rows += len(pending_points)
        last_committed_row = int(pending_points[-1]["payload"]["_csvRow"])
        _write_checkpoint(
            checkpoint_path=checkpoint_path,
            enabled=args.resume,
            payload=_checkpoint_payload(
                csv_path=csv_path,
                collection=args.collection,
                model=args.model,
                embedding_profile=args.embedding_profile,
                vector_dim=args.vector_dim,
                last_committed_row=last_committed_row,
                stats=stats,
            ),
        )

    LOGGER.info(
        "Qdrant upload finished: uploaded=%s embedded=%s eligible=%s scanned=%s elapsed=%s",
        stats.uploaded_rows,
        stats.embedded_rows,
        stats.eligible_rows,
        stats.rows_scanned,
        _format_duration(stats.elapsed_seconds()),
    )


def _configure_logging(*, level_name: str, log_file: str) -> None:
    level = getattr(logging, level_name.upper(), logging.INFO)
    handlers = [logging.StreamHandler(sys.stdout)]
    if log_file:
        path = Path(log_file)
        path.parent.mkdir(parents=True, exist_ok=True)
        handlers.append(logging.FileHandler(path, encoding="utf-8"))
    logging.basicConfig(
        level=level,
        format="%(asctime)s %(levelname)s %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S",
        handlers=handlers,
    )


def _openrouter_api_key() -> str:
    from_env = os.environ.get("OPENROUTER_API_KEY", "").strip()
    if from_env:
        return from_env
    if CONFIG_PATH.exists():
        try:
            payload = json.loads(CONFIG_PATH.read_text(encoding="utf-8"))
            value = str(payload.get("OPENROUTER_API_KEY", "")).strip()
            if value:
                return value
        except Exception:
            pass
    raise RuntimeError(
        "OPENROUTER_API_KEY missing. Export it or set it in config/api_keys.json."
    )


def _embed_batch(
    *,
    texts: List[str],
    model: str,
    api_key: str,
    retries: int,
    retry_base_delay: float,
    request_timeout: float,
    target_dim: int,
) -> List[List[float]]:
    payload = {"model": model, "input": texts}

    def run():
        response = requests.post(
            "https://openrouter.ai/api/v1/embeddings",
            headers={
                "Authorization": f"Bearer {api_key}",
                "Content-Type": "application/json",
                "HTTP-Referer": "https://cineverse.app",
                "X-Title": "CineVerse",
            },
            json=payload,
            timeout=request_timeout,
        )
        body = response.json()
        if response.status_code >= 400:
            raise RuntimeError(f"OpenRouter embedding failed: {body}")
        data = body.get("data", [])
        if len(data) != len(texts):
            raise RuntimeError(f"Unexpected OpenRouter response: {body}")
        return [_project_embedding(item["embedding"], target_dim=target_dim) for item in data]

    return _retry(
        run,
        operation_name=f"OpenRouter embeddings ({len(texts)} texts)",
        retries=retries,
        retry_base_delay=retry_base_delay,
    )


def _project_embedding(embedding: List[float], *, target_dim: int) -> List[float]:
    if len(embedding) < target_dim:
        raise RuntimeError(
            f"Embedding dimension {len(embedding)} is smaller than requested target_dim={target_dim}."
        )
    if len(embedding) == target_dim:
        return embedding
    return embedding[:target_dim]


def _ensure_qdrant_collection(
    *,
    qdrant_url: str,
    qdrant_api_key: str,
    collection: str,
    vector_size: int,
    retries: int,
    retry_base_delay: float,
    request_timeout: float,
) -> None:
    base = qdrant_url.rstrip("/")
    headers = {"Content-Type": "application/json"}
    if qdrant_api_key:
        headers["api-key"] = qdrant_api_key

    def get_collection():
        response = requests.get(
            f"{base}/collections/{collection}",
            headers=headers,
            timeout=request_timeout,
        )
        if response.status_code == 200:
            return response.json()
        if response.status_code == 404:
            return None
        raise RuntimeError(
            f"Qdrant collection check failed ({response.status_code}): {response.text}"
        )

    state = _retry(
        get_collection,
        operation_name=f"Check Qdrant collection {collection}",
        retries=retries,
        retry_base_delay=retry_base_delay,
    )
    if state is not None:
        existing_size = _qdrant_vector_size(state)
        if existing_size is not None and int(existing_size) != int(vector_size):
            raise RuntimeError(
                "Existing collection vector size mismatch: "
                f"{collection} has size={existing_size}, requested={vector_size}. "
                "Use a new collection name (for example tmdb_movie_vectors_v3) "
                "when changing embedding dimension."
            )
        return

    payload = {
        "vectors": {
            "size": int(vector_size),
            "distance": "Cosine",
        }
    }

    def create_collection():
        response = requests.put(
            f"{base}/collections/{collection}",
            headers=headers,
            json=payload,
            timeout=request_timeout,
        )
        if response.status_code >= 400:
            raise RuntimeError(
                f"Create Qdrant collection failed ({response.status_code}): {response.text}"
            )
        return None

    _retry(
        create_collection,
        operation_name=f"Create Qdrant collection {collection}",
        retries=retries,
        retry_base_delay=retry_base_delay,
    )
    LOGGER.info("Created Qdrant collection %s (vector_size=%s)", collection, vector_size)


def _qdrant_vector_size(collection_response: dict) -> Optional[int]:
    vectors = (
        collection_response.get("result", {})
        .get("config", {})
        .get("params", {})
        .get("vectors")
    )
    if isinstance(vectors, dict):
        size = vectors.get("size")
        if isinstance(size, (int, float)):
            return int(size)
        for value in vectors.values():
            if isinstance(value, dict):
                nested_size = value.get("size")
                if isinstance(nested_size, (int, float)):
                    return int(nested_size)
    return None


def _qdrant_upsert_points(
    *,
    qdrant_url: str,
    qdrant_api_key: str,
    collection: str,
    points: List[dict],
    retries: int,
    retry_base_delay: float,
    request_timeout: float,
) -> None:
    base = qdrant_url.rstrip("/")
    headers = {"Content-Type": "application/json"}
    if qdrant_api_key:
        headers["api-key"] = qdrant_api_key

    payload = {"points": points}

    def run():
        response = requests.put(
            f"{base}/collections/{collection}/points?wait=true",
            headers=headers,
            json=payload,
            timeout=request_timeout,
        )
        if response.status_code >= 400:
            raise RuntimeError(
                f"Qdrant upsert failed ({response.status_code}): {response.text}"
            )
        return None

    _retry(
        run,
        operation_name=f"Qdrant upsert ({len(points)} points)",
        retries=retries,
        retry_base_delay=retry_base_delay,
    )


def _retry(fn, *, operation_name: str, retries: int, retry_base_delay: float):
    attempt = 0
    while True:
        attempt += 1
        try:
            return fn()
        except Exception as error:
            if attempt >= retries:
                LOGGER.error("%s failed after %s attempts: %s", operation_name, attempt, error)
                raise
            delay = retry_base_delay * (2 ** (attempt - 1)) + random.uniform(0, 0.5)
            LOGGER.warning(
                "%s failed on attempt %s/%s: %s. Retrying in %.1fs",
                operation_name,
                attempt,
                retries,
                error,
                delay,
            )
            time.sleep(delay)


def _load_checkpoint(
    *,
    checkpoint_path: Path,
    enabled: bool,
    collection: str,
    model: str,
    embedding_profile: str,
    vector_dim: int,
    csv_path: Path,
) -> Optional[dict]:
    if not enabled or not checkpoint_path.exists():
        return None
    payload = json.loads(checkpoint_path.read_text(encoding="utf-8"))
    if (
        payload.get("collection") != collection
        or payload.get("model") != model
        or payload.get("embedding_profile") != embedding_profile
        or int(payload.get("vector_dim", DEFAULT_VECTOR_DIM)) != int(vector_dim)
        or payload.get("csvPath") != str(csv_path.resolve())
    ):
        LOGGER.warning("Checkpoint exists but metadata mismatched. Ignoring checkpoint.")
        return None
    LOGGER.info(
        "Loaded checkpoint from %s (last_committed_row=%s)",
        checkpoint_path,
        payload.get("last_committed_row", 0),
    )
    return payload


def _write_checkpoint(*, checkpoint_path: Path, enabled: bool, payload: dict) -> None:
    if not enabled:
        return
    checkpoint_path.parent.mkdir(parents=True, exist_ok=True)
    checkpoint_path.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )


def _checkpoint_payload(
    *,
    csv_path: Path,
    collection: str,
    model: str,
    embedding_profile: str,
    vector_dim: int,
    last_committed_row: int,
    stats: UploadStats,
) -> dict:
    return {
        "csvPath": str(csv_path.resolve()),
        "collection": collection,
        "model": model,
        "embedding_profile": embedding_profile,
        "vector_dim": int(vector_dim),
        "last_committed_row": int(last_committed_row),
        "rows_scanned": int(stats.rows_scanned),
        "eligible_rows": int(stats.eligible_rows),
        "embedded_rows": int(stats.embedded_rows),
        "uploaded_rows": int(stats.uploaded_rows),
        "embed_batches": int(stats.embed_batches),
        "upsert_batches": int(stats.upsert_batches),
        "updatedAt": int(time.time()),
    }


def _iter_eligible_movies(
    *,
    csv_path: Path,
    max_rows: int,
    max_items: int,
    min_vote_count: int,
    regional_min_vote_count: int,
    min_vote_average: float,
    exclude_adult: bool,
    stats: UploadStats,
    scan_log_every: int,
    resume_after_row: int,
) -> Iterator[dict]:
    seen_ids = set()
    with csv_path.open("r", encoding="utf-8", newline="") as handle:
        reader = csv.DictReader(handle)
        for row_index, row in enumerate(reader, start=1):
            stats.rows_scanned += 1
            if max_rows > 0 and row_index > max_rows:
                break
            if resume_after_row and row_index <= resume_after_row:
                continue
            if scan_log_every and row_index % scan_log_every == 0:
                LOGGER.info(
                    "Scanned rows=%s eligible=%s uploaded=%s",
                    row_index,
                    stats.eligible_rows,
                    stats.uploaded_rows,
                )
            parsed = _parse_movie(
                row,
                min_vote_count=min_vote_count,
                regional_min_vote_count=regional_min_vote_count,
                min_vote_average=min_vote_average,
                exclude_adult=exclude_adult,
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
    exclude_adult: bool,
) -> Optional[dict]:
    if _clean(row.get("status")).lower() != "released":
        return None
    if exclude_adult and _clean(row.get("adult")).lower() == "true":
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
        "schemaVersion": "tmdb_movie_payload_v2",
        "title": title,
        "originalTitle": _clean(row.get("original_title")) or title,
        "overview": overview,
        "tagline": _clean(row.get("tagline")) or None,
        "genres": _split_list(row.get("genres")),
        "keywords": _split_list(row.get("keywords")),
        "originalLanguage": original_language,
        "spokenLanguages": _split_list(row.get("spoken_languages")),
        "productionCompanies": _split_list(row.get("production_companies")),
        "productionCountries": _split_list(row.get("production_countries")),
        "releaseDate": release_date,
        "releaseYear": _release_year(release_date),
        "runtimeMinutes": _to_int(row.get("runtime")),
        "voteAverage": round(vote_average, 3),
        "voteCount": vote_count,
        "popularity": round(_to_float(row.get("popularity")) or 0.0, 3),
        "posterPath": _clean(row.get("poster_path")) or None,
        "adult": False,
        "runtimeBucket": _runtime_bucket(_to_int(row.get("runtime"))),
        "decade": _decade(_release_year(release_date)),
        "qualityTier": _quality_tier(vote_average, vote_count),
        "franchiseHints": _franchise_hints(
            title=title,
            original_title=_clean(row.get("original_title")) or title,
            keywords=_split_list(row.get("keywords")),
        ),
    }


def _embedding_text(row: dict, *, profile: str) -> str:
    if profile == "movie_profile_v1":
        return _embedding_text_v1(row)
    if profile != DEFAULT_EMBEDDING_PROFILE:
        LOGGER.warning(
            "Unknown embedding profile %s. Falling back to %s.",
            profile,
            DEFAULT_EMBEDDING_PROFILE,
        )
    return _embedding_text_v2(row)


def _embedding_text_v1(row: dict) -> str:
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


def _embedding_text_v2(row: dict) -> str:
    genres = ", ".join(row["genres"][:8]) if row["genres"] else "unknown"
    keywords = ", ".join(row["keywords"][:32]) if row["keywords"] else "none"
    companies = (
        ", ".join(row["productionCompanies"][:8])
        if row["productionCompanies"]
        else "unknown"
    )
    countries = (
        ", ".join(row["productionCountries"][:8])
        if row["productionCountries"]
        else "unknown"
    )
    languages = (
        ", ".join(row["spokenLanguages"][:8]) if row["spokenLanguages"] else "unknown"
    )
    franchise_hints = ", ".join(row["franchiseHints"]) if row["franchiseHints"] else "none"
    quality = (
        f"tier={row['qualityTier']}, rating={row['voteAverage']}, "
        f"votes={row['voteCount']}, popularity={row['popularity']}"
    )
    parts = [
        "Movie retrieval profile (v2)",
        f"title={row['title']}",
        f"original_title={row['originalTitle']}",
        f"tagline={row['tagline'] or 'none'}",
        f"overview={row['overview']}",
        f"genres={genres}",
        f"keywords={keywords}",
        f"language.original={row['originalLanguage'] or 'unknown'}",
        f"language.spoken={languages}",
        f"countries={countries}",
        f"production_companies={companies}",
        f"runtime.minutes={row['runtimeMinutes'] or 0}",
        f"runtime.bucket={row['runtimeBucket']}",
        f"release.year={row['releaseYear'] or 0}",
        f"release.decade={row['decade'] or 'unknown'}",
        f"franchise_hints={franchise_hints}",
        f"quality={quality}",
    ]
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


def _clean(value) -> str:
    if value is None:
        return ""
    return str(value).strip()


def _to_int(value) -> Optional[int]:
    raw = _clean(value)
    if not raw:
        return None
    try:
        return int(float(raw))
    except ValueError:
        return None


def _to_float(value) -> Optional[float]:
    raw = _clean(value)
    if not raw:
        return None
    try:
        return float(raw)
    except ValueError:
        return None


def _split_list(raw: str) -> List[str]:
    text = _clean(raw)
    if not text:
        return []
    if text.startswith("[") and text.endswith("]"):
        text = text[1:-1]
    parts = [part.strip(" '\"\t\n\r") for part in text.split(",")]
    values = []
    seen = set()
    for part in parts:
        normalized = " ".join(part.split())
        if not normalized:
            continue
        lowered = normalized.lower()
        if lowered in seen:
            continue
        seen.add(lowered)
        values.append(normalized)
    return values


def _runtime_bucket(runtime_minutes: Optional[int]) -> str:
    if runtime_minutes is None or runtime_minutes <= 0:
        return "unknown"
    if runtime_minutes < 95:
        return "short"
    if runtime_minutes <= 130:
        return "medium"
    return "long"


def _decade(year: Optional[int]) -> Optional[str]:
    if year is None or year <= 0:
        return None
    return f"{(year // 10) * 10}s"


def _quality_tier(vote_average: float, vote_count: int) -> str:
    if vote_average >= 7.4 and vote_count >= 200:
        return "high"
    if vote_average >= 6.5 and vote_count >= 50:
        return "medium"
    return "emerging"


def _franchise_hints(*, title: str, original_title: str, keywords: List[str]) -> List[str]:
    source = normalize_text(" ".join([title, original_title, " ".join(keywords)]))
    matches = []
    for franchise, aliases in FRANCHISE_ALIASES.items():
        for alias in aliases:
            needle = normalize_text(alias)
            if not needle:
                continue
            if contains_phrase(source, needle):
                matches.append(franchise)
                break
    return sorted(set(matches))


def normalize_text(value: str) -> str:
    return " ".join(str(value or "").lower().replace("-", " ").split())


def contains_phrase(haystack: str, needle: str) -> bool:
    if not haystack or not needle:
        return False
    if haystack == needle:
        return True
    return (
        haystack.startswith(f"{needle} ")
        or haystack.endswith(f" {needle}")
        or f" {needle} " in haystack
    )


def _release_year(release_date: Optional[str]) -> Optional[int]:
    if not release_date:
        return None
    if len(release_date) < 4:
        return None
    try:
        return int(release_date[:4])
    except ValueError:
        return None


def _format_duration(seconds: float) -> str:
    seconds = max(0, int(seconds))
    hours, rem = divmod(seconds, 3600)
    minutes, secs = divmod(rem, 60)
    if hours:
        return f"{hours:02d}:{minutes:02d}:{secs:02d}"
    return f"{minutes:02d}:{secs:02d}"


if __name__ == "__main__":
    main()
