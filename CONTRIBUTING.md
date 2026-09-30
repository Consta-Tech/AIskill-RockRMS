# Contributing to AIskill-RockRMS

Thank you for helping keep this plugin honest. The plugin's value is that every Rock RMS answer it gives traces back to a **documented, cited reference** — so contributions are as much about provenance as about content.

## The short version

1. Fork, branch, change, open a PR against `main`. Once merged, every installed machine receives the change automatically (the plugin is unversioned on purpose — do not add a `version` field to `plugin.json`).
2. Every new or changed reference file gets a row in `knowledge/manifest.yaml`, a provenance header, and a bullet under `## Unreleased` in `CHANGELOG.md`.
3. Run `python3 knowledge/render.py` and commit the two rendered views it updates. `python3 knowledge/render.py --check` must pass — enable the pre-commit hook once per clone so you cannot forget:

   ```bash
   git config core.hooksPath .githooks
   ```

Inside a Claude Code session, `/rockrms:add-knowledge` performs steps 2 and 3 for you from a URL or a pasted excerpt, and stops right before the commit.

## Where does it belong? The sorting rule

| If the knowledge is… | It belongs in… |
|---|---|
| True of Rock anywhere — a Lava behavior, a core table, a stock block's settings, a Rock Shop plugin **as the vendor ships it** | This repo (the generic `rockrms` plugin) |
| True only at one church — instance Ids, hostnames, page structure, an intentional deviation from stock behavior | That church's **overlay** plugin (see `examples/overlay-template/`) |
| Only true for one developer or machine | That developer's workspace `docs/` |

"Verified on our instance" is provenance, not scope: a behavior measured at one church that would reproduce on any Rock instance is generic knowledge. Strip church-specific names, Ids, and hostnames before it lands here (`{your-rock-host}` is the placeholder convention).

## The three provenance tiers

Every manifest row and every reference file header states one tier. Choose the **lowest** tier the evidence supports; a later contributor can promote it.

| Tier | Claim | Evidence the file must carry |
|---|---|---|
| `measured` | Observed in a live Rock instance | What was done, what was observed, the date, and the Rock version (`Measured 2026-09-11 on v18.2.4`). A probe or the exact Lava/SQL used, where practical. |
| `traced` | Read from Rock source or official documentation | A link to the exact source file at a **pinned commit**, or to the documentation page, and the Rock version or plugin version it describes. |
| `summarized` | Condensed from a URL, not verified | The source URL, the access date, and explicit "unverified" wording. A short "to verify in Rock" checklist at the end turns the file into a measurement plan. |

Promotion is a normal PR: run the measurement, add the dated observation, change the tier in both the header and the manifest row.

## Summarize and cite — the licensing stance

Reference files are written **in our own words**. Community documentation, vendor documentation, and blog posts stay where their authors published them; we summarize what they say, link to them, and quote at most a short excerpt when the exact wording matters (a setting label, an error message). Rock's source is open (Rock Community License) and may be quoted in small, attributed snippets when the code itself is the fact being documented. Never paste a documentation page or a source file wholesale.

## The manifest row

`knowledge/manifest.yaml` is a flat list of flat mappings — a small YAML subset that `knowledge/render.py` parses without any installed library. One entry per reference file (or per stated coverage claim with `file: null`):

```yaml
- id: blocktype-content-channel-view          # lowercase-hyphen, unique
  category: rock-source                        # see the category list in knowledge/render.py
  title: Content Channel View block
  skill: rock-blocktypes                       # owning skill directory; null for rules/*.md
  file: references/ContentChannelView.md       # relative to the skill (or the plugin root when skill is null)
  source_url: https://github.com/SparkDevNetwork/Rock/blob/<sha>/Rock.Blocks/Cms/ContentChannelView.cs
  rock_version: v18.2                          # what it was verified on; unknown if not recorded; n/a for house conventions
  tier: traced
  status: current                              # or roadmap
  added: 2026-10-05                            # the date you added the row (the maintainer aligns it to the release date)
  notes: "Traced from the Obsidian block source at a pinned commit."
```

Rules the check enforces: every `skills/*/references/**/*.md` (except `README.md` index files) has a row; every row's file exists; the file's header states the same tier as its row; the two rendered views match the manifest. Quote a value in double quotes when it contains `: ` or starts with a special character.

Categories at launch: `community-docs`, `lava`, `rock-source`, `rock-schema`, `rockshop-plugin`, `front-end`, `house`. Overlays additionally use `instance-facts` and `deviations`. A category id the renderer does not know still renders, labelled by its id — add a label in `CATEGORY_LABELS` when you introduce one.

## The provenance header

The first thing after a reference file's title is one blockquote line stating the tier. `python3 knowledge/render.py --stamp` writes it for any listed file that lacks one, in this shape:

```markdown
> **Provenance tier:** `summarized` — condensed from the cited source, **not yet verified** in Rock (v18.2). Catalogued in the plugin's knowledge manifest; `/rockrms:knowledge-current` lists every entry.
```

## Render and check

```bash
python3 knowledge/render.py            # rewrite knowledge/Knowledge-current.md and Knowledge-future.md
python3 knowledge/render.py --check    # exit 1 on a stale view, a missing row, or a header/row tier mismatch
```

Commit the rendered views with your change; the PR diff to `Knowledge-current.md` is the reviewer's summary of what you added. There is no CI on this repo yet, so the pre-commit hook is the only automated gate — enable it.

## Proposing a roadmap row

A church that wants a topic documented — a BlockType, a Rock Shop plugin, a community documentation book — opens a PR that adds a `status: roadmap` row with the title, category, the source URL you would start from, and in `notes` one sentence on why it matters. `file` is `null` and `tier` is the tier you expect to reach (`summarized` is fine). It appears, numbered, in `/rockrms:knowledge-future`. When the reference lands, the same row flips to `status: current` and gains its `file`.

## Changelog and releases

Add a bullet under `## Unreleased` at the top of `CHANGELOG.md` (Added / Changed / Fixed / Removed). When the maintainer cuts a release, that heading becomes `## YYYY-MM-DD`, and any manifest rows added since the previous release have their `added` date aligned to it. `/rockrms:changelog` shows users the sections they have not seen yet, keyed on the installed commit.

## Running the eval suite

`evals/` holds a small `claude plugin eval` suite (Claude Code v2.1.269 or later). Each case is a prompt plus graders; runs are real model calls on your account.

```bash
# from the repo root
claude plugin eval . --allow-tools Bash Write Edit --scaffold --no-publish
# cheaper while iterating on one case:
claude plugin eval . --case changelog-prints-newest --runs 1 --ablation none --allow-tools Bash --no-publish
```

`--allow-tools Bash` is needed because the knowledge skills run the scripts under `knowledge/`; `--scaffold` lets the `add-knowledge` case copy this checkout into its sandbox workspace. Results land in `evals/results/` (gitignored). `claude plugin validate .` checks manifests and skills without any model call; its one warning — "No version specified" — is intentional.

## House style for the files themselves

- Skill names are lowercase-hyphen and equal their directory name; `SKILL.md` stays under 500 lines with depth in `references/`.
- Cross-skill and cross-plugin references are **by skill name**, never by relative path — installed plugins live in separate directories.
- Spell out BlockType and entity names (Dynamic Data block, PageParameterFilter). Say *documented* or *verified*, not "trained". Write skill invocations with the namespace: `/rockrms:format-tsql`.
- Nothing from a personal `input_box/` or other ephemeral location is cited in a shipped file.
