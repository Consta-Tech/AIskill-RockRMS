#!/usr/bin/env bash
# SessionStart hook: prints house-rule text to stdout, which the host adds to the session
# context. Plugins cannot ship always-on rule files for Claude Code or Codex, so a hook
# replicates that auto-load behavior. (Antigravity reads rules/*.md directly; the OpenCode
# plugin injects them into the system prompt.)
#
# hooks/hooks.json calls this script — on Claude Code and on Codex, which reads the same path from
# any plugin (codex-cli 0.162.1 hardcodes hooks/hooks.json; it has no manifest key to pick another
# file). One command per rule CHUNK, because each host caps a single hook command's output: Claude
# Code keeps only a short preview above ~10 KB (measured 2026-09-29 on Claude Code 2.1.285: a
# 9.5 KB block arrived intact, a 14.7 KB block was cut to a 2 KB preview); Codex defaults to
# ~2,500 tokens per hook. Each rule larger than BUDGET bytes is split at heading / <details>
# boundaries into numbered chunks, each its own command. Codex authorizes the whole file in one
# prompt at first start, so thirteen commands cost the user no more than one would.
#
# Usage:
#   inject-rule.sh <rule-file>            # the whole file (must fit the budget)
#   inject-rule.sh <rule-file> <n>        # chunk n (1-based) of that file; prints nothing past the last chunk
#   inject-rule.sh --all                  # every rule, in hooks.json order, as one block (for review)
#   inject-rule.sh --plan                 # print every rule's chunk count and sizes
#   inject-rule.sh --check                # exit 1 when a rule lacks a hooks.json slot, its Antigravity
#                                         #   frontmatter, or exceeds a size cap (run by .githooks/pre-commit)
#
# Rule text may reference <plugin-root> (or ${CLAUDE_PLUGIN_ROOT}); hook output gets no variable
# substitution after this script, so the path is substituted here. Every rule file opens with the
# three-line frontmatter Antigravity requires (--- / trigger: always_on / ---); it is stripped here.
#
# The Python is passed with -c, never as a heredoc: a heredoc needs a writable temp directory,
# and Codex's read-only sandbox denies that. So the Python strings below contain no single quotes.
set -euo pipefail

BUDGET=6000   # bytes per emitted chunk; under Claude Code's measured cap and Codex's ~2,500-token default
ROOT="${CLAUDE_PLUGIN_ROOT:-${PLUGIN_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}}"
RULES_DIR="${ROOT}/rules"

# Shared: frontmatter stripping, splitting at H2/H3 headings and top-level <details>, greedy packing.
PY_CORE='
import re, sys
def strip_fm(t):
    return re.sub(r"\A---[ \t]*\n.*?\n---[ \t]*\n?", "", t, count=1, flags=re.S)
def units_of(text):
    units, cur = [], []
    for l in text.split("\n"):
        if (l.startswith("## ") or l.startswith("### ") or l.startswith("<details")) and cur:
            units.append("\n".join(cur)); cur = []
        cur.append(l)
    if cur: units.append("\n".join(cur))
    return units
def pack(units, budget):
    chunks, cur, size = [], [], 0
    for u in units:
        if cur and size + len(u) + 1 > budget:
            chunks.append("\n".join(cur)); cur, size = [], 0
        cur.append(u); size += len(u) + 1
    if cur: chunks.append("\n".join(cur))
    return chunks
def read_rule(path, root):
    return strip_fm(open(path, encoding="utf-8").read()).replace("${CLAUDE_PLUGIN_ROOT}", root).replace("<plugin-root>", root)
def hook_order(root):
    import json
    hooks = json.load(open(root + "/hooks/hooks.json"))
    names = []
    for group in hooks["hooks"].get("SessionStart", []):
        for h in group.get("hooks", []):
            m = re.search(r"inject-rule\.sh (\S+\.md)", h.get("command", ""))
            if m and m.group(1) not in names: names.append(m.group(1))
    return names
'

PY_EMIT='
path, chunk, budget, root = sys.argv[1], int(sys.argv[2]), int(sys.argv[3]), sys.argv[4]
text = read_rule(path, root)
lines = text.split("\n")
title = next((l[2:].strip() for l in lines if l.startswith("# ")), path.rsplit("/", 1)[-1])
chunks = pack(units_of(text), budget)
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
'

PY_ALL='
root = sys.argv[1]
print("# Rock RMS House Rules (injected by the rockrms plugin)")
for name in hook_order(root):
    print()
    print(read_rule(root + "/rules/" + name, root).rstrip())
    print()
    print("---")
'

PY_PLAN='
import glob, os
rules_dir, budget = sys.argv[1], int(sys.argv[2])
for path in sorted(glob.glob(os.path.join(rules_dir, "*.md"))):
    units = units_of(strip_fm(open(path, encoding="utf-8").read()))
    chunks = pack(units, budget)
    sizes = " ".join(str(len(c)) for c in chunks)
    print(f"{os.path.basename(path)}\t{len(chunks)} chunk(s)\t{sizes} bytes\tmax unit {max(len(u) for u in units)}")
'

PY_CHECK='
import glob, json, os
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
    raw = open(path, encoding="utf-8").read()
    if not raw.startswith("---\ntrigger: always_on\n---\n"):
        problems.append(f"{name}: missing the Antigravity frontmatter (--- / trigger: always_on / ---)")
    if len(raw.encode("utf-8")) > 24000:
        problems.append(f"{name}: {len(raw.encode())} bytes, over the 24,000-byte Antigravity rule cap — split the file")
    units = units_of(strip_fm(raw))
    n = len(pack(units, budget))
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
'

case "${1:-}" in
    --all)   python3 -c "$PY_CORE$PY_ALL" "$ROOT" ;;
    --plan)  python3 -c "$PY_CORE$PY_PLAN" "$RULES_DIR" "$BUDGET" ;;
    --check) python3 -c "$PY_CORE$PY_CHECK" "$ROOT" "$BUDGET" ;;
    "")      echo "usage: inject-rule.sh <rule-file> [chunk] | --all | --plan | --check" >&2; exit 2 ;;
    *)       python3 -c "$PY_CORE$PY_EMIT" "$RULES_DIR/$1" "${2:-0}" "$BUDGET" "$ROOT" ;;
esac
