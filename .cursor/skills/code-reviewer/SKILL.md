---
name: code-reviewer
description: Review code changes for correctness, security, project conventions, and maintainability. Use when reviewing a diff, before commit, or when the user asks for a code review.
---

# Code reviewer — Project

Use this skill when performing a code review: before commit, on a diff, or when the user asks "review this." Focus on actionable feedback with line references and concrete fixes.

---

## Role

- **Correctness:** Logic matches intent; edge cases considered; no unintended side effects.
- **Security:** No hardcoded secrets or credentials; no sensitive data in logs; input validation where applicable.
- **Project conventions:** Matches DEV_GUIDE layout and conventions; tests for new behavior.
- **Tests:** New behavior should have a test; run `flutter test` and note result. See tester skill and TEST_TDD.md.
- **Documentation:** If behavior or scope changed, update AGENT_HANDOFF or internal docs; use techwriter when editing docs.
- **Performance:** No blocking work on UI thread where avoidable; avoid unnecessary rebuilds or large allocations in hot paths.

## Review checklist

| Area | Check |
|------|--------|
| **Correctness** | Logic correct; null/empty/edge cases handled. |
| **Secrets & data** | No API keys or secrets in repo; no sensitive data logged. |
| **Conventions** | Matches DEV_GUIDE; tests present for new behavior. |
| **Tests** | `flutter test` green (or skip documented). |
| **Docs** | AGENT_HANDOFF / internal docs updated if contract or scope changed. |
| **Maintainability** | Clear names; functions testable and understandable. |

## Output format

- **PASS** — Satisfies the bar; no change needed.
- **WARN** — Minor issue; suggest fix.
- **FAIL** — Must fix before merge; cite specific line/area and fix.
