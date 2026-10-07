# Pre-Push Audit Doctrine — Part 1: Code Files

> **Provenance tier:** `traced` — read from source or official documentation and cited (house convention, no Rock version). Catalogued in the plugin's knowledge manifest; `/rockrms:knowledge-current` lists every entry.


The rules Step 5 of the `audit-pre-push-1` skill applies to every in-scope code file.

## Ephemeral reference patterns (hardcoded — update this list as the repo evolves)

These are references that are useful during active development but meaningless to teammates or future sessions. Auto-delete on sight:

| Pattern | Example |
|---|---|
| Conversation/chat citations | `conv 12`, `chat 25`, `per conversation with…`, `discussed in chat` |
| Prompt file references | `prompt0-3.md`, `prompt2-1.md`, `per prompt file`, any bare filename matching `prompt*.md` |
| Reference material filenames in gitignored dirs | `notes-v0.4.md`, `answers-for-X.md`, `current-state-XX.md`, `brainstormX.md`, `future-features.md` |
| `input_box/` paths | Any literal path containing `input_box/` |
| `.trash/` paths | Any literal path containing `.trash/` |
| `.DS_Store` references | Any mention of `.DS_Store` |
| `idea/`, `inspiration/`, `diagnosis/` paths | Any literal path containing these directories |
| "Note to self" markers | `// note to self`, `// NTS:`, `// reminder:`, `{% comment %} note to self` |

## Stable references (DO NOT delete)

| Pattern | Example |
|---|---|
| Skill reference paths | `references/Lava-Language.md`, the `rock-sql-schema` skill |
| Memory file references | `feedback_*.md`, `reference_*.md`, `project_*.md`, `user_*.md` |
| External URLs | BEMA GitHub URLs, Rock community URLs, any http/https link |
| Internal cross-file references | `_render-summary-sidebar.lava Section 6` (verify accuracy; update if stale) |

## Boilerplate rules

- Every file keeps a header comment block. Empty boilerplates are not the goal — **concise** ones are.
- The boilerplate should contain structural metadata (path, slug, method, parameters) and a single-paragraph present-tense description of what the file does.
- **No version history** in boilerplates. Rely on git.
- **No cross-file convention prose** in boilerplates. That belongs in the directory README.
- **No citation footnotes** in boilerplates.
- If a boilerplate contains multi-paragraph explanations of behavior, evaluate: is it single-file detail or cross-file convention?
  - **Single-file detail** → move to an inline `{% comment %}` block near the relevant code site. Strip version stamps. Keep the *why*, drop the *history*.
  - **Cross-file convention** → write to `_audit-extractions.md` for `audit-pre-push-2` to absorb into the README. Leave a one-line pointer in the boilerplate (e.g., `See Endpoints/README.md § "OOB contract".`).

## Inline comment rules

- Format inline relocated content as `{% comment %} … {% endcomment %}` blocks, not HTML comments or Lava line comments.
- Place comments immediately above the code they explain.
- Present tense. No version stamps.
- Preserve existing section markers (e.g., `{% comment %} === Section 1 — Read + auth === {% endcomment %}`). If a section marker's name has drifted from what the section actually does, update the name.

## Version stamp rules

- Version-stamped prose in boilerplates: delete the version prefix, rewrite in present tense if the substance survives. If the entire comment is version narration with no surviving substance, delete entirely.
- `Tag: vX.Y` headers: replace with the version number from Step 3.
- `## v0.X additions` / `## v0.X conventions` section headings in READMEs: this is `audit-pre-push-2`'s concern, but if encountered in a code file's comment, flatten by removing the version prefix.
- `(vX.Y.Z introduced…)` parenthetical asides: delete the parenthetical.
- `// vX.Y.Z` inline markers: delete the marker; keep the comment body if it has substance.
