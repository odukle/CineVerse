#!/usr/bin/env bash
set -euo pipefail

# Resume TMDB vector embedding upload to Firestore.
# Usage:
#   scripts/resume_tmdb_vector_upload.sh
#   scripts/resume_tmdb_vector_upload.sh cineverse-flutter-591 tmdb_movie_vectors_v1

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  cat <<'EOF'
Usage:
  scripts/resume_tmdb_vector_upload.sh [PROJECT] [COLLECTION]

Examples:
  scripts/resume_tmdb_vector_upload.sh
  scripts/resume_tmdb_vector_upload.sh cineverse-flutter-591 tmdb_movie_vectors_v1
EOF
  exit 0
fi

log() {
  printf '[%s] %s\n' "$(date '+%H:%M:%S')" "$*"
}

pause_before_exit() {
  local exit_code="$1"
  if [[ -t 0 ]]; then
    if [[ "$exit_code" -eq 0 ]]; then
      read -r -p "Upload command finished. Press Enter to close this window..."
    else
      read -r -p "Upload command failed (exit ${exit_code}). Press Enter to close this window..."
    fi
  fi
}

on_exit() {
  local exit_code=$?
  pause_before_exit "$exit_code"
}
trap on_exit EXIT

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "${REPO_ROOT}"

# Add common paths used in GUI-launched terminals.
export PATH="${PATH}:/snap/bin:${HOME}/google-cloud-sdk/bin"

PROJECT="${1:-cineverse-flutter-591}"
COLLECTION="${2:-tmdb_movie_vectors_v1}"
BATCH_SIZE="${BATCH_SIZE:-8}"
COMMIT_SIZE="${COMMIT_SIZE:-100}"
CHECKPOINT_FILE="${CHECKPOINT_FILE:-.local/tmdb-upload-progress.json}"
LOG_FILE="${LOG_FILE:-.local/tmdb-upload.log}"

# If OPENROUTER_API_KEY is not exported, try loading it from config/api_keys.json.
if [[ -z "${OPENROUTER_API_KEY:-}" ]] && [[ -f "config/api_keys.json" ]]; then
  OPENROUTER_API_KEY="$(
    python3 - <<'PY'
import json
from pathlib import Path
path = Path("config/api_keys.json")
try:
    data = json.loads(path.read_text(encoding="utf-8"))
except Exception:
    print("")
    raise SystemExit(0)
for key in (
    "OPENROUTER_API_KEY",
    "openrouter_api_key",
    "openRouterApiKey",
    "openrouterApiKey",
):
    value = data.get(key)
    if isinstance(value, str) and value.strip():
        print(value.strip())
        break
else:
    print("")
PY
  )"
  export OPENROUTER_API_KEY
fi

if [[ -z "${OPENROUTER_API_KEY:-}" ]]; then
  echo "ERROR: OPENROUTER_API_KEY is not set."
  echo "Run: export OPENROUTER_API_KEY=\"your_key_here\""
  exit 1
fi

# If GOOGLE_OAUTH_ACCESS_TOKEN is not exported, try to fetch it from gcloud.
if [[ -z "${GOOGLE_OAUTH_ACCESS_TOKEN:-}" ]]; then
  log "Fetching Google OAuth token from gcloud..."
  if ! command -v gcloud >/dev/null 2>&1; then
    echo "ERROR: gcloud is not available in PATH."
    echo "Open a terminal and run:"
    echo "  gcloud auth login"
    exit 1
  fi

  GCLOUD_TOKEN=""
  if command -v timeout >/dev/null 2>&1; then
    GCLOUD_TOKEN="$(timeout 25s gcloud auth print-access-token 2>/dev/null || true)"
  else
    GCLOUD_TOKEN="$(gcloud auth print-access-token 2>/dev/null || true)"
  fi
  if [[ -n "${GCLOUD_TOKEN}" ]]; then
    export GOOGLE_OAUTH_ACCESS_TOKEN="${GCLOUD_TOKEN}"
    log "Google OAuth token loaded."
  else
    echo "ERROR: Could not fetch Google OAuth token from gcloud."
    echo "Run these once in terminal:"
    echo "  gcloud auth login"
    echo "  gcloud auth application-default login"
    echo "Then run this script again."
    exit 1
  fi
fi

mkdir -p .local

log "Resuming TMDB vector upload..."
log "Repo root: ${REPO_ROOT}"
log "Project: ${PROJECT}"
log "Collection: ${COLLECTION}"
log "Batch size: ${BATCH_SIZE}"
log "Commit size: ${COMMIT_SIZE}"
log "Checkpoint: ${CHECKPOINT_FILE}"
log "Log file: ${LOG_FILE}"
log "Starting uploader..."

python3 -u scripts/upload_tmdb_openrouter_vectors_to_firestore.py \
  --project "${PROJECT}" \
  --collection "${COLLECTION}" \
  --batch-size "${BATCH_SIZE}" \
  --commit-size "${COMMIT_SIZE}" \
  --resume \
  --skip-existing \
  --checkpoint-file "${CHECKPOINT_FILE}" \
  --log-file "${LOG_FILE}"
