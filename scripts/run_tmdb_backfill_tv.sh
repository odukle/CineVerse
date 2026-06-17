#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

CSV_PATH="${CSV_PATH:-TMDB_tv_dataset.csv}"
MAX_RPS="${MAX_RPS:-10}"
LOG_LEVEL="${LOG_LEVEL:-INFO}"
CHECKPOINT_FILE="${CHECKPOINT_FILE:-.local/tmdb_backfill_tv_checkpoint.json}"
LOOKBACK_DAYS="${LOOKBACK_DAYS:-21}"

print_help() {
  cat <<EOF
Usage:
  scripts/run_tmdb_backfill_tv.sh [--dry-run] [--resume] [extra args...]

Defaults:
  CSV_PATH=$CSV_PATH
  MAX_RPS=$MAX_RPS
  CHECKPOINT_FILE=$CHECKPOINT_FILE
  LOOKBACK_DAYS=$LOOKBACK_DAYS

Examples:
  scripts/run_tmdb_backfill_tv.sh
  scripts/run_tmdb_backfill_tv.sh --resume
  scripts/run_tmdb_backfill_tv.sh --dry-run
  scripts/run_tmdb_backfill_tv.sh --max-ids 25000 --max-rps 8
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
    --resume)
      EXTRA_ARGS+=("--resume")
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
  python3 scripts/tmdb_backfill_tv.py
  --csv "$CSV_PATH"
  --max-rps "$MAX_RPS"
  --checkpoint-file "$CHECKPOINT_FILE"
  --lookback-days "$LOOKBACK_DAYS"
  --log-level "$LOG_LEVEL"
)

if [[ "$DRY_RUN" -eq 0 ]]; then
  CMD+=(--in-place)
fi

if [[ "${#EXTRA_ARGS[@]}" -gt 0 ]]; then
  CMD+=("${EXTRA_ARGS[@]}")
fi

echo "Running TV backfill wrapper..."
echo "Command: ${CMD[*]}"
"${CMD[@]}"
