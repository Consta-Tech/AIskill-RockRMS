---
name: knowledge-manifest
description: Your Church's knowledge catalog for its rockrms overlay plugin — the manifest that lists every reference this overlay documents, with its provenance tier and Rock version. Loaded by the rockrms plugin's rockrms-knowledge-current and rockrms-knowledge-future skills to append an "Overlay" section to their output; also use when asked what this overlay documents.
---

# Your Church — Knowledge Manifest

**Church name:** Your Church
**Manifest:** `skills/knowledge-manifest/manifest.yaml`, relative to this overlay plugin's root — the directory two levels above this `SKILL.md` (Claude Code and Codex expose it as the overlay's own `${CLAUDE_PLUGIN_ROOT}`).

The generic `rockrms` plugin's `rockrms-knowledge-current` and `rockrms-knowledge-future` skills look for a skill named exactly `knowledge-manifest`, read the two lines above, resolve the manifest path against the directory they loaded this file from, and render it at runtime with the same renderer they use for their own catalog (`knowledge/render.py` in the `rockrms` plugin). Nothing here is pre-rendered.

The manifest uses the same format and fields as the generic plugin's `knowledge/manifest.yaml` — one entry per reference file, with `tier`, `rock_version`, `source_url`, and `status`. Overlay entries usually use the categories `instance-facts`, `deviations`, and `house`. To validate it from a clone of this overlay:

```bash
python3 <path-to-a-rockrms-clone>/knowledge/render.py --manifest skills/knowledge-manifest/manifest.yaml --check
```

Keep one row per file in this overlay's `skills/*/references/` and one row per `SKILL.md` that carries facts of its own.
