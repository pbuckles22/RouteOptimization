# Test plan (TEST_PLAN.md)

**Ship target:** iOS app. **Test efficiently:** automate as much as possible in headless + web E2E; use the iOS simulator only where native behavior differs.

**Default device ID:** Set in `script/test_integration.sh` as `DEFAULT_DEVICE_ID`, or pass as first argument. Get IDs with `flutter devices`.

---

## Strategy (read first)

| Question | Answer |
|----------|--------|
| Why test on web if we ship iOS? | **Speed and access.** Full UI E2E on Chrome runs on Windows/Mac/Linux without a simulator. Same Dart UI and providers; only platform adapters differ (proxy vs direct API, browser vs CoreLocation GPS). |
| Do we need headless iOS? | **No.** Flutter has no headless iOS integration runner. **Tier 1** already tests logic headlessly. **Tier 3** uses a simulator (automatable on macOS CI, not on Windows). |
| What must run on iOS? | Device GPS bias, direct Google Places (no proxy), `url_launcher` → Google Maps app, iOS layout/safe area. |
| What can stay on web E2E? | Search → pick results → build stop list → optimize → enable Launch button; error states; layout regressions. Use **mocked HTTP**, not live API keys, in CI. |
| Manual smoke? | Optional **Tier 4** with real keys + proxy before release—not in every agent loop. |

**Agent / dev loop:** Tier 1 after every change → Tier 2 web E2E before merge → Tier 3 iOS when touching native paths or pre-release.

---

## Tier 1: Headless (unit + widget + service)

**Runs:** anywhere (VM, no browser, no simulator). **Time:** ~seconds.

```bash
flutter test --reporter expanded
# Or: bash script/test.sh
# Coverage: bash script/test.sh --coverage
```

**Covers today (20 tests):** AppConfig, models, RouteProvider, SearchService / OptimizationService / NavigationService (mock HTTP), dashboard widget smoke, narrow-layout overflow.

**Rules:** Black-box; mock all network. TDD for new behavior (see TEST_TDD.md). Must stay green on every commit.

---

## Tier 2: Playwright browser E2E (Chrome / Edge)

**Runs:** real browser via [Playwright](https://playwright.dev/) against `http://localhost:8080`. **Not** Flutter `integration_test` (web is unsupported). **Works on Windows and Mac.**

```bash
bash script/test_e2e_web.sh
# Optional: PW_CHANNEL=msedge | chrome
```

**How it works:**

- Playwright **starts and stops** the app (`script/run_web_e2e.sh` → static build + `http.server` on 8080). No manual `run_web.sh` for E2E.
- After app code changes, rebuild: `E2E_FRESH_SERVER=1 bash script/test_e2e_web.sh`
- Tests run in **Chromium** (default), **Chrome**, or **Edge** (`PW_CHANNEL`)
- Network to Places proxy (`127.0.0.1:8765`) and Mapbox is **mocked in the browser** — no `places_proxy` process, no live API keys (CI-safe)
- **Manual live search:** `bash script/run_dev_harness.sh` — starts real places proxy + Flutter web; stop with Ctrl+C

**Also:** `test/e2e/route_flow_test.dart` — fast headless UI flow (same scenario, VM). Run via `flutter test test/e2e/`. Use Playwright for true browser validation.

**iOS:** `integration_test/route_flow_test.dart` runs on simulator via Tier 3.

**Planned scenarios (implement in order):**

1. **Happy path** — type in search → mocked results appear → tap result → stop added with Start chip → add second stop → Optimize → success state + distance → Launch enabled.
2. **Optimize error** — mock Mapbox non-Ok response → user-visible error (not generic swallow).
3. **Origin locked** — first stop cannot be deleted; optimize keeps index 0 fixed (`destination=last`).
4. **Layout** — narrow viewport + search dropdown (regression for RenderFlex overflow).

**Implementation notes:**

- Add test harness entry: `RouteWiseApp` (or test-only `main`) accepts optional `RouteProvider` factory / `searchOverride` + `optimizeOverride` (already on `RouteProvider`).
- Do **not** depend on live Google or Mapbox in Tier 2.
- `tool/places_proxy.dart` is **not** used in Tier 2 (mocks replace network).

**When to run:** Before merge; in CI on every PR (Linux/Windows runners OK).

---

## Tier 3: iOS integration (simulator / device)

**Runs:** macOS with Xcode + iOS Simulator (or physical device). **Not headless** — simulator process required.

```bash
bash script/test_integration.sh <device_id>
# Example: flutter test integration_test/ -d "iPhone 17 Pro Max"
```

**Purpose:** Validate **iOS-only** paths not covered by web E2E.

**Planned scenarios:**

1. App launches on iOS; dashboard visible.
2. Search uses **direct Google Places** backend (`SearchBackend.googlePlaces`), not proxy — mock HTTP at client layer.
3. Device location bias (once `geolocator` or equivalent is wired) — mock fixed coordinates; assert proximity passed to search.
4. `Launch in Google Maps` invokes `url_launcher` (verify call / mock platform channel).

**When to run:** After native/location changes; pre-release; macOS CI job (optional if Tier 1 + 2 are green and change is UI-only).

**Windows dev:** Skip Tier 3 locally; rely on Tier 1 + 2. Run Tier 3 on Mac before release or in CI.

---

## Tier 4: Live API smoke (manual / scheduled)

**Not automated in CI** (requires secrets, quota, flakiness).

```bash
# Dev-only harness — real keys in .env
dart run tool/places_proxy.dart          # web search only
bash script/run_web.sh                   # or flutter run -d chrome / iOS device
```

**Checklist (human or scheduled job with secrets):**

- [ ] Search "2314" with location allowed → local address ranks high
- [ ] 5-stop route optimizes without error
- [ ] Launch opens Google Maps with correct origin / waypoints / destination

**When:** Pre-release, or after API/key changes.

---

## CI matrix (target)

| Job | Tiers | Runner |
|-----|-------|--------|
| `test` | Tier 1 | any |
| `e2e-web` | Tier 2 | ubuntu / windows (`-d chrome`) |
| `e2e-ios` | Tier 3 | macos + simulator |
| `smoke-live` | Tier 4 | manual / scheduled with secrets |

---

## Golden tests

If added, use 2% pixel threshold (`test/flutter_test_config.dart`, `integration_test/flutter_test_config.dart`).

Update goldens: `flutter test integration_test/golden_test.dart -d <id> --update-goldens`

---

## Current status

| Tier | Status |
|------|--------|
| 1 | ✅ 20 tests green |
| 2 | ✅ Playwright `e2e/playwright/tests/route-flow.spec.ts` + fast `test/e2e/` |
| 3 | 🔲 `app_test.dart` only checks title; expand for iOS paths |
| 4 | 🔲 Manual checklist above |

**Next implementation:** Tier 2 web E2E happy path with mocked search/optimize (highest ROI for automation on Windows and Mac).
