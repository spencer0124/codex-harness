#!/usr/bin/env bash
# Usage: bash tests/run.sh   Checks apply.sh and scripts/presubmit.sh in throwaway repositories. Not copied into workspaces.
set -u
H=$(cd "$(dirname "$0")/.." && pwd)
T=$(mktemp -d); export TMPDIR="$T/tmp"; mkdir -p "$TMPDIR"
trap 'rm -rf "$T"' EXIT
pass=0; fail=0
check() { if eval "$2"; then pass=$((pass + 1)); echo "PASS $1"; else fail=$((fail + 1)); echo "FAIL $1"; fi; }
gitq() { git -c user.name=t -c user.email=t@t -C "$WS" "$@" >/dev/null 2>&1; }
pre() { (cd "$WS" && bash scripts/presubmit.sh "$@") > "$T/out" 2>&1; }

WS="$T/ws"; mkdir -p "$WS"
bash "$H/apply.sh" "$WS" > "$T/apply1" 2>&1
check "apply: copies rules, plan, scripts, gitignore block" \
  '[ -f "$WS/AGENTS.md" ] && [ -f "$WS/PLAN.md" ] && [ -x "$WS/scripts/presubmit.sh" ] && grep -q "^# >>> codex-harness" "$WS/.gitignore"'
check "apply: every skill the writeup skill names lands in the workspace, the vendored security skill with its license" \
  '[ -f "$WS/.agents/skills/security-best-practices/SKILL.md" ] && [ -f "$WS/.agents/skills/security-best-practices/LICENSE.txt" ] && [ -f "$WS/.agents/skills/security-best-practices/references/javascript-express-web-server-security.md" ] && for s in $(grep -oE "the \`[a-z-]+\` skill" "$WS/.agents/skills/writeup/SKILL.md" | grep -oE "[a-z-]+\`" | tr -d "\`"); do [ -f "$WS/.agents/skills/$s/SKILL.md" ] || exit 1; done'
check "apply: every phase skill named in AGENTS.md lands in the workspace" \
  'for s in $(grep -oE "^\| [0-9] [a-z-]+ \| \`\\\$[a-z]+" "$WS/AGENTS.md" | grep -oE "[a-z]+$"); do [ -f "$WS/.agents/skills/$s/SKILL.md" ] || exit 1; done'
bash "$H/apply.sh" "$WS" > "$T/apply2" 2>&1
check "apply: second run adds nothing" '! grep -q "^add " "$T/apply2"'
check "apply: one rules marker and one gitignore block after two runs" \
  '[ "$(grep -c codex-harness:rules "$WS/AGENTS.md")" = 1 ] && [ "$(grep -c "^# >>> codex-harness" "$WS/.gitignore")" = 1 ]'

WS2="$T/ws2"; mkdir -p "$WS2"; printf '# Task rules\nkeep me\n' > "$WS2/AGENTS.md"
bash "$H/apply.sh" "$WS2" > /dev/null 2>&1
check "apply: appends to an existing AGENTS.md and keeps its text" \
  'grep -q "keep me" "$WS2/AGENTS.md" && grep -q codex-harness:rules "$WS2/AGENTS.md"'

rm -rf "$WS/.agents/skills/drill"
gitq add -A; gitq commit -m init
pre; rc=$?; check "presubmit: clean workspace exits 0" "[ $rc -eq 0 ]"

mkdir -p "$WS/.study" "$WS/.agents/skills/drill"
printf '<!-- HARNESS-PRACTICE -->\ncard\n' > "$WS/.study/card.md"; echo x > "$WS/.agents/skills/drill/SKILL.md"
check "presubmit: ignore rules keep practice files out of git add -A" \
  'gitq add -A; [ -z "$(git -C "$WS" status --porcelain)" ]'
pre; rc=$?; check "presubmit: practice folders in the workspace fail" "[ $rc -ne 0 ] && grep -q 'FAIL .study' '$T/out'"
pre --fix; pre; rc=$?
check "presubmit: --fix moves practice folders out, then exits 0" \
  "[ $rc -eq 0 ] && [ ! -e '$WS/.study' ] && ls '$TMPDIR'/harness-practice-*/.study/card.md >/dev/null 2>&1"

mkdir -p "$WS/.study"; echo y > "$WS/.study/forced.md"; gitq add -f .study/forced.md; gitq commit -m forced
pre; rc=$?; check "presubmit: a force-added ignored file fails" "[ $rc -ne 0 ] && grep -q 'tracked files match' '$T/out'"
check "presubmit: history check names the committed practice file" "grep -q '.study/forced.md' '$T/out'"

WS="$T/ws3"; mkdir -p "$WS"; bash "$H/apply.sh" "$WS" > /dev/null 2>&1; rm -rf "$WS/.agents/skills/drill"
printf 'answer card <!-- HARNESS-PRACTICE -->\n' >> "$WS/PLAN.md"; gitq add -A; gitq commit -m leak
pre; rc=$?; check "presubmit: marker copied into a tracked doc fails" "[ $rc -ne 0 ] && grep -q 'PLAN.md' '$T/out'"

echo "tests: $pass passed, $fail failed"
for t in "$H"/tests/*.test.sh; do
  [ -f "$t" ] || continue
  out=$(bash "$t" 2>&1 | tail -1); echo "$(basename "$t"): $out"
  case "$out" in *" 0 failed"*) ;; *) fail=$((fail + 1)) ;; esac
done
[ "$fail" -eq 0 ] && echo "all suites: OK" || echo "all suites: FAILED"
[ "$fail" -eq 0 ]
