# Verify before claiming done

| Claim | Evidence required |
| --- | --- |
| Tests pass | The exact command and its summary line (`N passed, M failed`) from this turn |
| Bug fixed | A test that reproduces the bug: red output before the fix, green after |
| Route works | One success and one failure case: a test, or a `scripts/smoke.sh` line and its PASS output |
| UI works | Preview path, the steps taken by hand, what was seen. Mark it "checked by human" or "unchecked" |
| Requirement R# done | The R# row in PLAN.md points at a test name or smoke line that passed |

Report format:
1. Claim (one line, with R#)
2. Command(s) run
3. Key output lines, copied, not paraphrased
4. What was not checked
