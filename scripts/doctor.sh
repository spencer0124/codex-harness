#!/usr/bin/env bash
# Usage: bash scripts/doctor.sh   Read-only. Prints what this machine has and installs nothing. Exit 1 on any FAIL.
set -u
fails=0
row() { printf '%-5s %-13s %s\n' "$1" "$2" "$3"; [ "$1" = FAIL ] && fails=$((fails + 1)); return 0; }
ver() { "$@" 2>/dev/null | grep -Eo '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1; }
ge() { [ "$(printf '%s\n%s\n' "$1" "$2" | sort -t. -k1,1n -k2,2n -k3,3n | head -1)" = "$2" ]; }

v=$(ver codex --version)
if [ -z "$v" ]; then row FAIL codex "not found"
elif ! ge "$v" 0.115.0; then row WARN codex "$v: no subagents, the orchestrator runs every step itself"
elif ! ge "$v" 0.121.0; then row WARN codex "$v: subagents OK, humanize-korean needs 0.121.0"
else row OK codex "$v"; fi

v=$(ver node --version)
if [ -z "$v" ]; then row FAIL node "not found"
elif ge "$v" 20.19.0; then row OK node "$v"
else row FAIL node "$v: the default stack needs 20.19 or later"; fi

v=$(ver npm --version); [ -n "$v" ] && row OK npm "$v" || row FAIL npm "not found"

if command -v git >/dev/null; then
  if [ -n "$(git config user.name)" ] && [ -n "$(git config user.email)" ]; then row OK git "identity set"
  else row FAIL git "no user.name or user.email: the verifier cannot commit (git config --global user.name ...)"; fi
else row FAIL git "not found"; fi

v=$(bash .agents/skills/ui/scripts/pw.sh --version 2>/dev/null | tail -1)
[ "$v" = 0.1.22 ] && row OK playwright "playwright-cli $v" || row WARN playwright "playwright-cli ${v:-missing} (want 0.1.22): run bash scripts/install-tools.sh"

v=$(ver python3 --version); [ -n "$v" ] && row OK python3 "$v" || row WARN python3 "not found: the humanize-korean skill needs it"

code=$(curl -sS -m 5 -o /dev/null -w '%{http_code}' https://registry.npmjs.org/ 2>/dev/null)
[ "$code" = 200 ] && row OK network "npm registry reachable" || row WARN network "npm registry unreachable (HTTP ${code:-none}): installs will fail"

grep -q 'codex-harness:rules' AGENTS.md 2>/dev/null && row OK harness "AGENTS.md rules" || row FAIL harness "AGENTS.md rules missing: run apply.sh"
n=$(ls -d .agents/skills/*/ 2>/dev/null | wc -l | tr -d ' '); [ "$n" -gt 0 ] && row OK skills "$n in .agents/skills" || row FAIL skills "none in .agents/skills"
n=$(ls .codex/agents/*.toml 2>/dev/null | wc -l | tr -d ' '); [ "$n" -gt 0 ] && row OK agents "$n in .codex/agents" || row WARN agents "none in .codex/agents"
grep -q '^# >>> codex-harness' .gitignore 2>/dev/null && row OK gitignore "block present" || row FAIL gitignore "block missing: run apply.sh"

echo "doctor: $fails FAIL"
[ "$fails" -eq 0 ]
