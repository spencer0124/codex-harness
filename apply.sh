#!/usr/bin/env bash
# Usage: bash ~/harness/apply.sh "$PWD"   (no network; copies only)
set -eu
H=$(cd "$(dirname "$0")" && pwd); WS=${1:?workspace path}
if [ -f "$WS/AGENTS.md" ]; then
  printf '\n\n## Candidate working rules (appended)\n\n' >> "$WS/AGENTS.md"
  tail -n +2 "$H/AGENTS.md" >> "$WS/AGENTS.md"; echo "AGENTS.md existed: rules APPENDED"
else
  cp "$H/AGENTS.md" "$WS/AGENTS.md"; echo "AGENTS.md copied"
fi
for f in PLAN.md DECISIONS.md REPORT.md; do
  [ -e "$WS/$f" ] && echo "skip $f (exists)" || cp "$H/templates/$f" "$WS/$f"
done
mkdir -p "$WS/docs/playbooks"; for f in "$H"/playbooks/*.md; do [ -e "$WS/docs/playbooks/$(basename "$f")" ] || cp "$f" "$WS/docs/playbooks/"; done
mkdir -p "$WS/scripts"; [ -e "$WS/scripts/smoke.sh" ] || cp "$H/scripts/smoke.sh" "$WS/scripts/smoke.sh"
[ -d "$WS/.git" ] || git -C "$WS" init -q
git -C "$H" remote remove origin 2>/dev/null || true
echo "next: git add + commit, then run codex in $WS and check /status"
