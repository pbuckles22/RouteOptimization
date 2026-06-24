#!/usr/bin/env bash
# Run Tier 1 tests with full test names visible (--reporter expanded).
# See TEST_PLAN.md for Tier 2 (integration tests on device).
set -e
cd "$(dirname "$0")/.."
flutter test --reporter expanded "$@" 2>&1 | awk '
  /^[0-9]+:[0-9]+ \+[0-9]+:.*\.dart: / {
    name = $0
    sub(/^[0-9]+:[0-9]+ \+[0-9]+:.*\.dart: /, "", name)
    if (name != prev) { print; prev = name }
    next
  }
  { print }
'
