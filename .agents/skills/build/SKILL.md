---
name: build
description: Run the unit loop that implements PLAN.md units one at a time through the planner, implementer, reviewer, and verifier agents until every Must requirement is done or cut. Use after the plan is approved, or when the user says "build", "$build", or "continue".
---

# Build

The orchestrator runs this loop. It never edits `src/` or `tests/` itself. It writes briefs, runs reproduce commands, logs F#s, and updates PLAN.md.

## Pick the next unit
1. Read PLAN.md Timebox and Units. A DOING row means the last session stopped mid-unit: read `git status`, `git diff --stat`, and `.harness/briefs/U#-*`, then resume at the first step whose gate output is missing. Otherwise take the first TODO row whose earlier units are DONE, PARTIAL, or CUT.
2. Midpoint check, once, at the first unit boundary after the Timebox midpoint: run `scripts/smoke.sh` in full and, if there is a screen, `$ui check`. Then estimate from the units done so far whether every remaining Must row fits before the feature freeze. If not, or if smoke fails on a DONE row, mark Should and Could rows `CUT(시간)` from the bottom until it fits, with one change-log row and the smoke E#. Tell the user in two lines.
3. Past the feature freeze: finish the DOING unit, fix failing tests, start nothing new. Mark the remaining TODO rows `CUT(시간)` with one change-log row. Then hand over to `$writeup`.
4. An FE row runs the `ui` skill's steps in place of steps 2 to 4 below. Steps 1 and 5 stay the same.

## The loop for one unit
Set the row to DOING. Write every brief to `.harness/briefs/U#-<agent>.md` and give the agent that path.

### 1. Brief (planner)
Gate: the brief names one test per R#, every C# and A# that constrains the unit, the files to touch, and the done check. Otherwise send it back once with what is missing.

### 2. Red, then green (implementer)
Gate, all four:
- The report pastes the red run, and it fails for the reason the brief expects.
- The report pastes the full-suite summary line after the change.
- `git diff --stat HEAD -- tests '*.test.ts'` shows only new tests or tests this unit added. An edited older test stops the loop: ask the user.
- `git diff --stat HEAD` stays inside the brief's files, or the report says why it needed another file.

### 3. Review (reviewer)
A fresh `reviewer` gets the brief path and the base commit, nothing else. It may write only under `.harness/repro/`. It returns findings, each with severity (must-fix, should-fix, note), the claim, a reproduce command, and the expected against the actual output.

The review is read-only, so it may run while the planner drafts the next unit's brief.

For each must-fix and should-fix finding, run its reproduce command yourself:
- It reproduces: accept it for step 4.
- It does not reproduce, is out of scope, or contradicts a C#: drop it (폐기) and keep the command output as 근거.

### 4. Fix (implementer)
Give a fresh `implementer` the brief plus the accepted findings. For each one it adds a failing test first, pastes the red output, then fixes and runs the full suite. Record that red output as an E# with `판정: FAIL` and the line `메모: 의도한 red (F# 재현)`.

Retry budget: 3 fix rounds per unit. After the third failed round, set the row to PARTIAL, write what fails and why in the change log, and move on.

### 5. Verify and commit (verifier)
A fresh `verifier` runs typecheck, the full suite, and `scripts/smoke.sh` when the unit touched the server. It writes the E#, sets the PLAN.md row and its R#s, and commits. Gate: the E# says `판정: PASS`, and `git log -1` shows the commit. A FAIL goes back to step 4 and counts toward the budget. Smoke exit 2 means no server is running, not a FAIL: ask the user once to run `npm run dev` in a separate terminal (AGENTS.md section 1), wait, and rerun.

Report to the user per unit: one status line, then one line per F# judged in this unit, so the user knows each verdict and can overrule it.

```text
U3 DONE · R2, R4 · E7 PASS (vitest 24 passed) · 3f2a9c1
  F2 수용: reviewer, 같은 요청을 두 번 보내면 결과가 두 번 저장됨 → 재현됨 (E6 FAIL), 테스트 추가 후 수정
  F3 폐기: reviewer, 빈 입력 파일 처리 누락 → 재현 안 됨 (`npx vitest -t "R1: empty"` 통과)
```

The loop does not wait for an answer. If the user overrules a verdict ("F3 수용해"), change that F# row, append `(사용자 판단: <their words>)` to its 근거, and act on it as the next fix.

## Log every judged AI output in docs/AI_LOG.md
One row per F#. An F# is any agent output you had to judge: review findings, and planner or implementer proposals you changed or refused.

`| F# | 시각 | U# / R# | AI가 낸 것 (에이전트: 요지) | 판정 (수용/수정/폐기) | 근거 (명령과 핵심 출력, 또는 E#) | 커밋 |`

- 수용: applied as proposed.
- 수정: applied differently. Say how it differs in 근거.
- 폐기: not applied. Paste the output that showed it was wrong, or name the C# it contradicts.
- A verdict the user made or changed carries `(사용자 판단: ...)` in 근거, in the user's words.

Zero rows is a valid count. Never invent a row.

## Evidence format (docs/EVIDENCE.md)
Append only. Copy output, never paraphrase it.

````markdown
## E3 · 14:05 · U2 · R2, R4
명령: `npm test`
출력 (발췌, 그대로 복사):
```text
 Test Files  6 passed (6)
      Tests  24 passed (24)
```
판정: PASS
````

A UI check uses the `playwright-cli` command as 명령 and the screenshot path under `docs/screenshots/` plus what was seen as 출력.

## Commits
- Message: `<type>(R#): <what>`, with type one of `feat`, `fix`, `test`, `refactor`, `docs`, `chore`. Several R#s: `feat(R2,R4): ...`.
- The verifier stages the unit's files plus `PLAN.md`, `docs/EVIDENCE.md`, and `docs/AI_LOG.md` by path. Never `git add -A`.
- A commit cannot hold its own hash. The verifier fills the previous unit's 커밋 cell before committing. `$writeup` fills the last one.

## What-if step
When the what-if entry unit is DONE, write `scripts/what-if.scenarios.json`: the base params from the real data, plus these variants:

- Each rule constant a C# names: up, down, zero, a fractional value.
- Each numeric field of the input data (durations, distances, counts): all zero, fractional, one value missing. The entry applies these as params to a copy of the data.
- An empty input set and the largest size.
- `baseline`: the plainest method a reader would try first (one metric only, or no optimization) on the base data. The entry switches to it with a param.

`run()` returns the number of broken rules from `src/domain/check.ts` as `ruleViolations`, next to the metrics. Then run:

```bash
npx tsx scripts/what-if.mjs src/domain/what-if-entry.ts scripts/what-if.scenarios.json
```

Record the printed table as one E#. A variant that throws is a finding: log it as an F# and give it a unit if it breaks a Must R#.

## Without subagents
If this Codex build cannot spawn agents, do each step yourself with the same briefs and gates, in order. Start the review step by rereading only the brief and `git diff <base>`, as if you had not written the code. Say once that the loop ran inline.

## Stop and ask only when
- README and a stakeholder answer conflict.
- A test looks wrong, or the loop would need to edit an older test.
- A sandbox, network, or approval limit blocks a step.

Decide everything else, log it, and keep going.
