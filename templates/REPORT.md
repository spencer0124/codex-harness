# REPORT

## 1. 요약
<무엇을 만들었고 무엇이 동작하는지 3-5줄. Must R# n개 중 m개 VERIFIED.>

## 2. 실행 방법
- 설치: `<명령>`
- 실행: `PORT=<포트> <명령>` (0.0.0.0 바인딩) → 미리보기 경로 `/<경로>`
- 테스트: `<명령>`
- smoke: `PORT=<포트> bash scripts/smoke.sh`
- 민감도: `npx tsx scripts/what-if.mjs src/domain/what-if-entry.ts scripts/what-if.scenarios.json`

## 3. 구조
모듈별 책임과 소유 상태는 `docs/ARCHITECTURE.md`에 있다.

<입력> → <모듈> → <모듈> → <저장> → <화면 / 내보내기>

## 4. 추적표
| R# | 요구 | 근거 C#/A# | 구현 (파일:함수) | 검증 (테스트 / smoke / 스크린샷) | 증거 E# | 상태 | 확인 방법 | 커밋 |
|---|---|---|---|---|---|---|---|---|
| R1 | | C1 | | `R1: ...` | E1 | VERIFIED | `<명령>` 재실행 | |

| 상태 | 뜻 | 다른 사람이 확인하는 법 |
|---|---|---|
| VERIFIED | 테스트나 smoke가 통과했고, 그 출력이 E#에 있다 | E#의 명령을 다시 실행한다 |
| HUMAN-CHECKED | 사람이 미리보기에서 봤다. 자동 검사는 없다 | 7절 수동 확인 표의 경로와 단계를 따라 한다 |
| ASSUMED | 답이 없어 정한 기본값(A#)에 기대고 있다 | `docs/analysis/CONDITIONS.md`의 A#를 읽는다 |
| NOT-IMPLEMENTED | 만들지 않았다 | 9절 미구현 목록 |

## 5. 핵심 결정
상세는 `DECISIONS.md`에 있다. D#마다 한 줄.
- D1:

## 6. 지표와 민감도

### 지표 정의
| 지표 | 정의 (코드가 계산하는 그대로) | 코드 (파일:함수) | 한계 |
|---|---|---|---|

### 기준 실행과 변형 실행
`npx tsx scripts/what-if.mjs src/domain/what-if-entry.ts scripts/what-if.scenarios.json` 출력 그대로 (E#):

<표 붙여넣기>

| 변형 | 무엇이 바뀌었나 | 왜 (코드 근거) |
|---|---|---|

### 아직 검증하지 못한 것
-

## 7. 검증
| 명령 | 실행 시각 | 결과 | E# |
|---|---|---|---|
| `<테스트 명령>` | HH:MM | <n> passed, <m> failed | |
| `bash scripts/smoke.sh` | HH:MM | <n> passed, <m> failed | |

수동 확인 (미리보기):
| 경로 | 단계 | 본 것 | 확인한 사람과 시각 |
|---|---|---|---|

검증하지 않은 것:

## 8. AI 협업 요약
- 구조: <오케스트레이터와 하위 에이전트 역할 한 줄>, 하네스 <repo>@<sha>
- 리뷰 지적: F# n건 (수용 a, 수정 b, 폐기 c). 목록은 `docs/AI_LOG.md`.
- 사례와 어려웠던 점: `AI_COLLABORATION.md`

## 9. 한계와 다음 단계
상황별 위험은 `docs/RISKS.md`에 있다.

| # | 약점 (파일:함수) | 언제 무엇이 깨지나 | 다음 검증·개선 |
|---|---|---|---|
| 1 | | | |

미구현·제외: R# (사유)

## 10. 인수인계
<다음 사람이 5분 안에 이어받을 5줄: 현재 상태, 다음 할 일, 주의점, 열린 질문>
