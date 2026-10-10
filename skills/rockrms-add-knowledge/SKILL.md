---
name: rockrms-add-knowledge
description: Add a Rock RMS topic to the rockrms plugin's documented knowledge from a URL or a pasted excerpt — drafts a cited reference file in its own words at the summarized tier, files it under the right skill (or a new one), adds its knowledge-manifest row, re-renders the catalog views, and stops before any commit with the exact PR steps. Use when the user offers a source for something the plugin does not cover, accepts the "start documenting it" option from the knowledge-boundaries rule, or invokes the rockrms-add-knowledge skill by name.
allowed-tools: Bash Read Write Edit Grep Glob WebFetch AskUserQuestion
---

# rockrms-add-knowledge

Turn a source into a catalogued reference. The output is a **branch in a clone of the plugin repo** with a new reference file, a manifest row, updated views, and a CHANGELOG bullet — never a commit. The user opens the PR.

## Inputs

- A **URL** (community.rockrms.com, the SparkDevNetwork/Rock source on GitHub, a vendor's documentation, a Rock Shop plugin page) **or a pasted excerpt**. Ask for one if neither was given.
- Optionally the **topic name**. Otherwise derive it from the source and confirm it in one line.

## Locate the plugin first

Step 1 reads the installed plugin. Its root is the directory that holds `knowledge/` and `skills/`: Claude Code and Codex expose it as `${CLAUDE_PLUGIN_ROOT}`; on any other host it is two directories above this `SKILL.md`. Set it once:

```bash
ROOT="${CLAUDE_PLUGIN_ROOT:-${PLUGIN_ROOT:-<absolute path two directories above this SKILL.md>}}"
```

## Step 1 — Is it already documented?

Grep the catalog and the skills tree for the topic's distinctive terms (BlockType name, table, filter, plugin):

```bash
grep -il "<term>" "$ROOT/knowledge/manifest.yaml"
grep -ril "<term>" "$ROOT/skills" --include='*.md' | head
```

If a manifest entry already covers it, **say so** (title, skill, tier, Rock version) and offer to **extend that reference** instead — appending a dated section that carries its own source and tier wording — rather than creating a parallel file. Continue only with the user's choice.

## Step 2 — Generic or church-specific?

Apply the sorting rule: true of Rock anywhere → this plugin; true only at one church (instance Ids, hostnames, page structure, a local decision) → that church's overlay repo. When the source mixes both, split: the generic part goes here, the local part is offered to the overlay. If it is genuinely ambiguous, ask the user one question before writing anything. For an overlay destination, the same steps below apply inside the overlay clone, using its `skills/knowledge-manifest/manifest.yaml`.

## Step 3 — Work in a clone, never in the installed copy

`$ROOT` is the installed copy, replaced on every update — never write there. Find a working clone, in this order:

1. The current directory, if it is the plugin repo (`.claude-plugin/plugin.json` with `"name": "rockrms"`).
2. `../AIskill-RockRMS` or `~/GitHub/AIskill-RockRMS`.
3. Otherwise offer to clone: `git clone https://github.com/Consta-Tech/AIskill-RockRMS.git ~/GitHub/AIskill-RockRMS` (outside contributors fork first and clone their fork).

In the clone: `git fetch origin && git switch -c knowledge/<topic-slug> origin/main`. If the working tree is not clean, stop and ask.

## Step 4 — Read the source

Fetch the URL (or read the excerpt) for understanding. For Rock source, note the **commit SHA** in the URL you cite; for documentation, note today's date as the access date. Identify: what the thing is, what settings or parameters it has, what behavior the source actually states, and what it leaves unsaid.

## Step 5 — Choose the owning skill

| Topic | Skill |
|---|---|
| A core Rock table | `rock-sql-schema` |
| A core BlockType's behavior or settings | `rock-blocktypes` |
| A Lava filter, tag, command, or ShortCode | `language-lava` (extend `Lava-Language.md` with a section, or add a file under `references/`) |
| Helix, Lava Applications, endpoints | `surface-helix` |
| A Rock Shop plugin | its own `<vendor>-<plugin>` skill — `bema-room-management` is the model; create a new skill directory with a `SKILL.md` (frontmatter `name` = directory name, a description that says *when* to load it) and `references/` when none fits |
| Front-end behavior inside Rock blocks | `language-html-htmx` |

Add the new file to the skill's **File Index** table in `SKILL.md`, and to `references/README.md` as well when the skill keeps an index there too (`rock-sql-schema` does).

## Step 6 — Draft the reference, in our own words

Summarize and cite; never copy a page or a source file wholesale. Quotes are short excerpts (a label, an error message, one sentence) and are marked as quotes. Use this shape:

```markdown
# <Title>

> **Provenance tier:** `summarized` — condensed from the cited source, **not yet verified** in Rock (<rock_version or unknown>). Catalogued in the plugin's knowledge manifest; `rockrms-knowledge-current` lists every entry.

**Source:** <URL> (accessed <YYYY-MM-DD>; Rock source pinned at <sha> when applicable)
**Rock version described:** <what the source says, or unknown>

## What it is
## Settings / parameters / columns   (whatever the topic has)
## Behavior the source states
## What the source does not say
## To verify in Rock
- [ ] one measurable check per uncertain claim — the list a future contributor runs to promote this file to `measured`
```

Keep church names, hostnames, and Ids out of it. Spell out BlockType and entity names.

**Table of contents past 100 lines.** When the new file — or the file you extended in Step 1 — runs over 100 lines, it carries a `## Table of Contents` directly under the provenance header and intro, linking every `##` and `###` heading by its GitHub anchor. Update it whenever you add a section. A schema file's `## Summary` table (one row per table: description and key foreign keys) serves the same purpose and needs no separate list; add a row for every table you add.

## Step 7 — Manifest row, views, changelog

Append a row to `knowledge/manifest.yaml` (format and fields are documented at the top of that file and in CONTRIBUTING.md): `tier: summarized`, `status: current`, `added:` today's date, `source_url` set, `rock_version` as the source states it or `unknown`, one-sentence `notes` that names the access date. Then:

```bash
python3 knowledge/render.py && python3 knowledge/render.py --check
```

Add a bullet under `## Unreleased` at the top of `CHANGELOG.md` (create that heading above the newest dated section if it is missing).

## Step 8 — Stop. Do not commit.

Do not run `git add`, `git commit`, or `git push`. Print a summary — the branch, every file created or changed, the tier — followed by these steps for the user to run by hand, filled in with the real names:

```bash
cd <clone>
git config core.hooksPath .githooks        # once per clone; runs the render check before each commit
git add -A
git commit -m "Add <topic> reference (summarized)"
git push -u origin knowledge/<topic-slug>
gh pr create --fill --base main            # or open the PR in the browser
```

Close with one line: the reference enters the catalog at `summarized`; running its "To verify in Rock" checklist and adding the dated observations is what promotes it to `measured`.
