# DEV_GUIDE — Project

## Tech stack

- **Flutter 3.x+**, **Dart 3.x**. **Web-first** for RouteWise Phase 1 (`flutter run -d chrome` or `flutter run -d web-server`); **iOS** scaffold retained for later native retrofit. No Android in scope yet.
- Persistence, networking, etc.: add as your app requires.

## Architecture

- **lib/** — Application code. Organize by feature or layer (e.g. `screens/`, `widgets/`, `logic/`, `data/`).
- **test/** — Unit and widget tests (Tier 1). Black-box; see TEST_TDD.md and tester skill.
- **integration_test/** — Integration tests (Tier 2) run on device/simulator.

## Conventions

- Prefer pure functions for business logic where possible.
- Keep heavy work off the UI thread (use Isolates or compute if needed).
- See AGENT_HANDOFF.md for run/test commands and source of truth.
