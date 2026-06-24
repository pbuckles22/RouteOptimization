# Contributing to Route Optimization (RouteWise)

Thank you for contributing. This repo uses **tracked documentation** as the source of truth — not chat history and not local handoff files alone.

## Start here (reading order)

1. [README.md](README.md) — project overview
2. **[doc/PROJECT_STATUS.md](doc/PROJECT_STATUS.md)** — current state, active branch, what's next
3. [doc/plan/README.md](doc/plan/README.md) — epics, stories, agent bootstrap
4. [PM_PLAN.md](PM_PLAN.md) — phases, platform strategy (iOS ship / web dev harness)
5. [AGENT_HANDOFF.md](AGENT_HANDOFF.md) — run/test commands, merge-ready gate, conventions
6. [TEST_PLAN.md](TEST_PLAN.md) — Tier 1–4 testing strategy
7. [doc/requirements/](doc/requirements/) — product specs

**Agents:** Follow [context-bootstrapper](.cursor/skills/context-bootstrapper/SKILL.md) — produce a **Receiver Brief** before coding.

## Local session notes vs GitHub

| Location | On GitHub? | Purpose |
|----------|------------|---------|
| `doc/PROJECT_STATUS.md` | **Yes** | Human-readable current state — **update when milestones ship** |
| `doc/plan/` epics | **Yes** | Stories + acceptance criteria |
| `AGENT_HANDOFF.md` → Current state | **Yes** | Maintainer + agent snapshot — keep in sync |
| `PM_PLAN.md` | **Yes** | Phase checklists |
| `.cursor/handoff/*-handoff-*.md` | **No** (gitignored) | Optional local session diary |
| `doc/handoff/*-HANDOFF-*.md` | **No** (gitignored by default) | Same — promote decisions to tracked docs |

**Norm:** If a decision affects what contributors build next, update `doc/PROJECT_STATUS.md`, `doc/plan/`, and `AGENT_HANDOFF.md` — not only a gitignored handoff note.

## Development setup

### Prerequisites

- Flutter 3.x+, Dart 3.x
- **macOS + Xcode** for iOS run and Tier 3 integration tests
- **Optional:** Chrome / Flutter Web for Tier 2 web E2E and dev harness (`places_proxy`)

### Clone and branch

```bash
git clone https://github.com/pbuckles22/RouteOptimization.git
cd RouteOptimization
git fetch origin
git checkout main
flutter pub get
```

Active epic branch (if any) is named in **doc/PROJECT_STATUS.md**.

### Test

```bash
bash script/test.sh                    # Tier 1 (merge-ready minimum)
bash script/test.sh --coverage         # Tier 1 + coverage (handoff)
bash script/test_e2e_web.sh            # Tier 2 web E2E (when implemented)
bash script/test_integration.sh <id>   # Tier 3 iOS — see TEST_PLAN.md
```

**Merge-ready gate:** `bash script/test.sh --coverage` before merge to `main`.

## Upstream sync

Shared agentic skills/rules sync from [AgenticTemplate](https://github.com/pbuckles22/AgenticTemplate):

```bash
git fetch upstream && git merge upstream/main
```

Resolve conflicts — keep RouteWise-specific content in `PM_PLAN.md`, `doc/plan/`, and `AGENT_HANDOFF.md`.

## Pull request expectations

- [ ] Scope matches active epic in `doc/plan/`
- [ ] Merge-ready gate green
- [ ] No secrets or credentials (`.env` is gitignored)
- [ ] If a milestone shipped: update **PM_PLAN**, **doc/plan/**, and **doc/PROJECT_STATUS.md**

## Questions

Open a GitHub issue or see [AGENT_HANDOFF.md](AGENT_HANDOFF.md).
