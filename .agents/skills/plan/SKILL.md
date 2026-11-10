---
name: plan
description: Turn analyzed requirements and the approved core approach into an architecture, decisions, and an ordered unit list, then get the user's approval. `$approach` starts it on approval; the user can also say "plan" or "$plan".
---

# Plan

The orchestrator runs this skill. The `planner` agent drafts, the orchestrator checks and merges.

Inputs: PLAN.md Requirements and Timebox, `docs/analysis/CONDITIONS.md` (C#, A#), `docs/analysis/DATA.md`, DECISIONS.md D1, README.
Outputs: `docs/ARCHITECTURE.md`, D#s in DECISIONS.md, PLAN.md Units, one change-log row.

## 1. Check the inputs
- Every Must R# cites a C# or an A#, and has an acceptance criterion a test or smoke line can check. If not, go back to `$analyze`.
- D1 상태 is `승인됨` and `사용자 승인 (원문)` holds the user's reply. If not, go back to `$approach`. Never pick or swap the core approach here.
- Read the Timebox. Plan the Must units to finish before the feature freeze with about 20% slack.

## 2. Name the data shapes first
Write the TypeScript types in `docs/ARCHITECTURE.md` under "데이터 모양": the input records as parsed, the conditions, the result, and the stored envelope from `references/stateful-ops.md`. Every later unit builds on these names. Do not rename them after phase 2 without a change-log row.

## 3. Fix the stack and the state rules
- Use `references/stack.md` unless README prescribes another stack. A deviation is a D#.
- Apply `references/stateful-ops.md` to every action that changes stored state. Each default that applies becomes an R# with source A# and its test row. A default that does not apply gets one line saying why in the change log.
- If a C# names login, operators, roles, or state changes by a signed-in user, apply `references/web-security.md` the same way: its required tests become R#s, and the auth middleware and CSRF check land in the routes unit, not later.

## 4. Detail the core logic
D1 already holds the approved approach, the criteria, every candidate, and the spike E#s from `$approach`. Do not reopen the choice. Fill the rest of D1:
- 기준: the `file:function` that will compute the target measure.
- 동작 방식: 3 to 5 numbered steps a reader can follow without code.
- 증거: the spike E#s now, test names next, a what-if E# later (`build` skill, what-if step).
- 약점과 장애 시 동작: when it gives a bad answer and what the user sees.

If a C#, a stakeholder answer, or the Timebox makes the picked approach unworkable, stop and go back to `$approach` with the reason. Do not swap it yourself.

Log a D# for every other real choice only (storage, a library, a rule interpretation). Never invent alternatives.

Then list the hard rules: every rule a result must never break, each from a C#. Plan `src/domain/check.ts` exporting `checkResult(input, result)`, which returns one entry per broken rule with the rule's C#. It reads only the inputs and the result, never the generator's internals, so it can catch the generator's mistakes. The generate route runs it on every result before saving. What a violation does follows the C# for infeasible input; without one, use the A# default: save nothing and answer 422 with the broken rules.

## 5. Write the flow and ownership
In `docs/ARCHITECTURE.md`, for each user action (each button or route), headed by the button's label exactly as the screen shows it and its route:
1. List the steps: 화면 → API → 검증 → 도메인 → 저장 → 응답과 화면 or 내보내기, with the file for each step.
2. Say what happens on failure and which version the screen shows afterwards.

Fill the module table: 모듈 | 책임 | 소유 상태 | 상태를 바꾸는 주체 | 파일. Each piece of state (current dataset, conditions, result) has exactly one owning module. If two modules write the same state, change the design before building.

## 6. Order the units
Write PLAN.md Units. Rules:
- Each unit takes 20 to 45 minutes and ends in a named check: a test name, a smoke line, or a screenshot.
- One writer at a time, so the build runs units in table order. Keep that order:
  1. BE: types, the core logic, and `src/domain/check.ts`, with unit tests that run the check on the core logic's output for the real data.
  2. BE: store and the stateful defaults.
  3. BE: routes with smoke lines. Fix the API contract (request and response types in `src/domain/`) here.
  4. FE: the first screen against the real API, so a human can open the preview early.
  5. Then alternate BE and FE units by R# priority.
  6. BE: the what-if entry (`src/domain/what-if-entry.ts` exporting `run(params)`, with `asis` and `baseline` params and a `ruleViolations` metric; `build` skill, what-if step) once the core logic is DONE.
- Must units first. Should and Could units go after them and are the first to be cut at the feature freeze.
- Each row lists the files it touches. Two units never touch the same file in one pass.

## 7. Builder check
Adapted from the builder check in obra/superpowers `brainstorming` (MIT). Spawn a fresh read-only `planner` agent with this brief, so a reader who was not in the conversation tests the documents:

```text
You are a talented software engineer. You've been handed PLAN.md, docs/ARCHITECTURE.md, and DECISIONS.md and asked to build what they describe. You will not be able to talk to the person who wrote them.
Report only the questions you'd still need answered before you could plan this well: places where you'd have to guess and a wrong guess would matter. For each, give the question and why the answer changes the plan. Rank them by importance.
Skip anything the documents explicitly leave to the builder, and anything you could reasonably decide yourself. Skip nitpicks about wording.
If nothing important is left, say "nothing important left". Return your answer as markdown. Do not write files.
```

If this Codex build cannot spawn agents, read the documents as that builder yourself and say so in the step 8 message. Sort what comes back into three piles:
- Answered already by a C#, an A#, or the task files: put the answer in the document.
- Minor: a sensible builder could settle it without changing what gets built. Settle it, and log it as an A# or a D# marked as your call.
- Theirs: only the user or the stakeholder can answer it, and the answer changes what gets built. Add each stakeholder question to QUESTIONS.md as a Q# and put them in the step 8 message as a copy-ready block, most important first.

## 8. Get approval
Send one message and wait:
1. The R# table: id, one-line requirement, source, priority.
2. The U# table: id, lane, R#s, check, estimated minutes, and the total against the feature freeze.
3. The core D# in six lines: the approved approach and the E# that decided it, the criterion, how it works, what it gives up, and the hard rules `check.ts` will enforce.
4. The A#s the plan relies on, and the calls you made in the builder check.
5. The "theirs" questions from the builder check, if any.
6. One line for the user: during the routes unit Codex will ask once to run `npm run dev` in a separate terminal; leave it running and open its port in the preview.

Record the answer as a change-log row (승인, or the edits and their reason). Then start `$build`.

## Done when
- `docs/ARCHITECTURE.md` has types, one flow per user action, and the module table with one owner per state.
- The core D# has every field, with the user's approval quoted unchanged and 증거 marked "build 후 채움" where it waits on tests.
- The builder check ran, and each "theirs" question is answered or recorded as an A#.
- Every Must R# appears in at least one U#, and every U# names its check.
- The user approved, and the change log says so.
