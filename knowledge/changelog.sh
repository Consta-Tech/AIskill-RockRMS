#!/usr/bin/env bash
# knowledge/changelog.sh — what /rockrms:changelog prints.
#
# Prints the identity header, then the newest dated section of CHANGELOG.md. Remembers the
# installed commit it showed in the plugin's data directory; when that commit has changed
# since the last run, every release section newer than the one seen last time is printed
# under "Since you last checked" before the store is updated. Without a usable data
# directory it degrades to "latest section only" and says so — never an error.
#
# Usage: changelog.sh <plugin-root> [data-dir]
#   data-dir is normally ${CLAUDE_PLUGIN_DATA}; an empty or unexpanded value disables the store.
set -uo pipefail

ROOT="${1:?usage: changelog.sh <plugin-root> [data-dir]}"
DATA="${2:-}"
CHANGELOG="$ROOT/CHANGELOG.md"
IDENTITY="$ROOT/knowledge/plugin-identity.sh"

if [ ! -r "$CHANGELOG" ]; then
    echo "CHANGELOG.md not found at $CHANGELOG"
    exit 1
fi

header="$(bash "$IDENTITY" "$ROOT")"
sha="$(bash "$IDENTITY" "$ROOT" --sha-only)"
latest="$(bash "$IDENTITY" "$ROOT" --date-only)"

store=""
if [ -n "$DATA" ] && [[ "$DATA" != *'${'* ]]; then
    if mkdir -p "$DATA" 2>/dev/null && [ -w "$DATA" ]; then
        store="$DATA/changelog-seen.tsv"
    fi
fi

prev_sha=""
prev_date=""
if [ -n "$store" ] && [ -r "$store" ]; then
    IFS=$'\t' read -r prev_sha prev_date _rest < "$store" || true
fi

# print_sections ""        → the newest dated section only
# print_sections YYYY-MM-DD → every dated section strictly newer than that date
print_sections() {
    awk -v since="$1" '
        /^## [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]/ {
            d = substr($2, 1, 10)
            if (since == "") { if (n > 0) exit; n++; p = 1 }
            else { p = (d > since); if (p) n++ }
        }
        /^## / && $2 !~ /^[0-9][0-9][0-9][0-9]-/ { p = 0 }   # an "## Unreleased" heading is not a release
        p { print }
    ' "$CHANGELOG"
}

echo "$header"
echo
if [ -n "$prev_sha" ] && [ "$prev_sha" != "$sha" ] && [ "$sha" != "unknown" ]; then
    echo "## Since you last checked (you were on commit ${prev_sha}, release ${prev_date:-unknown})"
    echo
    newer="$(print_sections "${prev_date}")"
    if [ -n "$newer" ]; then
        echo "$newer"
    else
        echo "The installed commit moved from ${prev_sha} to ${sha}, but no new release section has been added since ${prev_date:-unknown}. Latest release:"
        echo
        print_sections ""
    fi
else
    print_sections ""
fi

if [ -n "$store" ]; then
    printf '%s\t%s\t%s\n' "$sha" "$latest" "$(date -u +%Y-%m-%dT%H:%M:%SZ)" > "$store"
else
    echo
    echo "_(No plugin data directory was available, so this shows the latest release only; the \"since you last checked\" view needs one.)_"
fi
