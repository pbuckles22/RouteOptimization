# Agent handoff — Project

## Purpose

This repo is **Route Optimization** (RouteWise Phase 1): a **web-first** Flutter app with Cursor rules, skills, handoff protocol, and tests. Phase 1 targets Flutter Web; the iOS scaffold remains for a later native retrofit.

**Related:** For **non-Flutter** projects (browser extensions, backends, etc.), clone [AgenticTemplate](https://github.com/pbuckles22/AgenticTemplate) instead — shared agentic layer without `lib/` / Flutter tooling.

**Sync:** This repo tracks **AgenticTemplate** as an **upstream remote** for shared skills/rules. To pull shared updates: `git fetch upstream && git merge upstream/main` (resolve Flutter-specific conflicts manually).

## Source of truth

- **Scope / sprints:** [PM_PLAN.md](PM_PLAN.md)
- **Skills:** [.cursor/skills/](.cursor/skills/) — DEV_GUIDE.md, TEST_TDD.md, DESIGN_SYSTEM.md, techwriter, tester, code-reviewer, **code-quality-gate**, **tech-lead**, tech-debt-evaluator, eval-engineer, risk-manager, release-manager, security-reviewer, incident-triager, green-and-clean, context-bootstrapper, session-summarizer, pm-governance, ui-ux, game-readiness, visual-match, **github-feature-workflow**

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
- **Tester:** Tests are black-box. Run **Tier 1** via `./script/test.sh` (or `flutter test`); **Tier 2** via `./script/test_integration.sh <device_id>` (see [TEST_PLAN.md](TEST_PLAN.md)). Keep the suite green.
- **Handoff (mandatory):** When the user wants a handoff, run code review (code-reviewer), tech debt (tech-debt-evaluator), and `flutter test --coverage`; record in the handoff note. See [.cursor/rules/handoff-checklist.mdc](.cursor/rules/handoff-checklist.mdc).

## Current state

- **App:** Playable RouteWise web prototype on branch `feature/epic-0-s0-1-pubspec-deps` — search (Google Places), stop list, distance optimize (Mapbox `driving`), Google Maps handoff. Keys via `--dart-define=MAPS_API_KEY` / `MAPBOX_ACCESS_TOKEN`. Tier 1: 18 tests green.
- **Next:** Merge feature branch to `main`; optional Phase 1b traffic profile (`driving-traffic`); docs split (`phase1-spec.md`, `PM_PLAN` epics).

## Run and test

```bash
flutter pub get
flutter run -d chrome --dart-define=MAPS_API_KEY=... --dart-define=MAPBOX_ACCESS_TOKEN=...
./script/run_web.sh                # Local web server (default port 8080)
.\script\run_web.ps1               # Windows (reads $env:MAPS_API_KEY, $env:MAPBOX_ACCESS_TOKEN)
./script/test.sh                    # Tier 1
./script/test.sh --coverage         # Tier 1 + coverage (handoff)
./script/test_integration.sh <id>   # Tier 2 (iOS device/simulator)
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
