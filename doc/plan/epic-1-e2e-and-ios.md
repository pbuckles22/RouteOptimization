# Epic 1 — E2E automation & iOS path

**Branch:** `feature/epic-1-e2e-ios`  
**Status:** 🔲 In progress (E1-S1 done)

## Goal

Automate full UI flows efficiently (web E2E on Windows/Mac); implement iOS-native paths for location and integration testing. Ship target remains iOS.

See [TEST_PLAN.md](../../TEST_PLAN.md) for tier definitions.

---

## Stories

### E1-S1 — Tier 2 web E2E happy path ✅

**Acceptance criteria:**

- [x] `e2e/playwright/tests/route-flow.spec.ts` — Playwright in Chrome/Edge; mocks proxy + Mapbox
- [x] `test/e2e/route_flow_test.dart` — fast headless duplicate for CI without Node
- [x] Flow: type search → pick result → add stops → optimize → success + Launch enabled
- [x] `bash script/test_e2e_web.sh` runs Playwright (starts web server automatically)
- [x] No live API keys or `places_proxy` process required

**Validation:** `bash script/test_e2e_web.sh`

---

### E1-S2 — iOS device location for search bias ✅

**Acceptance criteria:**

- [x] Replace `search_proximity_stub` no-op on iOS with device GPS (e.g. `geolocator`)
- [x] Proximity passed to `SearchService.search` on iOS
- [x] Tier 1 test with injected coordinates; manual verify on simulator optional

**Validation:** Tier 1 green; search ranks local results when location allowed on device

---

### E1-S3 — Tier 3 iOS integration tests 🔲

**Acceptance criteria:**

- [ ] Expand `integration_test/` for iOS simulator
- [ ] Verify `SearchBackend.googlePlaces` path (no proxy)
- [ ] `url_launcher` handoff testable (mock or platform fake)
- [ ] `DEFAULT_DEVICE_ID` set in `script/test_integration.sh` or documented

**Validation:** `bash script/test_integration.sh <device_id>`

---

### E1-S4 — Traffic-aware optimize 🔲

**Acceptance criteria:**

- [ ] Mapbox profile `driving-traffic` (per requirements spec)
- [ ] Tier 1 test updated for profile URL
- [ ] Manual smoke: optimize returns sensible order with traffic profile

**Validation:** Tier 1 green + Tier 4 smoke optional

---

## Decisions (fixed — do not re-litigate)

- Web E2E uses **mocked HTTP**, not live Google/Mapbox
- Web + proxy remain **dev harness only**, not product architecture
- Tier 3 required for native-only changes; Tier 2 sufficient for UI/logic before merge
