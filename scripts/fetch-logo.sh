#!/usr/bin/env bash
# Usage: bash scripts/fetch-logo.sh [dest-dir]   Run it at contest time; the logo files never live in the harness repository.
# Downloads the official SK hynix logos from skhynix.com into src/web/public/brand/ (served at /brand/) or public/brand/.
# Exit 1 when a required file no longer downloads as the expected image, which means the site moved it.
set -u
ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
if [ -n "${1:-}" ]; then DEST=$1; elif [ -d "$ROOT/src/web" ]; then DEST="$ROOT/src/web/public/brand"; else DEST="$ROOT/public/brand"; fi
mkdir -p "$DEST"
fail=0

png_size() { od -An -tu1 -j16 -N8 "$1" | awk 'NF==8{printf "%dx%d", $1*16777216+$2*65536+$3*256+$4, $5*16777216+$6*65536+$7*256+$8}'; }

get() {
  local url=$1 name=$2 kind=$3 need=$4 tmp code ok=0
  tmp=$(mktemp)
  code=$(curl -sSL -m 20 -A 'Mozilla/5.0' -o "$tmp" -w '%{http_code}' "$url" 2>/dev/null)
  if [ "$code" = 200 ]; then
    case $kind in
      png) [ "$(od -An -tx1 -N4 "$tmp" | tr -d ' \n')" = 89504e47 ] && ok=1 ;;
      svg) grep -q '<svg' "$tmp" && ok=1 ;;
    esac
  fi
  if [ $ok = 1 ]; then
    mv "$tmp" "$DEST/$name"
    local info="$(wc -c < "$DEST/$name" | tr -d ' ') bytes"
    [ "$kind" = png ] && info="$(png_size "$DEST/$name"), $info"
    echo "OK   $DEST/$name ($info)"
  else
    rm -f "$tmp"
    if [ "$need" = required ]; then echo "FAIL $url (HTTP ${code:-none}, not a $kind): find the new path in the site's CSS"; fail=1
    else echo "WARN $url (HTTP ${code:-none}): optional, skipped"; fi
  fi
}

get https://www.skhynix.com/img/common/img_logo_m.png skhynix-logo.png png required
get https://www.skhynix.com/img/content/img_logo_white.png skhynix-logo-white.png png required
get https://news.skhynix.co.kr/wp-content/themes/skhynix/assets/images/img_logo_footer_pc_250524.svg skhynix-logo-white.svg svg optional

[ $fail = 0 ] && echo "fetch-logo: done. Show skhynix-logo.png at 66x36 CSS px (2x asset); see design/DESIGN.md, Logo." || echo "fetch-logo: FAILED"
exit $fail
