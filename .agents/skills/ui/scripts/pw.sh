#!/usr/bin/env bash
# Usage: bash .agents/skills/ui/scripts/pw.sh <playwright-cli args>
# Runs the pinned playwright-cli that scripts/install-tools.sh put in .harness/tools, with its browser and daemon state inside the workspace.
set -eu
ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
BIN="$ROOT/.harness/tools/node_modules/.bin/playwright-cli"
[ -x "$BIN" ] || { echo "playwright-cli missing: run bash scripts/install-tools.sh" >&2; exit 127; }
export PLAYWRIGHT_BROWSERS_PATH="${PLAYWRIGHT_BROWSERS_PATH:-$ROOT/.harness/tools/ms-playwright}"
# On Linux playwright-cli keeps its session daemon under $XDG_CACHE_HOME (~/.cache), which a workspace-only sandbox cannot write.
[ "$(uname -s)" = Linux ] && export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$ROOT/.harness/cache}"
cd "$ROOT"
exec "$BIN" "$@"
