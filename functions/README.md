# CineVerse Recommendation Function

Production flow:

1. `scripts/upload_tmdb_openrouter_vectors_to_qdrant.py` embeds TMDB movie rows
   with OpenRouter and upserts them to Qdrant collection `tmdb_movie_vectors_v2`.
2. `scripts/upload_tmdb_openrouter_vectors_to_firestore.py` can still ingest the
   same rows to Firestore `tmdb_movie_vectors_v1` as operational fallback.
3. `recommendTonight` receives the app prompt, uses OpenRouter to build a query
   plan and query embedding, runs vector search (Qdrant primary, Firestore fallback),
   filters/reranks, and returns TMDB ids to the Flutter app.

## Configure

```bash
firebase functions:secrets:set OPENROUTER_API_KEY
firebase functions:secrets:set GEMINI_API_KEY
```

The function uses defaults for model names. To override them locally or during
deployment, create `functions/.env` with:

```bash
OPENROUTER_CHAT_MODEL=openrouter/free
OPENROUTER_CHAT_FALLBACK_MODELS=deepseek/deepseek-v4-flash:free,qwen/qwen3-32b:free,mistralai/mistral-small-3.2-24b-instruct:free,meta-llama/llama-3.3-70b-instruct:free
GEMINI_CHAT_MODEL=gemini-2.5-flash-lite
GEMINI_CHAT_FALLBACK_MODELS=gemini-2.0-flash,gemini-2.5-flash
OPENROUTER_EMBEDDING_MODEL=nvidia/llama-nemotron-embed-vl-1b-v2:free
TONIGHT_VECTOR_BACKEND=zilliz
TONIGHT_VECTOR_COLLECTION=tmdb_movie_vectors_v1
QDRANT_URL=https://<cluster>.cloud.qdrant.io
QDRANT_COLLECTION=tmdb_movie_vectors_v2
QDRANT_TIMEOUT_MS=12000
QDRANT_FAILOVER_TO_FIRESTORE=true
ZILLIZ_ENDPOINT=https://<cluster-endpoint>.zillizcloud.com
ZILLIZ_COLLECTION=tmdb_movie_vectors_v3
ZILLIZ_API_KEY=...
ZILLIZ_DB_NAME=default
ZILLIZ_VECTOR_FIELD=vector
ZILLIZ_VECTOR_DIM=1024
ZILLIZ_TIMEOUT_MS=12000
ZILLIZ_FAILOVER_TO_FIRESTORE=true
```

Backend behavior:
- Primary retrieval is Zilliz (`ZILLIZ_COLLECTION`) when
  `TONIGHT_VECTOR_BACKEND=zilliz`.
- If Zilliz fails, Qdrant (`QDRANT_COLLECTION`) is attempted.
- If both vector backends fail and `ZILLIZ_FAILOVER_TO_FIRESTORE=true`,
  Firestore (`TONIGHT_VECTOR_COLLECTION`) is used as final fallback.

Planner model routing:
- Primary planner: Gemini (`GEMINI_CHAT_MODEL`).
- Fallback planner: OpenRouter (`OPENROUTER_CHAT_MODEL` + fallback list).
- Embeddings remain on OpenRouter by default.
- Function rate limits are tuned so per-caller planner traffic remains under
  Gemini 2.5 Flash-Lite free-tier RPM in normal usage.

## Upload Vector Documents

```bash
python3 -m pip install --target .local/firestore_vector_packages \
  -r requirements-tmdb-firestore-vector.txt

gcloud auth login

python3 scripts/upload_tmdb_openrouter_vectors_to_firestore.py \
  --project cineverse-flutter-591 \
  --max-items 10000
```

Defaults now relax ingestion filters (`--min-vote-count 0`,
`--regional-min-vote-count 0`, `--min-vote-average 0.0`) and include adult
titles. Pass `--exclude-adult` if you want to omit them.

Use the same embedding model in the upload script and Cloud Function.

## Upload to Qdrant

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

The Qdrant upload uses deterministic point IDs (`movie id`), so reruns are idempotent.
Defaults are aligned with Firestore upload (relaxed vote filters, adult included;
use `--exclude-adult` to omit adult titles).

Resume helper:

```bash
scripts/resume_qdrant_upload.sh
```

Full re-embed helper (v2 defaults):

```bash
scripts/reembed_qdrant_v2.sh
```

## Evaluate v1 vs v2 before cutover

```bash
python3 scripts/evaluate_qdrant_collections.py \
  --qdrant-url "$QDRANT_URL" \
  --qdrant-api-key "$QDRANT_API_KEY" \
  --collection-a tmdb_movie_vectors_v1 \
  --collection-b tmdb_movie_vectors_v2 \
  --queries-file scripts/recommendation_eval_queries.txt \
  --output-json .local/qdrant_v1_v2_eval.json
```

Use the report to compare:
- latency average/p95
- non-empty result rate
- exclusion violation rate on top-k

For long backfills, use resume mode so interrupted runs continue from the last
committed CSV row and skip docs that already exist in Firestore:

```bash
python3 scripts/upload_tmdb_openrouter_vectors_to_firestore.py \
  --project cineverse-flutter-591 \
  --resume \
  --log-file .local/tmdb-upload.log
```

## Firestore Vector Index

Firestore vector search requires a vector index on:

`tmdb_movie_vectors_v1.embedding`

If the index is missing, the function logs include the exact `gcloud` command
Firestore wants. Run that command once, wait for the index to finish building,
then retry the feature.

## Deploy

```bash
cd functions
npm install
cd ..
firebase deploy --only functions
```
