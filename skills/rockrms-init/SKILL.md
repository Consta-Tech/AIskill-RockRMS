---
name: rockrms-init
description: Initialize the current directory as a Rock RMS development workspace — interview the user, scaffold _code, docs/, input_box/, .gitignore, and write an AGENTS.md (plus a CLAUDE.md that imports it) from their answers. Use only when the user asks to set up, initialize, or repair a Rock workspace, or invokes the rockrms-init skill by name.
disable-model-invocation: true
---

# rockrms-init — Rock Workspace Initialization

Turn the **current working directory** into a Rock RMS development workspace: interview the user, scaffold the directory, and write an `AGENTS.md` from their answers.

Ground rules for the whole flow:

- **Never overwrite an existing file, directory, or symlink.** Whatever already exists is left untouched and reported in the final summary. Re-running this skill on a half-scaffolded workspace is repair mode: it fills gaps only.
- The user may be new to development. Explain each step in one plain sentence as you go; do not assume they know what git, symlinks, or JSON are.
- Whenever you tell the user something to type, enclose the exact text in backticks (`` `exit` ``); whenever you name a keyboard key to press, enclose it in single quotes ('Enter').
- Scaffold templates live in the `templates/` directory **next to this SKILL.md**. Read them from there — do not reconstruct their content from memory.

## Step 1 — Preflight

1. State the current directory and that you are about to set it up as a Rock workspace.
2. If the directory contains anything other than `.git` and `.DS_Store`, list what is there (names only) and ask whether to proceed anyway. If the user declines, stop — suggest they `cd` to the right directory and run `rockrms-init` again.

## Step 2 — Church overlay detection

Check whether a church overlay plugin is installed by looking through your available skills for one named **`workspace-defaults`** (overlay plugins such as `rockrms-tsc` ship it). Match by skill name only — never by file path.

- **Found:** load it now. It supplies the church code repo, the `_code` layout, the Claude Code `.claude/settings.json` content, and the AGENTS.md placeholder values. Skip the interview's code-layout question, and skip the instance-basics question if the overlay also provides an `instance-facts` skill.
- **Not found:** the interview asks everything.

## Step 3 — Interview

Ask the questions below — with the host's structured-question tool when it has one (Claude Code: AskUserQuestion, in one call where possible), otherwise as one numbered block in plain prose. Only the applicable questions:

1. **Git preference** (always ask):
   - *No git* — "I do not want to track this directory as a git repo"
   - *Help me* — "I know what git is, and I prefer that you help me manage the git commands in this workspace"
   - *I'll manage it* — "I know what git is, I will manage it myself. Do not offer to help with git unless I ask first"
2. **Code layout** (skip when overlay defaults exist): does their church keep Rock code in a shared GitHub repo?
   - *Shared repo* — follow up by asking them to **copy and paste the repo's URL**, with an example so beginners recognize what's being asked for. Suggested wording:

     > You said your church keeps its code in a shared repository (e.g. on GitHub or Bitbucket). Open that repo in your browser and paste its URL here — it will look something like `https://github.com/SomeChurch/rock-code`. (Pasting a deeper link, like `https://github.com/SomeChurch/rock-code/tree/main/README.md`, is fine too.)

     Accept whatever arrives and normalize it yourself: an `https://` URL (with or without `.git`, and strip any trailing path like `/tree/main/...` down to the repo), an SSH `git@...` form, or a bare `owner/name` from users who know the shorthand. A non-GitHub host (Bitbucket, GitLab, …) is fine — just clone it with `git clone` rather than `gh`. Confirm the normalized repo back to them before cloning. `_code` becomes a symlink into a sibling clone of that repo.
   - *No shared repo* — `_code` is created as a plain local directory.
3. **Instance basics** (skip when an overlay `instance-facts` skill exists; every field skippable): internal/staff site URL, its Site Id if known, external site URL.
4. **Rock version** (skippable; skip when an overlay `instance-facts` skill states one): which Rock version the instance runs. Tell them where to look — in Rock, Admin Tools > System Information shows it (e.g. `v18.2.4`) — and that skipping is fine; the value can be filled in later. The `rockrms` plugin's `rockrms-knowledge-current` skill uses it to flag references verified on a newer Rock version than theirs.

## Step 4 — Scaffold

Create each item below, skipping anything that already exists:

1. **`_code`**
   - *Shared-repo layout:* the church repo is cloned as a **sibling** of this workspace (i.e. into the parent directory of the cwd). If the sibling clone is missing, clone it — with `gh repo clone` when `gh` is available (required for private repos), else `git clone`. Then `ln -s ../<church-repo>/_code _code`.
   - *Plain layout:* `mkdir _code`.
2. **`docs/`** — the user's local knowledgebase:
   - `docs/README.md` from `templates/workspace-docs-README.md`.
   - `docs/instance-facts.md` from `templates/workspace-instance-facts.md`, with the interview answers filled in. When an overlay `instance-facts` skill exists, still scaffold the file but fill `{{OVERLAY_POINTER}}` with a note that church-wide constants live in the overlay skill and this file is for personal / not-yet-upstreamed values; otherwise remove the placeholder line.
     Fill the Rock version row as a **real table row**, never a comment: `{{ROCK_VERSION}}` becomes the answer (or the overlay's value), `{{ROCK_VERSION_VERIFIED}}` becomes today's date in `YYYY-MM-DD`. When the question was skipped, write `unknown` and leave the Verified cell empty — the row must still exist so it can be filled in later.
3. **`input_box/`** — `mkdir input_box`.
4. **`.gitignore`** from `templates/workspace-gitignore`. If one already exists, do not replace it — instead show which of the template's lines are missing and ask whether to append them.
5. **`.claude/settings.json`** — **only when the agent running this skill is Claude Code** (other agents do not read it). From the overlay's `workspace-defaults` block when there is one. Otherwise build it: `permissions.additionalDirectories: ["../<church-repo>"]` only in the shared-repo layout, plus:

   ```json
   "extraKnownMarketplaces": {
     "consta-tech": { "source": { "source": "github", "repo": "Consta-Tech/AIskill-RockRMS" } }
   },
   "enabledPlugins": { "rockrms@consta-tech": true }
   ```

6. **`AGENTS.md`** from `templates/workspace-AGENTS.md`, replacing every placeholder. Every supported agent (Claude Code, Codex, OpenCode, Antigravity) reads this file at session start.

   | Placeholder | Value |
   |---|---|
   | `{{CHURCH_SUFFIX}}` | ` at <Church Name>` when known (overlay or interview), else empty string |
   | `{{PLUGINS_PARAGRAPH}}` | Overlay installed: name both plugins. Else: the generic single-plugin paragraph already in the template comment. |
   | `{{CODE_LAYOUT_BULLET}}` | The symlink bullet (with the church repo named) or the plain-directory bullet — both drafted in the template comment. |
   | `{{COMMIT_TARGET}}` | Shared-repo layout: `in the <church-repo> repo`. Plain layout: `in this workspace repo` (or drop the parenthetical entirely under the no-git preference). |
   | `{{GIT_PREFERENCE}}` | The sentence matching the interview answer — all three drafted in the template comment. |
   | `{{OVERLAY_NOTES}}` | The overlay's AGENTS.md bullets when installed, else remove the placeholder line. |

   Delete the template's HTML comment blocks from the rendered file.

7. **`CLAUDE.md`** from `templates/workspace-CLAUDE.md` — a one-line file that imports `AGENTS.md`, so Claude Code reads the same instructions as every other agent. Write it on every host (it is harmless elsewhere and keeps the workspace portable to a teammate who uses Claude Code). If a `CLAUDE.md` with other content already exists, leave it and tell the user it should import or be replaced by `AGENTS.md`.

## Step 5 — Git

Per the interview answer:

- **No git:** run no git commands. (`.gitignore` still gets written — harmless, and ready if they change their mind.)
- **Help me:** if there is no `.git`, run `git init -b main`. Then stage and commit the scaffold with message `Scaffold Rock workspace`.
- **I'll manage it:** if there is no `.git`, run `git init -b main` so the `.gitignore` takes effect, then stop — tell them the scaffold is uncommitted and theirs to commit.

## Step 6 — Report and hand off

1. Summarize: what was created, what already existed and was skipped, and (shared-repo layout) where the church clone sits.
2. Note that a **new session** in this directory will pick up `AGENTS.md` (and, in Claude Code, the settings); instruction files are read when a session starts, so this session does not see them.
3. Do **not** offer to start work in this session. Close by walking the user out and back in, matched to the agent they are running — if you cannot tell which one, give the terminal steps for all four and the new-session line for app users:

   > One note: the files I just wrote apply fully in your NEXT session, so restart your agent before doing real work here.
   >
   > 1. Type `exit`, press 'Enter'. (In Antigravity, close the chat instead.)
   > 2. Back at your terminal, start it again — `claude`, `codex`, `opencode`, or `agy` — and press 'Enter'.
   >
   > When the new session opens, just say hello — I'll offer you a menu of ways to get started.

   - **Desktop/web app or IDE:** same first line, then tell them to start a **new session in this same folder** (in an app: the new-session button, or 'Cmd+N' on Mac), and to open it by saying hello.

   (The "say hello" hand-off works because the `AGENTS.md` just written tells the next session to offer the workspace menu on a vague opener.)
