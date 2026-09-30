# evals/

A small `claude plugin eval` suite for the knowledge-catalog skills and the ask-first fallback. How to run it, and what each flag is for, is in [CONTRIBUTING.md](../CONTRIBUTING.md#running-the-eval-suite). Results land in `results/` (gitignored).

| Case | Checks |
|---|---|
| `knowledge-current-lists-catalog` | `/rockrms:knowledge-current` prints the identity header (plugin, marketplace, installed commit) and the catalog's category headings. |
| `changelog-prints-newest` | `/rockrms:changelog` prints the newest `## YYYY-MM-DD` section and the installed commit. |
| `uncovered-topic-asks-first` | A question about a BlockType the plugin does not document triggers the knowledge-boundaries fallback: one sentence, two options, no full answer. |
| `add-knowledge-drafts-without-commit` | `/rockrms:add-knowledge` from a pasted excerpt produces a `summarized`-tier reference file and a manifest row in a scaffolded clone, and never runs `git commit`. Needs `--scaffold` and `--allow-tools Bash Write Edit`. |
