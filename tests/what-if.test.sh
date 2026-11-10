#!/usr/bin/env bash
# Usage: bash tests/what-if.test.sh   Checks scripts/what-if.mjs against throwaway entries. Not copied into workspaces.
set -u
H=$(cd "$(dirname "$0")/.." && pwd)
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
pass=0; fail=0
check() { if eval "$2"; then pass=$((pass + 1)); echo "PASS $1"; else fail=$((fail + 1)); echo "FAIL $1"; fi; }

cat > "$T/entry.mjs" <<'EOF'
export function run(p) {
  if (p.binSize <= 0) throw new Error('binSize must be positive');
  if (p.mode === 'text') return { bins: 'many' };
  return { bins: Math.ceil(p.items / p.binSize), avgFill: p.items / Math.ceil(p.items / p.binSize) };
}
EOF
cat > "$T/ok.json" <<'EOF'
{ "base": { "items": 100, "binSize": 40 }, "variants": { "smaller": { "binSize": 30 }, "same": { "items": 100 } } }
EOF
cat > "$T/bad.json" <<'EOF'
{ "base": { "items": 100, "binSize": 40 }, "variants": { "zero": { "binSize": 0 }, "text": { "mode": "text" } } }
EOF
echo 'export const x = 1;' > "$T/noexport.mjs"

node "$H/scripts/what-if.mjs" "$T/entry.mjs" "$T/ok.json" > "$T/out" 2>&1; rc=$?
cat "$T/out"
check "what-if: valid scenarios exit 0" "[ $rc -eq 0 ]"
check "what-if: base row has raw values" "grep -q '^| base | - | 3 | 33.333 |' '$T/out'"
check "what-if: variant shows delta against base" "grep -q '^| smaller | .*| 4 (+1) | 25 (-8.333) |' '$T/out'"
check "what-if: every row ends with its run time in ms" "grep -q '| ms |\$' '$T/out' && grep -qE '^\\| same \\|.*\\| [0-9]+\\.[0-9] \\|\$' '$T/out'"
check "what-if: unchanged metric shows ±0" "grep -q '^| same | .*| 3 (±0) |' '$T/out'"

node "$H/scripts/what-if.mjs" "$T/entry.mjs" "$T/bad.json" > "$T/out" 2>&1; rc=$?
cat "$T/out"
check "what-if: a throwing variant exits 1 and shows the error" "[ $rc -eq 1 ] && grep -q 'error: binSize must be positive' '$T/out'"
check "what-if: a non-number metric is reported" "grep -q 'metric \"bins\" is string' '$T/out'"

node "$H/scripts/what-if.mjs" "$T/noexport.mjs" "$T/ok.json" > "$T/out" 2>&1; rc=$?
check "what-if: entry without run() exits 2" "[ $rc -eq 2 ] && grep -q 'must export run' '$T/out'"
node "$H/scripts/what-if.mjs" > /dev/null 2>&1; rc=$?
check "what-if: missing arguments exit 2" "[ $rc -eq 2 ]"

echo "tests: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
