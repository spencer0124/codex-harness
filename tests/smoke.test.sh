#!/usr/bin/env bash
# Usage: bash tests/smoke.test.sh   Checks scripts/smoke.sh against a throwaway HTTP server.
set -u
H=$(cd "$(dirname "$0")/.." && pwd)
D=$(mktemp -d); SPID=""; LPID=""
trap '[ -n "$SPID" ] && kill "$SPID" 2>/dev/null; [ -n "$LPID" ] && kill "$LPID" 2>/dev/null; rm -rf "$D"' EXIT
pass=0; fail=0
check() { if eval "$2"; then pass=$((pass + 1)); echo "PASS $1"; else fail=$((fail + 1)); echo "FAIL $1"; fi; }

cat > "$D/server.mjs" <<'JS'
import http from 'node:http';
import fs from 'node:fs';
const sessions = new Set();
const srv = http.createServer((req, res) => {
  const sid = /(?:^|;\s*)sid=([^;]+)/.exec(req.headers.cookie ?? '')?.[1];
  const send = (code, body = '{}', headers = {}) => { res.writeHead(code, { 'Content-Type': 'application/json', ...headers }); res.end(body); };
  req.resume();
  req.on('end', () => {
    const route = `${req.method} ${req.url}`;
    if (route === 'GET /') return send(200, '{"ok":true}');
    if (route === 'POST /api/login') { sessions.add('s1'); return send(200, '{"user":"op"}', { 'Set-Cookie': 'sid=s1; Path=/; HttpOnly; SameSite=Lax' }); }
    if (route === 'POST /api/bad-login') return send(200, '{}', { 'Set-Cookie': 'sid=s2; Path=/; HttpOnly; Secure; SameSite=Lax' });
    if (route === 'GET /api/me') return sessions.has(sid) ? send(200, '{"user":"op"}') : send(401);
    if (route === 'POST /api/items') {
      if (!sessions.has(sid)) return send(401);
      const origin = req.headers.origin;
      const sameOrigin = !origin || new URL(origin).host === req.headers.host;
      return req.headers['x-requested-with'] === 'fetch' && sameOrigin ? send(201, '{"id":1}') : send(403, '{"error":{"code":"CSRF"}}');
    }
    send(404);
  });
});
srv.listen(0, '127.0.0.1', () => fs.writeFileSync(process.argv[2], String(srv.address().port)));
JS
node "$D/server.mjs" "$D/port" > "$D/server.log" 2>&1 &
SPID=$!; disown "$SPID" 2>/dev/null
for _ in $(seq 1 50); do [ -s "$D/port" ] && break; sleep 0.1; done
port=$(cat "$D/port" 2>/dev/null)
check "test server started" "[ -n '$port' ]"

# mk <name> <line>...   Writes $D/<name>.sh: smoke.sh with the fill-in block replaced by the given lines.
mk() {
  local name=$1; shift
  printf '%s\n' "$@" > "$D/block"
  awk -v blk="$D/block" '/^# >>> smoke checks/ { print; while ((getline l < blk) > 0) print l; skip = 1; next }
    /^# <<< smoke checks/ { skip = 0 } !skip' "$H/scripts/smoke.sh" > "$D/$name.sh"
}
run() { (PORT=${2:-$port} bash "$D/$1.sh") > "$D/out" 2>&1; }

(PORT=$port bash "$H/scripts/smoke.sh") > "$D/out" 2>&1; rc=$?
check "shipped fill-in block runs: check R0 GET / 200" "[ $rc -eq 0 ] && grep -q 'PASS R0 GET / -> 200' '$D/out'"

mk good \
  "check R0 GET / 200" \
  "check_cookie R1 POST /api/login '{\"user\":\"op\"}'" \
  "check R1 GET /api/me 200 '' '\"op\"'" \
  "check R2 POST /api/items 201 '{\"name\":\"a\"}' '\"id\"'" \
  "check_no_csrf R2 POST /api/items 403 '{\"name\":\"a\"}'" \
  "check_foreign_origin R2 POST /api/items 403 '{\"name\":\"a\"}'"
check "fill-in markers present in smoke.sh" "grep -q '^check_cookie R1' '$D/good.sh'"
run good; rc=$?
check "login, protected route, CSRF checks: all pass, exit 0" "[ $rc -eq 0 ] && grep -q 'smoke: 6 passed, 0 failed' '$D/out'"
check "cookie jar carries the login into the protected check" "grep -q 'PASS R1 GET /api/me -> 200' '$D/out'"
check "check sends the CSRF header on POST" "grep -q 'PASS R2 POST /api/items -> 201' '$D/out'"
check "check_no_csrf sees 403" "grep -q 'PASS R2 POST /api/items without CSRF header -> 403' '$D/out'"
check "check_foreign_origin sees 403" "grep -q 'PASS R2 POST /api/items from a foreign Origin -> 403' '$D/out'"

mk nologin "check R1 GET /api/me 200"
run nologin; rc=$?
check "without a login the protected check fails with exit 1" "[ $rc -eq 1 ] && grep -q 'FAIL R1 GET /api/me -> 401' '$D/out'"

mk secure "check_cookie R1 POST /api/bad-login" "check_cookie R0 GET /"
run secure; rc=$?
check "check_cookie fails on a Secure cookie over http" "[ $rc -eq 1 ] && grep -q 'FAIL R1 POST /api/bad-login cookie -> 200: Secure over http' '$D/out'"
check "check_cookie fails when no cookie is set" "grep -q 'FAIL R0 GET / cookie -> 200: no Set-Cookie' '$D/out'"

free=$(node -e "const s=require('net').createServer().listen(0,'127.0.0.1',()=>{console.log(s.address().port);s.close()})")
(PORT=$free SMOKE_WAIT=0 bash "$D/good.sh") > "$D/out" 2>&1; rc=$?
check "no server: exit 2 and asks for npm run dev" \
  "[ $rc -eq 2 ] && grep -qF 'smoke: no server at http://127.0.0.1:$free. Ask the user to run \`npm run dev\` in a separate terminal.' '$D/out'"

node -e "setTimeout(() => require('http').createServer((q, s) => s.end('ok')).listen($free, '127.0.0.1'), 1500)" > /dev/null 2>&1 &
LPID=$!; disown "$LPID" 2>/dev/null
(PORT=$free bash "$H/scripts/smoke.sh") > "$D/out" 2>&1; rc=$?
check "a server that comes up 1.5 s late (tsx watch restart) is waited for" "[ $rc -eq 0 ] && grep -q 'PASS R0 GET / -> 200' '$D/out'"

echo "tests: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
