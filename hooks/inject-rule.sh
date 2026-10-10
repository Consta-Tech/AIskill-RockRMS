#!/usr/bin/env bash
# SessionStart hook: prints ONE house-rule file (or one chunk of it) to stdout, which Claude
# Code adds to the session context. Plugins cannot ship always-on .claude/rules/ files, so
# hooks/hooks.json runs this script once per rule file to replicate that auto-load behavior.
#
# Why one hook command per rule, and why chunks: Claude Code caps the size of a single hook
# command's output that it keeps inline in context (measured 2026-09-29 on Claude Code 2.1.285:
# a 9.5 KB block arrived intact, a 14.7 KB block was cut to a 2 KB preview with the rest
# persisted to a file the model never reads). One 50 KB block therefore delivered almost
# nothing. Each rule is emitted by its own command, and a rule larger than BUDGET bytes is
# split at heading / <details> boundaries into numbered chunks, each its own command.
#
# Usage:
#   inject-rule.sh <rule-file>            # the whole file (must fit the budget)
#   inject-rule.sh <rule-file> <n>        # chunk n (1-based) of that file; prints nothing past the last chunk
#   inject-rule.sh --plan                 # print every rule's chunk count and sizes
#   inject-rule.sh --check                # exit 1 when hooks.json lacks a slot for some chunk (run by .githooks/pre-commit)
#
# Rule text may reference <plugin-root> (or ${CLAUDE_PLUGIN_ROOT}); hook output gets no variable substitution
# after this script, so the path is substituted here.
set -euo pipefail

BUDGET=8000   # bytes per emitted block; keep well under the measured cap
ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
RULES_DIR="${ROOT}/rules"

emit() {   # emit <file> <chunk-or-0>
    python3 - "$RULES_DIR/$1" "$2" "$BUDGET" "$ROOT" <<'PY'
import re, sys
path, chunk, budget, root = sys.argv[1], int(sys.argv[2]), int(sys.argv[3]), sys.argv[4]
text = open(path, encoding="utf-8").read().replace("${CLAUDE_PLUGIN_ROOT}", root).replace("<plugin-root>", root)
lines = text.split("\n")
title = next((l[2:].strip() for l in lines if l.startswith("# ")), path.rsplit("/", 1)[-1])
# Split into units at H2/H3 headings and top-level <details> blocks, then pack greedily.
units, cur = [], []
for l in lines:
    if (l.startswith("## ") or l.startswith("### ") or l.startswith("<details")) and cur:
        units.append("\n".join(cur)); cur = []
    cur.append(l)
if cur: units.append("\n".join(cur))
chunks, cur, size = [], [], 0
for u in units:
    if cur and size + len(u) + 1 > budget:
        chunks.append("\n".join(cur)); cur, size = [], 0
    cur.append(u); size += len(u) + 1
if cur: chunks.append("\n".join(cur))
if chunk == 0:
    body = text
else:
    if chunk > len(chunks): sys.exit(0)          # past the last chunk: emit nothing
    body = chunks[chunk - 1]
    if chunk > 1:
        body = f"# {title} (continued, part {chunk} of {len(chunks)})\n\n" + body
    elif len(chunks) > 1:
        body = body.replace(f"# {title}", f"# {title} (part 1 of {len(chunks)})", 1)
print("# Rock RMS House Rule (injected by the rockrms plugin)")
print()
print(body)
PY
}

plan() {
    for f in "$RULES_DIR"/*.md; do
        python3 - "$f" "$BUDGET" <<'PY'
import sys
path, budget = sys.argv[1], int(sys.argv[2])
lines = open(path, encoding="utf-8").read().split("\n")
units, cur = [], []
for l in lines:
    if (l.startswith("## ") or l.startswith("### ") or l.startswith("<details")) and cur:
        units.append("\n".join(cur)); cur = []
    cur.append(l)
if cur: units.append("\n".join(cur))
chunks, cur, size = [], [], 0
for u in units:
    if cur and size + len(u) + 1 > budget:
        chunks.append(size); cur, size = [], 0
    cur.append(u); size += len(u) + 1
if cur: chunks.append(size)
name = path.rsplit("/", 1)[-1]
print(f"{name}\t{len(chunks)} chunk(s)\t{' '.join(str(s) for s in chunks)} bytes\tmax unit {max(len(u) for u in units)}")
PY
    done
}

check() {   # every rules/*.md must be listed in hooks/hooks.json with slots >= its chunk count
    python3 - "$ROOT" "$BUDGET" <<'PY'
import glob, json, os, re, sys
root, budget = sys.argv[1], int(sys.argv[2])
hooks = json.load(open(os.path.join(root, "hooks", "hooks.json")))
slots = {}
for group in hooks["hooks"].get("SessionStart", []):
    for h in group.get("hooks", []):
        m = re.search(r"inject-rule\.sh (\S+\.md) (\d+)", h.get("command", ""))
        if m:
            slots[m.group(1)] = max(slots.get(m.group(1), 0), int(m.group(2)))
problems = []
for path in sorted(glob.glob(os.path.join(root, "rules", "*.md"))):
    name = os.path.basename(path)
    lines = open(path, encoding="utf-8").read().split("\n")
    units, cur = [], []
    for l in lines:
        if (l.startswith("## ") or l.startswith("### ") or l.startswith("<details")) and cur:
            units.append("\n".join(cur)); cur = []
        cur.append(l)
    if cur: units.append("\n".join(cur))
    n, size = 1, 0
    for u in units:
        if size and size + len(u) + 1 > budget:
            n += 1; size = 0
        size += len(u) + 1
    big = max(len(u) for u in units)
    if big > budget:
        problems.append(f"{name}: a single section is {big} bytes, over the {budget}-byte budget — add a heading or <details> boundary")
    if name not in slots:
        problems.append(f"{name}: not listed in hooks/hooks.json")
    elif slots[name] < n:
        problems.append(f"{name}: needs {n} chunk slot(s) in hooks/hooks.json, has {slots[name]}")
for p in problems:
    print("ERROR " + p, file=sys.stderr)
print("house-rule hooks OK" if not problems else f"{len(problems)} problem(s)")
sys.exit(1 if problems else 0)
PY
}

case "${1:-}" in
    --plan)  plan ;;
    --check) check ;;
    "")      echo "usage: inject-rule.sh <rule-file> [chunk] | --plan | --check" >&2; exit 2 ;;
    *)      emit "$1" "${2:-0}" ;;
esac
