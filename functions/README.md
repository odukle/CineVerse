# CineVerse Recommendation Function

Production flow:

1. `scripts/upload_tmdb_openrouter_vectors_to_firestore.py` embeds TMDB movie rows
   with OpenRouter and stores them in Firestore collection
   `tmdb_movie_vectors_v1`.
2. Optional Qdrant path: `scripts/upload_tmdb_openrouter_vectors_to_qdrant.py`
   embeds the same rows and upserts to a Qdrant collection with the same payload
   schema.
3. `recommendTonight` receives the app prompt, uses OpenRouter to build a query
   plan and query embedding, runs vector search (Firestore / Qdrant / dual),
   filters/reranks, and returns TMDB ids to the Flutter app.

## Configure

```bash
firebase functions:secrets:set OPENROUTER_API_KEY
```

The function uses defaults for model names. To override them locally or during
deployment, create `functions/.env` with:

```bash
OPENROUTER_CHAT_MODEL=openrouter/free
OPENROUTER_CHAT_FALLBACK_MODELS=deepseek/deepseek-v4-flash:free,qwen/qwen3-32b:free,mistralai/mistral-small-3.2-24b-instruct:free,meta-llama/llama-3.3-70b-instruct:free
OPENROUTER_EMBEDDING_MODEL=nvidia/llama-nemotron-embed-vl-1b-v2:free
TONIGHT_VECTOR_COLLECTION=tmdb_movie_vectors_v1
TONIGHT_VECTOR_BACKEND=firestore
QDRANT_URL=https://<cluster>.cloud.qdrant.io
QDRANT_COLLECTION=tmdb_movie_vectors_v1
QDRANT_TIMEOUT_MS=12000
```

`TONIGHT_VECTOR_BACKEND` values:
- `firestore` (default): current production behavior.
- `qdrant`: query only Qdrant.
- `dual`: query both backends, merge candidates, and keep serving while validating.

## Upload Vector Documents

```bash
python3 -m pip install --target .local/firestore_vector_packages \
  -r requirements-tmdb-firestore-vector.txt

gcloud auth login

python3 scripts/upload_tmdb_openrouter_vectors_to_firestore.py \
  --project cineverse-flutter-591 \
  --max-items 10000
```

Use the same embedding model in the upload script and Cloud Function.

## Upload to Qdrant

```bash
python3 -m pip install -r requirements-tmdb-qdrant-vector.txt

export OPENROUTER_API_KEY=...
export QDRANT_URL=https://<cluster>.cloud.qdrant.io
export QDRANT_API_KEY=...

python3 scripts/upload_tmdb_openrouter_vectors_to_qdrant.py \
  --collection tmdb_movie_vectors_v1 \
  --resume \
  --log-file .local/tmdb-qdrant-upload.log
```

The Qdrant upload uses deterministic point IDs (`movie id`), so reruns are idempotent.

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
