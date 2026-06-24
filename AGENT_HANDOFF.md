# Agent handoff — Project

## Purpose

This repo is **Route Optimization** (RouteWise): a **Flutter iOS app** with Cursor rules, skills, handoff protocol, and tests. Map/search/optimize logic lives in shared Dart services; **Flutter Web + `tool/places_proxy.dart` are dev-only** for browser testing—not the ship target.

**Related:** For **non-Flutter** projects (browser extensions, backends, etc.), clone [AgenticTemplate](https://github.com/pbuckles22/AgenticTemplate) instead — shared agentic layer without `lib/` / Flutter tooling.

**Sync:** This repo tracks **AgenticTemplate** as an **upstream remote** for shared skills/rules. To pull shared updates: `git fetch upstream && git merge upstream/main` (resolve Flutter-specific conflicts manually).

## Source of truth

- **Contributor entry:** [CONTRIBUTING.md](CONTRIBUTING.md), [doc/PROJECT_STATUS.md](doc/PROJECT_STATUS.md)
- **Epics / stories:** [doc/plan/](doc/plan/)
- **Scope / phases:** [PM_PLAN.md](PM_PLAN.md)
- **Skills:** [.cursor/skills/](.cursor/skills/) — DEV_GUIDE.md, TEST_TDD.md, DESIGN_SYSTEM.md, techwriter, tester, code-reviewer, **code-quality-gate**, **tech-lead**, tech-debt-evaluator, eval-engineer, risk-manager, release-manager, security-reviewer, incident-triager, green-and-clean, context-bootstrapper, session-summarizer, pm-governance, ui-ux, game-readiness, visual-match, **github-feature-workflow**

## Context hierarchy (what belongs where)

Contributors and agents use **tracked docs** for product truth. See [CONTRIBUTING.md](CONTRIBUTING.md).

- **Level 1:** CONTRIBUTING, PROJECT_STATUS, `.cursor/rules/always.mdc`, this file
- **Level 2:** PM_PLAN, TEST_PLAN, `doc/plan/` (active epic)
- **Level 3:** Current story acceptance criteria in epic file
- **Level 4 (optional, local only):** `.cursor/handoff/NNNN-handoff-*.md` — gitignored; never sole source of truth

## Green and clean operating model (how we work)

This template assumes a strict operating model aimed at **green and clean** delivery:

- **Green**: each change is verifiable against explicit acceptance criteria and validated at the appropriate tier.
- **Clean**: context is curated; durable state lives in tracked docs; handoffs are compressed and decision-first.

Skills that enforce this:

- [.cursor/skills/green-and-clean/SKILL.md](.cursor/skills/green-and-clean/SKILL.md)
- [.cursor/skills/context-bootstrapper/SKILL.md](.cursor/skills/context-bootstrapper/SKILL.md)
- [.cursor/skills/session-summarizer/SKILL.md](.cursor/skills/session-summarizer/SKILL.md)
- [.cursor/skills/eval-engineer/SKILL.md](.cursor/skills/eval-engineer/SKILL.md)

## Pod (agents always working)

- **Techwriter:** Use when editing README, AGENT_HANDOFF, or internal docs. Keeps docs consistent.
- **Tester:** Black-box. Run **Tier 1** via `bash script/test.sh`; **Tier 2 web E2E** via `bash script/test_e2e_web.sh` (when implemented); **Tier 3 iOS** via `bash script/test_integration.sh <device_id>`. See [TEST_PLAN.md](TEST_PLAN.md). Keep the suite green.
- **Handoff (mandatory):** When the user wants a handoff, run code review (code-reviewer), tech debt (tech-debt-evaluator), and `flutter test --coverage`; record in the handoff note. See [.cursor/rules/handoff-checklist.mdc](.cursor/rules/handoff-checklist.mdc).

## Current state

- **Ship target:** iOS app. See **PM_PLAN.md → Platform strategy** and **doc/PROJECT_STATUS.md**.
- **App:** RouteWise on **`main`** — search, stop list, Mapbox optimize (`driving`), Google Maps handoff. Epic 0 complete ([doc/plan/epic-0-route-core.md](doc/plan/epic-0-route-core.md)).
- **Tests:** Tier 1 — 22 green. Tier 2 Playwright — 1 green (`bash script/test_e2e_web.sh`). Tier 3 — `integration_test/route_flow_test.dart` green on iOS sim.
- **Next:** Epic 1 E1-S3 — finish Tier 3 (`DEFAULT_DEVICE_ID`, native-path tests).

## Run and test

**Primary (iOS — ship target):**

```bash
flutter pub get
flutter run -d <ios_simulator_or_device> \
  --dart-define=MAPS_API_KEY=... \
  --dart-define=MAPBOX_ACCESS_TOKEN=...
./script/test_integration.sh <device_id>   # Tier 3 iOS
```

**Dev-only (browser harness — not the product):**

```bash
bash script/run_dev_harness.sh           # places proxy (8765) + web (8080); Ctrl+C stops both
bash script/test_e2e_web.sh              # Tier 2 Playwright (auto-starts web; mocked APIs)
```

```bash
./script/test.sh                    # Tier 1 (headless)
./script/test.sh --coverage         # Tier 1 + coverage (handoff)
```

See TEST_PLAN.md for device ID. List devices: `flutter devices`. Web builds: `flutter build web`.

## Conventions

- Prefer pure functions for business logic where possible.
- **Docs:** Use the **techwriter** skill when editing README, AGENT_HANDOFF, or internal docs.
- **Tests:** Black-box; run `flutter test` after logic or test changes; keep suite green (see .cursor/skills/tester/SKILL.md). Write a failing test before new production code (TDD).

---

## Git workflow (how work lands on `main`)

Document **your** team rules here and keep them in sync with what you run locally.

1. **Integration branch:** Usually **`main`**. All shipped product state (PM_PLAN, roadmap checkboxes) should reflect what is merged here.
2. **Optional short-lived branches:** For larger slices, use `feature/<topic>` or `fix/<topic>`, then merge or rebase into `main`. Agents should follow [.cursor/skills/github-feature-workflow/SKILL.md](.cursor/skills/github-feature-workflow/SKILL.md) when branching or pushing.
3. **Before push / merge-ready:** Run your **full gate** (`./script/test.sh --coverage` for Tier 1; add Tier 2 if behavior demands it). Same checks should run in CI if you use GitHub Actions (or equivalent).
4. **Pull requests:** **Optional** in this template — set `Required` or `Optional` for your org. If optional, direct push to `main` after green CI is still valid; if required, open a PR and use the same test plan text you ran locally.
5. **After merge:** Delete the local feature branch; delete the remote feature branch if your flow created one.

---

## Handoff protocol

When ending a session:

1. Run the handoff checklist (code review, tech debt, tests/coverage). See [.cursor/rules/handoff-checklist.mdc](.cursor/rules/handoff-checklist.mdc).
2. Update **PM_PLAN.md** and your **product plan / roadmap** (if you maintain one under `doc/plan/` or similar) when shipped scope changed — that is what **`main`** should carry for product state.
3. Use [.cursor/skills/session-summarizer/SKILL.md](.cursor/skills/session-summarizer/SKILL.md), then write a **local** session note (gitignored by default): **`doc/handoff/NNNN-HANDOFF-YYYY-MM-DD_HHmm.md`** and/or **`.cursor/handoff/NNNN-handoff-YYYY-MM-DD_HHmm.md`** (new monotonic `NNNN` each time; never overwrite prior notes). Include Code review, Tech debt, Tests / coverage, Done this session, Next up. Use [.cursor/handoff/_template.md](.cursor/handoff/_template.md) as a starting point. See [.cursor/handoff/README.md](.cursor/handoff/README.md).
4. Update **"Current state"** above only when it helps the next session; keep **AGENT_HANDOFF** for process and commands, not epic inventories.

Anything the team must see on the remote should land in **PM_PLAN**, the **product plan**, **README**, or the **PR** — not only in gitignored handoff files.
