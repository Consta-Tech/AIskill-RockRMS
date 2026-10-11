#!/usr/bin/env bash
# scripts/check.sh — every model-free repo check, in one place.
#
# .githooks/pre-commit and .github/workflows/knowledge-check.yml both run this script, so the
# local and CI checks cannot drift. Nothing here ships to an installed session; the scripts
# that do (knowledge/render.py, knowledge/changelog.sh, hooks/inject-rule.sh, …) live next to
# the data they read and are only *called* from here.
#
# Usage: bash scripts/check.sh          # exit 1 on the first failing check
set -euo pipefail
cd "$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"

step() { printf '\n\033[1m== %s ==\033[0m\n' "$1"; }
command -v python3 >/dev/null 2>&1 || { echo "check.sh: python3 not found" >&2; exit 1; }

step "Knowledge catalog is current and complete"
python3 knowledge/render.py --check

step "Overlay template manifest is valid"
python3 knowledge/render.py --manifest examples/overlay-template/skills/knowledge-manifest/manifest.yaml --check

step "House rules fit their hook slots and the Antigravity caps"
bash hooks/inject-rule.sh --check

step "Host manifests are valid JSON"
for f in plugin.json .codex-plugin/plugin.json .agents/plugins/marketplace.json \
         .claude-plugin/plugin.json .claude-plugin/marketplace.json hooks/hooks.json; do
    python3 -c "import json, sys; json.load(open(sys.argv[1]))" "$f" && echo "ok $f"
done

step "Skill frontmatter parses as strict YAML"
python3 - <<'EOF'
# Antigravity's YAML parser rejects an unquoted ': ' in a plain scalar and hides the skill.
import glob, re, sys
bad = []
for p in sorted(glob.glob("skills/*/SKILL.md")):
    m = re.match(r"^---\n(.*?)\n---\n", open(p, encoding="utf-8").read(), re.S)
    if not m:
        bad.append(f"{p}: no frontmatter"); continue
    for line in m.group(1).split("\n"):
        k, _, v = line.partition(":")
        v = v.strip()
        if k == "description" and ": " in v and not (v[:1] in "'\"" and v[-1:] == v[:1]):
            bad.append(f"{p}: description contains ': ' and is not quoted")
for b in bad: print("ERROR " + b, file=sys.stderr)
print("skill frontmatter OK" if not bad else f"{len(bad)} problem(s)")
sys.exit(1 if bad else 0)
EOF

step "INSTALL.md keeps one block per host"
python3 scripts/check-install-docs.py

step "OpenCode plugin registers every skill, every rule, and /rockrms-init"
if command -v node >/dev/null 2>&1; then
    node --check .opencode/plugins/rockrms.mjs
    node scripts/opencode-driver.mjs
else
    echo "SKIP: node not found (CI runs this step)"
fi

step "Claude Code manifest and skills validate"
if command -v claude >/dev/null 2>&1; then
    # Expected warnings: "No version specified" (intentional, see README) and "CLAUDE.md at the
    # plugin root is not loaded as project context" (intentional: it imports AGENTS.md for
    # contributors working on a clone, not for installed sessions).
    claude plugin validate .
else
    echo "SKIP: claude not found"
fi

printf '\n\033[1mall checks passed\033[0m\n'
