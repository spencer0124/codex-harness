#!/usr/bin/env bash
# Usage: bash .agents/skills/ui/scripts/shoot.sh <url> <label> [WxH ...]
# Screenshots <url> at each viewport (default 1440x900 1280x800 390x844) into .harness/screenshots/,
# prints the layout-check JSON for each, then the console errors. Exit 1 if any check or console error fails.
set -u
here=$(cd "$(dirname "$0")" && pwd)
ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
url=${1:?url, e.g. http://127.0.0.1:3000/}; label=${2:?label, e.g. U3 or fix-route-view}; shift 2
[ $# -gt 0 ] || set -- 1440x900 1280x800 390x844
out="$ROOT/.harness/screenshots"; mkdir -p "$out"
ts=$(date +%H%M%S)
pw() { bash "$here/pw.sh" -s=ui "$@"; }

pw open "$url" > /dev/null || { echo "FAIL could not open $url (is the dev server running?)"; exit 1; }
fail=0
for vp in "$@"; do
  w=${vp%x*}; h=${vp#*x}
  pw resize "$w" "$h" > /dev/null
  pw goto "$url" > /dev/null
  shot="$out/$label-$vp-$ts.png"
  pw screenshot --filename "$shot" > /dev/null
  res=$(pw --raw run-code --filename "$here/layout-checks.js")
  echo "== $vp $shot"
  echo "$res"
  case "$res" in *'"ok":true'*) ;; *) fail=1 ;; esac
done
errs=$(pw --raw console error)
echo "== console errors"
echo "$errs"
case "$errs" in *"Errors: 0"*|"") ;; *) fail=1 ;; esac
pw close > /dev/null
[ $fail = 0 ] && echo "shoot: clean" || echo "shoot: issues found"
exit $fail
