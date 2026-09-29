# Install AIskill-RockRMS

Two parts: **(1)** install the `rockrms` plugin into Claude Code, **(2)** initialize your personal Rock workspace repo. Part 1 takes two terminal commands; Part 2 happens inside Claude Code via the `/rock-init` command.

## Prerequisites

- [Claude Code](https://code.claude.com) installed and authenticated
- `git`, with access to GitHub (`gh auth status` to check)
- macOS or Linux shell (the rules-injection hook is a bash script)

## Quick install (scripted)

[`setup.sh`](setup.sh) automates the plugin install, then prints the exact Part 2 commands:

```bash
git clone https://github.com/Consta-Tech/AIskill-RockRMS.git ~/GitHub/AIskill-RockRMS
bash ~/GitHub/AIskill-RockRMS/setup.sh
```

Safe to re-run. Prefer the manual steps? Read on.

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
<summary><strong>Part 2 — Initialize your workspace repo</strong></summary>

> **The Summit Church developers:** skip this section and follow the [AIskill-RockRMS-TSC INSTALL](https://github.com/Summit-Church/AIskill-RockRMS-TSC/blob/main/INSTALL.md) instead (private repo — TSC org access required); it has the exact TSC commands and also installs the TSC overlay plugin.

Each developer creates a personal workspace repo named `claude-rockrms-<yourname>`. The scaffolding itself happens **inside Claude Code**:

```bash
mkdir -p ~/GitHub/claude-rockrms-<yourname>
cd ~/GitHub/claude-rockrms-<yourname>
claude
```

Then run **`/rock-init`** (fully qualified: `/rockrms:rock-init`). It:

- confirms before touching a non-empty directory, and **never overwrites an existing file** — safe to re-run to repair a partial scaffold;
- interviews you: your git preference, where your church's Rock code lives, and your instance's basic constants;
- scaffolds the workspace: `_code` (a plain directory, or a symlink into a sibling clone of your church's shared code repo), `docs/` (your local knowledgebase), `input_box/`, `.gitignore`, `.claude/settings.json`, and a `CLAUDE.md` built from your answers;
- if your church's **overlay plugin** is installed, reads its `workspace-defaults` skill instead of interviewing — see [`examples/overlay-template/`](examples/overlay-template/).

Prefer to scaffold by hand? Every file `/rock-init` writes comes from [`templates/`](templates/) — copy them yourself and fill the `{{…}}` placeholders.

> **Where do code commits go?** With the shared-repo layout, files under `_code/` belong to your church-code-repo clone — `git status` in your workspace repo will not show changes to them. Branch, commit, and open PRs for Rock code in that repo. Your workspace repo only versions your personal scaffold and `docs/`.

</details>

## Contributing improvements back

The plugin content (rules, references, skills) is maintained in this repo. To propose a change:

```bash
git clone https://github.com/Consta-Tech/AIskill-RockRMS.git
```

Branch, edit, and open a PR. Once merged, every installed developer receives the change automatically. Don't clone this repo into `~/.claude/skills/` — combined with the marketplace install, the skills would load twice.

## Troubleshooting

**`/rockrms:` skills missing from autocomplete, or `/rock-init` not offered.** Restart Claude Code — the plugin index is read at startup.

**`claude plugin marketplace add` fails.** Use the `Consta-Tech/AIskill-RockRMS` (owner/repo) form.

**House rules not in context.** Run `claude plugin list` to confirm `rockrms` is enabled, then start a new session and check `/context`. The hook requires a bash-capable shell (on Windows, use WSL or Git Bash).

**Permission prompts when editing files under `_code/`.** Confirm `.claude/settings.json` contains the `additionalDirectories` entry and that the church clone actually sits at the sibling path.

**Not receiving updates.** Run `claude plugin marketplace update consta-tech`, then restart the session.

## Other harnesses

Claude Code is the only supported harness today. The `skills/` tree follows the [Agent Skills](https://agentskills.io) standard, so Codex/Zed/other-harness install paths can be added here later without restructuring content.
