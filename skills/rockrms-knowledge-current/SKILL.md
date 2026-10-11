---
name: rockrms-knowledge-current
description: List what the rockrms plugin has documented — every reference file and coverage claim, grouped by category and provenance tier (measured, traced, summarized) with the Rock version each was verified on — plus any installed church overlay's catalog. Load whenever a session must decide whether the plugin covers a Rock topic, when the user asks what the plugin knows or is documented on, or invokes the rockrms-knowledge-current skill by name.
allowed-tools: Bash Read Grep Skill
---

# rockrms-knowledge-current

The catalog lives in `knowledge/manifest.yaml`; `knowledge/render.py` prints it. This skill runs the renderer, adds the instance's Rock version when the workspace records one, and appends an installed church overlay's catalog.

## Locate the plugin first

The commands below need the plugin's root directory — the one that holds `knowledge/` and `skills/`. Claude Code and Codex expose it as `${CLAUDE_PLUGIN_ROOT}`; on any other harness it is two directories above this `SKILL.md` (`<root>/skills/rockrms-knowledge-current/SKILL.md`). Set it once:

```bash
ROOT="${CLAUDE_PLUGIN_ROOT:-${PLUGIN_ROOT:-<absolute path two directories above this SKILL.md>}}"
```

## Do this

1. **Instance Rock version (optional).** If `docs/instance-facts.md` exists in the current directory, read its Rock version row (a table row under a "Rock version" heading, written by the `rockrms-init` skill). Keep the value only if it looks like a version (`v18.2.4`, `18.2`); ignore `unknown` or a blank.

2. **Header.** Run and print verbatim:

   ```bash
   bash "$ROOT/knowledge/plugin-identity.sh" "$ROOT"
   ```

3. **Catalog.** Run and print verbatim (add `--instance-version <value>` when step 1 found one):

   ```bash
   python3 "$ROOT/knowledge/render.py" --stdout current --format terminal
   ```

   The renderer groups by category, then by tier, one line per entry. With an instance version it marks ⚠ every entry verified on a **newer** Rock version than the instance runs — read that as "treat as unverified here", and say so in one sentence after the list.

4. **Overlay.** Look through your available skills for one named exactly `knowledge-manifest` (match by skill name only, never by path; church overlay plugins such as `rockrms-tsc` ship it). If present, load it: its content states the church name and where its `manifest.yaml` sits relative to the overlay's own root — resolve that against the directory you loaded the overlay's `SKILL.md` from. Then run and print:

   ```bash
   python3 "$ROOT/knowledge/render.py" --manifest "<that path>" --stdout current --format terminal --heading "Overlay: <church name>"
   ```

   Overlays may not ship pre-rendered views, so the overlay is always rendered at runtime. If no such skill exists, say nothing about overlays.

5. **Footer.** End with: `For a table with source links, see https://github.com/Consta-Tech/AIskill-RockRMS/blob/main/knowledge/Knowledge-current.md` and one line pointing at `rockrms-knowledge-future` (roadmap) and `rockrms-add-knowledge` (contribute a topic).

Print the renderer's output as-is; do not summarize rows away or re-group them.

## Answering "does the plugin cover X?"

When the user asks about one topic rather than the whole catalog, do not print everything. Grep the manifest for the topic's distinctive terms, then the skills tree:

```bash
grep -il "<term>" "$ROOT/knowledge/manifest.yaml"
grep -ril "<term>" "$ROOT/skills" --include='*.md' | head
```

Report the matching entry (title, skill, tier, Rock version) or say there is none and offer `rockrms-add-knowledge`, per the injected knowledge-boundaries rule.

## Wording

The plugin is *documented* on these topics, never "trained". It is a plugin, not a Skill, and it has no version number — the header's commit is its identity.
