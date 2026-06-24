#!/usr/bin/env bash
# Run the app on a local web server (no browser auto-launch).
# Usage: ./script/run_web.sh [port]
# Default port: 8080. Open the printed URL in any browser.
set -e
cd "$(dirname "$0")/.."
PORT="${1:-8080}"
shift 2>/dev/null || true

if [ -f .env ]; then
  set -a
  # shellcheck disable=SC1091
  . ./.env
  set +a
fi

EXTRA=()
[ -n "${MAPS_API_KEY:-}" ] && EXTRA+=(--dart-define="MAPS_API_KEY=${MAPS_API_KEY}")
[ -n "${MAPBOX_ACCESS_TOKEN:-}" ] && EXTRA+=(--dart-define="MAPBOX_ACCESS_TOKEN=${MAPBOX_ACCESS_TOKEN}")

flutter run -d web-server --web-port="$PORT" --web-hostname=localhost "${EXTRA[@]}" "$@"
