---
name: ui
description: Build and check the frontend. Applies design/DESIGN.md and the frontend-design skill, screenshots the app at 1440x900, 1280x800, and 390x844 with playwright-cli, runs layout checks, and fixes until clean. Use for an FE row in PLAN.md, for "$ui check" (look without changing), and for "$ui fix <request>" when the user reports something that looks wrong.
---

# UI

Three modes:
- `$ui` runs one FE unit. In the build loop it replaces build steps 2 to 4. The planner brief (step 1) and the verifier (step 5) stay.
- `$ui check` shoots the current app and reports problems. It changes nothing.
- `$ui fix <request>` handles a visual problem the user reports, such as "the route view is too narrow".

## Tools
- `bash .agents/skills/ui/scripts/shoot.sh <url> <label> [WxH ...]` screenshots the page at 1440x900, 1280x800, and 390x844 into `.harness/screenshots/`, prints the layout-check JSON per viewport and the console errors, and exits 0 only when all are clean.
- `bash .agents/skills/ui/scripts/pw.sh -s=ui <command>` runs any other playwright-cli command. Commands: `references/playwright-cli.md`.
- What each check means, how to fix it, and how to shoot empty, loading, error, and long-data states: `references/checks.md`.
- Korean copy rules: `references/copy.md`.

## Before the first FE unit
1. Read `design/DESIGN.md` in full, then `.agents/skills/frontend-design/SKILL.md`. DESIGN.md sets the tokens and components. frontend-design sets the judgment: hierarchy, type, no generated-looking defaults. Where they disagree, DESIGN.md wins.
2. Run `bash .agents/skills/ui/scripts/pw.sh --version`. It must print `0.1.22`. Exit 127 means the tools are missing: ask the user to run `bash scripts/install-tools.sh`. Do not install a browser yourself.
3. If the logo files listed in the Logo section of DESIGN.md are missing, run `bash scripts/fetch-logo.sh`. On FAIL, put the brand name as text in the header and tell the user. Do not look for logo files anywhere else.
4. Write the DESIGN.md tokens once as CSS custom properties in `src/web/styles/tokens.css`. Components use `var(--...)`, never a raw hex value.

## $ui: one FE unit
1. Implement. Give a fresh `implementer` the brief plus: "Follow design/DESIGN.md and .agents/skills/ui/references/copy.md." Logic the brief names (formatting, sorting, what a state shows) gets a test first, as in any unit.
2. Start the dev server if none runs (`npm run dev`, note the PID and port), or reuse the running one.
3. Shoot: `shoot.sh http://127.0.0.1:<port>/<path> U#`. Then shoot each state the brief names (empty, loading, error, long data) with the mocks in `references/checks.md`, labeled `U#-<state>`.
4. Open and look at every screenshot. The checks catch geometry only. Looking catches wrong hierarchy, low contrast, misaligned numbers, a cramped view, and copy that reads machine-written. Write each problem down with its viewport and screenshot path.
5. Review. Give a fresh `ui-tester` the brief path, the URL, and the states. It shoots and looks on its own and returns findings. It edits nothing.
6. Fix. Give a fresh `implementer` the accepted findings from steps 3 to 5. Reshoot all three viewports. Repeat until `shoot.sh` exits 0 and your own look finds nothing. Budget: 3 rounds, then PARTIAL as in build step 4.
7. Copy. Collect the Korean strings the unit added and run `$humanize-korean` on them in light mode. Apply only edits that keep the meaning and fit the element.
8. Evidence. Copy the final 1440x900 and 390x844 shots to `docs/screenshots/U#-<WxH>.png`. Write the E#: 명령 is the `shoot.sh` line, 출력 is the `"ok":true` lines and what you saw. Log every judged finding as an F# in `docs/AI_LOG.md` (build skill format). Hand over to the verifier.

## $ui check
Shoot every screen named in PLAN.md's FE rows at the three viewports, look at each shot, and report a list: screen, viewport, screenshot path, problem, and the DESIGN.md rule or R# it breaks. Change nothing.

## $ui fix <request>
The user's words are the spec.
1. Rewrite the request as a condition you can check. "경로 뷰가 너무 좁다" becomes "the route view is at least 320x240 at 390px wide and fills its column at 1280px and 1440px".
2. Reproduce first. Shoot the viewports the request implies with label `fix-<slug>-before` and look at the shots. If you cannot see the problem, show the user the screenshot path and ask once what they see. Do not fix blind.
3. Find the cause in the layout: a fixed width, a flex item that cannot shrink or grow, a missing `min-width: 0`, a parent with `overflow: hidden`, no height on the parent of an SVG. Fix the cause. No `!important`, no pixel value that fits one viewport only.
4. Reshoot all three viewports with label `fix-<slug>-after` and look at them. The fix must not break the other two.
5. Lock it in when that is cheap. A size problem gets `data-ui-min="WxH"` on the element, and every later shoot enforces it. Overlap, clipping, and sideways overflow are already checked everywhere. Anything else is "checked by screenshot only" in the E#.
6. Copy the before and after shots to `docs/screenshots/fix-<slug>-{before,after}-<WxH>.png`. Report the cause in one line, the change, and the E#. The verifier commits it as `fix(R#): <what>` with the R# of the screen.

## Rules
- No screen scrolls sideways at any of the three viewports. A wide table scrolls inside its own box.
- Every map, chart, or route view fills its container, has a minimum size, and carries `data-ui-min`. Never a fixed small width.
- Long Korean names: `word-break: keep-all`, and ellipsis with a `title` tooltip where space is short. Never clip silently.
- SVG first for paths and charts. A drawing or map library needs a C# and a D# (`.agents/skills/plan/references/stack.md`).
- Drive only this workspace's dev server (AGENTS.md section 1).
- If the sandbox stops the browser from starting or from reaching the dev server, stop and tell the user (AGENTS.md section 1). Do not switch tools.
