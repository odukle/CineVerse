#!/usr/bin/env python3
"""Build a local vector index from TMDB_movie_dataset.csv.

The generated files are intentionally local-only:
  .local/tmdb_vector_index/movie.index
  .local/tmdb_vector_index/movie_embeddings.npy
  .local/tmdb_vector_index/movie_metadata.jsonl
  .local/tmdb_vector_index/manifest.json

Install dependencies with:
  python3 -m pip install --target .local/python_packages -r requirements-tmdb-vector.txt
"""

from __future__ import annotations

import argparse
import csv
import json
import math
import re
import sys
import warnings
from datetime import datetime, timezone
from pathlib import Path
from typing import Dict, Iterable, Iterator, List, Optional, Sequence, Tuple


DEFAULT_MODEL = "sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2"
DEFAULT_CSV = Path("TMDB_movie_dataset.csv")
DEFAULT_OUTPUT_DIR = Path(".local/tmdb_vector_index")
LOCAL_PACKAGE_DIR = Path(__file__).resolve().parents[1] / ".local" / "python_packages"
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


def main() -> None:
    _suppress_fastembed_pooling_warning()
    parser = argparse.ArgumentParser(
        description="Build local FAISS embeddings for TMDB movie recommendations."
    )
    parser.add_argument("--csv", default=str(DEFAULT_CSV), help="TMDB CSV path.")
    parser.add_argument(
        "--output-dir",
        default=str(DEFAULT_OUTPUT_DIR),
        help="Directory where local index files are written.",
    )
    parser.add_argument(
        "--model",
        default=DEFAULT_MODEL,
        help="SentenceTransformer model. Default is a free multilingual E5 model.",
    )
    parser.add_argument(
        "--batch-size",
        type=int,
        default=128,
        help="Embedding batch size. Lower this if memory is tight.",
    )
    parser.add_argument(
        "--max-rows",
        type=int,
        default=0,
        help="Optional raw CSV row cap for quick debugging.",
    )
    parser.add_argument(
        "--max-items",
        type=int,
        default=50000,
        help="Maximum indexed movies. Use 0 to keep every eligible title.",
    )
    parser.add_argument(
        "--min-vote-count",
        type=int,
        default=5,
        help="Default vote-count floor for eligible movies.",
    )
    parser.add_argument(
        "--regional-min-vote-count",
        type=int,
        default=1,
        help="Lower vote-count floor for languages that are sparse in TMDB.",
    )
    parser.add_argument(
        "--min-vote-average",
        type=float,
        default=1.0,
        help="Minimum vote average. Keeps unrated/noise rows out.",
    )
    args = parser.parse_args()

    csv_path = Path(args.csv)
    output_dir = Path(args.output_dir)
    if not csv_path.exists():
        raise FileNotFoundError(f"CSV not found: {csv_path}")
    if args.batch_size <= 0:
        raise ValueError("--batch-size must be greater than zero")

    TextEmbedding, faiss, np = _load_vector_dependencies()
    output_dir.mkdir(parents=True, exist_ok=True)

    print(f"Reading eligible movies from {csv_path}")
    rows = list(
        _iter_eligible_movies(
            csv_path=csv_path,
            max_rows=args.max_rows,
            max_items=args.max_items,
            min_vote_count=args.min_vote_count,
            regional_min_vote_count=args.regional_min_vote_count,
            min_vote_average=args.min_vote_average,
        )
    )
    if not rows:
        raise RuntimeError("No eligible movies found. Relax thresholds and retry.")

    print(f"Encoding {len(rows)} movies with {args.model}")
    model = TextEmbedding(model_name=args.model)
    profiles = [_embedding_text(row, model_name=args.model) for row in rows]
    embeddings = np.asarray(
        list(model.embed(profiles, batch_size=args.batch_size)),
        dtype="float32",
    )
    embeddings = _normalize_embeddings(np, embeddings)

    if embeddings.ndim != 2:
        raise RuntimeError("Embedding model returned an unexpected tensor shape.")

    dimension = int(embeddings.shape[1])
    index = faiss.IndexFlatIP(dimension)
    index.add(embeddings)

    index_path = output_dir / "movie.index"
    embeddings_path = output_dir / "movie_embeddings.npy"
    metadata_path = output_dir / "movie_metadata.jsonl"
    manifest_path = output_dir / "manifest.json"

    faiss.write_index(index, str(index_path))
    np.save(embeddings_path, embeddings)
    with metadata_path.open("w", encoding="utf-8") as handle:
        for row in rows:
            handle.write(json.dumps(row, ensure_ascii=False, separators=(",", ":")))
            handle.write("\n")

    manifest = {
        "version": 1,
        "createdAt": datetime.now(timezone.utc).isoformat(),
        "sourceCsv": str(csv_path),
        "model": args.model,
        "distance": "cosine_via_normalized_inner_product",
        "dimension": dimension,
        "count": len(rows),
        "filters": {
            "status": "Released",
            "adult": False,
            "requiresTitle": True,
            "requiresOverview": True,
            "minVoteAverage": args.min_vote_average,
            "minVoteCount": args.min_vote_count,
            "regionalMinVoteCount": args.regional_min_vote_count,
        },
        "files": {
            "index": index_path.name,
            "embeddings": embeddings_path.name,
            "metadata": metadata_path.name,
        },
    }
    manifest_path.write_text(
        json.dumps(manifest, ensure_ascii=True, indent=2),
        encoding="utf-8",
    )

    print(f"Wrote FAISS index: {index_path}")
    print(f"Wrote embeddings: {embeddings_path}")
    print(f"Wrote metadata: {metadata_path}")
    print(f"Wrote manifest: {manifest_path}")


def _load_vector_dependencies():
    if LOCAL_PACKAGE_DIR.exists():
        sys.path.insert(0, str(LOCAL_PACKAGE_DIR))
    try:
        import faiss
        import numpy as np
        from fastembed import TextEmbedding
    except Exception as exc:
        raise RuntimeError(
            "Missing vector dependencies. Run: "
            "python3 -m pip install --target .local/python_packages "
            "-r requirements-tmdb-vector.txt"
        ) from exc
    return TextEmbedding, faiss, np


def _suppress_fastembed_pooling_warning() -> None:
    warnings.filterwarnings(
        "ignore",
        message=r"The model .* now uses mean pooling instead of CLS embedding.*",
        category=UserWarning,
    )


def _normalize_embeddings(np, embeddings):
    norms = np.linalg.norm(embeddings, axis=1, keepdims=True)
    norms[norms == 0] = 1
    return embeddings / norms


def _iter_eligible_movies(
    *,
    csv_path: Path,
    max_rows: int,
    max_items: int,
    min_vote_count: int,
    regional_min_vote_count: int,
    min_vote_average: float,
) -> Iterator[dict]:
    seen_ids: set[int] = set()
    kept = 0

    with csv_path.open("r", encoding="utf-8", errors="replace", newline="") as handle:
        reader = csv.DictReader(handle)
        for row_index, row in enumerate(reader, start=1):
            if max_rows > 0 and row_index > max_rows:
                break
            parsed = _parse_movie(
                row,
                min_vote_count=min_vote_count,
                regional_min_vote_count=regional_min_vote_count,
                min_vote_average=min_vote_average,
            )
            if parsed is None:
                continue
            movie_id = parsed["id"]
            if movie_id in seen_ids:
                continue
            seen_ids.add(movie_id)
            yield parsed
            kept += 1
            if max_items > 0 and kept >= max_items:
                break
            if row_index % 100000 == 0:
                print(f"Processed {row_index} rows, kept {kept} movies")


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

    genres = _split_list(row.get("genres"))
    keywords = _split_list(row.get("keywords"))
    release_date = _clean(row.get("release_date")) or None
    release_year = _release_year(release_date)

    return {
        "id": movie_id,
        "mediaType": "movie",
        "title": title,
        "originalTitle": _clean(row.get("original_title")) or title,
        "overview": overview,
        "tagline": _clean(row.get("tagline")) or None,
        "genres": genres,
        "keywords": keywords,
        "originalLanguage": original_language,
        "spokenLanguages": _split_list(row.get("spoken_languages")),
        "productionCountries": _split_list(row.get("production_countries")),
        "releaseDate": release_date,
        "releaseYear": release_year,
        "runtimeMinutes": _to_int(row.get("runtime")),
        "voteAverage": round(vote_average, 3),
        "voteCount": vote_count,
        "popularity": round(_to_float(row.get("popularity")) or 0.0, 3),
        "posterPath": _clean(row.get("poster_path")) or None,
        "backdropPath": _clean(row.get("backdrop_path")) or None,
        "imdbId": _clean(row.get("imdb_id")) or None,
    }


def _embedding_text(row: dict, *, model_name: str) -> str:
    parts = [
        f"Title: {row['title']}",
        f"Original title: {row['originalTitle']}",
    ]
    if row["genres"]:
        parts.append("Genres: " + ", ".join(row["genres"]))
    if row["keywords"]:
        # Keywords are sparse but highly predictive, so keep them near the front.
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
    text = "\n".join(parts)
    return "passage: " + text if _uses_retrieval_prefix(model_name) else text


def _uses_retrieval_prefix(model_name: str) -> bool:
    lowered = model_name.lower()
    return "e5" in lowered or "bge" in lowered


def _split_list(value: object) -> List[str]:
    text = _clean(value)
    if not text:
        return []
    return [
        item.strip()
        for item in text.split(",")
        if item.strip() and item.strip().lower() not in {"nan", "none", "null"}
    ]


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
