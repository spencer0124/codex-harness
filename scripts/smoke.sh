#!/usr/bin/env bash
# Usage: PORT=3000 bash scripts/smoke.sh   The server must already run: the user starts `npm run dev` in a separate terminal.
# Exit 0: every check passed. 1: a check failed. 2: no server answered at $BASE within SMOKE_WAIT seconds (default 5).
set -u
BASE="${BASE:-http://127.0.0.1:${PORT:-3000}}"
CSRF_HEADER="${CSRF_HEADER:-X-Requested-With: fetch}"
JAR=$(mktemp); OUT=$(mktemp); HDR=$(mktemp)
trap 'rm -f "$JAR" "$OUT" "$HDR"' EXIT
pass=0; fail=0

# `tsx watch` restarts the server after every file change, so a run right after an edit waits for it to come back.
tries=$(( ${SMOKE_WAIT:-5} * 2 ))
while [ "$(curl -s -m 2 -o /dev/null -w '%{http_code}' "$BASE/" 2>/dev/null)" = 000 ]; do
  if [ "$tries" -le 0 ]; then
    echo "smoke: no server at $BASE. Ask the user to run \`npm run dev\` in a separate terminal."
    exit 2
  fi
  tries=$((tries - 1)); sleep 0.5
done

# req <METHOD> <PATH> <BODY_JSON> [curl args]   Every request shares one cookie jar, so a login check carries into later checks.
req() {
  local method=$1 path=$2 body=$3; shift 3
  if [ -n "$body" ]; then
    code=$(curl -s -m 10 -o "$OUT" -D "$HDR" -w '%{http_code}' -b "$JAR" -c "$JAR" -X "$method" "$@" \
      -H 'Content-Type: application/json' --data "$body" "$BASE$path")
  else
    code=$(curl -s -m 10 -o "$OUT" -D "$HDR" -w '%{http_code}' -b "$JAR" -c "$JAR" -X "$method" "$@" "$BASE$path")
  fi
}
send() { # send <METHOD> <PATH> <BODY_JSON>   Adds $CSRF_HEADER to every request that is not GET or HEAD.
  case "$1" in GET|HEAD) req "$1" "$2" "$3" ;; *) req "$1" "$2" "$3" -H "$CSRF_HEADER" ;; esac
}
ok() { pass=$((pass+1)); echo "PASS $*"; }
bad() { fail=$((fail+1)); echo "FAIL $*"; head -c 300 "$OUT"; echo; }

# check <R#> <METHOD> <PATH> <EXPECTED_STATUS> [BODY_JSON] [MUST_CONTAIN]
check() {
  local id=$1 method=$2 path=$3 want=$4 body=${5:-} needle=${6:-}
  send "$method" "$path" "$body"
  if [ "$code" = "$want" ] && { [ -z "$needle" ] || grep -q -- "$needle" "$OUT"; }; then
    ok "$id $method $path -> $code"
  else
    bad "$id $method $path -> $code (want $want${needle:+, contains '$needle'})"
  fi
}

# check_no_csrf <R#> <METHOD> <PATH> <EXPECTED_STATUS> [BODY_JSON]   Same cookies, no CSRF header. Proves the server rejects it.
check_no_csrf() {
  local id=$1 method=$2 path=$3 want=$4 body=${5:-}
  req "$method" "$path" "$body"
  if [ "$code" = "$want" ]; then ok "$id $method $path without CSRF header -> $code"
  else bad "$id $method $path without CSRF header -> $code (want $want)"; fi
}

# check_foreign_origin <R#> <METHOD> <PATH> <EXPECTED_STATUS> [BODY_JSON]   CSRF header present, Origin from another site.
check_foreign_origin() {
  local id=$1 method=$2 path=$3 want=$4 body=${5:-}
  req "$method" "$path" "$body" -H "$CSRF_HEADER" -H 'Origin: http://evil.example'
  if [ "$code" = "$want" ]; then ok "$id $method $path from a foreign Origin -> $code"
  else bad "$id $method $path from a foreign Origin -> $code (want $want)"; fi
}

# check_cookie <R#> <METHOD> <PATH> [BODY_JSON]   Every Set-Cookie needs HttpOnly and SameSite=Lax, and no Secure while BASE is http.
check_cookie() {
  local id=$1 method=$2 path=$3 body=${4:-} why="" line
  send "$method" "$path" "$body"
  grep -qi '^set-cookie:' "$HDR" || why=" no Set-Cookie;"
  while IFS= read -r line; do
    printf '%s' "$line" | grep -qi 'httponly' || why="$why no HttpOnly;"
    printf '%s' "$line" | grep -qi 'samesite=lax' || why="$why no SameSite=Lax;"
    case "$BASE" in http:*)
      printf '%s' "$line" | grep -qiE '(^|;)[[:space:]]*secure[[:space:]]*(;|$)' \
        && why="$why Secure over http (the browser never sends it back);" ;;
    esac
  done <<EOF
$(grep -i '^set-cookie:' "$HDR" | tr -d '\r')
EOF
  if [ -z "$why" ]; then ok "$id $method $path cookie -> $code"
  else bad "$id $method $path cookie -> $code:$why"; fi
}

# --- fill in per task (one line per acceptance criterion) ---
# >>> smoke checks
check R0 GET / 200
# check R1 GET  /api/items 200 '' '"items"'
# check R2 POST /api/items 400 '{"name":""}'
# check R3 POST /api/items 201 '{"name":"a"}' '"id"'
# With a login (.agents/skills/plan/references/web-security.md), in this order:
# check_cookie         R5 POST /api/login '{"username":"op","password":"..."}'
# check                R5 GET  /api/me 200
# check_no_csrf        R6 POST /api/items 403 '{"name":"a"}'
# check_foreign_origin R6 POST /api/items 403 '{"name":"a"}'
# check                R5 POST /api/logout 204
# check                R5 GET  /api/me 401
# <<< smoke checks

echo "smoke: $pass passed, $fail failed ($(date '+%H:%M:%S'))"
[ "$fail" -eq 0 ]
