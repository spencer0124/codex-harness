# REPORT

## 1. Summary
<무엇을 만들었고 무엇이 동작하는지 3-5줄. Must R# 몇 개 중 몇 개 DONE.>

## 2. How to run
- 설치: `<명령>`
- 실행: `PORT=<포트> <명령>` (0.0.0.0 바인딩) -> 미리보기 경로 `/<경로>`
- 테스트: `<명령>` / smoke: `PORT=<포트> bash scripts/smoke.sh`

## 3. Traceability
| R# | 요구 | 구현 위치 (파일:함수) | 검증 | 결과 | 커밋 |
|---|---|---|---|---|---|
| R1 | | | `R1: ...` 테스트 | PASS | |
| R4 | | - | - | CUT (사유, 7절) | - |

## 4. Decisions
D# 별 한 줄 요약. 상세는 DECISIONS.md.
- D1:
- D2:

## 5. AI collaboration
- 사용: 모델 <이름>, effort <값>, 하네스 <repo>@<sha> (AGENTS.md, 템플릿만)
- 위임한 것:
- 내가 직접 판단·작성한 것:
- AI 출력을 바꾼 지점: DECISIONS.md "AI proposal -> my change" (<n>건)
- 막힌 지점과 복구: <무엇이, 몇 분, 어떻게>
- 업무 담당자와 확인한 것: PLAN.md Q&A (<n>건)

## 6. Verification
| 명령 | 실행 시각 | 결과 |
|---|---|---|
| `<테스트 명령>` | HH:MM | <n> passed, <m> failed |
| `bash scripts/smoke.sh` | HH:MM | <n> passed, <m> failed |

수동 확인 (미리보기):
| 경로 | 시나리오 | 결과 |
|---|---|---|

검증하지 않은 것:

## 7. Limitations and next steps
| # | 약점 (파일:함수) | 위험 (언제 무엇이 깨지나) | 다음 검증·개선 |
|---|---|---|---|
| L1 | | | |
| L2 | | | |
| L3 | | | |

미구현·제외: R# (사유)

## 8. Handoff
<다음 사람이 5분 안에 이어받기 위한 5줄: 현재 상태, 다음 할 일, 주의점, 열린 질문>
