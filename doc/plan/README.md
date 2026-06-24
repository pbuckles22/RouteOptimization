# Product plan — epics & stories

**This is how we roll.** Agents must read this (and the active epic) before coding—not ask the user to re-explain.

| Doc | Purpose |
|-----|---------|
| [PM_PLAN.md](../../PM_PLAN.md) | Phases, platform strategy (iOS ship / web dev harness), quality gates |
| [TEST_PLAN.md](../../TEST_PLAN.md) | Tier 1–4 testing; web E2E for automation on Windows |
| [AGENT_HANDOFF.md](../../AGENT_HANDOFF.md) | Process, commands, current branch pointer |
| **This folder** | Epics, stories, acceptance criteria |

## Epics

| Epic | Branch (if any) | Status |
|------|-----------------|--------|
| [Epic 0 — Route core](epic-0-route-core.md) | `feature/epic-0-s0-1-pubspec-deps` | ✅ Complete (on `main`) |
| [Epic 1 — E2E automation & iOS path](epic-1-e2e-and-ios.md) | `feature/epic-1-e2e-ios` | In progress (E1-S1 ✅) |

## Story ID format

`E{epic}-S{story}` — e.g. **E0-S1** (pubspec + AppConfig). Branch names may include this: `feature/epic-0-s0-1-pubspec-deps`.

## Agent session start (mandatory)

1. [CONTRIBUTING.md](../../CONTRIBUTING.md) reading order through active epic.
2. Read `.cursor/rules/always.mdc`, [doc/PROJECT_STATUS.md](../PROJECT_STATUS.md), `AGENT_HANDOFF.md`, `PM_PLAN.md` (platform strategy).
3. Read **active epic** in this folder + `TEST_PLAN.md`.
4. Read latest handoff note if present (`doc/handoff/` or `.cursor/handoff/`).
5. Produce **Receiver Brief** per [context-bootstrapper SKILL](../../.cursor/skills/context-bootstrapper/SKILL.md)—do not act until scope is clear.
6. Confirm git branch matches epic before implementing.

## Decisions (do not re-litigate without user)

- **Ship target:** iOS app.
- **Web + `places_proxy`:** dev/test harness only (CORS workaround); not product architecture.
- **Efficient E2E:** Tier 1 headless + **Tier 2 web E2E on Chrome** (works on Windows); Tier 3 iOS simulator for native-only; Tier 4 live smoke manual.
- **TDD:** failing test before production code (TEST_TDD.md).
