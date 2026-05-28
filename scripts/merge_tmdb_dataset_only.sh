#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

BASE_CSV="${BASE_CSV:-TMDB_movie_dataset.csv}"
NEW_CSV="${NEW_CSV:-new_dataset.csv}"
MERGE_STRATEGY="${MERGE_STRATEGY:-fill-missing}"
ENABLE_LLM_COLUMN_MAP="${ENABLE_LLM_COLUMN_MAP:-0}"
DRY_RUN="${DRY_RUN:-0}"
INSERT_ONLY="${INSERT_ONLY:-0}"

print_help() {
  cat <<'EOF'
Usage:
  scripts/merge_tmdb_dataset_only.sh [options]

Options:
  --base-csv <path>        Base canonical CSV (default: TMDB_movie_dataset.csv)
  --new-csv <path>         New incoming CSV (default: new_dataset.csv)
  --merge-strategy <mode>  fill-missing | prefer-existing | prefer-new (default: fill-missing)
  --enable-llm-column-map  Enable LLM-assisted header mapping
  --insert-only            Only append new IDs; skip updates for existing IDs
  --dry-run                No file changes
  -h, --help               Show help

Examples:
  scripts/merge_tmdb_dataset_only.sh --dry-run
  scripts/merge_tmdb_dataset_only.sh --enable-llm-column-map
  scripts/merge_tmdb_dataset_only.sh --insert-only
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --base-csv)
      BASE_CSV="$2"
      shift 2
      ;;
    --new-csv)
      NEW_CSV="$2"
      shift 2
      ;;
    --merge-strategy)
      MERGE_STRATEGY="$2"
      shift 2
      ;;
    --enable-llm-column-map)
      ENABLE_LLM_COLUMN_MAP="1"
      shift
      ;;
    --insert-only)
      INSERT_ONLY="1"
      shift
      ;;
    --dry-run)
      DRY_RUN="1"
      shift
      ;;
    -h|--help)
      print_help
      exit 0
      ;;
    *)
      echo "Unknown argument: $1"
      echo "Use --help for usage."
      exit 1
      ;;
  esac
done

if [[ ! -f "$BASE_CSV" ]]; then
  echo "Error: base CSV not found: $BASE_CSV"
  exit 1
fi
if [[ ! -f "$NEW_CSV" ]]; then
  echo "Error: new CSV not found: $NEW_CSV"
  exit 1
fi

CMD=(
  python3
  scripts/update_tmdb_dataset_and_vectors.py
  --base-csv "$BASE_CSV"
  --new-csv "$NEW_CSV"
  --merge-strategy "$MERGE_STRATEGY"
  --skip-vector-upsert
)

if [[ "$ENABLE_LLM_COLUMN_MAP" == "1" ]]; then
  CMD+=(--enable-llm-column-map)
fi
if [[ "$INSERT_ONLY" == "1" ]]; then
  CMD+=(--insert-only)
fi
if [[ "$DRY_RUN" == "1" ]]; then
  CMD+=(--dry-run)
else
  CMD+=(--in-place)
fi

echo "Running merge-only update..."
echo "Base CSV: $BASE_CSV"
echo "New CSV: $NEW_CSV"
echo "Merge strategy: $MERGE_STRATEGY"
echo "LLM column map: $ENABLE_LLM_COLUMN_MAP"
echo "Insert only: $INSERT_ONLY"
echo "Dry run: $DRY_RUN"
echo "Command: ${CMD[*]}"

"${CMD[@]}"

echo "Merge-only command finished."
