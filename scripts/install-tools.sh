#!/usr/bin/env bash
# Usage: bash scripts/install-tools.sh [--skip-browser]   Run it yourself at the start, from the workspace root. Safe to rerun.
# Installs the pinned playwright-cli into .harness/tools (gitignored, kept out of package.json), initializes it
# for this workspace, finds Chrome or downloads Chromium into .harness/tools/ms-playwright, and checks that a browser starts.
set -u
PWCLI_VERSION=0.1.22
ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd); cd "$ROOT"
TOOLS="$ROOT/.harness/tools"; BIN="$TOOLS/node_modules/.bin/playwright-cli"
export PLAYWRIGHT_BROWSERS_PATH="$TOOLS/ms-playwright"
[ "$(uname -s)" = Linux ] && export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$ROOT/.harness/cache}"
SKIP_BROWSER=0; [ "${1:-}" = "--skip-browser" ] && SKIP_BROWSER=1
fail=0
say() { printf '%-5s %s\n' "$1" "$2"; [ "$1" = FAIL ] && fail=1; return 0; }

have=$("$BIN" --version 2>/dev/null | tail -1)
if [ "$have" = "$PWCLI_VERSION" ]; then say OK "playwright-cli $have already in .harness/tools"
else
  mkdir -p "$TOOLS"
  if npm install --prefix "$TOOLS" --save-exact --no-audit --no-fund "@playwright/cli@$PWCLI_VERSION" > "$TOOLS/npm.log" 2>&1
  then say DONE "installed playwright-cli $PWCLI_VERSION into .harness/tools"
  else say FAIL "npm install failed, see .harness/tools/npm.log"; exit 1; fi
fi

if [ $SKIP_BROWSER = 1 ]; then say SKIP "browser setup (--skip-browser)"
elif "$BIN" install > "$TOOLS/install.log" 2>&1; then say DONE "workspace initialized: $(grep -Eo 'Found [a-z]+|Created default config for [a-z-]+' "$TOOLS/install.log" | head -1)"
else say FAIL "playwright-cli install failed, see .harness/tools/install.log"; fi

if [ $SKIP_BROWSER = 0 ] && [ $fail = 0 ]; then
  if bash "$ROOT/.agents/skills/ui/scripts/pw.sh" -s=install-check open about:blank > "$TOOLS/launch.log" 2>&1; then
    bash "$ROOT/.agents/skills/ui/scripts/pw.sh" -s=install-check close > /dev/null 2>&1
    say OK "a headless browser starts"
  else
    say FAIL "the browser does not start, see .harness/tools/launch.log. Missing system libraries on Linux: $BIN install-browser chromium --with-deps (needs root)"
  fi
fi

if [ -f "$ROOT/.agents/skills/humanize-korean/SKILL.md" ]; then
  if command -v python3 > /dev/null; then say OK "humanize-korean is vendored, python3 $(python3 -c 'import sys;print("%d.%d"%sys.version_info[:2])')"
  else say FAIL "humanize-korean needs python3"; fi
else say WARN "humanize-korean skill missing from .agents/skills (rerun apply.sh)"; fi

[ $fail = 0 ] && echo "install-tools: done" || echo "install-tools: FAILED"
exit $fail
