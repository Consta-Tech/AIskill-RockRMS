---
name: surface-dynamicdata
description: Working in Rock's Dynamic Data block (Obsidian) — the SQL Query and Lava Template pair, the block settings that matter (Timeout Length, Query Params, Results Display Mode, Enabled Lava Commands, the grid's person actions), how a PageParameterFilter drives it and what re-renders when, the paste-test-iterate loop, and the two traps unique to this block: HTMX attributes in its output are never processed until the template calls htmx.process() on itself, and every "current URL" Lava source returns the block's BlockActions API endpoint instead of the page. Use when building, debugging, or reviewing a Dynamic Data block, its query file, its Lava template, or a PageParameterFilter that feeds it.
---

# The Dynamic Data Block as a Workbench

> **Provenance tier:** `traced` — read from source or official documentation and cited (Rock version not recorded). Catalogued in the plugin's knowledge manifest; `/rockrms:knowledge-current` lists every entry.



A Dynamic Data block runs a SQL query and shows the result either as Rock's **grid** or through a **Lava template** you write. The T-SQL itself is governed by the injected house rules and the `format-tsql` skill; the tables by `rock-sql-schema`; the Lava by `language-lava`. This skill is about the block: its settings, its two-engine render, how it re-renders, and how to test it.

## Two files, two engines

Per the file-organization house rules, one block is two files under `_code/Block-DynamicData/PageId_{id}/`:

| File | Pasted into | Engine order |
|---|---|---|
| `BlockId_{id}-Query.lava.sql` | **SQL Query** | Lava renders first, then SQL Server receives the output |
| `BlockId_{id}-FormattedOutput.lava` | **Lava Template** (Results Display Mode = Lava Template) | Lava renders over the query's `rows` |

Because the query passes through two engines, its comments are **layer-matched**: a `//-` Lava comment about a Lava assignment is stripped before SQL sees it; a `--` SQL comment survives into the query text (and into Profiler). The boilerplate header at the top is a **SQL** block comment on purpose, so it survives into the text you paste into a SQL client when debugging (see the `surface-sql-editor` skill). The boilerplate templates are in `assets/boilerplates/`.

A block may have only a query (grid mode), or both.

## Settings that matter

As declared in Rock's Obsidian block source (`Rock.Blocks/Reporting/DynamicData`, `develop` branch, read September 2026; labels may differ by version):

| Setting | Default | Why it matters |
|---|---|---|
| **SQL Query** | — | The query text. Lava in it resolves first. |
| **Query Parameters** (`param=value;…`) | — | Rock's own way of passing page parameters into the query. **Leave it empty** when the Lava layer reads `'Global' \| PageParameter` and writes coerced literals — the two mechanisms fight, and only the Lava route lets you run the coercion guard. |
| **Timeout Length** | `30` s | The query's command timeout. The SQL Command page's default is 180 s, so a query that runs there can still time out here. A Lava Application endpoint's `{% sql timeout:'…' %}` is the equivalent control, same default. |
| **Results Display Mode** | Grid | `Grid` or `Lava Template`. Only Lava Template reads the Formatted Output file. |
| **Lava Template** | — | The Formatted Output. Receives `rows` (single result set), `table1`… and `tables` (multiple result sets), `PageParameters`, `CurrentPerson`, `CurrentPage`. Each row is a Lava data object keyed by column alias. |
| **Enabled Lava Commands** | none | Commands the query's and template's Lava may run. A template that needs `{% sql %}` fails without it. |
| **Page Title Lava** | — | Can read the result (`{{ rows[0].Name }}`) to title the page. |
| **Person Report** | off | Turns on the grid's person actions (Communicate, Bulk Update, Merge, Launch Workflow); needs a person-Id column named in **Communication Recipient Fields**. |
| **Selection URL** | — | Row-click navigation with column placeholders (`~/Person/{Id}`). |
| **Column Configurations**, **Enable Export**, **Merge Template**, **Show Checkbox Selection Column**, **Disable Paging**, **Enable Sticky Header** | mostly on | Grid-mode presentation and actions. |
| **Grid Header / Footer Content** | — | Lava rendered above/below the grid, with the dataset in scope — the place for a totals line in grid mode. |

Column aliases in the **final** `SELECT` become the grid's headers and the template's row keys, so they are always written (house rule).

## Reading page parameters into the query

Every `input_` value reaching SQL passes through a coercing filter first — the injected house rules explain the guard and why both halves of `{% if input_CampusId and input_CampusId >= 1 %}` are load-bearing. The shape of each parameter depends on the PageParameterFilter field type that produced it; `references/PageParameterFilter-Wiring.md` lists the shapes and the parse for each.

Document every parameter the query reads under **PageParameters consumed** in its boilerplate, with the field type and what an empty value means (no filter, or no rows).

## Guarding, and when `{% return %}` does not fit

The house rule is an early-out: `{% if … %}{% return %}{% endif %}` at the top, then the body at file indentation. That works in the query file when "nothing" is the right answer — the block simply gets no query text.

It does **not** fit when the guarded branch must still return a result set — for instance a second block on the page that should render *nothing* in one view but must not run its full query on every load of the other view. There the query wraps in `{% if %} … {% else %} … {% endif %}` and the guarded branch emits a one-column empty result:

```sql
{% if var_IsCampusView == false %} //- Wrapping IF: an early {% return %} would leave the block with no query text
SELECT TOP (0) CAST(NULL AS int) AS "OccurrenceId";
{% else %}
… the real query, at column 0 so the rendered text pastes cleanly into a SQL client …
{% endif %}
```

Put the guard in the **query**, not only in the template: a template-only guard still runs the expensive query and throws the rows away.

## Empty results in the template

`rows | Size` is `0` when the query returned nothing — but a query that always returns a header row (scope-wide figures with every row column NULL) needs a second test, such as `firstRow.RowKey != null`, to tell "no rows to list" from "no data at all". Decide which shape the query produces and test for that one; say so in a comment.

## Links from the template

Inside this block, `'Global' | Page:'Url'`, `Page:'Path'`, `Page:'QueryString'`, and `'Current' | SetUrlParameter:…` all return the **BlockActions API endpoint** the block was fetched from, not the page. Nothing errors; the link just navigates into JSON. Write links as bare relative query strings written out in full, one single-line `{% capture url_… %}` each. Measurements and the pattern are in `references/Current-Url-Is-BlockActions.md`.

## HTMX inside the template

The Obsidian block mounts client-side, after HTMX has scanned the page, so `hx-get` / `hx-post` in its output are inert until the template's own last line calls `htmx.process()` on the block root. The fix is one line; three plausible placements silently fail; re-renders are self-healing; `hx-params` is mandatory here too. All of it, with the devtools triage order, is in `references/DynamicData-With-Htmx.md`.

## The test loop

1. Edit the two files in the repo to house style.
2. In Rock: block settings → paste the query into **SQL Query**, the template into **Lava Template**, confirm Results Display Mode and Timeout Length, **Save**.
3. Load the page **with the query string the block expects** — an empty parameter set is a distinct test case, not a shortcut.
4. Read the failure honestly:
    - A **SQL error** renders as a red Rock alert in the block's place, carrying SQL Server's message. Read the rendered query, not the file — the Lava layer may have produced something other than what you meant.
    - A **Lava error** renders as `Lava Error:` text.
    - A **timeout** is a SQL error; before raising Timeout Length, stage the query (filter → group → format) per the house rules.
    - An **empty grid** with no error is usually a parameter that failed coercion and fell into the "no rows" branch — check the URL first.
5. Hand back to Claude: the **page URL including its query string**, **observed versus expected**, and the alert text verbatim. If Claude has browser tools, give it the URL and let it read the tab; a screenshot of the grid is the fallback.

## File index

| File | Covers |
|---|---|
| [DynamicData-With-Htmx.md](references/DynamicData-With-Htmx.md) | Why `hx-*` attributes are inert in this block, the one-line `htmx.process()` fix and the placements that fail, re-render paths (HTMX swaps, PageParameterFilter with and without Legacy Reload, publishing `QueryStringChanged` from your own block), `hx-params` measurements, and the devtools triage order. |
| [Current-Url-Is-BlockActions.md](references/Current-Url-Is-BlockActions.md) | The measured return values of every "current URL" Lava source inside this block, and the relative-query-string link pattern. |
| [PageParameterFilter-Wiring.md](references/PageParameterFilter-Wiring.md) | The PageParameterFilter block's settings that affect this block, the value shape each field type produces and how to parse it, and how to drive a re-render from a block of your own. |
| `assets/boilerplates/` | `boilerplate-block-DynamicData-Query.md` and `boilerplate-block-DynamicData-FormattedOutput.md` — the header templates the `audit-pre-push-1` skill enforces. |

## Related skills

- `format-tsql`, `rock-sql-schema` — the query itself. `language-lava` — the template language, including the `PageParameter` filter's caveats.
- `surface-sql-editor` — debugging the rendered query outside Rock; the 180-second versus 30-second timeout difference.
- `surface-helix` — the endpoints an HTMX-enabled template calls, and where the HTMX runtime on the page comes from.
- `surface-htmlcontent` — the block to use when you need the real page URL and no grid.
