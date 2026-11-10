#!/usr/bin/env bash
# Usage: bash tests/drill.test.sh   Checks that practice material stays out of a workspace's git history and submission.
set -u
H=$(cd "$(dirname "$0")/.." && pwd)
T=$(mktemp -d); export TMPDIR="$T/tmp"; mkdir -p "$TMPDIR"
trap 'rm -rf "$T"' EXIT
pass=0; fail=0
check() { if eval "$2"; then pass=$((pass + 1)); echo "PASS $1"; else fail=$((fail + 1)); echo "FAIL $1"; fi; }
MARK="HARNESS-""PRACTICE"
WS="$T/ws"; mkdir -p "$WS"
gitq() { git -c user.name=t -c user.email=t@t -C "$WS" "$@" >/dev/null 2>&1; }
pre() { (cd "$WS" && bash scripts/presubmit.sh "$@") > "$T/out" 2>&1; }

for s in writeup drill; do
  check "skill $s: frontmatter has name and description" \
    "sed -n '1,4p' '$H/.agents/skills/$s/SKILL.md' | grep -q '^name: $s\$' && sed -n '1,4p' '$H/.agents/skills/$s/SKILL.md' | grep -q '^description: .'"
done
check "drill: every reference the skill names exists" \
  "grep -oE 'references/[a-z-]+\.md' '$H/.agents/skills/drill/SKILL.md' | sort -u | while read -r r; do [ -f '$H/.agents/skills/drill/'\"\$r\" ] || exit 1; done"
check "drill: writes the pitch script under .study/ and runs it by default" \
  "grep -q '`.study/pitch.md`' '$H/.agents/skills/drill/SKILL.md' && grep -q 'none runs cards, then the pitch script, then the quiz' '$H/.agents/skills/drill/SKILL.md'"
check "marker: appears only in the drill skill and tests" \
  "[ -z \"\$(grep -rlF '$MARK' '$H' --exclude-dir=.git --exclude-dir=private --exclude-dir=tests | grep -v '/.agents/skills/drill/')\" ]"

bash "$H/apply.sh" "$WS" > /dev/null 2>&1
check "apply: write-up templates and both skills land" \
  "[ -f '$WS/REPORT.md' ] && [ -f '$WS/AI_COLLABORATION.md' ] && [ -f '$WS/DECISIONS.md' ] && [ -f '$WS/docs/RISKS.md' ] && [ -f '$WS/.agents/skills/writeup/SKILL.md' ] && [ -f '$WS/.agents/skills/drill/SKILL.md' ]"
gitq add -A; gitq commit -m init
check "git: drill skill is never tracked, writeup skill is" \
  "[ -z \"\$(git -C '$WS' ls-files .agents/skills/drill)\" ] && [ -n \"\$(git -C '$WS' ls-files .agents/skills/writeup)\" ]"
pre; check "presubmit: the ignored drill skill does not count as a marker leak" "grep -q 'OK   no practice marker in tracked files' '$T/out'"

mkdir -p "$WS/.study"
printf '<!-- %s -->\n## S1\n' "$MARK" > "$WS/.study/cards.md"
printf '<!-- %s -->\n# attempts\n' "$MARK" > "$WS/.study/attempts.md"
check "git: add -A after a drill session stages nothing" 'gitq add -A; [ -z "$(git -C "$WS" status --porcelain)" ]'
pre; rc=$?; check "presubmit: fails while .study and the drill skill are in the workspace" \
  "[ $rc -ne 0 ] && grep -q 'FAIL .study' '$T/out' && grep -q 'FAIL .agents/skills/drill' '$T/out'"
pre --fix; pre; rc=$?
check "presubmit: --fix moves both out, then exits 0" \
  "[ $rc -eq 0 ] && [ ! -e '$WS/.study' ] && [ ! -e '$WS/.agents/skills/drill' ] && ls '$TMPDIR'/harness-practice-*/.study/cards.md '$TMPDIR'/harness-practice-*/.agents/skills/drill/SKILL.md >/dev/null 2>&1"

echo "tests: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
