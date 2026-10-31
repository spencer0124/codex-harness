#!/usr/bin/env bash
# Usage: PORT=3000 bash scripts/smoke.sh   (server must already be running)
set -u
BASE="http://127.0.0.1:${PORT:-3000}"
pass=0; fail=0

# check <R#> <METHOD> <PATH> <EXPECTED_STATUS> [BODY_JSON] [MUST_CONTAIN]
check() {
  local id=$1 method=$2 path=$3 want=$4 body=${5:-} needle=${6:-}
  local out code
  out=$(mktemp)
  if [ -n "$body" ]; then
    code=$(curl -s -o "$out" -w '%{http_code}' -X "$method" -H 'Content-Type: application/json' --data "$body" "$BASE$path")
  else
    code=$(curl -s -o "$out" -w '%{http_code}' -X "$method" "$BASE$path")
  fi
  if [ "$code" = "$want" ] && { [ -z "$needle" ] || grep -q -- "$needle" "$out"; }; then
    pass=$((pass+1)); echo "PASS $id $method $path -> $code"
  else
    fail=$((fail+1)); echo "FAIL $id $method $path -> $code (want $want${needle:+, contains '$needle'})"; head -c 300 "$out"; echo
  fi
  rm -f "$out"
}

# --- fill in per task (one line per acceptance criterion) ---
check R0 GET / 200
# check R1 GET  /api/items 200 '' '"items"'
# check R2 POST /api/items 400 '{"name":""}'
# check R3 POST /api/items 201 '{"name":"a"}' '"id"'

echo "smoke: $pass passed, $fail failed ($(date '+%H:%M:%S'))"
[ "$fail" -eq 0 ]
