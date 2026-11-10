---
name: approach
description: Phase 2. Pick the core approach from evidence, not opinion. Fix the criteria first, draft candidates from independent lenses, run short spikes where candidates differ in measurable results, decide, record it as D1, report on one screen, and wait for one approval. On approval, go straight to `$plan`. Use `$approach` after `$analyze` exits.
---

# Approach

The user hands this choice to Codex: they ask for the best approach, picked and reported. Codex picks. The record must let anyone retrace the pick: the criteria came before the candidates, every candidate is on file, and every number has an E#.

Sources: the `brainstorming` skill of [obra/superpowers](https://github.com/obra/superpowers) (MIT) for laying out approaches, spikes, and the gate; quoted lines are its words. The independent drafts, criteria hidden from drafters, and anonymous comparison follow pstack `arena` and karpathy/llm-council. D1 follows the MADR layout (context, decision drivers, considered options, outcome, consequences).

Run in Default mode. Plan mode cannot write files.

Inputs: PLAN.md Goal, Requirements, and Timebox; `docs/analysis/CONDITIONS.md`; `docs/analysis/DATA.md`; README.
Outputs: D1 in DECISIONS.md, spike E#s in `docs/EVIDENCE.md`, one change-log row in PLAN.md.
Timebox: 40 minutes from start to report, spikes included. When time runs out, decide on the evidence you have and say what was not measured.

## 1. Name the core and fix the criteria

1. Name the one piece of logic the task is really about: the algorithm, the rule engine, the scoring. Only the core gets candidates. Storage, libraries, screens, and layout are ordinary calls under AGENTS.md section 4.
2. Before any candidate exists, write the criteria into D1 `판정 기준`. Apply them in order. A later criterion only breaks ties left by the earlier ones:
   1. 하드 제약: zero violations of every Must C# rule on the real data.
   2. Must 커버: meets every Must R#.
   3. 목표 지표: the result measure the task or the stakeholder named, with its C#. If it names several and no order, rank them by their effect on output (throughput, wafer moves, units shipped): the measure with less effect gives way. Record that order as an A#, add one confirming Q# to `docs/analysis/QUESTIONS.md`, and list it in the report under 확인 질문: "두 목표가 부딪치면 생산량 영향이 큰 <X>를 지키면 될까요?"
   4. 완성 가능성: buildable and testable before the feature freeze, with 20% slack.
   5. 설명 가능성: the user can explain how it works in three sentences without AI.
3. Do not change the criteria after you see candidates. If one turns out wrong, record the change and its reason in D1 and restart from step 3.

## 2. Draft candidates from independent lenses

Spawn three read-only `planner` agents in parallel, one lens each. Give none of them the criteria. Each returns one candidate in under 20 lines: how it works in three steps on the real data (names from DATA.md), the Must R#s it meets and strains, its cost in minutes, how it fails and what the user sees then.

- 현행·최소: reproduce how the work is done today, or the simplest thing that fully works.
- 정확해: an exact or global method (solver, full search, closed form).
- 휴리스틱: a rule, score, or greedy method, with a repair step if needed.

Add the common families that fit and no lens produced: optimizing one metric only, a weighted sum of metrics, and, for a recommendation, modes or weights the user picks. Drop each candidate that breaks a Must C#, contradicts a stakeholder answer, or cannot finish before the feature freeze, with one line on why.

If this Codex build cannot spawn agents, draft the three lenses yourself one after another and write `독립 초안 아님` in D1.

When two drafts converge, treat that as strong agreement. When all three diverge widely, the problem is probably underspecified: check CONDITIONS.md for a missing condition before comparing.

## 3. Compare without names, and measure what numbers decide

1. Label the surviving candidates P, Q, R in a random order. Score them against the criteria by label, not by lens.
2. Wherever two candidates could differ on criterion 1 or 3, run a spike instead of arguing. "A quick throwaway build is often the cheapest way to learn … whether something works." Dispatch one `implementer` per spike, one at a time, with this note at the top of its brief: `SPIKE: skip the test steps. Write only under .harness/spikes/<label>/. Run it on the real data and report violations, the target measure, and run time.` Give each spike 15 minutes at most. "Spikes get no tests or minimal ones, aren't bulletproof, and skip the plan, implementation, and review process."
3. Record each spike run as an E# in `docs/EVIDENCE.md` with the command and the output lines verbatim. A number without an E# does not count.
4. Pick the candidate that wins the criteria in order. If the top two tie on every measured criterion, take the simpler one.

## 4. Write D1

Fill D1 in DECISIONS.md:
- 상태: `승인 대기`
- 배경: the core and the C#s that shape it.
- 판정 기준: the list from step 1, as written before the candidates.
- 검토한 방안: every candidate, dropped ones included, with its lens and why it was dropped or lost.
- 비교: one row per candidate, one column per criterion, each cell a value with its E#, or `검토만, 실측 안 함`.
- 선택: the winner, and the rule that decided it ("1번 기준에서 Q만 위반 0건, E4").
- 포기한 것, 다시 볼 조건 (the measured threshold that sends you back to step 2), and 설명 3문장.
- 선택 주체: `Codex 판단 (사용자가 위임)`.

## 5. Report and wait for one approval

Send the report as a message of its own, on one screen:

```text
[핵심 방법] <선택> (Codex 판단, D1)
왜: <결정한 기준과 숫자, E#>
비교: <후보별 한 줄: 기준 1-3의 값, E#>
버린 것: <방안: 이유>
포기한 것: <한 줄>
다시 볼 조건: <측정 기준>
설명 3문장: <사용자가 AI 없이 말할 문장>
확인 질문: <기준 3의 지표 순서를 가정했으면 그 Q#과 문장, 없으면 생략>

승인하면 바로 $plan으로 갑니다. 승인할 때 이유를 한 줄 덧붙여 주세요(예: "위반 0건이 우선이라 수용").
```

Then stop until the user answers. Do not start `$plan`, `$build`, or product code before the answer. The report plays the part of the design doc in "Nothing gets built until your human partner approves the design doc".

## 6. On the answer

- Approval, in any words: copy the reply verbatim into D1 `사용자 승인 (원문)`, set 상태 to `승인됨 (HH:MM)`, add a change-log row in PLAN.md, and start `$plan` in the same turn. Do not wait for the user to type it.
- A different pick or a correction: record the reply verbatim the same way, update D1 (선택 주체 becomes `사용자 선택`), and go on to `$plan`.
- A question: answer it from D1 and the E#s, then wait again.

If a later fact or the midpoint check undermines the pick, run this skill again. Write the new pick as a new D# that supersedes D1, add a 되돌린 시도 row, and keep D1 as it was.

## Red flags

| Thought | Reality |
|---|---|
| "I'll set the criteria once I see which option looks best" | Criteria come first. Changed criteria go on record with a reason. |
| "The candidates differ on violations, but I can reason it out" | If running it would show the answer, run it. A number needs an E#. |
| "Three lenses is overkill, I'll write the one I like" | The record has to show the alternatives were real. |
| "The user approved, so I'll polish their reason" | Their words go in verbatim. Yours stay in the other D1 fields. |
| "The spike works, I'll keep building on it" | "Keeping it is a new request." Spikes stay in `.harness/spikes/`. |
