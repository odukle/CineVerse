#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

OUT_DIR="$ROOT_DIR/play_store_assets/screenshots/android-phone"
mkdir -p "$OUT_DIR"

echo "[1/5] Checking connected Android devices..."
DEVICE_COUNT="$(flutter devices --machine | grep -Ec '"targetPlatform"[[:space:]]*:[[:space:]]*"android-' || true)"
if [[ "$DEVICE_COUNT" -eq 0 ]]; then
  echo "No Android device/emulator connected."
  echo "Connect a device (adb) or start an emulator, then rerun."
  exit 1
fi
DEVICE_ID="$(adb devices | awk 'NR>1 && $2=="device" {print $1; exit}')"
if [[ -z "$DEVICE_ID" ]]; then
  echo "No ADB device in 'device' state."
  exit 1
fi
echo "Using Android device: $DEVICE_ID"

echo "[2/5] Installing dependencies..."
flutter pub get

echo "[3/5] Running screenshot integration test via flutter drive..."
flutter drive \
  --driver=test_driver/play_store_screenshots_driver.dart \
  --target=integration_test/play_store_screenshots_test.dart \
  -d "$DEVICE_ID" \
  --dart-define=SCREENSHOT_DIR="$OUT_DIR" \
  --dart-define-from-file=config/app_client.public.json \
  --dart-define=TONIGHT_RECOMMENDATIONS_API_URL=https://us-east4-cineverse-flutter-591.cloudfunctions.net/recommendTonight

echo "[4/5] Verifying generated screenshots..."
COUNT="$(find "$OUT_DIR" -maxdepth 1 -type f -name '*.png' | wc -l | tr -d ' ')"
if [[ "$COUNT" -eq 0 ]]; then
  echo "No screenshots generated in $OUT_DIR"
  exit 1
fi
echo "Generated $COUNT screenshots."

echo "[5/5] Done."
echo "Screenshots copied to: $OUT_DIR"
