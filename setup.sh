#!/usr/bin/env bash
# setup.sh — scripted install for the rockrms Claude Code plugin, with an
# optional workspace-repo scaffold for your church.
#
# Performs the steps documented in INSTALL.md:
#   Part 1: adds the consta-tech marketplace and installs the rockrms plugin
#   Part 2 (optional): scaffolds ~/GitHub/claude-rockrms-<name>, clones your
#           church's code repo as a sibling, and symlinks _code
#
# Idempotent: safe to re-run. Existing files are never overwritten.
#
# The Summit Church developers: use the setup.sh in the AIskill-RockRMS-TSC
# repo instead — it also installs the TSC overlay plugin.
#
# Usage:  bash setup.sh

set -euo pipefail

GITHUB_DIR="$HOME/GitHub"

step() { printf '\n\033[1m== %s ==\033[0m\n' "$1"; }
note() { printf '   %s\n' "$1"; }
die()  { printf 'ERROR: %s\n' "$1" >&2; exit 1; }

# Writes stdin to $1 with every {{CHURCH_REPO}} / {{CHURCH_REPO_SLUG}}
# placeholder replaced. sed-to-temp keeps this portable across macOS/Linux.
render() {
    sed -e "s|{{CHURCH_REPO}}|$CHURCH_REPO|g" -e "s|{{CHURCH_REPO_SLUG}}|$CHURCH_REPO_SLUG|g" > "$1"
}

step "Preflight checks"
command -v git    >/dev/null || die "git is not installed."
command -v claude >/dev/null || die "Claude Code CLI not found — install it first: https://code.claude.com"
note "git and claude are present."

step "Part 1 — Install the rockrms plugin"
if claude plugin marketplace add Consta-Tech/AIskill-RockRMS; then
    note "Added marketplace: consta-tech"
else
    note "consta-tech marketplace not added — if the message above says it already exists, that's fine."
fi
if claude plugin install rockrms@consta-tech; then
    note "Installed: rockrms@consta-tech"
else
    note "rockrms not installed — if the message above says it is already installed, that's fine."
fi

step "Part 2 — Workspace repo (optional)"
printf 'Scaffold a workspace repo for your church now? [y/N] '
read -r SCAFFOLD
case "$SCAFFOLD" in
    y|Y|yes|YES) ;;
    *) step "Done"; note "Plugin installed. Re-run this script any time to scaffold a workspace."; exit 0 ;;
esac

printf 'Your church code repo (owner/name or full git URL): '
read -r CHURCH_INPUT
[ -n "$CHURCH_INPUT" ] || die "A church code repo is required."
case "$CHURCH_INPUT" in
    *://*|git@*) CHURCH_URL="$CHURCH_INPUT" ;;
    *)           CHURCH_URL="https://github.com/$CHURCH_INPUT.git" ;;
esac
CHURCH_REPO_SLUG="$CHURCH_INPUT"
CHURCH_REPO="$(basename "$CHURCH_URL" .git)"

printf 'Short name for your workspace repo (claude-rockrms-<name>): '
read -r NAME
[ -n "$NAME" ] || die "A name is required."
WS="$GITHUB_DIR/claude-rockrms-$NAME"

mkdir -p "$WS/input_box" "$WS/.claude"
note "Workspace directory: $WS"

created_repo=0
if [ ! -d "$WS/.git" ]; then
    git -C "$WS" init -b main >/dev/null
    created_repo=1
    note "Initialized git repository."
fi

if [ -f "$WS/CLAUDE.md" ]; then
    note "CLAUDE.md already exists — left untouched."
else
    render "$WS/CLAUDE.md" <<'EOF'
# CLAUDE.md

## Context

This is my Rock RMS development workspace. Rock RMS is an open-source church management system built on ASP.NET.

House rules, language references (Lava, T-SQL, HTMX), Rock schema docs, and audit skills come from the `rockrms` Claude Code plugin (`Consta-Tech/AIskill-RockRMS`). The house rules are injected automatically at session start — follow them.

## Layout

- `_code/` is a symlink into my sibling clone of `{{CHURCH_REPO_SLUG}}`. All Rock code lives there. Commits and PRs for code changes happen in that repo, not this one.
- `input_box/` is a gitignored dropbox for rough drafts. Each file's line 1 is a comment hinting its destination directory or end goal; process it per the file-organization rules.

## Workflow Context

Code in this workspace follows this development cycle:

1. Write/edit code in `_code/`
2. Paste into a Rock RMS Block to test behavior
3. Iterate until the code behaves as expected
4. Commit clean, working code (in the `{{CHURCH_REPO}}` repo)
5. Update corresponding documentation if behavior changed

When I describe what I'm observing after testing in Rock, treat that as the ground truth — Rock's rendering is the authority on whether code works.

## Task Types

When I start a conversation, I will tell you whether this is:

- **Brainstorming** — Explore approaches, weigh tradeoffs, no code changes yet
- **Troubleshooting** — Code exists but isn't behaving as expected. I'll describe what I see vs. what I expected.
- **Polishing** — Code works correctly but needs UX/visual/readability improvements
- **Documentation** — Update or create docs to reflect current implementations

## Important Notes

- Lava is NOT identical to Liquid. Do not assume Liquid syntax works in Lava. When unsure, consult the `language-lava` skill.
- When writing SQL that joins to people, always join through PersonAlias — see the `rock-sql-schema` skill.
EOF
    note "Wrote CLAUDE.md"
fi

if [ -f "$WS/.gitignore" ]; then
    note ".gitignore already exists — left untouched."
else
    cat > "$WS/.gitignore" <<'EOF'
input_box/
CLAUDE.local.md
.claude/settings.local.json
.DS_Store
EOF
    note "Wrote .gitignore"
fi

if [ -f "$WS/.claude/settings.json" ]; then
    note ".claude/settings.json already exists — left untouched."
else
    render "$WS/.claude/settings.json" <<'EOF'
{
  "permissions": {
    "additionalDirectories": ["../{{CHURCH_REPO}}"]
  },
  "extraKnownMarketplaces": {
    "consta-tech": {
      "source": { "source": "github", "repo": "Consta-Tech/AIskill-RockRMS" }
    }
  },
  "enabledPlugins": {
    "rockrms@consta-tech": true
  }
}
EOF
    note "Wrote .claude/settings.json"
fi

step "Church code repo + _code symlink"
if [ -d "$GITHUB_DIR/$CHURCH_REPO" ]; then
    note "$GITHUB_DIR/$CHURCH_REPO already exists — left untouched."
else
    git clone "$CHURCH_URL" "$GITHUB_DIR/$CHURCH_REPO"
    note "Cloned $CHURCH_URL"
fi

if [ -L "$WS/_code" ] || [ -e "$WS/_code" ]; then
    note "_code already exists — left untouched."
else
    ln -s "../$CHURCH_REPO/_code" "$WS/_code"
    note "Symlinked _code -> ../$CHURCH_REPO/_code"
fi

if [ "$created_repo" -eq 1 ]; then
    git -C "$WS" add -A
    git -C "$WS" commit -m "Scaffold Rock workspace" >/dev/null
    note "Committed the workspace scaffold."
else
    note "Pre-existing git repo — review 'git status' there and commit manually."
fi

step "Done"
note "Workspace: $WS"
note "Next steps:"
note "  1. Open a new Claude Code session in $WS"
note "  2. Run /context — the 'Rock RMS House Rules' should be listed"
note "  3. Type /rockrms: — autocomplete should offer the skills"
note "  4. Building a church overlay plugin? See examples/overlay-template/ in this repo."
