#!/usr/bin/env bash
# Manual dev: start places proxy + Flutter web. Ctrl+C stops both.
# Usage: bash script/run_dev_harness.sh [web-port]
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
PORT="${1:-8080}"
PROXY_PORT="${PLACES_PROXY_PORT:-8765}"

cleanup() {
  if [ -n "${PROXY_PID:-}" ]; then
    kill "$PROXY_PID" 2>/dev/null || true
    wait "$PROXY_PID" 2>/dev/null || true
  fi
}
trap cleanup EXIT INT TERM

bash script/run_places_proxy.sh &
PROXY_PID=$!

echo "Waiting for places proxy on http://127.0.0.1:${PROXY_PORT}/health …"
for _ in $(seq 1 50); do
  if curl -sf "http://127.0.0.1:${PROXY_PORT}/health" >/dev/null 2>&1; then
    echo "Places proxy ready."
    break
  fi
  sleep 0.2
done

exec bash script/run_web.sh "$PORT"
