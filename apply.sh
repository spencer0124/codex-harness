#!/usr/bin/env bash
# Usage: bash ~/harness/apply.sh "$PWD"   Copies only, no network. Safe to rerun: existing files are kept.
set -eu
H=$(cd "$(dirname "$0")" && pwd)
WS=$(cd "${1:?workspace path}" && pwd)

put() {
  if [ -e "$2" ]; then echo "skip $2"; return; fi
  mkdir -p "$(dirname "$2")"; cp -R "$1" "$2"; echo "add  $2"
}

if [ ! -e "$WS/AGENTS.md" ]; then
  cp "$H/AGENTS.md" "$WS/AGENTS.md"; echo "add  AGENTS.md"
elif grep -q 'codex-harness:rules' "$WS/AGENTS.md"; then
  echo "skip AGENTS.md (rules already present)"
else
  { printf '\n\n# Harness working rules (appended)\n'; tail -n +2 "$H/AGENTS.md"; } >> "$WS/AGENTS.md"
  echo "AGENTS.md existed: rules APPENDED"
fi

for d in "$H"/.agents/skills/*/; do
  [ -d "$d" ] && put "$d" "$WS/.agents/skills/$(basename "$d")"
done
for f in "$H"/.codex/agents/*.toml; do
  [ -f "$f" ] && put "$f" "$WS/.codex/agents/$(basename "$f")"
done
for root in templates design; do
  [ -d "$H/$root" ] || continue
  (cd "$H/$root" && find . -type f) | while IFS= read -r rel; do
    rel=${rel#./}
    if [ "$root" = templates ]; then put "$H/$root/$rel" "$WS/$rel"; else put "$H/$root/$rel" "$WS/$root/$rel"; fi
  done
done
for f in "$H"/playbooks/*.md; do put "$f" "$WS/docs/playbooks/$(basename "$f")"; done
for f in "$H"/scripts/*; do put "$f" "$WS/scripts/$(basename "$f")"; done
chmod +x "$WS"/scripts/*.sh 2>/dev/null || true

if grep -q '^# >>> codex-harness' "$WS/.gitignore" 2>/dev/null; then
  echo "skip .gitignore (block present)"
else
  { [ -s "$WS/.gitignore" ] && echo; cat "$H/gitignore.block"; } >> "$WS/.gitignore"; echo "add  .gitignore block"
fi

[ -d "$WS/.git" ] || { git -C "$WS" init -q; echo "git init"; }
echo "next: bash scripts/doctor.sh, then git add -A && git commit -m 'chore: apply codex-harness', then start codex"
