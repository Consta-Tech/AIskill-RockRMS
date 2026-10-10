#!/usr/bin/env bash
# setup.sh — bootstrap for the rockrms Claude Code plugin.
#
# Adds the consta-tech marketplace and installs the rockrms plugin (Part 1 of
# INSTALL.md). Workspace scaffolding happens inside Claude Code afterwards,
# via the rockrms-init skill — this script tells you how at the end.
#
# Idempotent: safe to re-run.
#
# The Summit Church developers: use the setup.sh in the AIskill-RockRMS-TSC
# repo instead — it also installs the TSC overlay plugin.
#
# Usage:  bash setup.sh

set -euo pipefail

step() { printf '\n\033[1m== %s ==\033[0m\n' "$1"; }
note() { printf '   %s\n' "$1"; }
die()  { printf 'ERROR: %s\n' "$1" >&2; exit 1; }

step "Preflight checks"
command -v git    >/dev/null || die "git is not installed."
command -v claude >/dev/null || die "Claude Code CLI not found — install it first: https://code.claude.com"
note "git and claude are present."

step "Install the rockrms plugin"
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

step "Done — next: initialize your workspace"
note "Create (or cd into) your workspace directory and start Claude Code:"
note ""
note "    mkdir -p ~/GitHub/claude-rockrms-<yourname>"
note "    cd ~/GitHub/claude-rockrms-<yourname>"
note "    claude"
note ""
note "Then run /rockrms:rockrms-init. It interviews"
note "you and scaffolds everything: _code, docs/, input_box/, .gitignore,"
note "an AGENTS.md built from your answers, and a CLAUDE.md that imports it."
