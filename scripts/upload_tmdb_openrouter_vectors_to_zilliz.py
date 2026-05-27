#!/usr/bin/env python3
"""Create OpenRouter embeddings and upsert vectors into Zilliz Cloud (Milvus REST v2).

Usage example (small test batch):
  python3 scripts/upload_tmdb_openrouter_vectors_to_zilliz.py \
    --zilliz-endpoint https://<cluster-endpoint> \
    --zilliz-api-key <api-key> \
    --collection tmdb_movie_vectors_v3 \
    --vector-dim 1024 \
    --max-items 120 \
    --resume \
    --smoke-test-query "movies like interstellar but not sci-fi"
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
DEFAULT_COLLECTION = "tmdb_movie_vectors_v3"
DEFAULT_MODEL = "nvidia/llama-nemotron-embed-vl-1b-v2:free"
DEFAULT_EMBEDDING_PROFILE = "movie_profile_v2"
DEFAULT_VECTOR_DIM = 1024
DEFAULT_VECTOR_FIELD = "vector"
DEFAULT_DB_NAME = "default"
CONFIG_PATH = Path("config/api_keys.json")
LOGGER = logging.getLogger("tmdb_zilliz_upload")

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
    embed_batches: int = 0
    upsert_batches: int = 0

    def elapsed_seconds(self) -> float:
        return max(0.0, time.time() - self.started_at)


class ZillizClient:
    def __init__(
        self,
        *,
        endpoint: str,
        api_key: str,
        db_name: str,
        retries: int,
        retry_base_delay: float,
        request_timeout: float,
    ) -> None:
        self.base = endpoint.rstrip("/")
        self.db_name = db_name
        self.retries = retries
        self.retry_base_delay = retry_base_delay
        self.request_timeout = request_timeout
        self.headers = {
            "Content-Type": "application/json",
            "Authorization": f"Bearer {api_key}",
        }

    def ensure_collection(
        self, *, collection: str, vector_dim: int, vector_field: str
    ) -> None:
        existing = self.describe_collection(collection=collection)
        if existing is not None:
            existing_dim = _extract_zilliz_vector_dim(existing, vector_field)
            if existing_dim is not None and int(existing_dim) != int(vector_dim):
                raise RuntimeError(
                    "Existing Zilliz collection vector dim mismatch: "
                    f"{collection} has dim={existing_dim}, requested={vector_dim}. "
                    "Use a new collection name for a different dimension."
                )
            LOGGER.info(
                "Collection %s already exists (dim=%s).",
                collection,
                existing_dim if existing_dim is not None else "unknown",
            )
            return

        payload = {
            "dbName": self.db_name,
            "collectionName": collection,
            "dimension": int(vector_dim),
            "metricType": "COSINE",
            "vectorFieldName": vector_field,
            "idType": "Int64",
            "autoId": False,
            "enableDynamicField": True,
        }
        self._post(
            "/v2/vectordb/collections/create",
            payload=payload,
            operation_name=f"Create Zilliz collection {collection}",
        )
        LOGGER.info(
            "Created Zilliz collection %s (dim=%s, vectorField=%s).",
            collection,
            vector_dim,
            vector_field,
        )

    def describe_collection(self, *, collection: str) -> Optional[dict]:
        payload = {"dbName": self.db_name, "collectionName": collection}
        try:
            response = self._post(
                "/v2/vectordb/collections/describe",
                payload=payload,
                operation_name=f"Describe Zilliz collection {collection}",
                allow_not_found=True,
            )
        except RuntimeError:
            return None
        return response

    def upsert(
        self, *, collection: str, points: List[dict], vector_field: str
    ) -> None:
        data = []
        for point in points:
            row = dict(point["payload"])
            row["id"] = int(point["id"])
            row[vector_field] = point["vector"]
            data.append(row)
        payload = {
            "dbName": self.db_name,
            "collectionName": collection,
            "data": data,
        }
        self._post(
            "/v2/vectordb/entities/upsert",
            payload=payload,
            operation_name=f"Zilliz upsert ({len(points)} points)",
        )

    def search(
        self,
        *,
        collection: str,
        vector: List[float],
        vector_field: str,
        limit: int,
        output_fields: List[str],
    ) -> List[dict]:
        payload = {
            "dbName": self.db_name,
            "collectionName": collection,
            "data": [vector],
            "annsField": vector_field,
            "limit": int(limit),
            "outputFields": output_fields,
        }
        response = self._post(
            "/v2/vectordb/entities/search",
            payload=payload,
            operation_name="Zilliz smoke search",
        )
        if isinstance(response, list):
            data = response
        elif isinstance(response, dict):
            data = response.get("data", [])
        else:
            data = []
        if not data:
            return []
        if isinstance(data, list) and data and isinstance(data[0], list):
            data = data[0]
        return data if isinstance(data, list) else []

    def _post(
        self,
        path: str,
        *,
        payload: dict,
        operation_name: str,
        allow_not_found: bool = False,
    ) -> dict:
        url = f"{self.base}{path}"

        def run():
            response = requests.post(
                url,
                headers=self.headers,
                json=payload,
                timeout=self.request_timeout,
            )
            body = {}
            try:
                body = response.json()
            except Exception:
                body = {"raw": response.text}

            if allow_not_found and response.status_code == 404:
                raise RuntimeError("NOT_FOUND")
            if response.status_code >= 400:
                raise RuntimeError(
                    f"{operation_name} failed ({response.status_code}): {body}"
                )

            code = body.get("code")
            if code not in (None, 0, "0"):
                message = str(body.get("message") or body.get("msg") or body)
                if allow_not_found and "not found" in message.lower():
                    raise RuntimeError("NOT_FOUND")
                raise RuntimeError(f"{operation_name} failed: {body}")
            return body.get("data", body.get("result", body))

        try:
            return _retry(
                run,
                operation_name=operation_name,
                retries=self.retries,
                retry_base_delay=self.retry_base_delay,
            )
        except RuntimeError as error:
            if allow_not_found and str(error) == "NOT_FOUND":
                return {}
            raise


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--csv", default=str(DEFAULT_CSV))
    parser.add_argument("--zilliz-endpoint", default=os.environ.get("ZILLIZ_ENDPOINT", ""))
    parser.add_argument("--zilliz-api-key", default=os.environ.get("ZILLIZ_API_KEY", ""))
    parser.add_argument("--zilliz-db-name", default=os.environ.get("ZILLIZ_DB_NAME", DEFAULT_DB_NAME))
    parser.add_argument("--collection", default=DEFAULT_COLLECTION)
    parser.add_argument("--vector-field", default=DEFAULT_VECTOR_FIELD)
    parser.add_argument("--vector-dim", type=int, default=DEFAULT_VECTOR_DIM)
    parser.add_argument("--model", default=DEFAULT_MODEL)
    parser.add_argument("--embedding-profile", default=DEFAULT_EMBEDDING_PROFILE)
    parser.add_argument("--batch-size", type=int, default=8)
    parser.add_argument("--upsert-size", type=int, default=64)
    parser.add_argument("--max-rows", type=int, default=0)
    parser.add_argument("--max-items", type=int, default=0)
    parser.add_argument("--min-vote-count", type=int, default=0)
    parser.add_argument("--regional-min-vote-count", type=int, default=0)
    parser.add_argument("--min-vote-average", type=float, default=0.0)
    parser.add_argument("--exclude-adult", action="store_true")
    parser.add_argument("--scan-log-every", type=int, default=5000)
    parser.add_argument("--embed-retries", type=int, default=5)
    parser.add_argument("--zilliz-retries", type=int, default=5)
    parser.add_argument("--retry-base-delay", type=float, default=2.0)
    parser.add_argument("--request-timeout", type=float, default=30.0)
    parser.add_argument("--log-level", default="INFO")
    parser.add_argument("--log-file", default="")
    parser.add_argument("--resume", action="store_true")
    parser.add_argument("--checkpoint-file", default=".local/tmdb-zilliz-upload-progress.json")
    parser.add_argument("--smoke-test-query", default="")
    args = parser.parse_args()

    _configure_logging(level_name=args.log_level, log_file=args.log_file)

    # config fallback
    config = _load_config()
    if not args.zilliz_endpoint:
        args.zilliz_endpoint = (
            str(config.get("ZILLIZ_ENDPOINT") or config.get("ZILLIZ_URL") or "").strip()
        )
    if not args.zilliz_api_key:
        args.zilliz_api_key = str(config.get("ZILLIZ_API_KEY") or "").strip()

    if not args.zilliz_endpoint:
        raise RuntimeError(
            "Zilliz endpoint missing. Use --zilliz-endpoint or set ZILLIZ_ENDPOINT in config/api_keys.json."
        )
    if not args.zilliz_api_key:
        raise RuntimeError(
            "Zilliz API key missing. Use --zilliz-api-key or set ZILLIZ_API_KEY in config/api_keys.json."
        )
    if args.zilliz_endpoint not in ("",) and not (
        args.zilliz_endpoint.startswith("http://")
        or args.zilliz_endpoint.startswith("https://")
    ):
        raise RuntimeError("Zilliz endpoint must include scheme (https://...).")
    if args.vector_dim <= 0:
        raise ValueError("--vector-dim must be > 0")
    if args.batch_size <= 0 or args.upsert_size <= 0:
        raise ValueError("--batch-size and --upsert-size must be > 0")
    if args.scan_log_every <= 0:
        raise ValueError("--scan-log-every must be > 0")

    csv_path = Path(args.csv)
    if not csv_path.exists():
        raise FileNotFoundError(f"CSV not found: {csv_path}")

    api_key = _openrouter_api_key(config=config)
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
        "Starting Zilliz upload: csv=%s collection=%s dim=%s model=%s max_items=%s resume=%s resume_after_row=%s",
        csv_path,
        args.collection,
        args.vector_dim,
        args.model,
        args.max_items or "all",
        args.resume,
        resume_after_row or 0,
    )

    zilliz = ZillizClient(
        endpoint=args.zilliz_endpoint,
        api_key=args.zilliz_api_key,
        db_name=args.zilliz_db_name,
        retries=args.zilliz_retries,
        retry_base_delay=args.retry_base_delay,
        request_timeout=args.request_timeout,
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
            zilliz.ensure_collection(
                collection=args.collection,
                vector_dim=len(embeddings[0]),
                vector_field=args.vector_field,
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
            zilliz.upsert(
                collection=args.collection,
                points=batch,
                vector_field=args.vector_field,
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
        zilliz.upsert(
            collection=args.collection,
            points=pending_points,
            vector_field=args.vector_field,
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
        "Zilliz upload finished: uploaded=%s embedded=%s eligible=%s scanned=%s elapsed=%s",
        stats.uploaded_rows,
        stats.embedded_rows,
        stats.eligible_rows,
        stats.rows_scanned,
        _format_duration(stats.elapsed_seconds()),
    )

    if args.smoke_test_query.strip():
        _run_smoke_test(
            zilliz=zilliz,
            query=args.smoke_test_query.strip(),
            model=args.model,
            api_key=api_key,
            request_timeout=args.request_timeout,
            retries=args.embed_retries,
            retry_base_delay=args.retry_base_delay,
            collection=args.collection,
            vector_field=args.vector_field,
            vector_dim=args.vector_dim,
        )


def _run_smoke_test(
    *,
    zilliz: ZillizClient,
    query: str,
    model: str,
    api_key: str,
    request_timeout: float,
    retries: int,
    retry_base_delay: float,
    collection: str,
    vector_field: str,
    vector_dim: int,
) -> None:
    query_vector = _embed_batch(
        texts=[query],
        model=model,
        api_key=api_key,
        retries=retries,
        retry_base_delay=retry_base_delay,
        request_timeout=request_timeout,
        target_dim=vector_dim,
    )[0]
    results = zilliz.search(
        collection=collection,
        vector=query_vector,
        vector_field=vector_field,
        limit=5,
        output_fields=[
            "id",
            "title",
            "releaseYear",
            "originalLanguage",
            "genres",
            "voteAverage",
            "voteCount",
        ],
    )
    LOGGER.info("Smoke test results for query=%r", query)
    for idx, hit in enumerate(results, start=1):
        entity = {}
        if isinstance(hit, dict):
            entity_raw = hit.get("entity")
            if isinstance(entity_raw, dict) and entity_raw:
                entity = entity_raw
            else:
                entity = hit
        distance = hit.get("distance", hit.get("score")) if isinstance(hit, dict) else None
        LOGGER.info(
            "#%s id=%s title=%s year=%s score=%s",
            idx,
            entity.get("id", hit.get("id") if isinstance(hit, dict) else None),
            entity.get("title"),
            entity.get("releaseYear"),
            distance,
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


def _openrouter_api_key(*, config: dict) -> str:
    from_env = os.environ.get("OPENROUTER_API_KEY", "").strip()
    if from_env:
        return from_env
    value = str(config.get("OPENROUTER_API_KEY", "")).strip()
    if value:
        return value
    raise RuntimeError(
        "OPENROUTER_API_KEY missing. Export it or set it in config/api_keys.json."
    )


def _load_config() -> dict:
    if not CONFIG_PATH.exists():
        return {}
    try:
        return json.loads(CONFIG_PATH.read_text(encoding="utf-8"))
    except Exception:
        return {}


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
            f"Embedding dimension {len(embedding)} is smaller than target_dim={target_dim}."
        )
    if len(embedding) == target_dim:
        return embedding
    return embedding[:target_dim]


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


def _extract_zilliz_vector_dim(collection_payload: dict, vector_field: str) -> Optional[int]:
    data = collection_payload.get("data", collection_payload.get("result", collection_payload))
    if isinstance(data, list) and data:
        data = data[0]
    if isinstance(data, dict):
        # common quick-setup response shape
        if isinstance(data.get("dimension"), (int, float)):
            return int(data["dimension"])
        schema = data.get("schema")
        if isinstance(schema, dict):
            fields = schema.get("fields", [])
            if isinstance(fields, list):
                for field in fields:
                    if not isinstance(field, dict):
                        continue
                    name = str(field.get("name") or field.get("fieldName") or "")
                    if name == vector_field and isinstance(field.get("dimension"), (int, float)):
                        return int(field["dimension"])
    return None


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
    if profile != DEFAULT_EMBEDDING_PROFILE:
        LOGGER.warning(
            "Unknown embedding profile %s. Falling back to %s.",
            profile,
            DEFAULT_EMBEDDING_PROFILE,
        )
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


def _release_year(release_date: Optional[str]) -> Optional[int]:
    if not release_date:
        return None
    try:
        return int(release_date.split("-")[0])
    except Exception:
        return None


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
    if vote_average >= 8.2 and vote_count >= 500:
        return "elite"
    if vote_average >= 7.4 and vote_count >= 200:
        return "strong"
    if vote_average >= 6.5 and vote_count >= 80:
        return "solid"
    return "emerging"


def _franchise_hints(
    *, title: str, original_title: str, keywords: List[str]
) -> List[str]:
    haystack = " ".join([title, original_title, *keywords]).lower()
    matches: List[str] = []
    for franchise, aliases in FRANCHISE_ALIASES.items():
        for alias in aliases:
            if alias in haystack:
                matches.append(franchise)
                break
    return matches


def _format_duration(seconds: float) -> str:
    seconds = int(seconds)
    h, rem = divmod(seconds, 3600)
    m, s = divmod(rem, 60)
    if h > 0:
        return f"{h}h {m}m {s}s"
    if m > 0:
        return f"{m}m {s}s"
    return f"{s}s"


if __name__ == "__main__":
    main()
