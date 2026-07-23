# Install AIskill-RockRMS

Two parts: **(1)** install the `rockrms` plugin into Claude Code, **(2)** set up your personal Rock workspace repo. Part 1 takes two commands; Part 2 is a one-time scaffold.

## Prerequisites

- [Claude Code](https://code.claude.com) installed and authenticated
- `git`, with access to GitHub (`gh auth status` to check)
- macOS or Linux shell (the rules-injection hook is a bash script)

## Quick install (scripted)

[`setup.sh`](setup.sh) automates the plugin install and — optionally, with prompts for your church's values — the workspace scaffold:

```bash
git clone https://github.com/Consta-Tech/AIskill-RockRMS.git ~/GitHub/AIskill-RockRMS
bash ~/GitHub/AIskill-RockRMS/setup.sh
```

Safe to re-run; never overwrites files you already have. Prefer the manual steps? Read on.

<details open>
<summary><strong>Part 1 — Install the plugin (Claude Code)</strong></summary>

### Install

```bash
claude plugin marketplace add Consta-Tech/AIskill-RockRMS
claude plugin install rockrms@consta-tech
```

No cloning needed — Claude Code fetches this repo from GitHub and keeps it updated.

### Verify

```bash
claude plugin list
```

You should see `rockrms` enabled. Then start a session anywhere and type `/rockrms:` — autocomplete should offer `format-tsql`, `audit-pre-push-1`, `audit-pre-push-2`, and the reference skills. Run `/context` and confirm the "Rock RMS House Rules" appear in the session context.

### Update

Updates are automatic: every commit pushed to this repo counts as a new plugin version, and Claude Code's background marketplace refresh picks it up. To force it:

```bash
claude plugin marketplace update consta-tech
```

### Uninstall

```bash
claude plugin uninstall rockrms
claude plugin marketplace remove consta-tech
```

Or keep it installed and turn it off: `claude plugin disable rockrms`.

</details>

<details open>
<summary><strong>Part 2 — Set up your workspace repo</strong></summary>

> **The Summit Church developers:** skip this section and follow the [AIskill-RockRMS-TSC INSTALL](https://github.com/Summit-Church/AIskill-RockRMS-TSC/blob/main/INSTALL.md) instead (private repo — TSC org access required); it has the exact TSC commands and also installs the TSC overlay plugin.

Each developer manually creates a personal workspace repo named `claude-rockrms-<yourname>`. Your actual Rock code lives in your church's shared code repo and is symlinked in as `_code`. Replace `<your-org>/<church-code-repo>` below with your church's repository.

### 1. Create the workspace repo

```bash
cd ~/GitHub
mkdir claude-rockrms-<yourname> && cd claude-rockrms-<yourname>
git init
mkdir input_box
```

### 2. Create `CLAUDE.md`

```markdown
# CLAUDE.md

## Context

This is my Rock RMS development workspace. Rock RMS is an open-source church management system built on ASP.NET.

House rules, language references (Lava, T-SQL, HTMX), Rock schema docs, and audit skills come from the `rockrms` Claude Code plugin (`Consta-Tech/AIskill-RockRMS`). The house rules are injected automatically at session start — follow them.

## Layout

- `_code/` is a symlink into my sibling clone of `<your-org>/<church-code-repo>`. All Rock code lives there. Commits and PRs for code changes happen in that repo, not this one.
- `input_box/` is a gitignored dropbox for rough drafts. Each file's line 1 is a comment hinting its destination directory or end goal; process it per the file-organization rules.

## Workflow Context

Code in this workspace follows this development cycle:

1. Write/edit code in `_code/`
2. Paste into a Rock RMS Block to test behavior
3. Iterate until the code behaves as expected
4. Commit clean, working code (in the church code repo)
5. Update corresponding documentation if behavior changed

When I describe what I'm observing after testing in Rock, treat that as the ground truth — Rock's rendering is the authority on whether code works.

## Task Types

When I start a conversation, I will tell you whether this is:

- **Brainstorming** — Explore approaches, weigh tradeoffs, no code changes yet
- **Troubleshooting** — Code exists but isn't behaving as expected. I'll describe what I see vs. what I expected.
- **Polishing** — Code works correctly but needs UX/visual/readability improvements
- **Documentation** — Update or create docs to reflect current implementations

## Important Notes

- Lava is NOT identical to Liquid. Do not assume Liquid syntax works in Lava. When unsure, consult the `language-lava` skill.
- When writing SQL that joins to people, always join through PersonAlias — see the `rock-sql-schema` skill.
```

### 3. Create `.gitignore`

```gitignore
input_box/
CLAUDE.local.md
.claude/settings.local.json
.DS_Store
```

### 4. Create `.claude/settings.json`

The `_code` symlink resolves to files *outside* this workspace, so grant Claude Code access to the sibling clone:

```json
{
  "permissions": {
    "additionalDirectories": ["../<church-code-repo>"]
  }
}
```

### 5. Clone your church's code repo and symlink `_code`

Clone as a **sibling** of your workspace repo (the symlink and settings above assume this layout):

```bash
git clone https://github.com/<your-org>/<church-code-repo>.git ~/GitHub/<church-code-repo>
ln -s ../<church-code-repo>/_code _code
```

Commit the workspace scaffold (the symlink itself gets committed; the church code does not):

```bash
git add -A && git commit -m "Scaffold Rock workspace"
```

> **Where do code commits go?** Files under `_code/` belong to the church-code-repo clone — `git status` in your workspace repo will not show changes to them. Branch, commit, and open PRs for Rock code in that repo. Your workspace repo only versions your personal scaffold.

</details>

## Contributing improvements back

The plugin content (rules, references, skills) is maintained in this repo. To propose a change:

```bash
git clone https://github.com/Consta-Tech/AIskill-RockRMS.git
```

Branch, edit, and open a PR. Once merged, every installed developer receives the change automatically. Don't clone this repo into `~/.claude/skills/` — combined with the marketplace install, the skills would load twice.

## Troubleshooting

**`/rockrms:` skills missing from autocomplete.** Restart Claude Code — the plugin index is read at startup.

**`claude plugin marketplace add` fails.** Use the `Consta-Tech/AIskill-RockRMS` (owner/repo) form.

**House rules not in context.** Run `claude plugin list` to confirm `rockrms` is enabled, then start a new session and check `/context`. The hook requires a bash-capable shell (on Windows, use WSL or Git Bash).

**Permission prompts when editing files under `_code/`.** Confirm `.claude/settings.json` contains the `additionalDirectories` entry and that the church clone actually sits at the sibling path.

**Not receiving updates.** Run `claude plugin marketplace update consta-tech`, then restart the session.

## Other harnesses

Claude Code is the only supported harness today. The `skills/` tree follows the [Agent Skills](https://agentskills.io) standard, so Codex/Zed/other-harness install paths can be added here later without restructuring content.
