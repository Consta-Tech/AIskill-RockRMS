---
name: rockrms-knowledge-future
description: List the rockrms plugin's knowledge roadmap — the topics with a status of roadmap in its catalog, numbered, plus any installed church overlay's roadmap. Use when the user asks what the plugin will document next, whether a topic is planned, how to request a topic, or invokes the rockrms-knowledge-future skill by name.
allowed-tools: Bash Read Skill
---

# rockrms-knowledge-future

Roadmap entries are manifest rows with `status: roadmap` — a title, a category, the source a contributor would start from, and a note on why it matters. They become `current` when the reference file lands.

## Locate the plugin first

The commands below need the plugin's root directory — the one that holds `knowledge/` and `skills/`. Claude Code and Codex expose it as `${CLAUDE_PLUGIN_ROOT}`; on any other host it is two directories above this `SKILL.md` (`<root>/skills/rockrms-knowledge-future/SKILL.md`). Set it once:

```bash
ROOT="${CLAUDE_PLUGIN_ROOT:-${PLUGIN_ROOT:-<absolute path two directories above this SKILL.md>}}"
```

## Do this

1. **Header.** Run and print verbatim:

   ```bash
   bash "$ROOT/knowledge/plugin-identity.sh" "$ROOT"
   ```

2. **Roadmap.** Run and print verbatim:

   ```bash
   python3 "$ROOT/knowledge/render.py" --stdout future --format terminal
   ```

   An empty roadmap prints a one-line notice; print that too rather than inventing entries.

3. **Overlay.** Look through your available skills for one named exactly `knowledge-manifest` (by skill name only). If present, load it to learn the church name and where its `manifest.yaml` sits relative to the overlay's root (resolve against the directory you loaded that `SKILL.md` from), then run and print:

   ```bash
   python3 "$ROOT/knowledge/render.py" --manifest "<that path>" --stdout future --format terminal --heading "Overlay roadmap: <church name>"
   ```

4. **Footer.** One line each: how to propose a topic (a `status: roadmap` row via PR — CONTRIBUTING.md in the repo has the steps, or run `rockrms-add-knowledge` with a URL to skip the roadmap and document it now), and `rockrms-knowledge-current` for what is documented today. Link the rendered file: https://github.com/Consta-Tech/AIskill-RockRMS/blob/main/knowledge/Knowledge-future.md

Never say a roadmap item is "coming in vX.Y" — releases are date-stamped and the plugin has no version number.
