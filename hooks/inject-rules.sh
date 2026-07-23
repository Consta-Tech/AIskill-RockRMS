#!/usr/bin/env bash
# SessionStart hook: prints the Rock RMS house rules to stdout, which Claude
# Code adds to the session context. Plugins cannot ship always-on
# .claude/rules/ files, so this hook replicates that auto-load behavior.
set -euo pipefail

RULES_DIR="${CLAUDE_PLUGIN_ROOT}/rules"

echo "# Rock RMS House Rules (injected by the rockrms plugin)"
echo
echo "The following conventions apply to all Rock RMS development work in this session. Follow them exactly as written."

for f in formatting-standards.md lava-conventions.md about-documentation.md file-organization.md; do
    echo
    echo "---"
    echo
    cat "${RULES_DIR}/${f}"
done
