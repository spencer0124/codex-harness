#!/usr/bin/env bash
# Usage: bash scripts/check-refs.sh [doc ...]   Prints each cited E#, `R#: test name`, or `file:function` that does not exist. Exit 1 if any.
set -u
cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
[ $# -gt 0 ] || set -- REPORT.md AI_COLLABORATION.md DECISIONS.md docs/RISKS.md docs/ARCHITECTURE.md
docs=""; for d in "$@"; do [ -f "$d" ] && docs="$docs $d"; done
[ -n "$docs" ] || { echo "check-refs: no docs found"; exit 1; }
missing=0
miss() { echo "missing $*"; missing=$((missing + 1)); }

for e in $(grep -ohE '(^|[^A-Za-z0-9])E[0-9]+([^A-Za-z0-9]|$)' $docs | grep -oE 'E[0-9]+' | sort -u); do
  grep -q "^## $e · " docs/EVIDENCE.md 2>/dev/null || miss "evidence $e"
done

tests=$(grep -ohE '`R[0-9]+: [^`]+`' $docs | tr -d '`' | sort -u)
while IFS= read -r t; do
  [ -n "$t" ] || continue
  git grep -qF -- "$t" -- ':!*.md' 2>/dev/null || miss "test \"$t\""
done <<EOF
$tests
EOF

refs=$(grep -ohE '`[A-Za-z0-9_./-]+\.[a-z]+:[A-Za-z_$][A-Za-z0-9_$]*`' $docs | tr -d '`' | sort -u)
while IFS=: read -r f s; do
  [ -n "$f" ] || continue
  { [ -f "$f" ] && grep -qF -- "$s" "$f"; } || miss "ref $f:$s"
done <<EOF
$refs
EOF

echo "check-refs: $missing missing"
[ "$missing" -eq 0 ]
