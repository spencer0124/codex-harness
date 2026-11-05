# Verify before claiming done

| Claim | Evidence required |
| --- | --- |
| Tests pass | An E# from this turn with the exact command and its summary line (`N passed`) |
| Bug fixed | A red E# that reproduces it (`판정: FAIL`, `메모: 의도한 red`), then a green E# after the fix |
| Route works | One success and one failure case: a test, or a `scripts/smoke.sh` line whose PASS output sits in an E# |
| UI works | A screenshot in `docs/screenshots/<U#>-<viewport>.png` named in an E#, with what was seen. Mark it "사람이 확인함" or "미확인" |
| Requirement R# done | The R# row in PLAN.md points at a U#, whose row points at a test name or smoke line and an E# that says PASS |
| AI output judged | A row in `docs/AI_LOG.md` with 판정 and the command output or E# behind it |

Report format:
1. Claim (one line, with R#)
2. Command(s) run
3. Key output lines, copied, not paraphrased, and the E# that holds them
4. What was not checked
