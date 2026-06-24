---
name: tester
description: Black-box tests, test-first for core logic, and continuous test runs. Use when adding or changing tests or app logic. Run flutter test after changes; keep suite green.
---

# Tester — Project

Use this skill when writing or running tests, or when touching app logic or new behavior. **First action when adding new behavior:** Read this skill and [TEST_TDD.md](../TEST_TDD.md), then write a failing test. Keeps tests behavioral and the suite green.

---

## Role

- **Black-box tests:** Assert on **behavior** (public API: inputs and outputs). Do not depend on implementation details.
- **Test-first:** For each new behavior, **write a failing test before writing production code**. See TEST_TDD.md.
- **TDD loop:** (1) Write test → run `flutter test` → **red**. (2) Write code → **green**. (3) Add Tier 2 if runnable on device. (4) Document if needed.
- **Integration tests:** For behavior that runs on device, add tests in `integration_test/` and run with `./script/test_integration.sh <device_id>`. See TEST_PLAN.md.
- **Continuous:** Run `flutter test` after each small step. Keep the suite green.

## Server lifecycle (web harness)

**Do not** leave `run_web.sh` running in the background for automated tests. Scripts own start/stop:

| Goal | Command | Servers |
|------|---------|---------|
| Tier 1 logic | `bash script/test.sh` | none |
| Tier 2 browser E2E | `bash script/test_e2e_web.sh` | Playwright starts/stops web on **8080** (`run_web_e2e.sh`). Places + Mapbox **mocked in browser** — no `places_proxy` process. |
| Tier 2 after app changes | `E2E_FRESH_SERVER=1 bash script/test_e2e_web.sh` | Rebuilds web bundle, then same as above |
| Tier 3 iOS | `bash script/test_integration.sh` | iOS simulator only |
| Manual dev / Tier 4 live | `bash script/run_dev_harness.sh` | Starts **places proxy (8765)** + **Flutter web (8080)**; Ctrl+C stops both |

For manual browser testing with real search, use `run_dev_harness.sh` (needs `.env` with `MAPS_API_KEY`). For merge-ready automation, use Tier 2 — deterministic mocks, no keys required.

## Source of truth

- **What to test:** TEST_TDD.md.
- **Test plan (two tiers):** TEST_PLAN.md.
