# Slots, questions, and cards

## The six slots

| Slot | Asks about | Sub-questions, in answer order | Sources for the card |
|---|---|---|---|
| S1 design choice | the core decision (DECISIONS.md D1) | how it works (input → steps → output), why it was chosen, how each alternative differs, what was given up | DECISIONS.md D1, the `file:function` it cites |
| S2 data flow | one user action from input to the stored result, the screen, and the export | the modules in order, each module's responsibility, the state each module owns, who changes that state | `docs/ARCHITECTURE.md`, routes, store code |
| S3 verified vs not | what is implemented and checked, and what is planned, assumed, or unchecked | the status of each area, and how someone else checks it: the file, the command, the state to look at | REPORT.md traceability, `docs/EVIDENCE.md`, A# rows in `docs/analysis/CONDITIONS.md` |
| S4 change, failure, concurrency, edges | a condition change, a mid-way failure, two concurrent requests, boundary dates, hidden conditions | what happens to the current and the previous result, when wrong output appears or something breaks, what guards against it | `docs/RISKS.md`, store code and its tests, C# rows from stakeholder answers |
| S5 metrics and sensitivity | why the result is better, the limits of each metric, the effect of input changes | the metric definitions, the measured numbers, the limits, a prediction per input change, the next check to add | REPORT.md 지표와 민감도, the what-if E# |
| S6 AI case | one case in AI_COLLABORATION.md | how the problem was found, how it was reproduced, the order of test and fix, what was accepted, modified, or discarded and the evidence for each | AI_COLLABORATION.md, the F# row in `docs/AI_LOG.md`, the E#s, `git log` |

## Write the question

Write every question as someone who read this submission closely.

- Open with one specific claim from the docs, in the docs' own words: the decision's name, an action or route name, a metric name, or a case title.
- Ask the sub-questions in one paragraph, in the order of the table. Put the uncomfortable one last: what was given up, when it breaks, or what is still unverified.
- Write in Korean, polite form ("설명해 주세요").
- Use only what this repository says. A question about something the docs never claim teaches nothing.

Fill these shapes from the docs:

- S1: "<D1 이름> 방식을 택했다고 적었습니다. 이 방식이 실제로 어떻게 동작하는지, 왜 이것을 골랐는지, <기각한 대안들>과 무엇이 다른지, 이 선택으로 포기한 것은 무엇인지 설명해 주세요."
- S2: "사용자가 <동작>을 하면 <입력>에서 <저장되는 결과>와 화면까지 데이터가 어떤 모듈을 어떤 순서로 거치나요? 모듈마다 책임과, 어떤 상태를 누가 소유하고 바꾸는지도 설명해 주세요."
- S3: "<핵심 규칙이나 기능>이 지켜진다는 것을 이 제출물은 어떻게 확인하나요? 실제로 구현하고 검증한 것과 가정이거나 사람이 확인하지 못한 것을 나누고, 다른 사람이 각각을 확인하려면 어떤 파일과 명령을 보면 되는지 예를 들어 주세요."
- S4: "<조건>이 바뀌거나, <작업>이 도중에 실패하거나, 두 사용자가 동시에 <작업>을 요청하면 현재 결과와 이전 결과는 어떻게 되나요? <경계 날짜나 숨은 조건>에서는 어떤 위험이 있나요?"
- S5: "<지표>로 결과가 나아졌다고 판단한 근거는 무엇인가요? 지표 정의의 한계를 짚고, <입력 변화 2-3개>가 들어오면 결과가 어떻게 달라질지 예측한 뒤, 다음에 어떤 점검을 추가하겠습니까?"
- S6: "AI_COLLABORATION.md에 적은 <사례 제목>을 실제로 어떻게 진행했나요? 문제를 어떻게 발견하고 재현했는지, 테스트와 수정은 어떤 순서였는지, AI가 낸 것 중 받아들인 것, 고친 것, 버린 것과 각각의 근거를 설명해 주세요."

## Variants for re-asks

Ask the same slot from a different angle:

- S1: compare against one rejected alternative in depth, or ask what result the alternative would have produced.
- S2: a different user action, or the failure path of the same action.
- S3: the weakest area in the traceability table, or the HUMAN-CHECKED rows.
- S4: another failure point, another boundary date, or a hidden condition from a C# row.
- S5: other input changes from the what-if table, or an input the table does not cover.
- S6: the second case, or the AI output that was discarded.

## Card format

Write one card per slot in `.study/cards.md`, in Korean.

```markdown
## S1 설계 선택
- 예상 질문: <위 형식으로 만든 질문>
- 하위 질문 순서: 동작 → 이유 → 대안과 차이 → 포기한 것
- 핵심 포인트:
  1. <사실 한 줄> (`src/domain/rules.ts:checkRules`)
  2. <숫자가 있는 사실> (E7)
  3. ...
- 답 뼈대: <하위 질문마다 한 문장>
- 약한 곳: <근거가 얇은 주장, 파일:줄>
```

Keep five to seven points per card. Every point names a file, a command, a test, an E#, or a number from an E#.
