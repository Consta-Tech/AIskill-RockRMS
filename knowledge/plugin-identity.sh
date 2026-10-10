#!/usr/bin/env bash
# knowledge/plugin-identity.sh — the one-line identity header every knowledge skill opens with:
#   rockrms (marketplace consta-tech) · installed commit 5a1fe7b · latest release 2026-09-29
#
# The plugin has no version number on purpose (see README "How updates work"), so identity is
# the installed git commit. Lookup order:
#   1. ~/.claude/plugins/installed_plugins.json  → plugins["rockrms@consta-tech"][0].gitCommitSha
#   2. claude plugin list --json                  → the same record
#   3. git rev-parse in the plugin root           → a git clone (OpenCode vendor install, dev checkout, eval run)
#   4. "unknown"
#
# Usage: plugin-identity.sh [plugin-root] [--sha-only | --date-only]
#   plugin-root defaults to the directory above this script.
set -uo pipefail

if [[ "${1:-}" == --* || -z "${1:-}" ]]; then
    ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    MODE="${1:-}"
else
    ROOT="$1"
    MODE="${2:-}"
fi
PLUGIN="rockrms"
MARKET="consta-tech"
KEY="${PLUGIN}@${MARKET}"

sha=""
suffix=""
registry="${HOME:-}/.claude/plugins/installed_plugins.json"
if [ -r "$registry" ] && command -v python3 >/dev/null 2>&1; then
    sha="$(python3 - "$registry" "$KEY" <<'PY' 2>/dev/null
import json, sys
try:
    data = json.load(open(sys.argv[1]))
    recs = data.get("plugins", {}).get(sys.argv[2]) or []
    rec = recs[0] if recs else {}
    print(rec.get("gitCommitSha") or rec.get("version") or "")
except Exception:
    print("")
PY
)"
fi
if [ -z "$sha" ] && command -v claude >/dev/null 2>&1 && command -v python3 >/dev/null 2>&1; then
    sha="$(claude plugin list --json 2>/dev/null | python3 -c '
import json, sys
try:
    for rec in json.load(sys.stdin):
        if rec.get("id") == sys.argv[1]:
            print(rec.get("gitCommitSha") or rec.get("version") or ""); break
except Exception:
    pass' "$KEY" 2>/dev/null)"
fi
if [ -z "$sha" ] && git -C "$ROOT" rev-parse --short=7 HEAD >/dev/null 2>&1; then
    sha="$(git -C "$ROOT" rev-parse --short=7 HEAD)"
    suffix=" (git checkout)"
fi
[ -z "$sha" ] && sha="unknown"
short="${sha:0:7}"

release="$(grep -m1 -E '^## [0-9]{4}-[0-9]{2}-[0-9]{2}' "$ROOT/CHANGELOG.md" 2>/dev/null | sed -E 's/^## ([0-9]{4}-[0-9]{2}-[0-9]{2}).*/\1/')"
[ -z "$release" ] && release="unknown"

case "$MODE" in
    --sha-only)  echo "$short" ;;
    --date-only) echo "$release" ;;
    *)           echo "${PLUGIN} (marketplace ${MARKET}) · installed commit ${short}${suffix} · latest release ${release}" ;;
esac
