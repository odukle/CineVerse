#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

CSV_PATH="${CSV_PATH:-TMDB_movie_dataset.csv}"
MAX_RPS="${MAX_RPS:-10}"
LOG_LEVEL="${LOG_LEVEL:-INFO}"
CHECKPOINT_FILE="${CHECKPOINT_FILE:-.local/tmdb_incremental_movies_checkpoint.json}"
AUTO_ZILLIZ_UPLOAD="${AUTO_ZILLIZ_UPLOAD:-1}"
DELTA_DIR="${DELTA_DIR:-.local/dataset_deltas}"

print_help() {
  cat <<EOF
Usage:
  scripts/run_tmdb_incremental_movies.sh [--dry-run] [--no-zilliz-upload] [extra args...]

Defaults:
  CSV_PATH=$CSV_PATH
  MAX_RPS=$MAX_RPS
  CHECKPOINT_FILE=$CHECKPOINT_FILE
  AUTO_ZILLIZ_UPLOAD=$AUTO_ZILLIZ_UPLOAD
  DELTA_DIR=$DELTA_DIR

Examples:
  scripts/run_tmdb_incremental_movies.sh
  scripts/run_tmdb_incremental_movies.sh --dry-run
  scripts/run_tmdb_incremental_movies.sh --no-zilliz-upload
  scripts/run_tmdb_incremental_movies.sh --start-date 2026-05-20 --end-date 2026-05-28
EOF
}

DRY_RUN=0
EXTRA_ARGS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      print_help
      exit 0
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    --no-zilliz-upload)
      AUTO_ZILLIZ_UPLOAD=0
      shift
      ;;
    *)
      EXTRA_ARGS+=("$1")
      shift
      ;;
  esac
done

mkdir -p .local

CMD=(
  python3 scripts/tmdb_incremental_movies.py
  --csv "$CSV_PATH"
  --max-rps "$MAX_RPS"
  --checkpoint-file "$CHECKPOINT_FILE"
  --log-level "$LOG_LEVEL"
)

if [[ "$DRY_RUN" -eq 0 ]]; then
  CMD+=(--in-place)
fi

if [[ "${#EXTRA_ARGS[@]}" -gt 0 ]]; then
  CMD+=("${EXTRA_ARGS[@]}")
fi

echo "Running movie incremental wrapper..."
echo "Command: ${CMD[*]}"
"${CMD[@]}"

if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "Dry run complete. Skipping delta generation and Zilliz upload."
  exit 0
fi

if [[ "$AUTO_ZILLIZ_UPLOAD" != "1" ]]; then
  echo "Incremental CSV update complete. Skipping Zilliz upload because AUTO_ZILLIZ_UPLOAD=$AUTO_ZILLIZ_UPLOAD."
  exit 0
fi

CHANGED_IDS="$(
  python3 - "$CHECKPOINT_FILE" <<'PY'
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
if not path.exists():
    print("")
    raise SystemExit
try:
    payload = json.loads(path.read_text(encoding="utf-8"))
except Exception:
    print("")
    raise SystemExit
print(payload.get("changed_ids", ""))
PY
)"

if [[ "${CHANGED_IDS:-}" == "0" ]]; then
  echo "No changed movie IDs found. Skipping delta generation and Zilliz upload."
  exit 0
fi

BACKUP_CSV="$(
  python3 - "$CSV_PATH" <<'PY'
from pathlib import Path
import sys
print(Path(sys.argv[1]).with_suffix(".pre_incremental.bak.csv"))
PY
)"

if [[ ! -f "$BACKUP_CSV" ]]; then
  echo "Error: expected pre-incremental backup not found: $BACKUP_CSV"
  echo "Cannot generate a safe Zilliz delta."
  exit 1
fi

echo "Generating changed-row delta for Zilliz..."
DELTA_LOG="$(mktemp)"
python3 scripts/generate_tmdb_backfill_delta.py \
  --before-csv "$BACKUP_CSV" \
  --after-csv "$CSV_PATH" \
  --delta-dir "$DELTA_DIR" | tee "$DELTA_LOG"

DELTA_CSV="$(awk -F'Output CSV: ' '/Output CSV: / {print $2}' "$DELTA_LOG" | tail -n 1)"
CHANGED_ROWS="$(awk -F': ' '/Changed rows written: / {print $2}' "$DELTA_LOG" | tail -n 1 | tr -d ',')"
rm -f "$DELTA_LOG"

if [[ -z "$DELTA_CSV" || ! -f "$DELTA_CSV" ]]; then
  echo "Error: delta CSV was not created."
  exit 1
fi

if [[ "${CHANGED_ROWS:-0}" == "0" ]]; then
  echo "No changed rows in delta. Skipping Zilliz upload."
  exit 0
fi

echo "Uploading changed rows to Zilliz..."
echo "Delta CSV: $DELTA_CSV"
scripts/resume_zilliz_upload.sh --latest-delta --delta-dir "$DELTA_DIR"
