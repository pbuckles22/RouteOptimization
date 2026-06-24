# Epic 0 — Route core

**Branch:** `feature/epic-0-s0-1-pubspec-deps` (merged to `main`)  
**Status:** ✅ Complete

## Goal

Playable RouteWise prototype: search places, build a stop list, optimize order, launch in Google Maps. Shared Dart services work on iOS (canonical) and web (dev harness).

---

## Stories

### E0-S1 — Project setup & AppConfig ✅

**Branch slice:** `feature/epic-0-s0-1-pubspec-deps` (initial)

**Acceptance criteria:**

- [x] `pubspec.yaml` includes `http`, `uuid`, `url_launcher`, `provider`
- [x] `AppConfig` loads `MAPS_API_KEY` and `MAPBOX_ACCESS_TOKEN` via `--dart-define`; throws if empty
- [x] `.env.example` + `.env` gitignored
- [x] Tier 1 tests for AppConfig

---

### E0-S2 — Service layer ✅

**Acceptance criteria:**

- [x] `SearchService` — Google Places (direct on iOS; proxy on web dev)
- [x] `OptimizationService` — Mapbox Optimization API, `source=first`, `destination=last`, `roundtrip=false`
- [x] `NavigationService` — Google Maps URL with origin, destination, waypoints
- [x] Tier 1 service tests with mock HTTP

---

### E0-S3 — State & UI ✅

**Acceptance criteria:**

- [x] `RouteProvider` — `AppState`, stops list, search results, origin lock, dedupe
- [x] Split-pane dashboard — search, stops, optimize, launch buttons
- [x] Tier 1 provider + widget tests

---

### E0-S4 — Dev harness & fixes ✅

**Acceptance criteria:**

- [x] `tool/places_proxy.dart` — dev-only CORS proxy for web search testing
- [x] `script/run_web.sh` loads `.env` and passes `--dart-define`
- [x] Mapbox `destination=any` + `roundtrip=false` bug fixed → `destination=last`
- [x] Search dropdown layout overflow fixed (narrow viewport widget test)
- [x] iOS-first platform strategy documented in PM_PLAN

---

## Out of scope (Epic 1+)

- Tier 2 web E2E automation
- iOS CoreLocation / geolocator
- Mapbox `driving-traffic`
- Requirements doc milestone checkboxes sync
