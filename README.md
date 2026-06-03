# Route Optimization

Flutter **RouteWise Phase 1** web prototype, bootstrapped from [FlutterAgenticTemplate](https://github.com/pbuckles22/FlutterAgenticTemplate) with Cursor rules, skills, handoff protocol, and test setup.

Product spec: [`doc/requirements/route-wise-phase1-web-prototype.md`](doc/requirements/route-wise-phase1-web-prototype.md).

**Not using Flutter?** Use the stack-agnostic template instead: [AgenticTemplate](https://github.com/pbuckles22/AgenticTemplate) (browser extensions, CLIs, backends, etc.). This repo is the Flutter scaffold plus the same style of agentic layer.

## Quick start

```bash
cd MultlocationMapsCreator   # or RouteOptimization after rename
flutter pub get
flutter test
flutter run -d chrome        # Web dev with hot reload
./script/run_web.sh            # Local web server on port 8080
```

**Flutter SDK:** Install from [flutter.dev](https://docs.flutter.dev/get-started/install/windows) or clone stable to `C:\Users\pbuck\flutter` and add `...\flutter\bin` to your user PATH. Run `flutter doctor` to verify Chrome/web support.

**Tier 2 (integration tests):** Set `DEFAULT_DEVICE_ID` in `script/test_integration.sh` or run `./script/test_integration.sh <device_id>` (iOS).

---

### Point this clone at your own repo

If you want to push and pull from **your own** GitHub repo instead of the shared template:

```bash
git remote set-url origin https://github.com/YOUR_USERNAME/YOUR_REPO.git
git push -u origin main
```

(Use your repo URL and branch name.) After that, `git pull` and `git push` use your repo. The template files stay; you’re just changing where the remote points.

---

### Template already on my machine — copy folder and start

**Recommended: use the script** (run from the template root; only asks where to create the new project):

```bash
cd /path/to/FlutterAgenticTemplate
./script/new_project.sh
```

The script checks if the destination exists (errors if non-empty), asks to create it if it doesn’t exist, then copies the template, removes `.git`, runs `git init`, `flutter upgrade`, `flutter pub get`, and `flutter test`. You can’t accidentally run it in the wrong directory.

**Or do it manually.** You have the template locally (e.g. `~/dev/FlutterAgenticTemplate`) and want to **copy it to a new directory** and start a fresh project:

```bash
# Copy the whole folder to your new project path (edit paths to match your machine)
cp -R /path/to/FlutterAgenticTemplate /path/to/MyNewProject
cd /path/to/MyNewProject

# Fresh git repo (drops any history from the template)
rm -rf .git
git init

# Optional: update Flutter SDK if the template was built with an older version
# flutter upgrade

# Install deps and confirm tests pass
flutter pub get
flutter test

# Open this folder in Cursor and start coding
```

**Flutter SDK:** `flutter pub get` and `flutter test` use your current Flutter; they don’t upgrade it. If you want the latest framework, run `flutter upgrade` before the steps above.

Then **open the new folder in Cursor** (File → Open Folder → choose your new folder). You’re in a clean repo with no template history; push to your own repo when ready (`git remote add origin ...` then `git push -u origin main`).

**Folder name ≠ app name.** You can rename the folder to anything (e.g. `MyNewProject`, `CoolApp`); the app will still show as “Template App” until you change it. To set your app name: edit `pubspec.yaml` → `name:`, your app’s `MaterialApp` title in `lib/main.dart`, and the display name in `ios/Runner/Info.plist` (e.g. `CFBundleDisplayName`) when you’re ready.

---

### Start from a zip or copy (no git yet)

If you have a zip or folder copy (no clone):

```bash
cd /path/to/FlutterAgenticTemplate
git init
flutter pub get
flutter test
# then open folder in Cursor
```

## What’s included

| Area | Contents |
|------|----------|
| **App** | Minimal Flutter app (`lib/main.dart` → "Template App"). Replace with your product. |
| **.cursor/rules** | `always.mdc`, `handoff-checklist.mdc`, `testing.mdc` — applied in Cursor. |
| **.cursor/skills** | DEV_GUIDE, TEST_TDD, DESIGN_SYSTEM, techwriter, tester, code-reviewer, tech-debt-evaluator, pm-governance, ui-ux, game-readiness, visual-match. All generalized; no project-specific logic. |
| **.cursor/handoff** | Handoff note template and README. |
| **script/** | `new_project.sh` (copy template to a new path; run from template root). `test.sh` (Tier 1), `test_integration.sh` (Tier 2; set device ID). |
| **test/** | Widget test, golden comparator (2% threshold), `flutter_test_config.dart`. |
| **integration_test/** | App load test, golden config and comparator. |
| **doc/requirements** | Placeholder; add your product/UI requirements. |
| **examples/** | Placeholder; add reference screenshots/specs for visual-match. |
| **Gemini/** | Placeholder; use for session summaries and AI context. |

Source of truth: [AGENT_HANDOFF.md](AGENT_HANDOFF.md), [PM_PLAN.md](PM_PLAN.md), [TEST_PLAN.md](TEST_PLAN.md), and `.cursor/skills/`.

## What not to put in the repo

- **No secrets** — API keys, tokens, credentials. Use environment variables or a local config that’s gitignored.
- **No machine-specific paths** — Flutter’s `ios/Flutter/flutter_export_environment.sh` is already gitignored (regenerated per machine).
- **Device IDs** — `script/test_integration.sh` has an empty `DEFAULT_DEVICE_ID`; each dev sets their own or passes it. Don’t commit your personal simulator ID if you want the template to stay generic.
- **Handoff notes** — `.cursor/handoff/handoff-*.md` are gitignored so local handoff notes aren’t pushed to the shared repo. The template `_template.md` and `README.md` are committed.

## Keeping platform folders up to date

When you **upgrade Flutter**, the `ios/` folder generated by an older Flutter can become outdated (e.g. new Xcode project format, new APIs). To refresh it to match your current Flutter SDK:

```bash
# From the project root:
flutter create . --platforms=web,ios
```

This **updates** `ios/` with the current Flutter template while keeping your `lib/`, `test/`, `integration_test/`, `pubspec.yaml`, and the rest of your code. After running it, re-apply any customizations you made (bundle ID, display name, entitlements) if they were overwritten. Your app code, tests, and `.cursor/` are untouched.

So: **out of the box** you get a working Flutter app and run/tests; **after a Flutter upgrade**, run `flutter create .` once to refresh platform folders, then continue coding.

## Stack

- Flutter 3.x+, Dart 3.x
- **Web-first** (Chrome / local web server) for Phase 1; iOS scaffold for later native retrofit
- Lints: `flutter_lints` in `analysis_options.yaml`

## Docs

- [AGENT_HANDOFF.md](AGENT_HANDOFF.md) — for AI and context handoff; run/test and conventions
- [TEST_PLAN.md](TEST_PLAN.md) — Tier 1 vs Tier 2, device ID
- [PM_PLAN.md](PM_PLAN.md) — replace with your phases/sprints
- `.cursor/skills/` — all skills and DEV_GUIDE, TEST_TDD, DESIGN_SYSTEM
