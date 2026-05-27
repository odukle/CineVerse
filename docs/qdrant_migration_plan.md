# Qdrant Migration Plan (CineVerse Tonight Recommendations)

## Goal

Move vector retrieval for `recommendTonight` from Firestore vector search to
Qdrant `v2` embeddings, with zero downtime and rollback safety.

## Scope

- Keep existing endpoint and response contract unchanged.
- Keep OpenRouter planning + embedding unchanged.
- Move only candidate retrieval backend.
- Keep reranking/filtering logic in Firebase Function unchanged.

## What is implemented

1. Function backend switch:
   - `TONIGHT_VECTOR_BACKEND=firestore|qdrant|dual`
2. Qdrant runtime config:
   - `QDRANT_URL`
   - `QDRANT_COLLECTION`
   - `QDRANT_TIMEOUT_MS`
   - `QDRANT_FAILOVER_TO_FIRESTORE=true|false`
   - `QDRANT_API_KEY` (optional param if cluster is private)
3. Dual-read mode:
   - Queries both Firestore and Qdrant.
   - Merges candidates by movie id.
   - Uses best vector similarity per id.
4. New ingestion script:
   - `scripts/upload_tmdb_openrouter_vectors_to_qdrant.py`
   - Versioned embedding profile (`movie_profile_v2`) and richer payload fields.
   - Resume mode + deterministic upsert IDs.
5. Shadow-collection diagnostics:
   - `QDRANT_SHADOW_COLLECTION` can run a second collection lookup for side-by-side
     latency/coverage checks while serving primary results.

## Payload schema in Qdrant (v2)

Each point:
- `id`: TMDB movie id (integer)
- `vector`: OpenRouter embedding vector
- `payload`:
  - `id`, `mediaType`, `schemaVersion`, `title`, `originalTitle`, `overview`, `tagline`
  - `genres`, `keywords`
  - `originalLanguage`, `spokenLanguages`, `productionCountries`, `productionCompanies`
  - `releaseDate`, `releaseYear`, `runtimeMinutes`
  - `voteAverage`, `voteCount`, `popularity`
  - `runtimeBucket`, `decade`, `qualityTier`, `franchiseHints`, `adult`
  - `posterPath`
  - `_csvRow` (ingestion bookkeeping)

## Rollout procedure

1. Ingest to Qdrant
```bash
python3 -m pip install -r requirements-tmdb-qdrant-vector.txt
export OPENROUTER_API_KEY=...
export QDRANT_URL=https://<cluster>.cloud.qdrant.io
export QDRANT_API_KEY=...
python3 scripts/upload_tmdb_openrouter_vectors_to_qdrant.py \
  --collection tmdb_movie_vectors_v2 \
  --embedding-profile movie_profile_v2 \
  --resume \
  --log-file .local/tmdb-qdrant-upload.log
```

Or run the helper:

```bash
scripts/reembed_qdrant_v2.sh
```

2. Configure function params/secrets
```bash
firebase functions:secrets:set OPENROUTER_API_KEY
```

3. Deploy function
```bash
firebase deploy --only functions
```

4. Start in dual mode
```bash
firebase functions:config:set \
  TONIGHT_VECTOR_BACKEND=dual \
  QDRANT_URL=https://<cluster>.cloud.qdrant.io \
  QDRANT_COLLECTION=tmdb_movie_vectors_v2 \
  QDRANT_SHADOW_COLLECTION=tmdb_movie_vectors_v1 \
  QDRANT_TIMEOUT_MS=12000
```
Then redeploy functions.

5. Validate for 24-72 hours
- Compare:
  - Timeout rate
  - Empty-result rate
  - Median/95th response latency
  - Quality on difficult prompts (negations, non-English)
- Read `diagnostics.vectorBackendStats` from responses.
- Run offline A/B script:

```bash
python3 scripts/evaluate_qdrant_collections.py \
  --qdrant-url "$QDRANT_URL" \
  --qdrant-api-key "$QDRANT_API_KEY" \
  --collection-a tmdb_movie_vectors_v1 \
  --collection-b tmdb_movie_vectors_v2 \
  --queries-file scripts/recommendation_eval_queries.txt \
  --output-json .local/qdrant_v1_v2_eval.json
```

6. Cut over
```bash
TONIGHT_VECTOR_BACKEND=qdrant
```

7. Keep rollback ready
```bash
TONIGHT_VECTOR_BACKEND=firestore
```

## Operational notes

- Qdrant score is treated as cosine similarity (clamped to `[0,1]`).
- Function computes `distance = 1 - similarity` for compatibility with existing diagnostics/reranking shape.
- If Qdrant fails in `dual`, Firestore still serves results.
- If both fail, function returns error.

## Capacity planning (initial)

- Vector dimension: from OpenRouter model output (auto-detected by script during first batch).
- Collection distance: `Cosine`.
- Start with one collection and no extra payload index.
- Add payload indexes later only if Qdrant-side filtering is introduced.

## Next step (optional)

If you want cost and latency optimization beyond this migration:
- Move lightweight exclusion filtering into Qdrant payload filters.
- Cache query embeddings for very frequent prompts (short TTL).
- Add model-specific A/B for embedding quality vs latency.
