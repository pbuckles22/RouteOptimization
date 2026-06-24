# TEST_TDD — Project

## How to test

- **Black-box:** Assert on behavior (public API: inputs and outputs). Do not depend on implementation details. See [tester/SKILL.md](tester/SKILL.md).
- **Continuous:** Run `flutter test` after adding or changing logic or tests; keep the suite green.
- **Hybrid (TEST_PLAN.md):** **Tier 1** — `flutter test` (headless). **Tier 2** — `bash script/test_e2e_web.sh` (Playwright + auto web server). **Tier 3** — `bash script/test_integration.sh` (iOS simulator). Run the tiers that match your change.

## Server lifecycle

- **Tier 2:** Playwright starts and stops the web app on port 8080. Do not manually run `run_web.sh` for E2E. After Dart/UI edits: `E2E_FRESH_SERVER=1 bash script/test_e2e_web.sh`.
- **Manual / live search:** `bash script/run_dev_harness.sh` starts places proxy (8765) + web (8080); stop with Ctrl+C.

## Test-first (mandatory for new behavior)

**Before writing production code for new behavior:** Read this file and [tester/SKILL.md](tester/SKILL.md), then write a failing test.

1. **Write test** — Add a black-box test. Run `flutter test` → **red**.
2. **Write code** — Implement until **green**.
3. **Tier 2 if runnable on device** — Add integration test(s) and run on device/simulator.
4. **Document** — Update AGENT_HANDOFF or docs if contract/scope changed.

Never leave failing tests in the tree.
