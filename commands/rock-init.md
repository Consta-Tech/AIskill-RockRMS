---
description: Initialize the current directory as a Rock RMS development workspace — interview, scaffold, CLAUDE.md
---

# /rock-init — Rock Workspace Initialization

Turn the **current working directory** into a Rock RMS development workspace: interview the user, scaffold the directory, and write a `CLAUDE.md` from their answers.

Ground rules for the whole flow:

- **Never overwrite an existing file, directory, or symlink.** Whatever already exists is left untouched and reported in the final summary. Re-running this command on a half-scaffolded workspace is repair mode: it fills gaps only.
- The user may be new to development. Explain each step in one plain sentence as you go; do not assume they know what git, symlinks, or JSON are.
- Scaffold templates live in `${CLAUDE_PLUGIN_ROOT}/templates/`. Read them from there — do not reconstruct their content from memory.

## Step 1 — Preflight

1. State the current directory and that you are about to set it up as a Rock workspace.
2. If the directory contains anything other than `.git` and `.DS_Store`, list what is there (names only) and ask whether to proceed anyway. If the user declines, stop — suggest they `cd` to the right directory and re-run `/rock-init`.

## Step 2 — Church overlay detection

Check whether a church overlay plugin is installed by looking through your available skills for one named **`workspace-defaults`** (overlay plugins such as `rockrms-tsc` ship it). Match by skill name only — never by file path.

- **Found:** load it now. It supplies the church code repo, the `_code` layout, the `.claude/settings.json` content, and the CLAUDE.md placeholder values. Skip the interview's code-layout question, and skip the instance-basics question if the overlay also provides an `instance-facts` skill.
- **Not found:** the interview asks everything.

## Step 3 — Interview

Ask with AskUserQuestion, in one call where possible. Only the applicable questions:

1. **Git preference** (always ask):
   - *No git* — "I do not want to track this directory as a git repo"
   - *Help me* — "I know what git is, and I prefer that you help me manage the git commands in this workspace"
   - *I'll manage it* — "I know what git is, I will manage it myself. Do not offer to help with git unless I ask first"
2. **Code layout** (skip when overlay defaults exist): does their church keep Rock code in a shared GitHub repo?
   - *Shared repo* — follow up for the `owner/name`; `_code` becomes a symlink into a sibling clone of that repo.
   - *No shared repo* — `_code` is created as a plain local directory.
3. **Instance basics** (skip when an overlay `instance-facts` skill exists; every field skippable): internal/staff site URL, its Site Id if known, external site URL.

## Step 4 — Scaffold

Create each item below, skipping anything that already exists:

1. **`_code`**
   - *Shared-repo layout:* the church repo is cloned as a **sibling** of this workspace (i.e. into the parent directory of the cwd). If the sibling clone is missing, clone it — with `gh repo clone` when `gh` is available (required for private repos), else `git clone`. Then `ln -s ../<church-repo>/_code _code`.
   - *Plain layout:* `mkdir _code`.
2. **`docs/`** — the user's local knowledgebase:
   - `docs/README.md` from `templates/workspace-docs-README.md`.
   - `docs/instance-facts.md` from `templates/workspace-instance-facts.md`, with the interview answers filled in. When an overlay `instance-facts` skill exists, still scaffold the file but fill `{{OVERLAY_POINTER}}` with a note that church-wide constants live in the overlay skill and this file is for personal / not-yet-upstreamed values; otherwise remove the placeholder line.
3. **`input_box/`** — `mkdir input_box`.
4. **`.gitignore`** from `templates/workspace-gitignore`. If one already exists, do not replace it — instead show which of the template's lines are missing and ask whether to append them.
5. **`.claude/settings.json`** — from the overlay's `workspace-defaults` block when there is one. Otherwise build it: `permissions.additionalDirectories: ["../<church-repo>"]` only in the shared-repo layout, plus:

   ```json
   "extraKnownMarketplaces": {
     "consta-tech": { "source": { "source": "github", "repo": "Consta-Tech/AIskill-RockRMS" } }
   },
   "enabledPlugins": { "rockrms@consta-tech": true }
   ```

6. **`CLAUDE.md`** from `templates/workspace-CLAUDE.md`, replacing every placeholder:

   | Placeholder | Value |
   |---|---|
   | `{{CHURCH_SUFFIX}}` | ` at <Church Name>` when known (overlay or interview), else empty string |
   | `{{PLUGINS_PARAGRAPH}}` | Overlay installed: name both plugins. Else: the generic single-plugin paragraph already in the template comment. |
   | `{{CODE_LAYOUT_BULLET}}` | The symlink bullet (with the church repo named) or the plain-directory bullet — both drafted in the template comment. |
   | `{{COMMIT_TARGET}}` | Shared-repo layout: `in the <church-repo> repo`. Plain layout: `in this workspace repo` (or drop the parenthetical entirely under the no-git preference). |
   | `{{GIT_PREFERENCE}}` | The sentence matching the interview answer — all three drafted in the template comment. |
   | `{{OVERLAY_NOTES}}` | The overlay's CLAUDE.md bullets when installed, else remove the placeholder line. |

   Delete the template's HTML comment blocks from the rendered file.

## Step 5 — Git

Per the interview answer:

- **No git:** run no git commands. (`.gitignore` still gets written — harmless, and ready if they change their mind.)
- **Help me:** if there is no `.git`, run `git init -b main`. Then stage and commit the scaffold with message `Scaffold Rock workspace`.
- **I'll manage it:** if there is no `.git`, run `git init -b main` so the `.gitignore` takes effect, then stop — tell them the scaffold is uncommitted and theirs to commit.

## Step 6 — Report and hand off

1. Summarize: what was created, what already existed and was skipped, and (shared-repo layout) where the church clone sits.
2. Note that a **new session** in this directory will pick up `CLAUDE.md` and the settings; if this session was started before `.claude/settings.json` existed, some settings apply only after restart.
3. Close by offering the workspace menu:
   1. Ask a question about Rock in general
   2. Ask a debugging question about my current Rock instance
   3. Ask a brainstorming question about a new solution
   4. Help me write a prompt file
   5. Help me document some knowledge
