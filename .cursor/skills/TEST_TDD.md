# TEST_TDD — Project

## How to test

- **Black-box:** Assert on behavior (public API: inputs and outputs). Do not depend on implementation details. See [tester/SKILL.md](tester/SKILL.md).
- **Continuous:** Run `flutter test` after adding or changing logic or tests; keep the suite green.
- **Hybrid (TEST_PLAN.md):** **Tier 1** — `flutter test` (headless). **Tier 2** — `flutter test integration_test/ -d <device_id>`. Run both when validating.

## Test-first (mandatory for new behavior)

**Before writing production code for new behavior:** Read this file and [tester/SKILL.md](tester/SKILL.md), then write a failing test.

1. **Write test** — Add a black-box test. Run `flutter test` → **red**.
2. **Write code** — Implement until **green**.
3. **Tier 2 if runnable on device** — Add integration test(s) and run on device/simulator.
4. **Document** — Update AGENT_HANDOFF or docs if contract/scope changed.

Never leave failing tests in the tree.
