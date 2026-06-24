#!/usr/bin/env bash
# Build Flutter web and serve static files for Playwright E2E (dummy keys OK — tests mock network).
set -e
cd "$(dirname "$0")/.."
PORT="${PORT:-8080}"
export MAPS_API_KEY="${MAPS_API_KEY:-test-maps-key-for-e2e}"
export MAPBOX_ACCESS_TOKEN="${MAPBOX_ACCESS_TOKEN:-test-mapbox-token-for-e2e}"

flutter build web \
  --dart-define=MAPS_API_KEY="$MAPS_API_KEY" \
  --dart-define=MAPBOX_ACCESS_TOKEN="$MAPBOX_ACCESS_TOKEN" \
  --dart-define=E2E_SEMANTICS=true

cd build/web
exec python3 -m http.server "$PORT"
