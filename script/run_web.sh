#!/usr/bin/env bash
# Run the app on a local web server (no browser auto-launch).
# Usage: ./script/run_web.sh [port]
# Default port: 8080. Open the printed URL in any browser.
set -e
cd "$(dirname "$0")/.."
PORT="${1:-8080}"
flutter run -d web-server --web-port="$PORT" --web-hostname=localhost
