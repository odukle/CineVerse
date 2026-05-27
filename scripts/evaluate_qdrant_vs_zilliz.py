#!/usr/bin/env python3
"""Evaluate Qdrant vs Zilliz for recommendation quality and latency.

This benchmark compares:
1) vector search latency only
2) query->result latency (embedding + vector search + rerank)
3) quality heuristics (non-empty rate, exclusion violation rate, language hits)
"""

from __future__ import annotations

import argparse
import json
import statistics
import time
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, Iterable, List, Optional, Sequence, Tuple

import requests

DEFAULT_MODEL = "nvidia/llama-nemotron-embed-vl-1b-v2:free"
DEFAULT_QUERIES_FILE = "scripts/recommendation_eval_queries.txt"
DEFAULT_TOP_K = 10
DEFAULT_LIMIT = 80
DEFAULT_RUNS = 3

GENRE_ALIASES = {
    "science fiction": ["science fiction", "sci fi", "sci-fi", "scifi", "sf"],
    "horror": ["horror", "scary", "supernatural horror"],
    "action": ["action", "action-packed", "action packed"],
    "romance": ["romance", "romantic"],
    "thriller": ["thriller", "suspense", "suspenseful"],
    "comedy": ["comedy", "funny", "humor", "humour"],
    "drama": ["drama", "dramatic"],
}

FRANCHISE_ALIASES = {
    "marvel": ["marvel", "mcu", "avengers", "x men", "x-men", "spider man", "spider-man"],
    "dc": ["dc", "dceu", "batman", "superman", "justice league", "wonder woman"],
}

LANGUAGE_KEYWORDS = {
    "hi": ["hindi", "bollywood"],
    "ta": ["tamil", "kollywood"],
    "te": ["telugu", "tollywood"],
    "ml": ["malayalam", "mollywood"],
    "kn": ["kannada", "sandalwood"],
}


@dataclass
class QueryRun:
    query: str
    run: int
    backend: str
    embed_ms: float
    vector_ms: float
    total_ms: float
    top_k: int
    violations: int
    language_hits: int
    non_empty: bool


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--queries-file", default=DEFAULT_QUERIES_FILE)
    parser.add_argument("--model", default=DEFAULT_MODEL)
    parser.add_argument("--top-k", type=int, default=DEFAULT_TOP_K)
    parser.add_argument("--limit", type=int, default=DEFAULT_LIMIT)
    parser.add_argument("--runs", type=int, default=DEFAULT_RUNS)
    parser.add_argument("--output-json", default=".local/qdrant_vs_zilliz_eval.json")
    args = parser.parse_args()

    config = _load_api_keys_config()

    openrouter_key = str(config.get("OPENROUTER_API_KEY") or "").strip()
    qdrant_url = str(config.get("QDRANT_URL") or config.get("QDRANT_ENDPOINT") or "").strip()
    qdrant_key = str(config.get("QDRANT_API_KEY") or "").strip()
    qdrant_collection = str(config.get("QDRANT_COLLECTION") or "tmdb_movie_vectors_v2").strip()
    zilliz_endpoint = str(config.get("ZILLIZ_ENDPOINT") or "").strip()
    zilliz_key = str(config.get("ZILLIZ_API_KEY") or "").strip()
    zilliz_collection = str(config.get("ZILLIZ_COLLECTION") or "tmdb_movie_vectors_v3").strip()
    zilliz_db = str(config.get("ZILLIZ_DB_NAME") or "default").strip() or "default"
    zilliz_vector_field = str(config.get("ZILLIZ_VECTOR_FIELD") or "vector").strip() or "vector"
    zilliz_vector_dim = int(config.get("ZILLIZ_VECTOR_DIM") or 1024)

    if not openrouter_key:
        raise RuntimeError("OPENROUTER_API_KEY missing in config/api_keys.json")
    if not qdrant_url or not qdrant_collection:
        raise RuntimeError("QDRANT endpoint/collection missing in config/api_keys.json")
    if not zilliz_endpoint or not zilliz_collection or not zilliz_key:
        raise RuntimeError("ZILLIZ endpoint/collection/api key missing in config/api_keys.json")

    queries = _load_queries(args.queries_file)
    if not queries:
        raise RuntimeError("No evaluation queries found.")

    session = requests.Session()

    qdrant_dim = detect_qdrant_dim(
        session=session,
        qdrant_url=qdrant_url,
        qdrant_api_key=qdrant_key,
        collection=qdrant_collection,
    )
    target_dim = min(qdrant_dim or 1024, zilliz_vector_dim)
    print(
        f"Using target query vector dim={target_dim} "
        f"(qdrant={qdrant_dim}, zilliz={zilliz_vector_dim})"
    )

    report: Dict[str, object] = {
        "generatedAt": int(time.time()),
        "queriesFile": args.queries_file,
        "model": args.model,
        "topK": args.top_k,
        "limit": args.limit,
        "runs": args.runs,
        "qdrantCollection": qdrant_collection,
        "zillizCollection": zilliz_collection,
        "targetVectorDim": target_dim,
        "results": {},
        "perQuery": [],
    }

    all_runs: List[QueryRun] = []
    for run_idx in range(1, args.runs + 1):
        print(f"\n=== Run {run_idx}/{args.runs} ===")
        for query in queries:
            plan = infer_constraints(query)

            embed_started = time.perf_counter()
            raw_embedding = embed_text(
                session=session,
                api_key=openrouter_key,
                model=args.model,
                text=query,
            )
            embed_ms = (time.perf_counter() - embed_started) * 1000.0
            vector = adjust_embedding_dimension(raw_embedding, target_dim)

            q_started = time.perf_counter()
            q_rows = qdrant_query(
                session=session,
                qdrant_url=qdrant_url,
                qdrant_api_key=qdrant_key,
                collection=qdrant_collection,
                vector=vector,
                limit=args.limit,
            )
            q_vector_ms = (time.perf_counter() - q_started) * 1000.0
            q_ranked = rerank_rows(rows=q_rows, plan=plan, top_k=args.top_k)
            q_eval = evaluate_ranked(query=query, ranked=q_ranked, plan=plan)
            all_runs.append(
                QueryRun(
                    query=query,
                    run=run_idx,
                    backend="qdrant",
                    embed_ms=embed_ms,
                    vector_ms=q_vector_ms,
                    total_ms=embed_ms + q_vector_ms,
                    top_k=q_eval["top_k"],
                    violations=q_eval["violations"],
                    language_hits=q_eval["language_hits"],
                    non_empty=q_eval["non_empty"],
                )
            )

            z_started = time.perf_counter()
            z_rows = zilliz_query(
                session=session,
                endpoint=zilliz_endpoint,
                api_key=zilliz_key,
                db_name=zilliz_db,
                collection=zilliz_collection,
                vector_field=zilliz_vector_field,
                vector=vector,
                limit=args.limit,
            )
            z_vector_ms = (time.perf_counter() - z_started) * 1000.0
            z_ranked = rerank_rows(rows=z_rows, plan=plan, top_k=args.top_k)
            z_eval = evaluate_ranked(query=query, ranked=z_ranked, plan=plan)
            all_runs.append(
                QueryRun(
                    query=query,
                    run=run_idx,
                    backend="zilliz",
                    embed_ms=embed_ms,
                    vector_ms=z_vector_ms,
                    total_ms=embed_ms + z_vector_ms,
                    top_k=z_eval["top_k"],
                    violations=z_eval["violations"],
                    language_hits=z_eval["language_hits"],
                    non_empty=z_eval["non_empty"],
                )
            )

            print(
                f"- {query[:56]}... "
                f"Qdrant {q_vector_ms:.1f}ms/{len(q_ranked)} "
                f"vs Zilliz {z_vector_ms:.1f}ms/{len(z_ranked)}"
            )

    q_runs = [r for r in all_runs if r.backend == "qdrant"]
    z_runs = [r for r in all_runs if r.backend == "zilliz"]
    report["results"] = {
        "qdrant": summarize(q_runs),
        "zilliz": summarize(z_runs),
    }
    report["perQuery"] = [vars(item) for item in all_runs]

    output_path = Path(args.output_json)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(json.dumps(report, indent=2), encoding="utf-8")
    print(f"\nSaved report to {output_path}")

    q = report["results"]["qdrant"]  # type: ignore[index]
    z = report["results"]["zilliz"]  # type: ignore[index]
    print("\n=== Summary ===")
    print(
        "Qdrant: "
        f"vector avg={q['vector_latency_avg_ms']:.1f}ms p95={q['vector_latency_p95_ms']:.1f}ms, "
        f"total avg={q['total_latency_avg_ms']:.1f}ms, "
        f"non-empty={q['non_empty_rate']:.3f}, violations={q['violation_rate']:.3f}"
    )
    print(
        "Zilliz: "
        f"vector avg={z['vector_latency_avg_ms']:.1f}ms p95={z['vector_latency_p95_ms']:.1f}ms, "
        f"total avg={z['total_latency_avg_ms']:.1f}ms, "
        f"non-empty={z['non_empty_rate']:.3f}, violations={z['violation_rate']:.3f}"
    )


def _load_api_keys_config() -> dict:
    path = Path("config/api_keys.json")
    if not path.exists():
        return {}
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except Exception:
        return {}


def _load_queries(queries_file: str) -> List[str]:
    path = Path(queries_file)
    if not path.exists():
        raise FileNotFoundError(f"Queries file not found: {path}")
    values: List[str] = []
    for line in path.read_text(encoding="utf-8").splitlines():
        cleaned = line.strip()
        if cleaned and not cleaned.startswith("#"):
            values.append(cleaned)
    return values


def detect_qdrant_dim(
    *,
    session: requests.Session,
    qdrant_url: str,
    qdrant_api_key: str,
    collection: str,
) -> Optional[int]:
    headers = {"Accept": "application/json"}
    if qdrant_api_key:
        headers["api-key"] = qdrant_api_key
    url = f"{qdrant_url.rstrip('/')}/collections/{collection}"
    response = session.get(url, headers=headers, timeout=35)
    payload = response.json()
    if response.status_code >= 400:
        raise RuntimeError(f"Qdrant collection inspect failed: {payload}")
    vectors = (((payload.get("result") or {}).get("config") or {}).get("params") or {}).get("vectors")
    if isinstance(vectors, dict):
        size = vectors.get("size")
        if isinstance(size, int):
            return size
        for value in vectors.values():
            if isinstance(value, dict) and isinstance(value.get("size"), int):
                return int(value["size"])
    return None


def embed_text(*, session: requests.Session, api_key: str, model: str, text: str) -> List[float]:
    response = session.post(
        "https://openrouter.ai/api/v1/embeddings",
        headers={
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json",
            "HTTP-Referer": "https://cineverse.app",
            "X-Title": "CineVerse",
        },
        json={"model": model, "input": text},
        timeout=45,
    )
    payload = response.json()
    if response.status_code >= 400:
        raise RuntimeError(f"OpenRouter embedding failed: {payload}")
    data = payload.get("data") or []
    if not data:
        raise RuntimeError(f"OpenRouter embedding payload missing vector: {payload}")
    return [float(x) for x in data[0]["embedding"]]


def adjust_embedding_dimension(vector: Sequence[float], target_dim: int) -> List[float]:
    base = [float(v) for v in vector]
    if target_dim <= 0:
        return base
    if len(base) == target_dim:
        return base
    if len(base) > target_dim:
        return base[:target_dim]
    return base + [0.0] * (target_dim - len(base))


def qdrant_query(
    *,
    session: requests.Session,
    qdrant_url: str,
    qdrant_api_key: str,
    collection: str,
    vector: Sequence[float],
    limit: int,
) -> List[dict]:
    headers = {"Content-Type": "application/json", "Accept": "application/json"}
    if qdrant_api_key:
        headers["api-key"] = qdrant_api_key
    base = qdrant_url.rstrip("/")
    endpoint_query = f"{base}/collections/{collection}/points/query"
    endpoint_search = f"{base}/collections/{collection}/points/search"
    body = {
        "query": list(vector),
        "limit": int(limit),
        "with_payload": True,
        "with_vector": False,
    }
    response = session.post(endpoint_query, headers=headers, json=body, timeout=40)
    payload = response.json()
    if response.status_code in {400, 404, 405}:
        fallback_body = {
            "vector": list(vector),
            "limit": int(limit),
            "with_payload": True,
            "with_vector": False,
        }
        response = session.post(
            endpoint_search, headers=headers, json=fallback_body, timeout=40
        )
        payload = response.json()
    if response.status_code >= 400:
        raise RuntimeError(f"Qdrant query failed ({response.status_code}): {payload}")
    points = payload.get("result", {}).get("points")
    if points is None:
        points = payload.get("result", [])
    rows: List[dict] = []
    for point in points or []:
        score = float(point.get("score") or 0.0)
        row = dict(point.get("payload") or {})
        row["vectorSimilarity"] = score
        row["vectorDistance"] = max(0.0, 1.0 - score)
        rows.append(row)
    return rows


def zilliz_query(
    *,
    session: requests.Session,
    endpoint: str,
    api_key: str,
    db_name: str,
    collection: str,
    vector_field: str,
    vector: Sequence[float],
    limit: int,
) -> List[dict]:
    response = session.post(
        f"{endpoint.rstrip('/')}/v2/vectordb/entities/search",
        headers={
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": f"Bearer {api_key}",
        },
        json={
            "dbName": db_name,
            "collectionName": collection,
            "data": [list(vector)],
            "annsField": vector_field,
            "limit": int(limit),
            "outputFields": [
                "id",
                "title",
                "originalTitle",
                "genres",
                "originalLanguage",
                "runtimeMinutes",
                "releaseYear",
                "voteAverage",
                "voteCount",
                "popularity",
                "posterPath",
                "tagline",
                "overview",
                "keywords",
                "franchiseHints",
            ],
        },
        timeout=40,
    )
    payload = response.json()
    if response.status_code >= 400:
        raise RuntimeError(f"Zilliz query failed ({response.status_code}): {payload}")
    if payload and int(payload.get("code", 0)) != 0:
        raise RuntimeError(f"Zilliz query returned error: {payload}")

    raw = payload.get("data") or []
    hits = raw[0] if isinstance(raw, list) and raw and isinstance(raw[0], list) else raw
    rows: List[dict] = []
    for hit in hits or []:
        entity_raw = hit.get("entity") if isinstance(hit, dict) else None
        if isinstance(entity_raw, dict) and entity_raw:
            entity = dict(entity_raw)
        elif isinstance(hit, dict):
            entity = dict(hit)
        else:
            entity = {}
        score_raw = hit.get("score", hit.get("distance", 0.0)) if isinstance(hit, dict) else 0.0
        score = float(score_raw or 0.0)
        normalized_score = max(-1.0, min(1.0, score))
        row = {
            **entity,
            "id": int(entity.get("id") or hit.get("id") or 0) if isinstance(hit, dict) else 0,
            "vectorSimilarity": normalized_score,
            "vectorDistance": float(f"{1.0 - normalized_score:.6f}"),
        }
        rows.append(row)
    return rows


def infer_constraints(query: str) -> dict:
    normalized = normalize_text(query)
    exclude_tokens = set()
    exclude_genres = set()
    for canonical, aliases in GENRE_ALIASES.items():
        for alias in aliases:
            if is_negated_mention(normalized, normalize_text(alias)):
                exclude_genres.add(canonical)
                exclude_tokens.add(normalize_text(alias))
    for aliases in FRANCHISE_ALIASES.values():
        for alias in aliases:
            if contains_phrase(normalized, normalize_text(alias)):
                exclude_tokens.add(normalize_text(alias))
    expected_language = None
    for code, aliases in LANGUAGE_KEYWORDS.items():
        if any(contains_phrase(normalized, normalize_text(alias)) for alias in aliases):
            expected_language = code
            break
    return {
        "exclude_tokens": exclude_tokens,
        "exclude_genres": exclude_genres,
        "expected_language": expected_language,
    }


def rerank_rows(*, rows: Iterable[dict], plan: dict, top_k: int) -> List[dict]:
    scored: List[Tuple[float, dict]] = []
    excluded_genres = set(plan["exclude_genres"])
    for row in rows:
        row_genres = {normalize_text(value) for value in row.get("genres", [])}
        if excluded_genres and excluded_genres.intersection(row_genres):
            continue
        similarity = float(
            row.get("vectorSimilarity")
            if row.get("vectorSimilarity") is not None
            else (1.0 - float(row.get("vectorDistance") or 1.0))
        )
        score = similarity + quality_score(row) * 0.25
        scored.append((score, row))
    scored.sort(key=lambda item: item[0], reverse=True)
    return [row for _, row in scored[:top_k]]


def evaluate_ranked(*, query: str, ranked: Sequence[dict], plan: dict) -> dict:
    violations = sum(
        1 for row in ranked if violates_exclusions(row, plan["exclude_tokens"])
    )
    expected_lang = plan.get("expected_language")
    language_hits = 0
    if expected_lang:
        language_hits = sum(
            1
            for row in ranked
            if str(row.get("originalLanguage") or "").lower() == expected_lang
        )
    return {
        "query": query,
        "top_k": len(ranked),
        "violations": violations,
        "language_hits": language_hits,
        "non_empty": bool(ranked),
    }


def quality_score(row: dict) -> float:
    vote_average = float(row.get("voteAverage") or 0.0)
    vote_count = float(row.get("voteCount") or 0.0)
    popularity = float(row.get("popularity") or 0.0)
    rating = min(1.0, vote_average / 8.5)
    confidence = min(1.0, (vote_count + 1) ** 0.5 / 35.0)
    momentum = min(1.0, (popularity + 1) ** 0.5 / 12.0)
    return rating * 0.55 + confidence * 0.3 + momentum * 0.15


def violates_exclusions(row: dict, exclude_tokens: set) -> bool:
    if not exclude_tokens:
        return False
    joined = normalize_text(
        " ".join(
            [
                str(row.get("title") or ""),
                str(row.get("originalTitle") or ""),
                str(row.get("overview") or ""),
                str(row.get("tagline") or ""),
                " ".join(str(item) for item in row.get("genres", [])),
                " ".join(str(item) for item in row.get("keywords", [])),
                " ".join(str(item) for item in row.get("franchiseHints", [])),
            ]
        )
    )
    return any(contains_phrase(joined, token) for token in exclude_tokens)


def summarize(runs: Sequence[QueryRun]) -> dict:
    vector_latencies = [r.vector_ms for r in runs]
    total_latencies = [r.total_ms for r in runs]
    embed_latencies = [r.embed_ms for r in runs]
    total_results = sum(r.top_k for r in runs)
    total_violations = sum(r.violations for r in runs)
    total_language_hits = sum(r.language_hits for r in runs)
    return {
        "samples": len(runs),
        "vector_latency_avg_ms": statistics.mean(vector_latencies) if vector_latencies else 0.0,
        "vector_latency_p95_ms": percentile(vector_latencies, 0.95) if vector_latencies else 0.0,
        "embed_latency_avg_ms": statistics.mean(embed_latencies) if embed_latencies else 0.0,
        "total_latency_avg_ms": statistics.mean(total_latencies) if total_latencies else 0.0,
        "total_latency_p95_ms": percentile(total_latencies, 0.95) if total_latencies else 0.0,
        "non_empty_rate": (sum(1 for r in runs if r.non_empty) / len(runs)) if runs else 0.0,
        "violation_rate": (total_violations / total_results) if total_results else 0.0,
        "language_hit_rate": (total_language_hits / total_results) if total_results else 0.0,
        "avg_top_k": (total_results / len(runs)) if runs else 0.0,
    }


def percentile(values: Sequence[float], p: float) -> float:
    ordered = sorted(values)
    if not ordered:
        return 0.0
    index = (len(ordered) - 1) * p
    lower = int(index)
    upper = min(lower + 1, len(ordered) - 1)
    if lower == upper:
        return float(ordered[lower])
    return ordered[lower] * (upper - index) + ordered[upper] * (index - lower)


def normalize_text(value: str) -> str:
    cleaned = "".join(
        ch.lower() if ch.isalnum() or ch.isspace() else " " for ch in str(value or "")
    )
    return " ".join(cleaned.split())


def contains_phrase(haystack: str, needle: str) -> bool:
    if not haystack or not needle:
        return False
    return (
        haystack == needle
        or haystack.startswith(f"{needle} ")
        or haystack.endswith(f" {needle}")
        or f" {needle} " in haystack
    )


def is_negated_mention(prompt: str, token: str) -> bool:
    if not prompt or not token:
        return False
    negations = ["not", "without", "excluding", "except", "avoid", "no"]
    words = prompt.split()
    token_words = token.split()
    for idx, word in enumerate(words):
        if word not in negations:
            continue
        window = words[idx : idx + 8]
        for start in range(len(window)):
            if window[start : start + len(token_words)] == token_words:
                return True
    return False


if __name__ == "__main__":
    main()
