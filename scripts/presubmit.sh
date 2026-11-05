#!/usr/bin/env bash
# Usage: bash scripts/presubmit.sh [--fix]   Run before you submit. Exit 0 means no practice material can reach the submission.
# --fix moves practice folders out of the workspace and untracks ignored files. It never rewrites history.
set -u
cd "$(git rev-parse --show-toplevel 2>/dev/null)" || { echo "FAIL not inside a git repository"; exit 2; }
FIX=0; [ "${1:-}" = "--fix" ] && FIX=1
fail=0
ok()  { echo "OK   $*"; }
bad() { echo "FAIL $*"; fail=1; }

PRACTICE_DIRS=".study .agents/skills/drill _workspace"
PRACTICE_RE='^(\.study/|\.agents/skills/drill/|_workspace/)'
MARK="HARNESS-""PRACTICE"
OUT="${TMPDIR:-/tmp}"; OUT="${OUT%/}/harness-practice-$(date +%Y%m%d-%H%M%S)"

if grep -q '^# >>> codex-harness' .gitignore 2>/dev/null; then ok "gitignore block present"
else bad "gitignore block missing: rerun apply.sh"; fi

tracked=$(git ls-files -ci --exclude-standard)
if [ -z "$tracked" ]; then ok "no tracked file matches the ignore rules"
elif [ $FIX = 1 ]; then
  printf '%s\n' "$tracked" | while IFS= read -r f; do git rm -q --cached -- "$f"; done
  bad "untracked these files, now commit the removal and rerun:"; printf '     %s\n' $tracked
else bad "tracked files match the ignore rules (rerun with --fix):"; printf '     %s\n' $tracked; fi

hits=$(git grep -l -F "$MARK" -- . 2>/dev/null; git grep -l -F "$MARK" HEAD -- . 2>/dev/null | sed 's/^HEAD://')
hits=$(printf '%s\n' "$hits" | sed '/^$/d' | sort -u)
if [ -z "$hits" ]; then ok "no practice marker in tracked files"
else bad "practice marker found in tracked files (remove that text by hand):"; printf '     %s\n' $hits; fi

if git rev-parse -q --verify HEAD >/dev/null; then
  hist=$(git log --all --name-only --format= | grep -E "$PRACTICE_RE" | sort -u)
  mhist=$(git log --all --format=%h -S "$MARK")
  if [ -z "$hist$mhist" ]; then ok "git history has no practice files or marker"
  else bad "git history holds practice material; ask before rewriting history:"; printf '     %s\n' $hist $mhist; fi
fi

left=0
for d in $PRACTICE_DIRS; do
  [ -e "$d" ] || continue
  if [ $FIX = 1 ]; then mkdir -p "$OUT/$(dirname "$d")"; mv "$d" "$OUT/$d"; echo "MOVE $d -> $OUT/$d"
  else bad "$d is in the workspace (rerun with --fix to move it to $OUT)"; left=1; fi
done
[ $left = 0 ] && ok "no practice folder in the workspace"

st=$(git status --porcelain)
[ -n "$st" ] && { echo "WARN uncommitted changes (not a failure):"; printf '%s\n' "$st" | sed 's/^/     /'; }

[ $fail = 0 ] && echo "presubmit: clean" || echo "presubmit: NOT clean"
exit $fail
