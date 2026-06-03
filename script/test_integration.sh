#!/usr/bin/env bash
# Run integration tests on simulator. Set DEFAULT_DEVICE_ID below or pass as first arg.
# Usage: ./script/test_integration.sh [device_id]
#   With no arg: uses default iOS Simulator.
#   To update goldens: flutter test integration_test/golden_test.dart -d <id> --update-goldens
set -e
cd "$(dirname "$0")/.."
DEFAULT_DEVICE_ID=""
DEVICE_ID="${1:-$DEFAULT_DEVICE_ID}"
if [ -z "$DEVICE_ID" ]; then
  echo "No device ID. Run: flutter devices"
  echo "Then: ./script/test_integration.sh <device_id>"
  echo "Or set DEFAULT_DEVICE_ID in this script."
  exit 1
fi
flutter test integration_test/app_test.dart -d "$DEVICE_ID" --reporter expanded 2>&1 | awk '
  /^[0-9]+:[0-9]+ \+[0-9]+: / {
    name = $0
    sub(/^[0-9]+:[0-9]+ \+[0-9]+: /, "", name)
    if (name != prev) { print; prev = name }
    next
  }
  { print }
'
