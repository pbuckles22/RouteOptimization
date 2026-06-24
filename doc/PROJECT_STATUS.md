# Project status — RouteWise

**Human-readable current state.** Keep in sync with [AGENT_HANDOFF.md](../AGENT_HANDOFF.md) → *Current state* when milestones ship.

**Last updated:** 2026-06-24

---

## Summary

**Route Optimization (RouteWise)** — Flutter **iOS app** for multi-stop route search, optimization, and Google Maps handoff. Flutter Web + `tool/places_proxy.dart` are **dev-only** for browser testing (see [PM_PLAN.md](../PM_PLAN.md) → Platform strategy).

**Bootstrapped from:** [FlutterAgenticTemplate](https://github.com/pbuckles22/FlutterAgenticTemplate). **Shared skills upstream:** [AgenticTemplate](https://github.com/pbuckles22/AgenticTemplate).

---

## Active branch

| Branch | Role |
|--------|------|
| **`main`** | Integration branch — RouteWise app + agentic docs (post Epic 0 merge) |

Feature branches: `feature/<epic-story-topic>` per [github-feature-workflow](../.cursor/skills/github-feature-workflow/SKILL.md).

---

## Completed

### Epic 0 — Route core ✅

See [doc/plan/epic-0-route-core.md](plan/epic-0-route-core.md).

- RouteWise dashboard: search, stop list, optimize, Google Maps launch
- Services: Search, Optimization (Mapbox `driving`), Navigation
- AppConfig + `.env.example`; Places proxy for **web dev only**
- Tier 1: 20 tests green
- Mapbox optimize fix (`destination=last`)
- Agentic alignment: CONTRIBUTING, PROJECT_STATUS, epic docs, TEST_PLAN tiers

---

## Next up

### Epic 1 — E2E automation & iOS path

See [doc/plan/epic-1-e2e-and-ios.md](plan/epic-1-e2e-and-ios.md).

1. **E1-S1** — Tier 2 web E2E happy path (mocked APIs)
2. **E1-S2** — iOS device location for search bias
3. **E1-S3** — Tier 3 iOS integration tests
4. **E1-S4** — Mapbox `driving-traffic` profile

---

## Reading order for contributors

See [CONTRIBUTING.md](../CONTRIBUTING.md).
