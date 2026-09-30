---
name: knowledge-future
description: List the rockrms plugin's knowledge roadmap — the topics with a status of roadmap in its catalog, numbered, plus any installed church overlay's roadmap. Use when the user asks what the plugin will document next, whether a topic is planned, how to request a topic, or runs /rockrms:knowledge-future.
allowed-tools: Bash Read Skill
---

# /rockrms:knowledge-future

Roadmap entries are manifest rows with `status: roadmap` — a title, a category, the source a contributor would start from, and a note on why it matters. They become `current` when the reference file lands.

## Do this

1. **Header.** Run and print verbatim:

   ```bash
   bash "${CLAUDE_PLUGIN_ROOT}/knowledge/plugin-identity.sh" "${CLAUDE_PLUGIN_ROOT}"
   ```

2. **Roadmap.** Run and print verbatim:

   ```bash
   python3 "${CLAUDE_PLUGIN_ROOT}/knowledge/render.py" --stdout future --format terminal
   ```

   An empty roadmap prints a one-line notice; print that too rather than inventing entries.

3. **Overlay.** Look through your available skills for one named exactly `knowledge-manifest` (by skill name only). If present, invoke it to learn the church name and its `manifest.yaml` path, then run and print:

   ```bash
   python3 "${CLAUDE_PLUGIN_ROOT}/knowledge/render.py" --manifest "<that path>" --stdout future --format terminal --heading "Overlay roadmap: <church name>"
   ```

4. **Footer.** One line each: how to propose a topic (a `status: roadmap` row via PR — CONTRIBUTING.md in the repo has the steps, or run `/rockrms:add-knowledge` with a URL to skip the roadmap and document it now), and `/rockrms:knowledge-current` for what is documented today. Link the rendered file: https://github.com/Consta-Tech/AIskill-RockRMS/blob/main/knowledge/Knowledge-future.md

Never say a roadmap item is "coming in vX.Y" — releases are date-stamped and the plugin has no version number.
