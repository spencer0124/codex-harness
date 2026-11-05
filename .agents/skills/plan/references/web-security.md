# Web security defaults

Use this only when a C# names a login, operators or roles, or an endpoint that changes state for a signed-in user. Without such a C#, build no auth (stack.md). No new dependency: `node:crypto`, Express 5, and zod cover it. In `$plan`, each part that applies becomes an R# whose source is an A# ("기본 설계: <part>").

## Passwords
- Hash with `crypto.scrypt(password, salt, 64)` and a random 16-byte salt. Store `salt:hash` in hex. Never store, log, or return the password.
- Compare with `crypto.timingSafeEqual` on buffers of equal length.
- Unknown user and wrong password get the same 401 body.
- Seed accounts come from the task data or a C#. A seed password the docs do not name is an A#.

## Sessions
- Keep a server-side map from session id to `{ userId, role, expiresAt }`. The id is `crypto.randomBytes(32).toString('hex')`.
- Cookie: `sid=<id>; Path=/; HttpOnly; SameSite=Lax`. Add `Secure` only when `req.secure` is true, and call `app.set('trust proxy', 1)` so an https preview proxy counts as secure.
- Why not always `Secure`: the web IDE preview may serve plain http, and a browser never sends a Secure cookie over http. Login answers 200, the next request is 401, and every supertest test still passes because supertest does not enforce the flag.
- Read the cookie with a few lines over `req.headers.cookie`. No cookie-parser.
- `tsx watch` restarts the server on every file change, so an in-memory map empties and the user is logged out while developing. If a C# says sessions survive a restart, keep them in the JSON store under the stateful defaults. Otherwise accept it and fill the RISKS row.
- Missing, unknown, or expired session: 401. Signed in with the wrong role: 403.
- Logout deletes the server entry and sends `sid=; Path=/; Max-Age=0; HttpOnly; SameSite=Lax`.

## CSRF
Every POST, PUT, PATCH, and DELETE under `/api` passes one middleware before its route:

1. It requires the header `X-Requested-With: fetch`. A cross-site form cannot set a custom header, and a cross-site fetch that sets one needs a CORS preflight this server never grants.
2. When an `Origin` header is present, `new URL(origin).host` must equal `req.headers['x-forwarded-host'] ?? req.headers.host`.

Either check failing answers 403 `{ error: { code: 'CSRF', message } }` and changes nothing.

- The preview proxy may rewrite `Host` and pass the public host in `x-forwarded-host`. Comparing against `Host` alone then rejects every real request from the browser. While developing, log both values on a 403.
- The frontend sends every request through the one fetch wrapper in `src/web/api.ts`. It adds the header and `credentials: 'same-origin'`. The one-port stack is same-origin, so no CORS setup.
- GET routes never change state.

## Tests
Use `request.agent(app)` from supertest, which keeps cookies between calls. Names start with the R#.

| Test | Expect |
|---|---|
| login, protected route, logout, protected route | 200, 200, 200 or 204, then 401 |
| wrong password, and an unknown user | 401 with the same body |
| a mutation without `X-Requested-With` | 403 `CSRF`, store unchanged |
| a mutation with `Origin: http://evil.example` | 403 `CSRF` |
| Set-Cookie on login over http | has `HttpOnly` and `SameSite=Lax`, has no `Secure` |
| an operator route with the wrong role | 403 |

## Smoke lines
In `scripts/smoke.sh`, in this order. Every line shares one cookie jar, and `check` sends `$CSRF_HEADER` on every request that is not GET.

```bash
check_cookie         R5 POST /api/login '{"username":"op","password":"..."}'
check                R5 GET  /api/me 200
check_no_csrf        R6 POST /api/<mutation> 403 '{}'
check_foreign_origin R6 POST /api/<mutation> 403 '{}'
check                R5 POST /api/logout 204
check                R5 GET  /api/me 401
```

## Record
- One D#: where sessions live (memory or the JSON store) and the CSRF method (custom header plus Origin check). Rejected options to name:
  - A synchronizer token: one more value to issue, store, and send, for no gain in a same-origin app.
  - SameSite alone: previews of other workspaces may sit on sibling subdomains of the same site, and SameSite does not separate same-site origins.
- `docs/RISKS.md` rows 7 to 9: the Secure cookie over http, CSRF on state-changing routes, sessions lost on restart.
