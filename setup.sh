#!/usr/bin/env bash
# setup.sh — bootstrap for the rockrms plugin on any supported harness.
#
# Installs the plugin into ONE harness (Part 1 of INSTALL.md) and prints how to
# initialize a workspace with the rockrms-init skill afterwards (Part 2).
#
# Usage:  bash setup.sh [--harness claude|codex|opencode|antigravity]
#         (no --harness: claude; --host is accepted as an alias)
#
# Idempotent: safe to re-run. Each harness's own package manager owns the install;
# this script only issues the commands INSTALL.md documents for that harness.
#
# The Summit Church developers: use the setup.sh in the AIskill-RockRMS-TSC
# repo instead — it also installs the TSC overlay plugin.

set -euo pipefail

REPO_SLUG="Consta-Tech/AIskill-RockRMS"
REPO_URL="https://github.com/${REPO_SLUG}"
HOST="claude"

while [ $# -gt 0 ]; do
    case "$1" in
        --harness|--host) HOST="${2:-}"; shift 2 ;;
        --harness=*) HOST="${1#--harness=}"; shift ;;
        --host=*) HOST="${1#--host=}"; shift ;;
        -h|--help) sed -n '2,13p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *) printf 'Unknown argument: %s\n' "$1" >&2; exit 2 ;;
    esac
done

step() { printf '\n\033[1m== %s ==\033[0m\n' "$1"; }
note() { printf '   %s\n' "$1"; }
die()  { printf 'ERROR: %s\n' "$1" >&2; exit 1; }
try()  { if "$@"; then return 0; else note "The command above did not succeed — if its message says this is already installed or already exists, that's fine."; fi; }

step "Preflight checks"
command -v git >/dev/null || die "git is not installed."

case "$HOST" in
    claude)
        command -v claude >/dev/null || die "Claude Code CLI not found — install it first: https://code.claude.com"
        step "Install the rockrms plugin into Claude Code"
        try claude plugin marketplace add "$REPO_SLUG"
        try claude plugin install rockrms@consta-tech
        INVOKE='/rockrms:rockrms-init'
        START='claude'
        ;;
    codex)
        command -v codex >/dev/null || die "Codex CLI not found — install it first: https://developers.openai.com/codex"
        step "Install the rockrms plugin into Codex"
        try codex plugin marketplace add "$REPO_SLUG" --ref main
        try codex plugin add rockrms@consta-tech
        INVOKE='$rockrms:rockrms-init'
        START='codex'
        ;;
    opencode)
        command -v opencode >/dev/null || die "OpenCode not found — install it first: https://opencode.ai"
        CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/opencode"
        VENDOR_DIR="$CONFIG_DIR/vendor/rockrms"
        LOADER="$CONFIG_DIR/plugins/rockrms.js"
        step "Install the rockrms plugin into OpenCode"
        if [ -d "$VENDOR_DIR/.git" ]; then
            git -C "$VENDOR_DIR" pull --ff-only && note "Updated clone: $VENDOR_DIR"
        else
            mkdir -p "$(dirname "$VENDOR_DIR")"
            git clone "$REPO_URL" "$VENDOR_DIR" && note "Cloned: $VENDOR_DIR"
        fi
        mkdir -p "$(dirname "$LOADER")"
        printf "export { default } from '../vendor/rockrms/.opencode/plugins/rockrms.mjs';\n" > "$LOADER"
        note "Wrote loader: $LOADER"
        INVOKE='/rockrms-init'
        START='opencode'
        ;;
    antigravity)
        command -v agy >/dev/null || die "Antigravity CLI (agy) not found — install it first: https://antigravity.google"
        step "Install the rockrms plugin into Antigravity"
        try agy plugin install "$REPO_URL"
        INVOKE='/rockrms-init'
        START='agy'
        ;;
    *)
        die "Unknown harness '$HOST'. Use --harness claude, codex, opencode, or antigravity."
        ;;
esac

step "Done — next: initialize your workspace"
note "Create (or cd into) your workspace directory and start your agent:"
note ""
note "    mkdir -p ~/GitHub/rockrms-workspace-<yourname>"
note "    cd ~/GitHub/rockrms-workspace-<yourname>"
note "    $START"
note ""
note "Then run $INVOKE. It interviews you and scaffolds everything:"
note "_code, docs/, input_box/, .gitignore, an AGENTS.md built from your"
note "answers, and a CLAUDE.md that imports it."
