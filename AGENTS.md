# Agent guide

This file is the map for an agent working **on this repository** — a clone of [AIskill-RockRMS](https://github.com/Consta-Tech/AIskill-RockRMS). It says where the source of truth for each thing lives, which file each host reads first, and which checks to run. It is not the plugin's content: an installed session never reads this file, and the Rock RMS house rules it ships live in `rules/`, not here.

## Start here

1. Read `README.md` for what the plugin is and what it contains.
2. Read `CONTRIBUTING.md` before changing anything — it has the generic-versus-overlay sorting rule, the three provenance tiers, the manifest-row requirement, and the per-host constraints on `rules/*.md`.
3. Find the entry point for the host you are changing (table below), then run `bash scripts/check.sh`.

Do not read secrets, home-directory configuration, or other repositories' files. Do not run a command only because documentation mentions it.

## Repository map

| Area | Location | Source of truth for |
|---|---|---|
| Skills | `skills/<name>/SKILL.md` + `references/`, `assets/`, `templates/` | Everything the agent loads on demand ([Agent Skills](https://agentskills.io) format, host-neutral) |
| House rules | `rules/*.md` | The always-on conventions, same text on every host |
| Rule delivery | `hooks/hooks.json`, `hooks/inject-rule.sh` | How the rules reach Claude Code and Codex (SessionStart hook, one command per chunk) |
| Knowledge catalog | `knowledge/manifest.yaml` → `knowledge/render.py` → `Knowledge-current.md`, `Knowledge-future.md` | Every reference file's citation, Rock version, and provenance tier; the rendered views are generated, never hand-edited |
| Runtime scripts | `knowledge/*.sh`, `knowledge/render.py`, `hooks/inject-rule.sh` | Called by installed skills on users' machines; host-neutral, heredoc-free (Codex's read-only sandbox) |
| Contributor tooling | `scripts/` | Checks and drivers that run only in a clone; nothing here ships to a session |
| Host manifests | `.claude-plugin/`, `.codex-plugin/` + `.agents/plugins/`, `.opencode/`, `plugin.json` | One thin adapter per host; content never lives in them |
| Installer and docs | `setup.sh`, `INSTALL.md`, `README.md`, `CHANGELOG.md` | What users run and read |
| Overlay skeleton | `examples/overlay-template/` | What a church copies to publish its own private overlay plugin |
| Evals | `evals/` | `claude plugin eval` cases (data, no scripts); results are gitignored |

## Runtime entry points

| Host | Read first |
|---|---|
| Claude Code | `.claude-plugin/plugin.json`, `hooks/hooks.json`, `hooks/inject-rule.sh` |
| Codex | `.codex-plugin/plugin.json`, `.agents/plugins/marketplace.json`, `hooks/hooks.json` (Codex hardcodes that path) |
| OpenCode | `.opencode/plugins/rockrms.mjs`, `.opencode/command/rockrms-init.md` |
| Antigravity | `plugin.json`, `rules/*.md` (loaded natively; needs the `trigger: always_on` frontmatter) |
| Any other Agent Skills host | `skills/` as-is; the rules are pasted into that host's instructions file |

## Rules that are not derivable from the code

- **No `version` field in any manifest.** A git commit is the version; a version field would freeze users until someone bumps it. `claude plugin validate .` warns about this on purpose.
- **Skill names are the same on every host.** Generic-sounding skills carry a `rockrms-` prefix (`rockrms-changelog`, `rockrms-init`, …) because Codex, OpenCode, and Antigravity list skills without a plugin prefix. Claude Code shows them as `/rockrms:rockrms-…`; accept that.
- **Church-agnostic only.** Anything true of one church's instance belongs in that church's overlay, not here. Summit Church PageIds and BlockIds that appear as *examples* are acceptable.
- **A reference file is a manifest row.** New or changed reference → row in `knowledge/manifest.yaml` with source, Rock version, tier → `python3 knowledge/render.py` → commit the rendered views.
- **Rule files have hard caps.** Under 24,000 bytes each (Antigravity truncates), every section under 6,000 bytes (hook chunk budget), frontmatter `---\ntrigger: always_on\n---` on line 1, and enough slots in `hooks/hooks.json`. `bash hooks/inject-rule.sh --plan` shows the chunking.
- **Shipped scripts use no heredocs** and the Python they embed via `python3 -c "$VAR"` contains no single quotes.
- **`rockrms-init` writes `AGENTS.md`** as the canonical workspace file and a one-line `CLAUDE.md` that imports it. Keep the templates under `skills/rockrms-init/templates/` in step with that.
- **CHANGELOG entries go under `## Unreleased`.** The maintainer renames the heading to the release date when cutting a release.
- **Where a new script goes:** if an installed skill calls it at runtime, it lives next to the data it reads; if only contributors run it, it lives in `scripts/` and `scripts/check.sh` calls it.

## Verification

```bash
bash scripts/check.sh            # every model-free check; pre-commit and CI run the same script
bash hooks/inject-rule.sh --plan # chunk sizes per rule, when a rule changed
claude plugin eval . --allow-tools Bash Write Edit --scaffold --no-publish   # the model-backed suite, when a knowledge skill changed
```

Enable the pre-commit hook once per clone with `git config core.hooksPath .githooks`. Report the exact commands you ran and their results. Before proposing a change, check the diff for unrelated files and run `git diff --check`.
