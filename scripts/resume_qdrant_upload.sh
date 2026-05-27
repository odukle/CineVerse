#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

API_KEYS_FILE="config/api_keys.json"
LOG_FILE=".local/tmdb-qdrant-upload.log"
COLLECTION="${QDRANT_COLLECTION:-tmdb_movie_vectors_v2}"
EMBEDDING_PROFILE="${EMBEDDING_PROFILE:-movie_profile_v2}"
VECTOR_DIM="${VECTOR_DIM:-1024}"
MIN_VOTE_AVERAGE="${MIN_VOTE_AVERAGE:-0.0001}"
MIN_VOTE_COUNT="${MIN_VOTE_COUNT:-0}"
REGIONAL_MIN_VOTE_COUNT="${REGIONAL_MIN_VOTE_COUNT:-0}"
MAX_ITEMS="${MAX_ITEMS:-0}"
CHECKPOINT_FILE="${CHECKPOINT_FILE:-.local/tmdb-qdrant-upload-progress-${COLLECTION}-d${VECTOR_DIM}-mva${MIN_VOTE_AVERAGE}-adult-all.json}"

if [[ ! -f "$API_KEYS_FILE" ]]; then
  echo "Error: $API_KEYS_FILE not found."
  exit 1
fi

QDRANT_URL="$(python3 -c 'import json; o=json.load(open("config/api_keys.json")); print((o.get("QDRANT_URL") or o.get("QDRANT_ENDPOINT") or "").strip())')"
QDRANT_API_KEY="$(python3 -c 'import json; o=json.load(open("config/api_keys.json")); print((o.get("QDRANT_API_KEY") or "").strip())')"

if [[ -z "$QDRANT_URL" ]]; then
  echo "Error: QDRANT_URL/QDRANT_ENDPOINT is missing in $API_KEYS_FILE."
  exit 1
fi

if [[ "$QDRANT_URL" != http://* && "$QDRANT_URL" != https://* ]]; then
  echo "Error: QDRANT URL must include scheme (https://...). Got: $QDRANT_URL"
  exit 1
fi

if [[ -z "$QDRANT_API_KEY" ]]; then
  echo "Error: QDRANT_API_KEY is missing in $API_KEYS_FILE."
  exit 1
fi

if [[ -z "${OPENROUTER_API_KEY:-}" ]]; then
  OPENROUTER_API_KEY="$(python3 -c 'import json; o=json.load(open("config/api_keys.json")); print((o.get("OPENROUTER_API_KEY") or "").strip())')"
  export OPENROUTER_API_KEY
fi

if [[ -z "${OPENROUTER_API_KEY:-}" ]]; then
  echo "Error: OPENROUTER_API_KEY is not set and not found in $API_KEYS_FILE."
  exit 1
fi

mkdir -p .local

echo "Starting/resuming Qdrant upload..."
echo "Qdrant URL: $QDRANT_URL"
echo "Collection: $COLLECTION"
echo "Embedding profile: $EMBEDDING_PROFILE"
echo "Vector dim: $VECTOR_DIM"
echo "Min vote average: $MIN_VOTE_AVERAGE"
echo "Min vote count: $MIN_VOTE_COUNT"
echo "Regional min vote count: $REGIONAL_MIN_VOTE_COUNT"
echo "Exclude adult: false"
echo "Max items this run: $MAX_ITEMS"
echo "Checkpoint file: $CHECKPOINT_FILE"
echo "Log file: $LOG_FILE"

python3 scripts/upload_tmdb_openrouter_vectors_to_qdrant.py \
  --qdrant-url "$QDRANT_URL" \
  --qdrant-api-key "$QDRANT_API_KEY" \
  --collection "$COLLECTION" \
  --embedding-profile "$EMBEDDING_PROFILE" \
  --vector-dim "$VECTOR_DIM" \
  --min-vote-average "$MIN_VOTE_AVERAGE" \
  --min-vote-count "$MIN_VOTE_COUNT" \
  --regional-min-vote-count "$REGIONAL_MIN_VOTE_COUNT" \
  --max-items "$MAX_ITEMS" \
  --checkpoint-file "$CHECKPOINT_FILE" \
  --resume \
  --log-file "$LOG_FILE"

echo "Upload command finished."
