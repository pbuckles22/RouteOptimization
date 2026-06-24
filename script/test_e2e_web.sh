#!/usr/bin/env bash
# Tier 2: Web E2E integration tests (Chrome). Runs on Windows/Mac/Linux — no iOS simulator.
# Uses mocked APIs in integration_test/ — no places_proxy or live keys required.
# See TEST_PLAN.md
set -e
cd "$(dirname "$0")/.."
flutter test integration_test/ -d chrome --reporter expanded "$@"
