---
name: writeup
description: Builds REPORT.md, AI_COLLABORATION.md, and docs/RISKS.md from PLAN.md, DECISIONS.md, docs/ARCHITECTURE.md, docs/EVIDENCE.md, docs/AI_LOG.md, and git log, then audits every claim in the tracked docs against evidence. Use in phase 4 after the feature freeze, or when asked to write or refresh the report.
---

# Write-up

The docs must let a reader, and the user, explain the submission from evidence alone. Fewer, deeper claims beat many thin ones. Write only what the user can defend.

Check the Timebox in PLAN.md first. Start after the feature freeze. After the doc freeze, change a doc only where the claim audit (step 6) requires it.

If the task names its own files or sections, use those and map the sections below onto them.

## Inputs

PLAN.md (R#, U#, change log), DECISIONS.md, `docs/ARCHITECTURE.md`, `docs/analysis/CONDITIONS.md` (C#, A#), `docs/EVIDENCE.md` (E#), `docs/AI_LOG.md` (F#), `git log --oneline`, and the source files these cite. Never read `.study/`.

## 1. Refresh the evidence

1. Run the full test suite and `scripts/smoke.sh` against a running server. Rerun the what-if table with the command the `build` skill's what-if step uses (`npx tsx scripts/what-if.mjs src/domain/what-if-entry.ts scripts/what-if.scenarios.json`).
2. Append one E# per command to `docs/EVIDENCE.md` in its existing entry format, output copied verbatim.
3. If anything fails, stop the write-up and hand the failure back to the build loop.
4. Spot-check by hand. Pick three records from the input data: an ordinary one, one at a boundary (a date edge, a limit), and one that a stakeholder C# makes an exception for. For each, give the user two short commands: one that prints the input row (`grep -n` or `sed -n` on the data file) and one that prints what the system produced for it (`curl -s` on the API, or a `node -e` one-liner over `var/`), plus one line on what should match. Do not wait; continue with step 2. When the user replies (`일치`, or what differs), write one E# per record with the commands as 명령, the user's words as 출력, and `판정: PASS (사람 확인)` or `판정: FAIL`. A mismatch goes back to the build loop.

Every number in a doc is copied from an E#. Never type a number from memory.

## 2. REPORT.md

Fill `REPORT.md` section by section from its template.

- Traceability: one row per R#. Status is one of VERIFIED (a test or smoke line passed, E# cited), HUMAN-CHECKED (the user saw it in the preview, or ran a step 1.4 spot-check; record what, where, and when, and cite the E#), ASSUMED (rests on an A#), NOT-IMPLEMENTED. Fill "확인 방법" for every row: the command to rerun, the preview path and steps, or the A# to read.
- 규칙 준수: one row per hard rule, from `src/domain/check.ts` and its tests. Say whether the check runs before every save or only in tests. A rule with no check is 미검증.
- 지표와 민감도: each metric's definition as the code computes it (`file:function`), the what-if table from step 1 pasted as printed, one line per variant on what changed and which code explains it, then the limits of each metric and what is still unmeasured. A claim that the result is better cites its difference from the `baseline` row, with the E#. With no `baseline` row, write that the improvement is unmeasured. If a prediction and a measurement disagree, write both.
- Limitations: weakness (`file:function`), when it breaks, the next check.

## 3. docs/RISKS.md

Fill one row per situation in the template: condition change, mid-way failure, concurrent requests, boundary dates, hidden conditions (one row per C# that came from a stakeholder answer and adds an exception), abnormal input. With a login, also rows 7 to 9 (`plan/references/web-security.md`); without one, delete them. Split row 4 into one row per combination the data or a C# makes possible (4a, 4b, …): a span that crosses midnight on the period's last day or into a day with other rules, a special day on the first or last day, an entity absent on a day it would otherwise be served. For each row, read the code path and write what it does now with `file:function` and the test that proves it. With no test, write 미검증 in the evidence column. Name what happens to the previous result.

## 4. AI_COLLABORATION.md

1. Count F# rows by verdict in `docs/AI_LOG.md` (`grep -cE '^\| F[0-9]+ .*\| 수용 \|' docs/AI_LOG.md`, same for 수정 and 폐기). Put the counts and the commands in section 2.
2. Pick two or three cases. A case qualifies only if its chain is complete in the repo: how it was found → reproduce command and output (E#) → failing test (E# with FAIL) → fix (`file:function`, commit) → passing suite (E# with PASS) → a verdict with evidence for each AI output involved. Prefer a case where an AI output was modified or discarded on evidence, and a case that shows where the AI fell short.
3. Fill each case in the template's shape. Use only facts from AI_LOG, EVIDENCE, and `git log`. 발견 names the command and output, or what was seen on screen, that revealed the problem. The verdict table has one row per AI output: the test it wrote, the code it wrote, and the review finding, each with its own verdict and evidence. If a link in the chain is missing, drop the case.
4. "어려웠던 점" names concrete problems: what went wrong, how it surfaced, how long it cost, how it was recovered. Link each to a case or an F# whose chain has commands and outputs. Cut a problem you cannot link that way.

## 5. DECISIONS.md

D1 holds the core decision, the one the product depends on. Check that it has every field in the template: the criterion in priority order, how it works with `file:function`, each rejected alternative and how it differs (including the common families the `plan` skill lists, marked 검토만, 실측 안 함 where not run), what was given up, evidence, known weakness. Fill gaps from the code and the change log. Never claim an alternative was run or measured without an E# or a 되돌린 시도 row.

## 6. Claim audit

A claim is a sentence that says what the system does, how well it does it, or that something was checked. Headings, placeholders, and run commands are not claims.

1. Resolve every cited reference with `bash scripts/check-refs.sh`. It prints each E#, `R#: test name`, and `` `file:function` `` that a doc cites but the repo lacks, and exits 1 if there is any.

2. Write `.harness/claim-audit.md` with one row per claim in the tracked docs you wrote or changed: `| 파일:줄 | 주장 | 근거 (E# / 테스트 / 파일:함수) | 근거가 맞나 | 처리 |`. An E# cited as support must have 판정 PASS and show the claimed behavior in its output.
3. For each claim without valid evidence: add the evidence by running the check, relabel it 가정, 미검증, or 미구현 in the same sentence, or cut it. Record the action in 처리.
4. Rerun `bash scripts/check-refs.sh` until it prints `check-refs: 0 missing`.

The audit file stays local in `.harness/`. Never cite it.

## 7. Korean pass

If the `humanize-korean` skill is installed, run it on the prose of REPORT.md, AI_COLLABORATION.md, and `docs/RISKS.md`, one doc at a time, light route. Leave headings, tables, and code blocks unchanged.

1. Copy the doc to `.harness/humanize/<name>.before.md` first.
2. Take its result from `_workspace/` and compare every identifier, number, path, and backticked string. The diff must print nothing:

   ```bash
   toks() { grep -oE '`[^`]+`|[A-Z]{1,2}[0-9]+|[0-9]+([.:,][0-9]+)*' "$1" | sort; }
   diff <(toks .harness/humanize/REPORT.md.before.md) <(toks REPORT.md)
   ```

3. Reread the changed sentences. If any added a claim, dropped a condition, or changed a meaning, restore that sentence from the copy.

If the skill is not installed, skip this step and say so in the reply.

## Rules for every tracked doc

- Every claim carries its evidence or its label in the same sentence.
- Nothing addressed to graders, reviewers, or examiners. Nothing from `.study/`.
- Docs describe the code as it is now. Not built means 미구현.

## Reply

Use the AGENTS.md reply format. Under "Verified", paste the last E# lines from step 1 and the `check-refs: 0 missing` line from step 6. Under "Skipped", list claims you cut and cases you dropped, one line each.
