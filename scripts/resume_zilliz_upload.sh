#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

API_KEYS_FILE="config/api_keys.json"
LOG_FILE=".local/tmdb-zilliz-upload.log"
COLLECTION="${ZILLIZ_COLLECTION:-tmdb_movie_vectors_v3}"
VECTOR_DIM="${VECTOR_DIM:-1024}"
MAX_ITEMS="${MAX_ITEMS:-0}"
EMBEDDING_PROFILE="${EMBEDDING_PROFILE:-movie_profile_v2}"
SMOKE_QUERY="${SMOKE_QUERY:-movies like interstellar but not sci-fi}"
ZILLIZ_DB_NAME="${ZILLIZ_DB_NAME:-}"
MIN_VOTE_AVERAGE="${MIN_VOTE_AVERAGE:-0.0001}"
MIN_VOTE_COUNT="${MIN_VOTE_COUNT:-0}"
REGIONAL_MIN_VOTE_COUNT="${REGIONAL_MIN_VOTE_COUNT:-0}"
CHECKPOINT_FILE="${CHECKPOINT_FILE:-.local/tmdb-zilliz-upload-progress-${COLLECTION}-d${VECTOR_DIM}-mva${MIN_VOTE_AVERAGE}-adult-all.json}"

if [[ ! -f "$API_KEYS_FILE" ]]; then
  echo "Error: $API_KEYS_FILE not found."
  exit 1
fi

ZILLIZ_ENDPOINT="$(python3 -c 'import json; o=json.load(open("config/api_keys.json")); print((o.get("ZILLIZ_ENDPOINT") or o.get("ZILLIZ_URL") or "").strip())')"
ZILLIZ_API_KEY="$(python3 -c 'import json; o=json.load(open("config/api_keys.json")); print((o.get("ZILLIZ_API_KEY") or "").strip())')"
if [[ -z "$ZILLIZ_DB_NAME" ]]; then
  ZILLIZ_DB_NAME="$(python3 -c 'import json; o=json.load(open("config/api_keys.json")); print((o.get("ZILLIZ_DB_NAME") or "").strip())')"
fi
if [[ -z "$ZILLIZ_DB_NAME" ]]; then
  ZILLIZ_DB_NAME="default"
fi

if [[ -z "$ZILLIZ_ENDPOINT" ]]; then
  echo "Error: ZILLIZ_ENDPOINT/ZILLIZ_URL is missing in $API_KEYS_FILE."
  exit 1
fi
if [[ "$ZILLIZ_ENDPOINT" != http://* && "$ZILLIZ_ENDPOINT" != https://* ]]; then
  echo "Error: Zilliz endpoint must include scheme (https://...). Got: $ZILLIZ_ENDPOINT"
  exit 1
fi
if [[ -z "$ZILLIZ_API_KEY" ]]; then
  echo "Error: ZILLIZ_API_KEY is missing in $API_KEYS_FILE."
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

echo "Starting/resuming Zilliz upload..."
echo "Endpoint: $ZILLIZ_ENDPOINT"
echo "Collection: $COLLECTION"
echo "Database: $ZILLIZ_DB_NAME"
echo "Vector dim: $VECTOR_DIM"
echo "Min vote average: $MIN_VOTE_AVERAGE"
echo "Min vote count: $MIN_VOTE_COUNT"
echo "Regional min vote count: $REGIONAL_MIN_VOTE_COUNT"
echo "Exclude adult: false"
echo "Max items this run: $MAX_ITEMS"
echo "Checkpoint file: $CHECKPOINT_FILE"
echo "Log file: $LOG_FILE"

python3 scripts/upload_tmdb_openrouter_vectors_to_zilliz.py \
  --zilliz-endpoint "$ZILLIZ_ENDPOINT" \
  --zilliz-api-key "$ZILLIZ_API_KEY" \
  --zilliz-db-name "$ZILLIZ_DB_NAME" \
  --collection "$COLLECTION" \
  --vector-dim "$VECTOR_DIM" \
  --embedding-profile "$EMBEDDING_PROFILE" \
  --min-vote-average "$MIN_VOTE_AVERAGE" \
  --min-vote-count "$MIN_VOTE_COUNT" \
  --regional-min-vote-count "$REGIONAL_MIN_VOTE_COUNT" \
  --max-items "$MAX_ITEMS" \
  --checkpoint-file "$CHECKPOINT_FILE" \
  --resume \
  --log-file "$LOG_FILE" \
  --smoke-test-query "$SMOKE_QUERY"

echo "Zilliz upload command finished."
