#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PUBSPEC_PATH="$ROOT_DIR/pubspec.yaml"
PUBSPEC_LOCK_PATH="$ROOT_DIR/pubspec.lock"
PUBSPEC_BACKUP_PATH="$ROOT_DIR/.local/build_android_release.pubspec.backup.yaml"
PUBSPEC_LOCK_BACKUP_PATH="$ROOT_DIR/.local/build_android_release.pubspec.backup.lock"
CONFIG_PATH="$ROOT_DIR/config/app_client.public.json"
RELEASE_DIR="$ROOT_DIR/release"
AAB_SOURCE="$ROOT_DIR/build/app/outputs/bundle/release/app-release.aab"
APK_SOURCE="$ROOT_DIR/build/app/outputs/flutter-apk/app-release.apk"
AAB_TARGET="$RELEASE_DIR/cineverse-app-release.aab"
APK_TARGET="$RELEASE_DIR/cineverse-app-release.apk"
GENERATED_REGISTRANT_PATH="$ROOT_DIR/android/app/src/main/java/io/flutter/plugins/GeneratedPluginRegistrant.java"
PLUGINS_DEPENDENCIES_PATH="$ROOT_DIR/.flutter-plugins-dependencies"

log() {
  printf '\n[%s] %s\n' "$(date '+%H:%M:%S')" "$1"
}

fail() {
  printf '\n[ERROR] %s\n' "$1" >&2
  exit 1
}

require_file() {
  local path="$1"
  [[ -f "$path" ]] || fail "Required file not found: $path"
}

require_command() {
  local cmd="$1"
  command -v "$cmd" >/dev/null 2>&1 || fail "Required command not found: $cmd"
}

read_version_line() {
  grep '^version:' "$PUBSPEC_PATH" | head -n 1
}

bump_version_code() {
  local version_line version_name version_code new_version_name new_version_code new_version_line
  version_line="$(read_version_line)"
  [[ -n "$version_line" ]] || fail "Could not find version line in pubspec.yaml"

  version_name="${version_line#version: }"
  version_name="${version_name%%+*}"
  version_code="${version_line##*+}"

  [[ "$version_code" =~ ^[0-9]+$ ]] || fail "Current version code is not numeric: $version_code"

  new_version_name="$(python3 - "$version_name" <<'PY'
import sys

version = sys.argv[1].strip()
parts = version.split(".")
if not parts:
    raise SystemExit("Current version name is empty")
if not parts[-1].isdigit():
    raise SystemExit(f"Last version segment is not numeric: {parts[-1]}")
parts[-1] = str(int(parts[-1]) + 1)
print(".".join(parts))
PY
)"
  new_version_code="$((version_code + 1))"
  new_version_line="version: ${new_version_name}+${new_version_code}"

  python3 - "$PUBSPEC_PATH" "$new_version_line" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
new_line = sys.argv[2]
lines = path.read_text().splitlines()

for index, line in enumerate(lines):
    if line.startswith("version: "):
        lines[index] = new_line
        path.write_text("\n".join(lines) + "\n")
        break
else:
    raise SystemExit("version line not found")
PY

  printf '%s|%s|%s|%s\n' \
    "$version_name" \
    "$new_version_name" \
    "$version_code" \
    "$new_version_code"
}

report_artifact() {
  local path="$1"
  [[ -f "$path" ]] || fail "Artifact missing: $path"
  local size
  size="$(du -h "$path" | awk '{print $1}')"
  printf '  - %s (%s)\n' "$path" "$size"
}

sanitize_generated_plugin_registrant() {
  rm -f "$GENERATED_REGISTRANT_PATH"
}

sanitize_flutter_plugins_dependencies() {
  [[ -f "$PLUGINS_DEPENDENCIES_PATH" ]] || return 0

  python3 - "$PLUGINS_DEPENDENCIES_PATH" <<'PY'
from pathlib import Path
import json
import sys

path = Path(sys.argv[1])
data = json.loads(path.read_text())
blocked = {"flutter_native_splash", "integration_test"}

plugins = data.get("plugins", {})
for platform in ("android",):
    entries = plugins.get(platform)
    if isinstance(entries, list):
        plugins[platform] = [
            entry for entry in entries
            if entry.get("name") not in blocked
        ]

graph = data.get("dependencyGraph")
if isinstance(graph, list):
    data["dependencyGraph"] = [
        entry for entry in graph
        if entry.get("name") not in blocked
    ]

path.write_text(json.dumps(data, separators=(",", ":")))
PY
}

strip_release_only_dev_plugins_from_pubspec() {
  python3 - "$PUBSPEC_PATH" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
lines = path.read_text().splitlines()
out = []
i = 0
while i < len(lines):
    line = lines[i]
    stripped = line.strip()

    if stripped == "integration_test:" and line.startswith("  "):
        i += 1
        while i < len(lines):
            nxt = lines[i]
            if nxt.startswith("    "):
                i += 1
                continue
            break
        continue

    if stripped.startswith("flutter_native_splash:") and not line.startswith("  "):
        i += 1
        while i < len(lines):
            nxt = lines[i]
            if nxt.startswith("  "):
                i += 1
                continue
            break
        continue

    if stripped.startswith("flutter_native_splash:") and line.startswith("  "):
        i += 1
        continue

    out.append(line)
    i += 1

path.write_text("\n".join(out) + "\n")
PY
}

restore_pubspec() {
  if [[ -f "$PUBSPEC_BACKUP_PATH" ]]; then
    cp "$PUBSPEC_BACKUP_PATH" "$PUBSPEC_PATH"
    rm -f "$PUBSPEC_BACKUP_PATH"
  fi
  if [[ -f "$PUBSPEC_LOCK_BACKUP_PATH" ]]; then
    cp "$PUBSPEC_LOCK_BACKUP_PATH" "$PUBSPEC_LOCK_PATH"
    rm -f "$PUBSPEC_LOCK_BACKUP_PATH"
  fi
}

main() {
  require_command flutter
  require_command python3
  require_file "$PUBSPEC_PATH"
  require_file "$CONFIG_PATH"

  cd "$ROOT_DIR"

  log "Bumping Android app version and version code in pubspec.yaml"
  IFS='|' read -r old_version_name new_version_name old_code new_code < <(bump_version_code)
  printf '  Previous: %s+%s\n' "$old_version_name" "$old_code"
  printf '  New:      %s+%s\n' "$new_version_name" "$new_code"

  mkdir -p "$ROOT_DIR/.local"
  cp "$PUBSPEC_PATH" "$PUBSPEC_BACKUP_PATH"
  if [[ -f "$PUBSPEC_LOCK_PATH" ]]; then
    cp "$PUBSPEC_LOCK_PATH" "$PUBSPEC_LOCK_BACKUP_PATH"
  fi
  trap restore_pubspec EXIT

  log "Temporarily stripping dev-only Android plugins from pubspec.yaml"
  strip_release_only_dev_plugins_from_pubspec

  log "Refreshing Flutter package metadata"
  flutter pub get

  log "Sanitizing stale dev-only Android plugin registrations"
  sanitize_flutter_plugins_dependencies
  sanitize_generated_plugin_registrant

  log "Building Android App Bundle (.aab)"
  flutter build appbundle \
    --no-pub \
    --release \
    --dart-define-from-file="$CONFIG_PATH"

  log "Building Android APK (.apk)"
  flutter build apk \
    --no-pub \
    --release \
    --dart-define-from-file="$CONFIG_PATH"

  log "Copying artifacts to release/"
  mkdir -p "$RELEASE_DIR"
  cp "$AAB_SOURCE" "$AAB_TARGET"
  cp "$APK_SOURCE" "$APK_TARGET"

  log "Release artifacts ready"
  report_artifact "$AAB_TARGET"
  report_artifact "$APK_TARGET"

  log "Restoring full development pubspec and package metadata"
  restore_pubspec
  trap - EXIT
  flutter pub get >/dev/null
}

main "$@"
