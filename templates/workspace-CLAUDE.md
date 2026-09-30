# CLAUDE.md

## Context

This is my Rock RMS development workspace{{CHURCH_SUFFIX}}. Rock RMS is an open-source church management system built on ASP.NET.

{{PLUGINS_PARAGRAPH}}
<!-- Generic (no overlay): "House rules, language references (Lava, T-SQL, HTMX), Rock schema docs, and audit skills come from the `rockrms` Claude Code plugin (`Consta-Tech/AIskill-RockRMS`). The house rules are injected automatically at session start — follow them."
     Overlay installed: same sentence, but name both plugins, e.g. "... come from the `rockrms` and `rockrms-<church>` Claude Code plugins. The house rules ..." -->

## Layout

- {{CODE_LAYOUT_BULLET}}
<!-- Shared-repo layout: "`_code/` is a symlink into my sibling clone of `<owner>/<church-repo>`. All Rock code lives there. Commits and PRs for code changes happen in that repo, not this one."
     Plain layout: "`_code/` holds all my Rock code, organized by block type per the file-organization rules." -->
- `docs/` is my local knowledgebase: verified facts about **my** Rock instance, internal procedures, and personal working notes. General Rock knowledge does not belong here — it belongs upstream in the `rockrms` plugin (open a PR). See `docs/README.md` for what goes where.
- `input_box/` is a gitignored dropbox for rough drafts. Each file's line 1 is a comment hinting its destination directory or end goal; process it per the file-organization rules.

## Prompt Files

A **prompt file** is a structured requirements/plan document that a future Claude session can execute without me present. It lives at `input_box/project-<NN>/prompt.md` (numbered sequentially), and I kick it off in a fresh session with: "Please read and execute the prompt in `input_box/project-01/`."

When helping me write one, capture at minimum: the goal, current vs. expected behavior, the pages/blocks/entities involved, constraints, and acceptance criteria. Refine it with me until it could be executed by a session that has no memory of this conversation. Like everything in `input_box/`, prompt files are gitignored working material.

## Workflow Context

Code in this workspace follows this development cycle:

1. Write/edit code in `_code/`
2. Paste into a Rock RMS Block to test behavior
3. Iterate until the code behaves as expected
4. Commit clean, working code ({{COMMIT_TARGET}})
5. Update corresponding documentation if behavior changed

When I describe what I'm observing after testing in Rock, treat that as the ground truth — Rock's rendering is the authority on whether code works.

## Session Openers

If I open a session with a concrete task, just do it — no menu. If I open vaguely (a greeting, "help", "not sure where to start"), offer this menu:

1. Ask a question about Rock in general
2. Ask a debugging question about my current Rock instance
3. Ask a brainstorming question about a new solution
4. Help me write a prompt file (see "Prompt Files" above)
5. Help me document some knowledge (into `docs/`, or as a PR to the plugins)

For options 1–3, do not assume I know which reference material applies. Ask diagnostic questions first — what am I observing vs. expecting, and which surface am I working in — and only then pull in the relevant plugin skills and `docs/` files. Each surface has a skill that knows its settings, its test loop, and what to ask me to paste back:

| Surface | Skill |
|---|---|
| Rock's SQL Command page, or a SQL client | `surface-sql-editor` |
| The Lava Tester block | `surface-lava-tester` |
| A Dynamic Data block (query + Lava template, PageParameterFilter) | `surface-dynamicdata` |
| An HTML Content block | `surface-htmlcontent` |
| A Lava Application endpoint or Lava Application Content block (Helix / HTMX) | `surface-helix` |

When I name the surface up front, load that skill without asking.

The plugin answers Rock questions only from its documented references (the injected knowledge-boundaries rule). When a topic is not covered it says so and asks whether to answer from general knowledge, marked unverified, or to start documenting it with `/rockrms:add-knowledge`. `/rockrms:knowledge-current` lists what is documented; `/rockrms:changelog` shows what changed in the plugin.

## Task Types

When I start a conversation, I will tell you whether this is:

- **Brainstorming** — Explore approaches, weigh tradeoffs, no code changes yet
- **Troubleshooting** — Code exists but isn't behaving as expected. I'll describe what I see vs. what I expected.
- **Polishing** — Code works correctly but needs UX/visual/readability improvements
- **Documentation** — Update or create docs to reflect current implementations

## Git

{{GIT_PREFERENCE}}
<!-- No git: "This directory is not tracked with git. Do not run git commands here or suggest tracking it unless I ask."
     Help me: "Help me manage git in this workspace: occasionally recommend committing progress, suggest a branch when a piece of work warrants one, and write the commit messages."
     I'll manage it: "I manage git myself. Do not offer git help or run git commands unless I explicitly ask." -->

## Important Notes

- Lava is NOT identical to Liquid. Do not assume Liquid syntax works in Lava. When unsure, consult the `language-lava` skill.
- When writing SQL that joins to people, always join through PersonAlias — see the `rock-sql-schema` skill.
{{OVERLAY_NOTES}}
