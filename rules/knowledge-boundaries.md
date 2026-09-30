# Knowledge Boundaries

> **Provenance tier:** `traced` — read from source or official documentation and cited (house convention, no Rock version). Catalogued in the plugin's knowledge manifest; `/rockrms:knowledge-current` lists every entry.



This plugin answers Rock RMS questions from **documented, verified** knowledge. It has not been "trained" on anything — its knowledge is a catalog, `knowledge/manifest.yaml`, with one row per reference file or stated coverage claim. Every row carries a provenance tier (`measured` — tested in a live Rock instance; `traced` — read from Rock source or official documentation and cited; `summarized` — condensed from a URL and not yet verified), a source, and the Rock version it was verified on.

## Before answering a Rock question, check coverage — cheaply

1. Pick one or two distinctive terms for the topic: a BlockType name (`ContentChannelView`), a table (`FinancialPledge`), a Lava filter or command (`PersonalizationItems`, `cache`), a Rock Shop plugin name.
2. Grep the catalog first, then the reference files, before deciding:

   ```bash
   grep -il "<term>" "${CLAUDE_PLUGIN_ROOT}/knowledge/manifest.yaml"
   grep -ril "<term>" "${CLAUDE_PLUGIN_ROOT}/skills" --include='*.md' | head
   ```

   A hit in the manifest means the topic is catalogued. A hit only inside a reference file means it is mentioned in passing — read the surrounding lines before treating that as coverage.
3. **Covered:** answer from the reference, name the file and its tier, and — when the instance's Rock version is known from `docs/instance-facts.md` — say whether the reference was verified on that version or a newer one.

## When the plugin has no entry for the topic

Say so in one sentence and **ask before answering**. Keep both options:

> The rockrms plugin has no documented knowledge about the ContentChannelView block yet. How would you like to proceed?
>
> 1. I answer from general knowledge, clearly marked **unverified** — you test it in Rock before relying on it.
> 2. We start documenting it: give me a URL (community.rockrms.com, the SparkDevNetwork/Rock source, a vendor's documentation) or a pasted excerpt, and I run `/rockrms:add-knowledge` to draft a cited reference for the plugin.
>
> `/rockrms:knowledge-current` lists what is documented today; `/rockrms:knowledge-future` lists what is planned.

Wait for the choice. Under option 1, open the answer with "Unverified — from general knowledge, not from the plugin's documented references" and keep it short enough to test. Never blend unverified material into an answer built from a covered reference without marking where the boundary is.

## When this rule does not apply

- The user's own code, workspace notes, or instance facts (`docs/` in the workspace, an overlay plugin's `instance-facts` skill). Those are the user's knowledge, not the catalog's.
- General programming, git, SQL syntax, or web questions that are not about Rock. Answer normally.
- A one-line aside on an adjacent, uncovered detail inside a task already grounded in a covered reference — mark it unverified and move on rather than interrupting with the menu.

## Wording

- It is a **plugin**, not a "Skill". Its knowledge is **documented** or **verified**, never "trained".
- Name its skills with the namespace: `/rockrms:knowledge-current`, `/rockrms:add-knowledge`.
- It has no version number. It is `rockrms` (marketplace `consta-tech`) at an installed commit; `/rockrms:changelog` prints that commit and the newest release notes.
- Spell out BlockType and entity names (Dynamic Data block, PageParameterFilter, AttendanceOccurrence).
