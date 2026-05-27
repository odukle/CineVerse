#!/usr/bin/env python3
"""Compare two Qdrant collections for recommendation quality and latency.

This is an offline A/B evaluator intended for v1 vs v2 migration checks.

Example:
  python3 scripts/evaluate_qdrant_collections.py \
    --qdrant-url https://<cluster>.cloud.qdrant.io \
    --qdrant-api-key <key> \
    --collection-a tmdb_movie_vectors_v1 \
    --collection-b tmdb_movie_vectors_v2 \
    --queries-file scripts/recommendation_eval_queries.txt
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
DEFAULT_QUERIES = [
    "I want something like Interstellar, but not sci-fi.",
    "A feel-good movie for tonight with great visuals.",
    "Hindi thriller under 2 hours with strong ratings.",
    "Like Marvel movies but not Marvel or DC.",
    "Mind-bending movies like Inception without action-heavy fights.",
    "A slow-burn mystery with emotional depth.",
    "Feel-good Tamil drama with family themes.",
    "High-rated crime thriller from the 2010s, not horror.",
]
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
class QueryEval:
    query: str
    latency_ms: float
    top_k: int
    violations: int
    language_hits: int
    non_empty: bool


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--qdrant-url", default="")
    parser.add_argument("--qdrant-api-key", default="")
    parser.add_argument("--openrouter-api-key", default="")
    parser.add_argument("--model", default=DEFAULT_MODEL)
    parser.add_argument("--collection-a", default="tmdb_movie_vectors_v1")
    parser.add_argument("--collection-b", default="tmdb_movie_vectors_v2")
    parser.add_argument("--top-k", type=int, default=10)
    parser.add_argument("--limit", type=int, default=80)
    parser.add_argument("--queries-file", default="")
    parser.add_argument("--output-json", default="")
    args = parser.parse_args()

    config = _load_api_keys_config()
    qdrant_url = args.qdrant_url.strip() or str(
        config.get("QDRANT_URL") or config.get("QDRANT_ENDPOINT") or ""
    ).strip()
    if not qdrant_url:
        raise RuntimeError(
            "Qdrant URL missing. Use --qdrant-url or set QDRANT_URL in config/api_keys.json."
        )
    qdrant_api_key = args.qdrant_api_key.strip() or str(
        config.get("QDRANT_API_KEY") or ""
    ).strip()
    openrouter_key = (
        args.openrouter_api_key.strip()
        or str(config.get("OPENROUTER_API_KEY") or "").strip()
    )
    if not openrouter_key:
        raise RuntimeError(
            "OpenRouter API key missing. Use --openrouter-api-key or config/api_keys.json."
        )

    queries = _load_queries(args.queries_file)
    if not queries:
        raise RuntimeError("No queries found for evaluation.")

    session = requests.Session()
    qdrant_headers = {"Content-Type": "application/json", "Accept": "application/json"}
    if qdrant_api_key:
        qdrant_headers["api-key"] = qdrant_api_key

    report = {
        "generatedAt": int(time.time()),
        "model": args.model,
        "topK": args.top_k,
        "limit": args.limit,
        "queries": queries,
        "collections": {},
    }

    for collection in [args.collection_a, args.collection_b]:
        print(f"\n=== Evaluating {collection} ===")
        per_query: List[QueryEval] = []
        for query in queries:
            plan = infer_constraints(query)
            embedding = embed_text(
                session=session,
                api_key=openrouter_key,
                model=args.model,
                text=query,
            )
            started = time.perf_counter()
            rows = qdrant_query(
                session=session,
                qdrant_url=qdrant_url,
                headers=qdrant_headers,
                collection=collection,
                vector=embedding,
                limit=args.limit,
            )
            latency_ms = (time.perf_counter() - started) * 1000
            ranked = rerank_rows(rows=rows, plan=plan, top_k=args.top_k)
            violations = sum(
                1 for row in ranked if violates_exclusions(row, plan["exclude_tokens"])
            )
            language_hits = 0
            expected_lang = plan.get("expected_language")
            if expected_lang:
                language_hits = sum(
                    1
                    for row in ranked
                    if str(row.get("originalLanguage") or "").lower() == expected_lang
                )
            eval_row = QueryEval(
                query=query,
                latency_ms=latency_ms,
                top_k=len(ranked),
                violations=violations,
                language_hits=language_hits,
                non_empty=bool(ranked),
            )
            per_query.append(eval_row)
            print(
                f"- {query[:72]}... latency={latency_ms:.1f}ms "
                f"results={len(ranked)} violations={violations} "
                f"lang_hits={language_hits}/{len(ranked) if ranked else 0}"
            )

        summary = summarize(per_query)
        report["collections"][collection] = {
            "summary": summary,
            "perQuery": [vars(item) for item in per_query],
        }
        print(
            "Summary: "
            f"latency_avg={summary['latency_avg_ms']:.1f}ms "
            f"latency_p95={summary['latency_p95_ms']:.1f}ms "
            f"non_empty_rate={summary['non_empty_rate']:.3f} "
            f"violation_rate={summary['violation_rate']:.3f}"
        )

    if args.output_json:
        output_path = Path(args.output_json)
        output_path.parent.mkdir(parents=True, exist_ok=True)
        output_path.write_text(json.dumps(report, indent=2), encoding="utf-8")
        print(f"\nWrote report: {output_path}")


def _load_api_keys_config() -> dict:
    path = Path("config/api_keys.json")
    if not path.exists():
        return {}
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except Exception:
        return {}


def _load_queries(queries_file: str) -> List[str]:
    if not queries_file:
        return list(DEFAULT_QUERIES)
    path = Path(queries_file)
    if not path.exists():
        raise FileNotFoundError(f"Queries file not found: {path}")
    values = []
    for line in path.read_text(encoding="utf-8").splitlines():
        cleaned = line.strip()
        if cleaned and not cleaned.startswith("#"):
            values.append(cleaned)
    return values


def embed_text(*, session: requests.Session, api_key: str, model: str, text: str) -> List[float]:
    payload = {"model": model, "input": text}
    response = session.post(
        "https://openrouter.ai/api/v1/embeddings",
        headers={
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json",
            "HTTP-Referer": "https://cineverse.app",
            "X-Title": "CineVerse",
        },
        json=payload,
        timeout=30,
    )
    body = response.json()
    if response.status_code >= 400:
        raise RuntimeError(f"OpenRouter embedding failed: {body}")
    data = body.get("data") or []
    if not data:
        raise RuntimeError(f"OpenRouter embedding payload missing vector: {body}")
    return [float(x) for x in data[0]["embedding"]]


def qdrant_query(
    *,
    session: requests.Session,
    qdrant_url: str,
    headers: Dict[str, str],
    collection: str,
    vector: Sequence[float],
    limit: int,
) -> List[dict]:
    base = qdrant_url.rstrip("/")
    endpoint_query = f"{base}/collections/{collection}/points/query"
    endpoint_search = f"{base}/collections/{collection}/points/search"
    query_body = {
        "query": vector,
        "limit": limit,
        "with_payload": True,
        "with_vector": False,
    }
    response = session.post(endpoint_query, headers=headers, json=query_body, timeout=35)
    payload = response.json()
    if response.status_code in {400, 404, 405}:
        search_body = {
            "vector": vector,
            "limit": limit,
            "with_payload": True,
            "with_vector": False,
        }
        response = session.post(
            endpoint_search, headers=headers, json=search_body, timeout=35
        )
        payload = response.json()
    if response.status_code >= 400:
        raise RuntimeError(f"Qdrant query failed ({response.status_code}): {payload}")
    points = payload.get("result", {}).get("points")
    if points is None:
        points = payload.get("result", [])
    rows = []
    for point in points or []:
        score = float(point.get("score") or 0.0)
        row = dict(point.get("payload") or {})
        row["vectorSimilarity"] = score
        row["vectorDistance"] = max(0.0, 1.0 - score)
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
    for _, aliases in FRANCHISE_ALIASES.items():
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
    scored = []
    excluded_genres = plan["exclude_genres"]
    for row in rows:
        row_genres = {normalize_text(value) for value in row.get("genres", [])}
        if excluded_genres and excluded_genres.intersection(row_genres):
            continue
        score = float(row.get("vectorSimilarity") or (1.0 - float(row.get("vectorDistance") or 1.0)))
        score += quality_score(row) * 0.25
        scored.append((score, row))
    scored.sort(key=lambda item: item[0], reverse=True)
    return [row for _, row in scored[:top_k]]


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


def summarize(rows: Sequence[QueryEval]) -> dict:
    latencies = [item.latency_ms for item in rows]
    non_empty = [1 if item.non_empty else 0 for item in rows]
    total_results = sum(item.top_k for item in rows)
    total_violations = sum(item.violations for item in rows)
    return {
        "queries": len(rows),
        "latency_avg_ms": statistics.mean(latencies) if latencies else 0.0,
        "latency_p95_ms": percentile(latencies, 0.95) if latencies else 0.0,
        "non_empty_rate": (sum(non_empty) / len(non_empty)) if non_empty else 0.0,
        "violation_rate": (total_violations / total_results) if total_results else 0.0,
        "avg_top_k": (total_results / len(rows)) if rows else 0.0,
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
    cleaned = "".join(ch.lower() if ch.isalnum() or ch.isspace() else " " for ch in str(value or ""))
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
