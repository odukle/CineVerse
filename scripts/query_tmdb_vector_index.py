#!/usr/bin/env python3
"""Query the local TMDB vector index from natural language.

Install dependencies with:
  python3 -m pip install --target .local/python_packages -r requirements-tmdb-vector.txt

Example:
  python3 scripts/query_tmdb_vector_index.py "Hindi thriller under 2 hours, not horror"
"""

from __future__ import annotations

import argparse
import json
import math
import re
import sys
import warnings
from pathlib import Path
from typing import Dict, Iterable, List, Optional, Sequence, Tuple


DEFAULT_INDEX_DIR = Path(".local/tmdb_vector_index")
LOCAL_PACKAGE_DIR = Path(__file__).resolve().parents[1] / ".local" / "python_packages"
LANGUAGE_ALIASES = {
    "arabic": "ar",
    "bengali": "bn",
    "cantonese": "cn",
    "chinese": "zh",
    "english": "en",
    "french": "fr",
    "german": "de",
    "hindi": "hi",
    "indonesian": "id",
    "italian": "it",
    "japanese": "ja",
    "kannada": "kn",
    "korean": "ko",
    "malayalam": "ml",
    "marathi": "mr",
    "portuguese": "pt",
    "spanish": "es",
    "tamil": "ta",
    "telugu": "te",
    "thai": "th",
    "turkish": "tr",
    "urdu": "ur",
}
GENRE_ALIASES = {
    "Action": ("action",),
    "Adventure": ("adventure",),
    "Animation": ("animation", "animated", "anime"),
    "Comedy": ("comedy", "funny", "hilarious"),
    "Crime": ("crime", "gangster", "mafia"),
    "Documentary": ("documentary", "docu"),
    "Drama": ("drama", "emotional"),
    "Family": ("family", "kids"),
    "Fantasy": ("fantasy",),
    "History": ("history", "historical", "period"),
    "Horror": ("horror", "scary", "haunted"),
    "Music": ("music", "musical"),
    "Mystery": ("mystery", "whodunit"),
    "Romance": ("romance", "romantic", "love story"),
    "Science Fiction": ("science fiction", "sci-fi", "sci fi", "space"),
    "Thriller": ("thriller", "suspense", "tense", "intense"),
    "War": ("war",),
    "Western": ("western",),
}


def main() -> None:
    _suppress_fastembed_pooling_warning()
    parser = argparse.ArgumentParser(description="Query a local TMDB vector index.")
    parser.add_argument("prompt", help="Natural-language recommendation request.")
    parser.add_argument(
        "--index-dir",
        default=str(DEFAULT_INDEX_DIR),
        help="Directory created by build_tmdb_vector_index.py.",
    )
    parser.add_argument("--top-k", type=int, default=12, help="Results to print.")
    parser.add_argument(
        "--candidate-limit",
        type=int,
        default=0,
        help="Max filtered candidates to rerank exactly. Use 0 for all.",
    )
    parser.add_argument(
        "--relax-language-if-needed",
        action="store_true",
        help="Fallback to any language when strict language filters return too few items.",
    )
    parser.add_argument(
        "--json",
        action="store_true",
        help="Emit JSON instead of human-readable text.",
    )
    args = parser.parse_args()

    if args.top_k <= 0:
        raise ValueError("--top-k must be greater than zero")

    TextEmbedding, np = _load_dependencies()
    index_dir = Path(args.index_dir)
    manifest = _load_manifest(index_dir)
    metadata = _load_metadata(index_dir / manifest["files"]["metadata"])
    embeddings = np.load(index_dir / manifest["files"]["embeddings"], mmap_mode="r")
    if len(metadata) != embeddings.shape[0]:
        raise RuntimeError("Metadata and embedding row counts do not match.")

    criteria = _parse_prompt(args.prompt)
    model = TextEmbedding(model_name=manifest["model"])
    query_text = (
        "query: " + args.prompt
        if _uses_retrieval_prefix(str(manifest["model"]))
        else args.prompt
    )
    query_embedding = np.asarray(
        list(model.embed([query_text])),
        dtype="float32",
    )[0]
    query_embedding = _normalize_vector(np, query_embedding)

    candidate_indices = [
        idx for idx, row in enumerate(metadata) if _matches_hard_filters(row, criteria)
    ]
    relaxed = False
    if args.relax_language_if_needed and len(candidate_indices) < args.top_k:
        relaxed = True
        candidate_indices = [
            idx
            for idx, row in enumerate(metadata)
            if _matches_hard_filters(row, criteria, relax_language=True)
        ]
    if not candidate_indices:
        raise RuntimeError("No local candidates matched the parsed hard filters.")

    if args.candidate_limit > 0 and len(candidate_indices) > args.candidate_limit:
        candidate_indices = _preselect_by_quality(
            candidate_indices,
            metadata,
            limit=args.candidate_limit,
        )

    matrix = embeddings[candidate_indices]
    similarities = matrix @ query_embedding
    scored = []
    for local_pos, idx in enumerate(candidate_indices):
        row = metadata[idx]
        similarity = float(similarities[local_pos])
        rerank = _rerank_score(row, criteria, similarity)
        scored.append((rerank, similarity, row))
    scored.sort(key=lambda item: item[0], reverse=True)

    results = [
        _result_payload(row=row, score=score, similarity=similarity, criteria=criteria)
        for score, similarity, row in scored[: args.top_k]
    ]
    payload = {
        "prompt": args.prompt,
        "criteria": criteria,
        "relaxed": relaxed,
        "searchedCandidates": len(candidate_indices),
        "results": results,
    }
    if args.json:
        print(json.dumps(payload, ensure_ascii=False, indent=2))
    else:
        _print_text(payload)


def _load_dependencies():
    if LOCAL_PACKAGE_DIR.exists():
        sys.path.insert(0, str(LOCAL_PACKAGE_DIR))
    try:
        import numpy as np
        from fastembed import TextEmbedding
    except Exception as exc:
        raise RuntimeError(
            "Missing vector dependencies. Run: "
            "python3 -m pip install --target .local/python_packages "
            "-r requirements-tmdb-vector.txt"
        ) from exc
    return TextEmbedding, np


def _suppress_fastembed_pooling_warning() -> None:
    warnings.filterwarnings(
        "ignore",
        message=r"The model .* now uses mean pooling instead of CLS embedding.*",
        category=UserWarning,
    )


def _normalize_vector(np, vector):
    norm = float(np.linalg.norm(vector))
    if norm == 0:
        return vector
    return vector / norm


def _load_manifest(index_dir: Path) -> dict:
    path = index_dir / "manifest.json"
    if not path.exists():
        raise FileNotFoundError(f"Manifest not found: {path}")
    return json.loads(path.read_text(encoding="utf-8"))


def _load_metadata(path: Path) -> List[dict]:
    if not path.exists():
        raise FileNotFoundError(f"Metadata not found: {path}")
    rows = []
    with path.open("r", encoding="utf-8") as handle:
        for line in handle:
            line = line.strip()
            if line:
                rows.append(json.loads(line))
    return rows


def _parse_prompt(prompt: str) -> dict:
    lower = prompt.lower()
    include_genres: set[str] = set()
    exclude_genres: set[str] = set()

    for genre, aliases in GENRE_ALIASES.items():
        for alias in aliases:
            if alias not in lower:
                continue
            if _is_negated(lower, alias):
                exclude_genres.add(genre)
            else:
                include_genres.add(genre)
            break

    language = None
    for alias, code in LANGUAGE_ALIASES.items():
        if re.search(rf"\b{re.escape(alias)}\b", lower):
            language = code
            break

    max_runtime = _runtime_minutes(lower, upper=True)
    min_runtime = _runtime_minutes(lower, upper=False)
    year_from, year_to = _year_range(lower)

    return {
        "language": language,
        "includeGenres": sorted(include_genres),
        "excludeGenres": sorted(exclude_genres),
        "maxRuntimeMinutes": max_runtime,
        "minRuntimeMinutes": min_runtime,
        "yearFrom": year_from,
        "yearTo": year_to,
    }


def _matches_hard_filters(
    row: dict,
    criteria: dict,
    *,
    relax_language: bool = False,
) -> bool:
    language = criteria.get("language")
    if language and not relax_language and row.get("originalLanguage") != language:
        return False

    genres = set(row.get("genres") or [])
    excluded = set(criteria.get("excludeGenres") or [])
    if genres & excluded:
        return False

    runtime = row.get("runtimeMinutes")
    if criteria.get("maxRuntimeMinutes") and runtime:
        if runtime > criteria["maxRuntimeMinutes"]:
            return False
    if criteria.get("minRuntimeMinutes") and runtime:
        if runtime < criteria["minRuntimeMinutes"]:
            return False

    release_year = row.get("releaseYear")
    if criteria.get("yearFrom") and release_year:
        if release_year < criteria["yearFrom"]:
            return False
    if criteria.get("yearTo") and release_year:
        if release_year > criteria["yearTo"]:
            return False

    return True


def _preselect_by_quality(
    indices: Sequence[int],
    metadata: Sequence[dict],
    *,
    limit: int,
) -> List[int]:
    ranked = sorted(
        indices,
        key=lambda idx: _quality_score(metadata[idx]),
        reverse=True,
    )
    return ranked[:limit]


def _rerank_score(row: dict, criteria: dict, similarity: float) -> float:
    metadata = 0.0
    row_genres = set(row.get("genres") or [])
    include_genres = set(criteria.get("includeGenres") or [])
    if include_genres:
        metadata += len(row_genres & include_genres) / max(1, len(include_genres))
    if criteria.get("language") and row.get("originalLanguage") == criteria["language"]:
        metadata += 0.6
    return (similarity * 0.72) + (_quality_score(row) * 0.18) + (metadata * 0.10)


def _quality_score(row: dict) -> float:
    vote_average = float(row.get("voteAverage") or 0.0)
    vote_count = float(row.get("voteCount") or 0.0)
    popularity = float(row.get("popularity") or 0.0)
    vote_component = min(1.0, vote_average / 8.5)
    confidence = min(1.0, math.log10(vote_count + 1) / 3.0)
    popularity_component = min(1.0, math.log10(popularity + 1) / 2.0)
    return (vote_component * 0.55) + (confidence * 0.35) + (popularity_component * 0.10)


def _result_payload(
    *,
    row: dict,
    score: float,
    similarity: float,
    criteria: dict,
) -> dict:
    return {
        "id": row["id"],
        "title": row["title"],
        "originalTitle": row.get("originalTitle"),
        "releaseYear": row.get("releaseYear"),
        "originalLanguage": row.get("originalLanguage"),
        "runtimeMinutes": row.get("runtimeMinutes"),
        "genres": row.get("genres") or [],
        "voteAverage": row.get("voteAverage"),
        "voteCount": row.get("voteCount"),
        "popularity": row.get("popularity"),
        "posterPath": row.get("posterPath"),
        "score": round(score, 5),
        "similarity": round(similarity, 5),
        "reason": _reason(row, criteria),
    }


def _reason(row: dict, criteria: dict) -> str:
    pieces = []
    genres = set(row.get("genres") or [])
    requested = set(criteria.get("includeGenres") or [])
    matched = sorted(genres & requested)
    if matched:
        pieces.append("matches " + ", ".join(matched))
    if criteria.get("language") and row.get("originalLanguage") == criteria["language"]:
        pieces.append(f"original language is {criteria['language']}")
    if row.get("runtimeMinutes"):
        pieces.append(f"{row['runtimeMinutes']} min")
    if row.get("voteAverage"):
        pieces.append(f"{row['voteAverage']}/10 from {row.get('voteCount', 0)} votes")
    return "; ".join(pieces) if pieces else "strong semantic match"


def _print_text(payload: dict) -> None:
    print(f"Prompt: {payload['prompt']}")
    print(f"Criteria: {json.dumps(payload['criteria'], ensure_ascii=False)}")
    print(f"Searched candidates: {payload['searchedCandidates']}")
    if payload["relaxed"]:
        print("Note: language was relaxed because too few strict candidates matched.")
    print()
    for index, row in enumerate(payload["results"], start=1):
        year = f" ({row['releaseYear']})" if row.get("releaseYear") else ""
        genres = ", ".join(row.get("genres") or [])
        print(f"{index}. {row['title']}{year}")
        print(
            f"   score={row['score']} sim={row['similarity']} "
            f"lang={row.get('originalLanguage')} runtime={row.get('runtimeMinutes')}"
        )
        if genres:
            print(f"   genres={genres}")
        print(f"   {row['reason']}")


def _is_negated(text: str, term: str) -> bool:
    return bool(
        re.search(
            rf"(?:not|no|without|except|avoid)\s+(?:\w+\s+){{0,3}}{re.escape(term)}",
            text,
            flags=re.IGNORECASE,
        )
    )


def _runtime_minutes(text: str, *, upper: bool) -> Optional[int]:
    words = (
        r"(?:under|less than|max(?:imum)?|up to|upto)"
        if upper
        else r"(?:over|more than|min(?:imum)?|at least)"
    )
    hour_match = re.search(
        rf"{words}\s*(\d{{1,2}})\s*(?:hours?|hrs?|hr|h)\b",
        text,
        flags=re.IGNORECASE,
    )
    if hour_match:
        return int(hour_match.group(1)) * 60
    minute_match = re.search(
        rf"{words}\s*(\d{{2,3}})\s*(?:min|mins|minutes?)\b",
        text,
        flags=re.IGNORECASE,
    )
    if minute_match:
        return int(minute_match.group(1))
    return None


def _year_range(text: str) -> Tuple[Optional[int], Optional[int]]:
    from_match = re.search(r"(?:after|since|from)\s*(19\d{2}|20\d{2})", text)
    to_match = re.search(r"(?:before|till|until)\s*(19\d{2}|20\d{2})", text)
    year_from = int(from_match.group(1)) if from_match else None
    year_to = int(to_match.group(1)) if to_match else None
    return year_from, year_to


def _uses_retrieval_prefix(model_name: str) -> bool:
    lowered = model_name.lower()
    return "e5" in lowered or "bge" in lowered


class LocalTmdbVectorEngine:
    def __init__(self, index_dir: Path | str = DEFAULT_INDEX_DIR):
        TextEmbedding, np = _load_dependencies()
        self.np = np
        self.index_dir = Path(index_dir)
        self.manifest = _load_manifest(self.index_dir)
        self.metadata = _load_metadata(
            self.index_dir / self.manifest["files"]["metadata"]
        )
        self.embeddings = np.load(
            self.index_dir / self.manifest["files"]["embeddings"],
            mmap_mode="r",
        )
        if len(self.metadata) != self.embeddings.shape[0]:
            raise RuntimeError("Metadata and embedding row counts do not match.")
        self.model = TextEmbedding(model_name=self.manifest["model"])

    def query(
        self,
        prompt: str,
        *,
        top_k: int = 12,
        candidate_limit: int = 0,
        relax_language_if_needed: bool = False,
    ) -> dict:
        criteria = _parse_prompt(prompt)
        query_text = (
            "query: " + prompt
            if _uses_retrieval_prefix(str(self.manifest["model"]))
            else prompt
        )
        query_embedding = self.np.asarray(
            list(self.model.embed([query_text])),
            dtype="float32",
        )[0]
        query_embedding = _normalize_vector(self.np, query_embedding)

        candidate_indices = [
            idx
            for idx, row in enumerate(self.metadata)
            if _matches_hard_filters(row, criteria)
        ]
        relaxed = False
        if relax_language_if_needed and len(candidate_indices) < top_k:
            relaxed = True
            candidate_indices = [
                idx
                for idx, row in enumerate(self.metadata)
                if _matches_hard_filters(row, criteria, relax_language=True)
            ]
        if not candidate_indices:
            return {
                "prompt": prompt,
                "criteria": criteria,
                "relaxed": relaxed,
                "searchedCandidates": 0,
                "results": [],
            }

        if candidate_limit > 0 and len(candidate_indices) > candidate_limit:
            candidate_indices = _preselect_by_quality(
                candidate_indices,
                self.metadata,
                limit=candidate_limit,
            )

        matrix = self.embeddings[candidate_indices]
        similarities = matrix @ query_embedding
        scored = []
        for local_pos, idx in enumerate(candidate_indices):
            row = self.metadata[idx]
            similarity = float(similarities[local_pos])
            rerank = _rerank_score(row, criteria, similarity)
            scored.append((rerank, similarity, row))
        scored.sort(key=lambda item: item[0], reverse=True)

        return {
            "prompt": prompt,
            "criteria": criteria,
            "relaxed": relaxed,
            "searchedCandidates": len(candidate_indices),
            "results": [
                _result_payload(
                    row=row,
                    score=score,
                    similarity=similarity,
                    criteria=criteria,
                )
                for score, similarity, row in scored[:top_k]
            ],
        }


if __name__ == "__main__":
    main()
