---
name: drill
description: Practice answering timed written questions about this submission, grade the answers against the repository, and write a three-minute pitch script from the evidence. Start only when the user types $drill. Never invoke it on your own or from another skill.
---

# Drill

The user practices explaining their own submission in their own words. You ask, they type, you grade against the repository. You also write the script for a three-minute spoken pitch. You never edit a tracked file.

Arguments: none runs cards, then the pitch script, then the quiz. `cards` writes cards only. `pitch` writes the pitch script only. `quiz` skips the cards and the pitch. `S1` to `S6` asks one slot. A number such as `quiz 3` sets the question count.

## Files

- Write only under `.study/`. The first line of every file you create there is exactly:

  ```text
  <!-- HARNESS-PRACTICE -->
  ```

  `scripts/presubmit.sh` fails if that line shows up in a tracked file or in git history, and moves `.study/` out of the workspace before submission. Append to existing files below the first line. Never write the line anywhere else.
- Before writing, run `git check-ignore -q .study/cards.md`. If it exits nonzero, stop and tell the user to rerun `apply.sh`.
- Files: `.study/cards.md` (one card per slot), `.study/attempts.md` (every graded answer), `.study/weak-claims.md` (claims the user could not defend), `.study/pitch.md` (the pitch script).

## 1. Read the submission

Read README (the task), REPORT.md, DECISIONS.md, `docs/ARCHITECTURE.md`, `docs/RISKS.md`, AI_COLLABORATION.md, `docs/EVIDENCE.md`, `docs/AI_LOG.md`, PLAN.md, `docs/analysis/CONDITIONS.md`, and `git log --oneline`. Open the source files those docs cite. List the claims a careful reader would quote: the core decision's name, user actions, metric names, case titles, hidden conditions from stakeholder answers.

## 2. Write the cards

Read `references/slots.md`. Write one card per slot S1 to S6 into `.study/cards.md`, in Korean, in the card format there: the conclusion line, the three keywords, both expected questions (A and B), "변형 대비", and "말하면 안 되는 것". Every point must be true in the current code. Check it before you write it.

When grading (step 4), a statement from a card's "말하면 안 되는 것" counts as a wrong statement under Accuracy.

## 2b. Write the pitch script

The pitch is spoken, about three minutes, with no slides assumed; at most the running product is on screen. Paper is not allowed in the room, so the user memorizes it. Write `.study/pitch.md` in Korean, spoken style, in five parts:

| Part | Seconds | Content |
|---|---|---|
| 문제 | 20 | The task in the stakeholder's words, and the bottleneck they named (C#) |
| 데모 | 60 | One screen: the target measure next to its `asis` value. Name the screen path and the clicks |
| 검증 | 40 | Rule violations, the difference from `asis` and `baseline`, the `ms` of the largest-size row |
| 한계 | 40 | One weakness from REPORT.md Limitations, and what the system does when it cannot decide |
| 마무리 | 10 | One sentence: the number, and the stakeholder question that produced it |

- Every number is copied from an E#. Put the E# in brackets after the sentence so the user can check it; they do not say it aloud.
- About 300 Korean characters per minute of speech: keep the script under 900 characters.
- No claim the repository does not back. Nothing from a card's "말하면 안 되는 것". If `asis` is 미확인, say the comparison is against the plainest method only.
- Below the script, list two questions a judge would likely ask (why this approach, what breaks first), each with a three-line answer skeleton.

Then tell the user, in Korean: read it aloud once with a phone timer and reply with the seconds. Over 190 seconds, cut the 데모 or 한계 lines that carry no number and rewrite. Do not wait for the reply before the quiz.

## 3. Run the quiz

Tell the user these rules once, in Korean:

- 기본 6문항, 문항당 5분. 휴대폰 타이머로 직접 잰다.
- 답은 직접 친다. 복사, 붙여넣기, 카드나 코드 보기 없이.
- 한 번 낸 답은 고치지 않는다. 다음 문항으로 넘어가면 돌아가지 않는다.
- 350~500자. 첫 문장은 결론, 그다음 하위 질문 순서대로 `1) 2) 3)` 번호를 붙인다.
- 질문에 괄호 안 목록이 있으면 항목 이름을 그대로 써서 하나씩 답한다.
- 시간이 모자라면 먼저 하위 질문마다 한 문장씩 쓰고, 남은 시간에 파일 이름, 명령, 숫자를 붙인다.

Ask one question at a time, built per `references/slots.md`: shape A for each slot on the first pass. Do not show the card or any hint before the answer. Wait for the answer.

## 4. Grade each answer

Score out of 10 and show the breakdown:

| Part | Points | Full marks when |
|---|---|---|
| Coverage | 4 | every sub-question, and every item of the question's parenthetical list, gets an explicit answer, in order |
| Accuracy | 3 | every factual statement matches the code and docs |
| Specificity | 2 | the answer names files, commands, tests, or numbers |
| Limits | 1 | the answer says what was given up, what breaks, or what is unverified |

Then give, in Korean:

1. 빠진 하위 질문.
2. 틀린 말: the wrong statement, the correct fact, and `file:line` where it is written.
3. 답 뼈대: one sentence per sub-question, in order, four to six lines. The user writes their own answer from it, not a script to memorize.

Grade strictly. A vague answer that sounds right scores low on specificity. Never round up.

Append to `.study/attempts.md`: time, slot, question, the answer verbatim, the breakdown, the missed points.

## 5. Repeat the weak slots

After the last question, show a table of slot, score, and the main miss. Re-ask the two weakest slots in shape B, then with the further variants in `references/slots.md`. Ask S4 in shape B even if it scored well: the two shapes test different knowledge. Continue until the user stops.

## 6. Collect weak claims

When the user cannot defend a claim twice, or the claim has no evidence in the repository, append to `.study/weak-claims.md`: the claim, `file:line`, why it is weak, and one suggestion (add evidence, relabel it 미검증, or cut it). Tell the user. Changing the doc is their call. If they want it and the doc freeze in PLAN.md has not passed, they run `$writeup`.
