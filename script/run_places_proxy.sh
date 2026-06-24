#!/usr/bin/env bash
# Dev-only Places CORS proxy (127.0.0.1:8765). Requires MAPS_API_KEY in .env or env.
set -e
cd "$(dirname "$0")/.."

if [ -f .env ]; then
  set -a
  # shellcheck disable=SC1091
  . ./.env
  set +a
fi

exec dart run tool/places_proxy.dart
