---
name: analyze
description: Phase 1 condition analysis. Turns the README, task text, and data into numbered conditions, writes every question for the stakeholder (업무 담당자) as one copy-ready block, and folds pasted answers back in round by round until no P0 or P1 question is open, then drafts the requirements in PLAN.md. Use `$analyze` at the start of a task and `$analyze integrate` each time stakeholder answers arrive.
---

# Analyze

Hidden conditions come out only when someone asks, and most come out on the second question about the same topic. Ask a lot, ask again after every answer, and give every condition a source.

## Files

| File | Holds | Written by |
|---|---|---|
| `docs/analysis/CONDITIONS.md` | C# conditions, A# assumptions, conflicts | this skill |
| `docs/analysis/QUESTIONS.md` | Q# questions, skipped categories, rounds | this skill |
| `docs/analysis/DATA.md` | data profile | `scripts/profile-data.mjs` |
| `docs/analysis/answers/round-N.md` | stakeholder transcript, verbatim | the user, or you when the user pastes it in chat |
| `PLAN.md` | Goal, Timebox, Requirements | this skill, at exit |

`scripts/` and `references/` are folders inside this skill.

## First run: `$analyze`

1. List the inputs: README and task files, other docs, data files (`.csv`, `.tsv`, `.json`), images or mockups. Read every one.
2. Profile the data yourself:
   `node .agents/skills/analyze/scripts/profile-data.mjs <data files or folders> > docs/analysis/DATA.md`
3. Dispatch two `analyst` agents in parallel (`.codex/agents/analyst.toml`). Both are read-only and return markdown:
   - `extract`: every line of the task sources that constrains data, rules, outputs, screens, or process, with its source line.
   - `probe`: candidate questions for each category in `references/hidden-conditions.md`, from the task sources and DATA.md.
   If this Codex build cannot spawn agents, do both yourself, extract first.
4. Write CONDITIONS.md: one C# per condition, one sentence, a short quote, a source (`README L12`, `DATA stops.csv:lat`). A C# without a source does not exist.
5. Collect questions from three places: every vague word in a C# ("적절히", "가까운", "효율적", and the like), every line under "질문 후보" in DATA.md, and every probe. Do not ask what a C# already answers plainly. Ask about its exceptions instead. A question the data can answer: answer it from DATA.md, then ask only to confirm the intent.
6. Write QUESTIONS.md. Remove duplicates, then give each Q# a priority:
   - P0: the answer changes the data model, the core algorithm, or what counts as a correct result.
   - P1: the answer changes an edge-case behavior or something the user sees.
   - P2: wording, defaults, display details.
   Each Q# carries its category, why it matters in one line, the default you would use without an answer, and the C# or R# it affects. A category from the reference that does not apply goes under "Skipped categories" with its reason.
7. Reply with the counts (C#, Q# per priority), the copy-ready block, and one question for the user: the end time of the task, for the Timebox in PLAN.md. Then stop and wait.

### Copy-ready block

The stakeholder sees none of our files, so every question must stand alone. Write one question per line, P0 first, in polite Korean. Split a compound question into one line per part. Include P2: questions cost nothing, and a missed condition costs a rebuild.

```text
[round 1 질문]
Q1. …?
Q4. …?
```

## Integrate: `$analyze integrate [N]`

1. If the user pasted the transcript in chat, save it verbatim to `docs/analysis/answers/round-N.md` first. Never edit a saved transcript. Without N, use the newest round.
2. Read the round. It has no fixed format. Match each answer to its Q# by meaning, not by order. One answer can close several questions.
3. Record each fact as a C# with source `담당자 HH:MM (round N, Q#)`. Use the time in the transcript, or the time of the paste when it has none. Record facts nobody asked about too. Those are often the hidden conditions.
4. Mark answered questions `ANSWERED→C#`. A partial answer stays OPEN with a note on what is missing.
5. Compare each new C# with the README conditions. On a conflict, add a row to the Conflicts table in CONDITIONS.md, show the user both quotes, and stop until the user decides (AGENTS.md section 2).
6. Write follow-ups for every answer and every unasked fact:
   - boundary: exactly at the limit, on the first and last day, at zero;
   - exception: who, which day, or which data does not follow the rule;
   - priority: which rule wins when this one meets another C#;
   - "그 밖에 이와 비슷하게 따로 처리해야 하는 경우가 있나요?"
   Ask each P0 fact a second time as a concrete example, as the reference describes.
7. If PLAN.md already has requirements, update the affected R#s and add a change-log row.
8. Reply with what changed (new C#s, closed Q#s, conflicts) and the next round's copy-ready block. If no P0 or P1 question is OPEN, go to Exit instead.

## Exit

1. Turn every OPEN question into an A# in CONDITIONS.md: the default, the Q# it replaces, why it is the safest reading, and the code that changes if it is wrong. Mark the Q# `ASSUMED→A#`.
2. Write the Goal in PLAN.md (one line with its README line) and the Requirements. Group C#s into R#s. Each R# cites its C#s or A#s and has an acceptance criterion that a test or a smoke line can check: a given input and the expected result. Items the README or the stakeholder calls required are Must.
3. Check coverage: every C# is cited by an R#, or its 반영 R# cell says 배경. List each C# that is neither.
4. Check that the Timebox in PLAN.md is filled. If the user has not given the end time, ask again.
5. Reply with the R# count per priority, the A# list (the user may overrule any of them), the uncovered C#s, and "next: `$approach`".

## Rules

- Docs are in Korean (AGENTS.md section 8). Use the ids in AGENTS.md section 6.
- Rounds have no limit. Keep going while answers produce new facts.
- Never invent a condition, a source line, or an answer.
