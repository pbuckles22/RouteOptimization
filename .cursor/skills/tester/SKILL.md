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

## Source of truth

- **What to test:** TEST_TDD.md.
- **Test plan (two tiers):** TEST_PLAN.md.
