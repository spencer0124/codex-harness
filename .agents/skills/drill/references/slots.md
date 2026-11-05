# Slots, questions, and cards

## How the questions are built

- One template per slot, always in the order S1 to S6. Each joins three or four sub-questions in one paragraph ("…하는지, …인지, 그리고 …는 무엇인지").
- The last sub-question asks for a weakness: what was given up, what is assumed or unbuilt, when it breaks, what is still unverified, what was fixed or discarded. S2 is the exception: its last asks who owns which state.
- Names come from the docs. Where the docs name something, the question quotes it: the decision's name, the module names, the state names, a button label, metric names, a case title, a section heading.
- Where the docs name nothing, the question fills in generic content. With no rejected alternative written down, it supplies common ones, marked "예:". Expect to compare against alternatives the docs never mention.
- A list in parentheses is the checklist. Questions often carry one: modules, conditions, metrics, example alternatives. Each item needs its own sentence in the answer, by name.
- Every slot comes in two shapes, A and B below. S4 differs the most between its two: shape A asks about stored state, shape B about domain edges built from hidden conditions. Prepare both shapes for every slot.

## The six slots

| Slot | Asks about | Sub-questions, in answer order | Sources for the card |
|---|---|---|---|
| S1 design choice | the core decision (DECISIONS.md D1) | the criterion for a better result, how it works (input → steps → output), why it was chosen, how each alternative differs, what was given up | DECISIONS.md D1, the `file:function` it cites |
| S2 data flow | one user action, or the whole pipeline, from stored input to the stored result, the screen, and the export | the modules in order, each module's responsibility, the state each module owns, who changes that state | `docs/ARCHITECTURE.md`, routes, store code |
| S3 verified vs not | what is implemented and checked, and what is planned, assumed, or unchecked; or how the output is shown to obey the rules | the status of each area, and how someone else checks it: the file, the command, the state to look at | REPORT.md traceability and 규칙 준수, `docs/EVIDENCE.md`, A# rows in `docs/analysis/CONDITIONS.md` |
| S4 change, failure, concurrency, edges | a condition change, a mid-way failure, two concurrent requests; or edge combinations from hidden conditions | what happens to the current and the previous result, or what the system produces, then when wrong output appears or something breaks, and what guards against it | `docs/RISKS.md`, store and domain code and their tests, C# rows from stakeholder answers |
| S5 metrics and sensitivity | why the result is better and the limits of each metric; or the effect of input changes and abnormal values | the metric definitions, the measured numbers against the baseline, the limits, a prediction per input change, the next check to add | REPORT.md 지표와 민감도, the what-if E# |
| S6 AI case | one case in AI_COLLABORATION.md, or one incident from its 어려웠던 점 | how the problem was found, how it was reproduced, the order of test and fix, what was accepted, modified, or discarded among the AI's tests and code, and the evidence for each | AI_COLLABORATION.md, the F# row in `docs/AI_LOG.md`, the E#s, `git log` |

## Write the question

Write every question as someone who read this submission closely, in Korean, polite form. Use only what this repository says, plus the generic fillers marked "예:". Put the uncomfortable sub-question last.

Fill both shapes from the docs. Ask shape A first. Use shape B for the re-ask.

- S1
  - A: "<D1 이름> 방식을 택하셨습니다. 이 방식이 정확히 어떻게 동작하는지, 왜 이것을 택했는지, <기각한 대안들>과 무엇이 다른지, 그리고 이 선택으로 포기한 것은 무엇인지 설명해 주세요."
  - B: "<과제가 맡긴 판단, 예: 좋은 결과의 기준>을 직접 정해야 하는 과제였습니다. <핵심 처리>를 어떤 접근으로 했나요? 다른 대안(예: 한 지표만 최소화, 가중치 점수 합산, 전역 최적화)과 비교해 왜 그 접근을 골랐는지, 그로 인해 포기한 것은 무엇인지 설명해 주세요."
- S2
  - A: "<입력>을 선택·검증·적용하고 <결과>를 만들어 저장한 뒤 화면과 <내보내기>로 이어지는 전체 흐름을 모듈(<ARCHITECTURE.md의 모듈 이름들>) 단위로 설명해 주세요. 각 모듈의 책임과, 어느 모듈이 어떤 상태(<상태 이름들>)를 소유하는지도 말씀해 주세요."
  - B: "사용자가 '<화면의 버튼 문구>'를 눌렀을 때 저장된 <입력>에서 최종 저장되는 <결과>까지 데이터가 어떤 모듈과 단계를 거치는지 설명해 주세요. 각 단계의 책임과 상태를 누가 갖는지도 알려 주세요."
- S3
  - A: "최종 제출물에서 실제로 구현·검증된 것과 계획만 있거나 사람이 확인하지 못한 것을 어떻게 구분해 두었나요? 각각을 다른 사람이 확인하려면 어떤 파일, 명령, 상태를 보면 되는지 예를 들어 설명해 주세요."
  - B: "생성된 <결과>가 <규칙들>을 지킨다는 것을 이 제출물은 어떻게 확인하나요? 어떤 부분이 실제로 구현·검증되었고, 어떤 부분이 가정이거나 구현하지 않은 것인지 구분해서 설명해 주세요."
- S4
  - A: "사용자가 조건(<조건 이름들>)을 바꾸거나, <생성이나 적용>이 도중에 실패하거나, 두 사용자가 동시에 <작업>을 요청하면 이 시스템은 현재 결과와 이전 결과를 어떻게 다루나요? 어떤 조건에서 잘못된 결과가 보이거나 깨질 위험이 있는지도 말씀해 주세요."
  - B: "<자정을 넘겨 성격이 다른 날로 이어지는 항목>과 <그날 빠지는 대상>의 경우 시스템은 <결과>를 어떻게 만드나요? <기간의 마지막 날이 그 경계에 걸릴 때>는 어떤 위험이 있나요?" Take the edges from C# rows and the data profile.
- S5
  - A: "<결과>가 실제로 <목표>를 개선했다고 어떤 근거로 확신하시나요? 지표 정의(<지표 이름들>)의 한계와 아직 검증하지 못한 부분을 짚고, 다음에 어떤 입력이나 점검을 추가하시겠습니까?"
  - B: "<한계값>을 줄이거나 <여유값>을 크게 늘리거나 <입력 필드>에 소수·0 값이 들어오면 결과가 어떻게 달라질지 예측하고, 이 설계의 약점을 확인하려면 어떤 추가 검증이나 개선을 하겠습니까?"
- S6
  - A: "AI_COLLABORATION.md에 적은 <사례 제목>을 실제로 어떻게 진행했나요? 문제를 어떻게 재현했고, 테스트와 수정은 어떤 순서로 했으며, 그 과정에서 AI가 낸 결과 중 받아들인 것, 고친 것, 버린 것은 무엇인가요? 각각 어떤 근거(실행 결과 등)로 판단했는지도 설명해 주세요."
  - B: "AI_COLLABORATION.md에 적은, AI의 한계가 드러난 사례(<어려웠던 점에 적은 작업>)를 실제로 어떻게 진행했나요? 문제를 어떻게 발견했고, AI가 준 코드·테스트 중 무엇을 그대로 두고 무엇을 고치거나 버렸는지, 각각 어떤 근거(실행한 테스트·명령과 결과 등)로 판단했는지 구체적으로 설명해 주세요."

## Variants for further re-asks

- S1: one generic alternative in depth: what result it would have given on this data.
- S2: the failure path of the same action, or the export.
- S3: the weakest row in the traceability table, or the HUMAN-CHECKED rows.
- S4: the shape not yet asked, another edge combination, or a hidden condition from a C# row.
- S5: an input the what-if table does not cover.
- S6: the second case, or the AI output that was discarded.

## Answer form

The user types 350 to 500 Korean characters in five minutes. Grade against this form and teach it:

1. One sentence that answers the whole question.
2. One numbered part per sub-question, in the question's order: `1) … 2) … 3) …`.
3. Each item of a parenthetical list by name, one sentence each, inside its part.
4. At least one name a reader can check in each part: `파일:함수`, a test name, a command, or a number with its source.
5. The last part gives the weakness as a condition and a consequence ("<입력>이 <조건>이면 <결과>가 생기고, 화면은 <무엇>을 보인다"), then the next check.

Time budget: 30 s to read and note the list items, 3 min for one sentence per part, 1 min to add names and numbers, 30 s to check the last part.

## Card format

Write one card per slot in `.study/cards.md`, in Korean.

```markdown
## S1 설계 선택
- 결론 한 줄: <질문 전체에 대한 답 한 문장>
- 키워드 3개: <`파일:함수`>, <숫자와 그 E#>, <테스트 이름>
- 예상 질문 A: <위 A 형식>
- 예상 질문 B: <위 B 형식>
- 하위 질문 순서: 기준 → 동작 → 이유 → 대안과 차이 → 포기한 것
- 핵심 포인트:
  1. <사실 한 줄> (`src/domain/rules.ts:checkRules`)
  2. <숫자가 있는 사실> (E7)
  3. ...
- 변형 대비: <아래 슬롯별 준비>
- 답 뼈대: <하위 질문마다 한 문장, 번호를 붙여>
- 약한 곳: <근거가 얇은 주장, 파일:줄>
- 말하면 안 되는 것: <이 주제에서 검증하지 않았거나 만들지 않은 것. 라벨(미검증, 미구현, 가정)과 함께>
```

Keep five to seven points per card. Every point names a file, a command, a test, an E#, or a number from an E#.

The conclusion line and the three keywords are what the user recalls first under the timer. "말하면 안 되는 것" lists claims that would sound right but have no E# or test; saying them costs accuracy. Take them from 미검증, 미구현, and 가정 labels in the docs, ASSUMED and NOT-IMPLEMENTED rows in REPORT.md, and PARTIAL or CUT rows in PLAN.md.

What goes under "변형 대비" for each slot:

- S1: the criterion in priority order. One line per generic family: one metric only, a weighted sum, an exact or global solver, modes or weights the user picks. Each line says how it differs and what it would have produced: from the what-if `baseline` row or a 되돌린 시도 row where it ran, marked 예측 where it did not.
- S2: two chains the user can say aloud, `파일:함수 → 파일:함수 → …`: the whole pipeline and the regenerate action. Then each state name with its one owner.
- S3: the four status labels and where each lives. Then the 규칙 준수 table: rule → check function → when it runs → test.
- S4: three state cases (condition change, mid-way failure, concurrent requests) and three edge combinations, each as "입력 → 담당 함수 → 실제 동작 → 테스트".
- S5: each metric's definition and its difference from the `baseline` row. Then three limit changes and two abnormal values (0, a fraction): the result from the what-if E# where it ran, marked 예측 where it did not.
- S6: every case and every incident in 어려웠던 점: the output that revealed it, the reproduce command, the order, and a verdict for the AI's test and for its code separately.
