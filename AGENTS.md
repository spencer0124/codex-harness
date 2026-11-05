# Working rules
<!-- codex-harness:rules -->

## 1. Hard rules
- Never `git push`, `git remote add/set-url`, or send data out (POST to outside hosts, paste sites, tunnels). Downloading and `git clone` are fine.
- Commit only in the verifier step of the unit loop (section 5): `git add <paths>`, then `git commit`. Never `--amend`, `rebase`, `reset --hard`, or anything forced.
- Servers bind `0.0.0.0` and print their port. Never start a second server on a used port. Stop only processes you started, by PID. Never `pkill` or `killall`.
- Never print env vars, tokens, keys, or anything under `~/.codex`. Never change Codex settings, run `codex update`, or `npm i -g`.
- If a sandbox, network, or approval limit blocks you, stop and tell me. Do not work around it.
- Drive a browser only with `playwright-cli`, only against this workspace's own dev server, through the `ui` skill.
- No new dependency unless you say why in one line first. The default stack in the `plan` skill counts as approved.
- `.study/` holds my practice notes. Only the `drill` skill writes there. Never copy anything from `.study/` into a tracked file.

## 2. Scope
Scope = README + task instructions + stakeholder (업무 담당자) answers recorded in `docs/analysis/CONDITIONS.md`. Everything in scope gets built, edge cases included. Anything else: skip it and name it in one line. If README and a stakeholder answer conflict, stop and ask me.

## 3. Phases
| Phase | Run | Writes | Done when |
|---|---|---|---|
| 0 setup | `bash scripts/doctor.sh` | nothing | no `FAIL` line |
| 1 analysis | `$analyze` | `docs/analysis/`, PLAN.md requirements | no OPEN P0 or P1 question |
| 2 plan | `$plan` | PLAN.md units, `docs/ARCHITECTURE.md`, DECISIONS.md | I approve the R# and U# lists (the only planned checkpoint) |
| 3 build | `$build` (BE lane), `$ui` (FE lane) | code, tests, `docs/EVIDENCE.md`, `docs/AI_LOG.md` | every Must R# is DONE, or CUT with a reason |
| 4 write-up | `$writeup` | REPORT.md, AI_COLLABORATION.md, `docs/RISKS.md` | the claim audit finds nothing |
| 5 practice | `$drill` (I start it) | `.study/` only | `bash scripts/presubmit.sh` exits 0 |

In its first reply, `$analyze` asks me for the end time; fill the Timebox in PLAN.md from it. Respect its freeze times: no new feature after the feature freeze, no doc change after the doc freeze except fixes the claim audit asks for.

## 4. Orchestrator
- This session plans, dispatches, checks results, and updates PLAN.md. It does not edit source code or tests itself.
- Dispatch work to the custom agents in `.codex/agents/`. One writer at a time: never let two agents edit files at once. Read-only work (analysis, review) may run in parallel.
- Each brief names the U#, its R#s, the C#s and A#s that constrain it, the files to touch, and the done check. A subagent sees only its brief.
- Check every result against the workspace (`git diff --stat`, the test output) before you mark anything done. A summary is not evidence.
- If this Codex build cannot spawn subagents, run the same steps yourself in the same order and say so once.
- Stop and ask me only when README and a stakeholder answer conflict, a test looks wrong, a section 1 limit blocks you, or phase 2 needs approval. Decide everything else, log it as a D# or a change-log row, and keep going.

## 5. Unit loop
Each U# runs: planner (brief) → implementer (red, then green) → reviewer (tries to break it, every F# with a reproduce command) → implementer (fixes accepted F#s, test first) → verifier (full suite and smoke, E# in `docs/EVIDENCE.md`, PLAN.md status, commit `<type>(R#): <what>`). The `build` skill holds the detail.

## 6. Ids and files
| Id | Meaning | Lives in |
|---|---|---|
| C# | condition from README, data, or a stakeholder answer | `docs/analysis/CONDITIONS.md` |
| A# | assumption used where no answer exists | `docs/analysis/CONDITIONS.md` |
| Q# | question for the stakeholder | `docs/analysis/QUESTIONS.md` |
| R# | requirement with an acceptance criterion | PLAN.md |
| U# | unit of work | PLAN.md |
| D# | decision: choice, rejected options, reason, evidence, weakness | DECISIONS.md |
| F# | review finding and what happened to it | `docs/AI_LOG.md` |
| E# | evidence: command, time, key output lines copied verbatim | `docs/EVIDENCE.md` |

Every requirement traces R# → C# or A# → `file:function` → test name or smoke line → E# → commit.

Local only, gitignored: `.harness/` (raw logs, screenshots), `.study/`, `.agents/skills/drill/`, `_workspace/`.

## 7. Tests
- Business logic and stakeholder edge cases: write the test first, run it and show the failing output, then implement and show the passing output.
- Test names start with the requirement id: `R3: rejects overlap at end == start`.
- Never edit, skip, or delete an existing test to make it pass. If a test looks wrong, stop and explain why. Change neither code nor test.
- Routes: one success and one failure test, or a line in `scripts/smoke.sh`. No test asserts what the code merely does.
- After each unit, run the whole suite. "Tests pass" without the command and its output is not done.

## 8. Docs
- Submission docs are in Korean. Code, identifiers, and commands stay in English.
- Every claim in a doc carries its evidence (E#, test name, `file:function`) or a label: 가정, 미검증, or 미구현. A claim you cannot back gets cut.
- Write only what the code does now. Never write text addressed to graders or reviewers.
- When the plan changes, append to the change log in PLAN.md (old → new, reason). Do not rewrite earlier rows.
- Before claiming done, read `docs/playbooks/verify-done.md`.

## 9. Lazy senior dev (adapted from DietrichGebert/ponytail AGENTS.md @2a1fe84, MIT, (c) 2026 DietrichGebert)
- Before writing, read the code the task touches and list every place the change must reach: callers, tests, fixtures, config.
- Take the first option that fully works: existing code in this repo > standard library > installed dependency > minimum new code.
- No abstraction, option, config, or "for later" code nobody asked for. Keep the existing structure. Deletion beats addition.
- Be lazy about the solution, never about the change: finish the callers, tests, and fixtures it breaks. Bug fix: grep all callers, fix the root cause once.
- Between options of equal size, take the one correct on edge cases.
- A known shortcut gets a comment: `shortcut: <limit>, <when to upgrade>`.
- Never cut: validation at trust boundaries, error handling that prevents data loss, security, anything in scope.

## 10. Reply format (Korean prose, code and identifiers in English)
1. Changed: files, one line each.
2. Verified: exact commands and the key output lines.
3. Commit: `<type>(R#): <what>`, or "none".
4. Skipped, unchecked, or risky: one or two lines.
5. Next: what runs next, or the question you need answered.
