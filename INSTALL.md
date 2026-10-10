# Install AIskill-RockRMS

Two parts: **(1)** install the `rockrms` plugin into your coding agent — pick your agent below, **(2)** initialize your personal Rock workspace with the `rockrms-init` skill. Part 1 is a few terminal commands; Part 2 happens inside the agent.

Every host gets the same content: the eighteen skills under `skills/`, and the house rules under `rules/`, which load into every session automatically. Only the install commands and the way you type a skill's name differ.

## Prerequisites

- One of the agents below, installed and signed in
- `git`, with access to GitHub (`gh auth status` to check)
- macOS or Linux shell with `python3` (the house-rule hook and the knowledge catalog are bash + Python; on Windows use WSL or Git Bash)

## Quick install (scripted)

[`setup.sh`](setup.sh) runs the install commands for one host, then prints the Part 2 commands:

```bash
git clone https://github.com/Consta-Tech/AIskill-RockRMS.git ~/GitHub/AIskill-RockRMS
bash ~/GitHub/AIskill-RockRMS/setup.sh --host claude      # or codex | opencode | antigravity
```

Safe to re-run. Prefer the manual steps? Pick your host.

<details>
<summary><strong>Claude Code</strong></summary>

### Install

```bash
claude plugin marketplace add Consta-Tech/AIskill-RockRMS
claude plugin install rockrms@consta-tech
```

No cloning needed — Claude Code fetches this repo from GitHub and keeps it updated. Skills are typed with the plugin prefix: `/rockrms:rockrms-init`, `/rockrms:format-tsql`.

### Verify

```bash
claude plugin list
```

You should see `rockrms` enabled. Start a session anywhere and type `/rockrms:` — autocomplete should offer `format-tsql`, `rockrms-init`, `rockrms-knowledge-current`, `rockrms-changelog`, and the rest. Run `/context` and confirm the "Rock RMS House Rule (injected by the rockrms plugin)" blocks are in the session context — one per rule chunk, thirteen at the time of writing.

### Update

Automatic: every commit pushed to this repo counts as a new plugin version, and Claude Code's background marketplace refresh picks it up. To force it:

```bash
claude plugin marketplace update consta-tech
```

### Uninstall

```bash
claude plugin uninstall rockrms
claude plugin marketplace remove consta-tech
```

Or keep it installed and turn it off: `claude plugin disable rockrms`.

### House rules

Loaded at session start by the plugin's `SessionStart` hook (`hooks/hooks.json` → `hooks/inject-rule.sh`), one command per rule chunk. Nothing to configure.

</details>

<details>
<summary><strong>Codex</strong></summary>

### Install

```bash
codex plugin marketplace add Consta-Tech/AIskill-RockRMS --ref main
codex plugin add rockrms@consta-tech
```

Skills are typed with a `$`: `$rockrms-init`, `$format-tsql`. Codex also picks a skill on its own when your request matches its description; `rockrms-init` is the one exception and only runs when you name it.

### Verify

```bash
codex plugin list
```

Then start `codex`, type `$` and confirm the `rockrms-…` skills are offered. Ask "which house rules are loaded?" — the answer should name the formatting standards, Lava conventions, documentation, file organization, and knowledge-boundaries rules.

### Update

```bash
codex plugin marketplace upgrade consta-tech
codex plugin remove rockrms
codex plugin add rockrms@consta-tech
```

### Uninstall

```bash
codex plugin remove rockrms
codex plugin marketplace remove consta-tech
```

### House rules

Codex runs the same `hooks/hooks.json` `SessionStart` hook Claude Code does (it sets `CLAUDE_PLUGIN_ROOT` for plugin hooks), so the rules are in context from the first message. Hooks are on by default in Codex; if you turned them off with `[features] hooks = false` in `~/.codex/config.toml`, the rules will not load.

</details>

<details>
<summary><strong>OpenCode</strong></summary>

OpenCode has no plugin marketplace for skill packs, so the install is a clone plus a one-line loader for the plugin shipped at `.opencode/plugins/rockrms.mjs`. The plugin registers every skill, injects the house rules into the system prompt on every turn, and adds the `/rockrms-init` command. Supports OpenCode V2 and V1 1.18.29+.

### Install

```bash
git clone https://github.com/Consta-Tech/AIskill-RockRMS.git ~/.config/opencode/vendor/rockrms
mkdir -p ~/.config/opencode/plugins
cat > ~/.config/opencode/plugins/rockrms.js <<'EOF'
export { default } from '../vendor/rockrms/.opencode/plugins/rockrms.mjs';
EOF
```

If `XDG_CONFIG_HOME` is set, replace `~/.config` in these paths with that directory.

Skills load through OpenCode's `skill` tool: ask for one by name ("use the format-tsql skill on this query") or let the agent pick from the descriptions. `/rockrms-init` is a slash command.

### Verify

Start `opencode`, type `/` and confirm `rockrms-init` is listed. Ask "which skills do you have?" — the answer should list `format-tsql`, `language-lava`, `rock-sql-schema`, and the other `rockrms-…` and `surface-…` skills. Ask "which house rules are loaded?" to confirm the rules are in the system prompt.

### Update

```bash
git -C ~/.config/opencode/vendor/rockrms pull
```

Then start a new session — the plugin reads the rules once per process.

### Uninstall

```bash
rm ~/.config/opencode/plugins/rockrms.js
rm -rf ~/.config/opencode/vendor/rockrms
```

### House rules

Injected by the plugin on every turn. Without the plugin — a skills-only copy under `.agents/skills/` or `~/.config/opencode/skills/` — the rules do **not** load; add `"instructions": ["<clone>/rules/*.md"]` to `~/.config/opencode/opencode.json` instead.

</details>

<details>
<summary><strong>Antigravity (<code>agy</code>)</strong></summary>

### Install

```bash
agy plugin install https://github.com/Consta-Tech/AIskill-RockRMS
```

Skills are slash commands: `/rockrms-init`, `/format-tsql`. The agent also activates a skill on its own when the task matches its description.

In the Antigravity IDE (no `agy`), clone the repo into a plugin directory instead — `~/.gemini/config/plugins/rockrms` for every workspace, or `<workspace>/.agents/plugins/rockrms` for one — and review the loaded components in the Customizations dropdown.

### Verify

```bash
agy plugin list
```

Start a session, type `/` and confirm the `rockrms-…` skills are offered. Ask "which house rules are loaded?".

### Update

```bash
agy plugin uninstall rockrms
agy plugin install https://github.com/Consta-Tech/AIskill-RockRMS
```

(IDE clone: `git pull` in the plugin directory.)

### Uninstall

```bash
agy plugin uninstall rockrms
```

Or keep it installed and turn it off: `agy plugin disable rockrms`.

### House rules

The plugin's `rules/*.md` are always-on Antigravity rules (`trigger: always_on`). They total about 50 KB, inside Antigravity's 20,000-token budget for always-on rules, but if you keep large always-on rules of your own the budget may overflow — Antigravity then reduces the largest files to pointers the agent reads on demand, which is a degradation, not a failure.

</details>

<details>
<summary><strong>Any other agent-skills harness (Cursor, Copilot, Zed, Gemini CLI, …)</strong></summary>

The `skills/` tree follows the [Agent Skills](https://agentskills.io) standard, so any harness that reads `SKILL.md` can use the skills. The house rules are plain Markdown you paste into that harness's persistent instructions file.

### Install

```bash
npx skills add Consta-Tech/AIskill-RockRMS        # this workspace
npx skills add Consta-Tech/AIskill-RockRMS -g     # all projects
```

Without the CLI, copy the skill folders into whatever directory your agent scans (`.agents/skills/` is the cross-tool convention):

```bash
git clone https://github.com/Consta-Tech/AIskill-RockRMS.git
mkdir -p .agents/skills && cp -R AIskill-RockRMS/skills/* .agents/skills/
```

### House rules

Append the rule files to your agent's instructions file (`AGENTS.md`, `.github/copilot-instructions.md`, `.cursor/rules/…`), dropping the three-line `trigger:` frontmatter each one starts with:

```bash
for f in AIskill-RockRMS/rules/*.md; do awk 'NR==1 && /^---$/ {skip=1; next} skip && /^---$/ {skip=0; next} !skip' "$f"; echo; done >> AGENTS.md
```

This route is documented from the standard, not tested by the maintainers.

</details>

## Part 2 — Initialize your workspace

> **The Summit Church developers:** skip this section and follow the [AIskill-RockRMS-TSC INSTALL](https://github.com/Summit-Church/AIskill-RockRMS-TSC/blob/main/INSTALL.md) instead (private repo — TSC org access required); it has the exact TSC commands and also installs the TSC overlay plugin.

Each developer creates a personal workspace directory and runs the `rockrms-init` skill inside it:

```bash
mkdir -p ~/GitHub/rockrms-workspace-<yourname>
cd ~/GitHub/rockrms-workspace-<yourname>
```

| Host | Start | Then type |
|---|---|---|
| Claude Code | `claude` | `/rockrms:rockrms-init` |
| Codex | `codex` | `$rockrms-init` |
| OpenCode | `opencode` | `/rockrms-init` |
| Antigravity | `agy` | `/rockrms-init` |

The skill:

- confirms before touching a non-empty directory, and **never overwrites an existing file** — safe to re-run to repair a partial scaffold;
- interviews you: your git preference, where your church's Rock code lives, and your instance's basic constants;
- scaffolds the workspace: `_code` (a plain directory, or a symlink into a sibling clone of your church's shared code repo), `docs/` (your local knowledgebase), `input_box/`, `.gitignore`, an **`AGENTS.md`** built from your answers — the instruction file all four agents read at session start — and a one-line `CLAUDE.md` that imports it (Claude Code also gets a `.claude/settings.json`);
- if your church's **overlay plugin** is installed, reads its `workspace-defaults` skill instead of interviewing — see [`examples/overlay-template/`](examples/overlay-template/).

Prefer to scaffold by hand? Every file the skill writes comes from [`skills/rockrms-init/templates/`](skills/rockrms-init/templates/) — copy them yourself and fill the `{{…}}` placeholders.

> **Where do code commits go?** With the shared-repo layout, files under `_code/` belong to your church-code-repo clone — `git status` in your workspace will not show changes to them. Branch, commit, and open PRs for Rock code in that repo. Your workspace only versions your personal scaffold and `docs/`.

## How the house rules load

| Host | Mechanism | Always on? |
|---|---|---|
| Claude Code | `hooks/hooks.json` SessionStart hook, one command per rule chunk | Yes |
| Codex | the same hook, run from the plugin install | Yes (unless hooks are disabled in `config.toml`) |
| OpenCode | `.opencode/plugins/rockrms.mjs` appends the rules to the system prompt every turn | Yes, with the plugin loader |
| Antigravity | `rules/*.md` carry `trigger: always_on` | Yes, within the always-on budget |
| Other harnesses | you paste the rules into the instructions file | Only if you do |

The rules say how we write SQL, Lava, comments, and files; they are the same text on every host. The skills load on demand: each host shows the agent every skill's one-line description and the agent reads a skill when a task calls for it (or when you name it).

## Contributing improvements back

The plugin content (rules, references, skills) is maintained in this repo. To propose a change:

```bash
git clone https://github.com/Consta-Tech/AIskill-RockRMS.git
```

Branch, edit, and open a PR — [CONTRIBUTING.md](CONTRIBUTING.md) has the provenance tiers, the manifest-row requirement, and the render check (enable it with `git config core.hooksPath .githooks`). Inside a session, the `rockrms-add-knowledge` skill drafts a reference from a URL and stops before the commit. Once merged, every installed developer receives the change on their next update. Don't also copy `skills/` into a directory your agent scans on its own (`~/.claude/skills/`, `~/.agents/skills/`) — combined with the plugin install, every skill would load twice.

## Troubleshooting

**Skills missing from autocomplete, or `rockrms-init` not offered.** Restart the agent — every host indexes plugins and skills at startup. On Codex, `codex plugin list` must show `rockrms`; on OpenCode, check that `~/.config/opencode/plugins/rockrms.js` exists and that its relative path reaches the clone.

**`claude plugin marketplace add` / `codex plugin marketplace add` fails.** Use the `Consta-Tech/AIskill-RockRMS` (owner/repo) form. A local path must point at the repo root, not `.claude-plugin/`.

**House rules not in context.** Ask "which house rules are loaded?". Claude Code: `claude plugin list` must show `rockrms` enabled; start a new session and check `/context`. Codex: hooks must be enabled (`[features] hooks = false` in `config.toml` turns them off). OpenCode: the loader file must exist — a skills-only copy under `.agents/skills/` never loads the rules. Antigravity: a session with many large always-on rules overflows the 20,000-token budget and the largest files become pointers; trim your own rules. The hook itself needs bash and `python3`. If a Claude Code rule block shows only a short preview followed by a note that the rest was saved to a file, that rule outgrew the per-hook output cap — run `bash hooks/inject-rule.sh --check` in a clone and open an issue.

**Permission prompts when editing files under `_code/`** (Claude Code). Confirm `.claude/settings.json` contains the `additionalDirectories` entry and that the church clone actually sits at the sibling path.

**Not receiving updates.** Claude Code: `claude plugin marketplace update consta-tech`, then restart. Codex: `codex plugin marketplace upgrade consta-tech`, then remove and re-add the plugin. OpenCode: `git pull` in the vendor clone. Antigravity: uninstall and reinstall.

**A skill name collides with another plugin's.** The generic-sounding skills carry a `rockrms-` prefix for this reason; the Rock-specific ones (`language-lava`, `rock-sql-schema`, `surface-helix`, …) do not. Codex lists both skills when two share a name; pick ours by its description.
