#!/usr/bin/env bash
# Tier 2: Playwright browser E2E (Chrome / Edge). Not Flutter integration_test.
#
# Playwright starts and stops the web app server (8080) automatically via
# playwright.config.ts → script/run_web_e2e.sh. Do not run run_web.sh separately.
#
# Places proxy (8765) is mocked in the browser for deterministic CI. For live
# search while developing, use: bash script/run_dev_harness.sh
#
# After app code changes, force a rebuild:
#   E2E_FRESH_SERVER=1 bash script/test_e2e_web.sh
#
# Usage:
#   bash script/test_e2e_web.sh
#   PW_CHANNEL=msedge bash script/test_e2e_web.sh   # Microsoft Edge
#   PW_CHANNEL=chrome bash script/test_e2e_web.sh # Google Chrome
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT/e2e/playwright"

if [ ! -d node_modules ]; then
  npm install
  npx playwright install chromium
fi

npm test
