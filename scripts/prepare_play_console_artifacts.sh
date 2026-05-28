#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

ASSET_DIR="$ROOT_DIR/play_store_assets"
mkdir -p "$ASSET_DIR"/{screenshots/android-phone,graphics,release,metadata}

echo "[1/4] Validating Android release signing config..."
if [[ ! -f android/key.properties ]]; then
  echo "Missing android/key.properties (release keystore config)."
  exit 1
fi
if ! rg -n "create\\(\"release\"\\)" android/app/build.gradle.kts >/dev/null; then
  echo "Release signing config not found in android/app/build.gradle.kts."
  exit 1
fi

echo "[2/4] Installing dependencies..."
flutter pub get

echo "[3/4] Building release app bundle (AAB)..."
flutter build appbundle \
  --release \
  --dart-define-from-file=config/app_client.public.json \
  --dart-define=TONIGHT_RECOMMENDATIONS_API_URL=https://us-east4-cineverse-flutter-591.cloudfunctions.net/recommendTonight

echo "[4/4] Collecting release artifact..."
cp -f build/app/outputs/bundle/release/app-release.aab "$ASSET_DIR/release/"

echo "Done. Artifact available at: $ASSET_DIR/release/app-release.aab"
