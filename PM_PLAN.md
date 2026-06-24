# PM_PLAN — RouteWise

## Platform strategy (read before every code change)

**Ship target:** **iOS app** (Flutter on iOS). This is not a web product.

**Dev-only harness:** Flutter Web and `tool/places_proxy.dart` exist **only** to exercise map/search/optimize flows in a browser during development. They are not the product architecture.

| Layer | iOS (canonical) | Web (dev testing only) |
|-------|-----------------|-------------------------|
| Search | Google Places API direct (`SearchBackend.googlePlaces`) | Local CORS proxy (`dart run tool/places_proxy.dart`) because browsers block direct Google calls |
| Location bias | Device GPS (`geolocator` / `search_proximity_io.dart`) | Browser geolocation (`search_proximity_web.dart`) |
| Optimize | Mapbox Optimization API (HTTP from app) | Same |
| Navigation | `url_launcher` → Google Maps app | `url_launcher` → new browser tab |

**Agent rule:** Before implementing or extending behavior, ask: *“Is this for the iOS app, or only for web dev testing?”* Do not add web-only features, UX, or workarounds unless they are explicitly scoped as dev harness—or they also serve iOS.

**Spec note:** `doc/requirements/route-wise-phase1-web-prototype.md` describes early prototype scope; **PM_PLAN platform strategy supersedes** any “web-first” wording in older docs.

**Epics:** [doc/plan/README.md](doc/plan/README.md)

---

## Phase 0 — Scaffold & agentic layer ✅

- Flutter project, Cursor rules/skills, test setup, handoff protocol.

## Phase 1 — Route core (Epic 0) ✅

**Epic:** [doc/plan/epic-0-route-core.md](doc/plan/epic-0-route-core.md)

- [x] AppConfig, RouteLocation, services (search, optimize, navigation)
- [x] RouteProvider + split-pane dashboard UI
- [x] Tier 1 tests (20 green)
- [x] Mapbox optimize fix (`destination=last`)
- [x] Agentic alignment (CONTRIBUTING, PROJECT_STATUS, epic docs)
- [x] Merged to `main`

## Phase 2 — E2E automation & iOS path (Epic 1) — **active**

**Epic:** [doc/plan/epic-1-e2e-and-ios.md](doc/plan/epic-1-e2e-and-ios.md)

- [x] **E1-S1** Tier 2 browser E2E (`e2e/playwright/`, `test/e2e/`, `bash script/test_e2e_web.sh`)
- [x] **E1-S2** iOS device location for search bias
- [ ] **E1-S3** Tier 3 iOS integration tests
- [ ] **E1-S4** Mapbox `driving-traffic` profile

## Phase 3 — Polish & release prep

- [ ] Requirements doc milestone checkboxes synced
- [ ] PM_PLAN / PROJECT_STATUS kept in sync after each epic

---

## Dev testing (not product)

```bash
dart run tool/places_proxy.dart          # terminal 1 — dev only
bash script/run_web.sh                   # terminal 2 — optional
```

Keep this file in sync with **doc/PROJECT_STATUS.md** and AGENT_HANDOFF “Current state”.
