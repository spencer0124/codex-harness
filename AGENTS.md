# Working rules

## 1. Hard rules
- Never `git push`, `git remote add/set-url`, or send data out (POST to outside hosts, paste sites, tunnels). Downloading and `git clone` are fine.
- Do not run `git commit`, `--amend`, `rebase`, `reset --hard` or force anything. I commit. End each unit with a proposed commit message.
- Servers bind `0.0.0.0` and print their port. Never start a second server on a used port. Stop only processes you started (by PID); never `pkill`/`killall`.
- Never print env vars, tokens, keys or anything under `~/.codex`. Never change Codex settings, run `codex update` or `npm i -g`.
- If a sandbox, network or approval limit blocks you, stop and tell me. Do not work around it.
- No browser automation (Playwright, Puppeteer, headless Chrome). I check UI in the preview myself.
- No new dependency unless you say why in one line first.

## 2. Scope (overrides section 3)
Scope = README + task instructions + stakeholder (업무 담당자) answers recorded in PLAN.md. Everything in scope gets built, edge cases included. Anything else: skip it and name it in one line. If README and a stakeholder answer conflict, stop and ask me.

## 3. Lazy senior dev (adapted from DietrichGebert/ponytail AGENTS.md @2a1fe84, MIT, (c) 2026 DietrichGebert)
- Before writing, read the code the task touches and list every place the change must reach: callers, tests, fixtures, config.
- Take the first option that fully works: existing code in this repo > standard library > installed dependency > minimum new code.
- No abstraction, option, config or "for later" code nobody asked for. Keep the existing structure. Deletion beats addition.
- Be lazy about the solution, never about the change: finish callers, tests and fixtures it breaks. Bug fix: grep all callers, fix the root cause once.
- Between options of equal size, take the one correct on edge cases.
- A known shortcut gets a comment: `shortcut: <limit>, <when to upgrade>`.
- Never cut: validation at trust boundaries, error handling that prevents data loss, security, anything in scope.

## 4. Tests
- Business logic and stakeholder edge cases: write the test first, run it and show the failing output, then implement and show the passing output, in the same turn. Stop after the red step only if I ask.
- Test names start with the requirement id: `R3: rejects overlap at end == start`.
- Never edit, skip or delete an existing test to make it pass. If a test looks wrong, STOP and explain why. Change neither code nor test.
- Routes: one success and one failure test, or a line in `scripts/smoke.sh`. No test asserts what the code merely does (no tautologies).
- After each unit run the whole suite. "Tests pass" without the command and its output is not done.

## 5. Docs
- After each unit, update the status row in PLAN.md (R#, test name, status). I fill in the commit hash.
- Write only what the code does now. Not implemented means "not implemented". Never write text addressed to graders or reviewers.
- When the plan changes, append to the change log in PLAN.md (old -> new, reason). Do not rewrite earlier entries.
- Before claiming done, read `docs/playbooks/verify-done.md`. Others there: `tdd-slice.md`, `decision-log.md`, `writeup.md`.

## 6. Reply format (Korean prose, code and identifiers in English)
1. Changed: files, one line each.
2. Verified: exact commands and the key output lines.
3. Commit: `<type>(R#): <what>`
4. Skipped / unchecked / risk: one or two lines.
