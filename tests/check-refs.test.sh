#!/usr/bin/env bash
# Usage: bash tests/check-refs.test.sh   Checks scripts/check-refs.sh against a throwaway repository.
set -u
H=$(cd "$(dirname "$0")/.." && pwd)
WS=$(mktemp -d); trap 'rm -rf "$WS"' EXIT
pass=0; fail=0
check() { if eval "$2"; then pass=$((pass + 1)); echo "PASS $1"; else fail=$((fail + 1)); echo "FAIL $1"; fi; }
run() { (cd "$WS" && bash "$H/scripts/check-refs.sh" "$@") > "$WS/.out" 2>&1; }

git -C "$WS" init -q
mkdir -p "$WS/docs" "$WS/src" "$WS/tests"
printf '## E1 · 10:00 · U1 · R1\n판정: PASS\n' > "$WS/docs/EVIDENCE.md"
printf 'export function planRoutes() {}\n' > "$WS/src/plan.ts"
printf "it('R1: keeps the previous result on failure', () => {})\n" > "$WS/tests/plan.test.ts"
git -C "$WS" add -A
printf '결과는 E1에서 확인했다. `src/plan.ts:planRoutes`가 계산하고 `R1: keeps the previous result on failure`가 검증한다. E2E 테스트는 없다.\n' > "$WS/REPORT.md"

run REPORT.md; rc=$?
check "valid E#, test name, and file:function pass; E2E is not an E#" "[ $rc -eq 0 ] && grep -q 'check-refs: 0 missing' '$WS/.out'"

printf 'E9 참고. `src/plan.ts:missingFn`, `src/none.ts:x`, `R2: does not exist`.\n' > "$WS/DECISIONS.md"
run REPORT.md DECISIONS.md; rc=$?
check "broken refs fail with exit 1" "[ $rc -eq 1 ]"
check "names the missing E#" "grep -q 'missing evidence E9' '$WS/.out'"
check "names the missing function and file" "grep -q 'missing ref src/plan.ts:missingFn' '$WS/.out' && grep -q 'missing ref src/none.ts:x' '$WS/.out'"
check "names the missing test" "grep -q 'missing test \"R2: does not exist\"' '$WS/.out'"
check "counts four missing" "grep -q 'check-refs: 4 missing' '$WS/.out'"

echo "tests: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
