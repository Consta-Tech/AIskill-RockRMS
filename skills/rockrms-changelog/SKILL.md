---
name: rockrms-changelog
description: Print what changed in the rockrms plugin — the newest date-stamped release section of its CHANGELOG, everything released since this machine last looked, and the installed commit. Use when the user asks what is new, what changed, which version or commit of the plugin is installed, or invokes the rockrms-changelog skill by name.
allowed-tools: Bash Read
---

# rockrms-changelog

The plugin has no version number; it is identified by the installed git commit, and releases are date-stamped sections in `CHANGELOG.md`. This skill prints both, and remembers what it showed so the next run can say what is new since then.

## Locate the plugin first

The commands below need the plugin's root directory — the one that holds `knowledge/` and `skills/`. Claude Code and Codex expose it as `${CLAUDE_PLUGIN_ROOT}`; on any other host it is two directories above this `SKILL.md` (`<root>/skills/rockrms-changelog/SKILL.md`). Set it once:

```bash
ROOT="${CLAUDE_PLUGIN_ROOT:-${PLUGIN_ROOT:-<absolute path two directories above this SKILL.md>}}"
```

## Do this

1. Run exactly this command and print its output **verbatim** — it is already formatted Markdown:

   ```bash
   bash "$ROOT/knowledge/changelog.sh" "$ROOT"
   ```

2. Add one closing line: `rockrms-knowledge-current` lists what the plugin documents today, `rockrms-knowledge-future` what is planned.

Do not paraphrase, reorder, or trim the sections. Do not add a version number of any kind; "vX.Y.Z" never applies to this plugin.

## What the script does

- Prints the identity header: `rockrms (marketplace consta-tech) · installed commit <sha> · latest release <date>`. The commit comes from Claude Code's `~/.claude/plugins/installed_plugins.json`, then `claude plugin list --json`, then `git rev-parse` in the plugin root, then `unknown`.
- Prints the newest `## YYYY-MM-DD` section.
- Stores the commit and release date in the plugin's data directory (`changelog-seen.tsv`) — `${CLAUDE_PLUGIN_DATA}` or `${PLUGIN_DATA}` when the host sets one, else `~/.local/share/rockrms/`. When the stored commit differs from the installed one, it first prints every release section newer than the stored date under **Since you last checked**, then updates the store.
- Without a writable data directory it prints the latest section only and says so. That is not an error.

## If the script cannot run

Read `$ROOT/CHANGELOG.md`, print its first `## YYYY-MM-DD` section, and open with the header from `bash "$ROOT/knowledge/plugin-identity.sh" "$ROOT"` (or `installed commit unknown` if that also fails).
