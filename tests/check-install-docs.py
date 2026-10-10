#!/usr/bin/env python3
"""tests/check-install-docs.py — INSTALL.md keeps one <details> block per host, each with the same headings.

Exit 1 when a host block lacks Install, Verify, Update, or Uninstall, or when a host named in the
"How the house rules load" table has no block. No model calls; run by .githooks/pre-commit and the
knowledge-check workflow.

    python3 tests/check-install-docs.py
"""
import os
import re
import sys

REQUIRED = ["### Install", "### Verify", "### Update", "### Uninstall"]
# Hosts that must have a full block. "Any other agent-skills harness" is documented, not tested,
# and is exempt from the Verify / Update / Uninstall requirement.
HOSTS = ["Claude Code", "Codex", "OpenCode", "Antigravity"]


def main():
    root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    text = open(os.path.join(root, "INSTALL.md"), encoding="utf-8").read()
    blocks = re.findall(r"<details>\s*<summary><strong>(.*?)</strong></summary>(.*?)</details>", text, re.S)
    problems = []
    found = {}
    for title, body in blocks:
        name = re.sub(r"<[^>]+>", "", title).strip()
        found[name] = body
    for host in HOSTS:
        block = next((b for n, b in found.items() if n.startswith(host)), None)
        if block is None:
            problems.append(f"INSTALL.md: no <details> block for {host}")
            continue
        for heading in REQUIRED:
            if heading not in block:
                problems.append(f"INSTALL.md: {host} block lacks '{heading}'")
        if "### House rules" not in block:
            problems.append(f"INSTALL.md: {host} block lacks '### House rules'")
    if "## How the house rules load" not in text:
        problems.append("INSTALL.md: missing '## How the house rules load'")
    if "## Troubleshooting" not in text:
        problems.append("INSTALL.md: missing '## Troubleshooting'")
    for p in problems:
        print("ERROR " + p, file=sys.stderr)
    print("INSTALL.md OK" if not problems else f"{len(problems)} problem(s)")
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main())
