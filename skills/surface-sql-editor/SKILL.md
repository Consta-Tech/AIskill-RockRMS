---
name: surface-sql-editor
description: How to collaborate with Claude while running T-SQL against a Rock RMS database — Rock's built-in SQL Command page (Admin Tools > Power Tools) versus a desktop client such as the VS Code mssql extension, when to graduate from one to the other, how the result grid and the red "SQL Error!" alert behave, and what to hand back to Claude after a run (a browser tab to read, a saved JSON result set, or the error text). Use when the user is about to run, is running, or has just run a query against Rock, or asks where a query should be run.
---

# Rock's SQL Editor as a Workbench

> **Provenance tier:** `measured` — tested in a live Rock instance (Rock version not recorded). Catalogued in the plugin's knowledge manifest; `/rockrms:knowledge-current` lists every entry.



This skill is about the **workbench**, not the language. How to write T-SQL to house style is the `format-tsql` skill and the injected house rules; what the tables mean is the `rock-sql-schema` skill. This skill covers where a query gets run, what that place does to it, and how the result comes back to Claude.

## Two workbenches

| | Rock's **SQL Command** page | A desktop client (VS Code + `mssql` extension) |
|---|---|---|
| Reach for it when | A quick, read-only question — one statement, one result set | Anything heavier: several result sets, table-type variables, saving results |
| Result set | One grid, in the browser | As many as the batch returns, with export |
| Where results go | The browser tab | A `.json` (or `.csv`) file beside the `.sql` file |
| Best hand-back to Claude | Let Claude read the tab, or paste the error text | "I saved the results of `thisQuery.sql` in `thisQuery.json`" |

Rock's page is a light, convenient tool, not a power tool. The moment a query wants more than one result set, declares table-type variables, or produces results worth keeping, move to the desktop client. (Azure Data Studio is retired; the VS Code `mssql` extension is its replacement.)

## Rock's SQL Command page

Found under **Admin Tools > Power Tools > SQL Command**. What is on it, as declared in Rock's source for the block (`RockWeb/Blocks/Reporting/SqlCommand`, `develop` branch, read September 2026 — labels may differ slightly by version):

- **SQL Text** — the query, or a stored procedure name. Runs as **one batch** (`CommandType.Text`), so `GO` separators do not belong here.
- **Selection Query?** toggle (Yes / No) — help text: *"Will the SQL Text above return rows? If so, a grid will be displayed containing the results of the query."*
    - **Yes** runs the text as a read-only data set and renders the first result set in a grid. Column types (boolean, date, date-time) are detected from the result schema; headers are the column names in split-case.
    - **No** runs it as a non-query and reports rows affected. This is the path for INSERT / UPDATE / DELETE, which is exactly why the habit below matters.
- **Run** — the execute button.
- A green **"Command completed successfully."** notification carrying the elapsed milliseconds, or a red **"SQL Error!"** notification carrying the exception message. A SQL error therefore looks like an ordinary red Rock alert, not a stack trace or a blank grid.
- **Database Timeout** — a block setting, default **180 seconds**, that is the only timeout in play here. Note that a Dynamic Data block's default is 30 seconds (see the `surface-dynamicdata` skill), so a query that finishes on this page can still time out once pasted into a block.

### Habits that keep this page safe

The page runs with the application's database credentials. Two habits, both of which came from how the maintainers actually work:

1. **Treat the page as read-only.** Leave *Selection Query?* on **Yes**. A statement that changes data does not belong in this box.
2. **Do writes through Lava, not SQL.** A bulk correction is a `{% modifyentity %}` command run in the Lava Tester (see the `surface-lava-tester` skill), not an `UPDATE`. Rock's entity layer then fires its own history, hooks, and validation, and the named `return:` variable tells you what happened to each row.

## Debugging a Dynamic Data query here

A Dynamic Data query file is Lava **and** SQL. Lava renders first, then SQL Server receives whatever Lava produced — so the text in the file is not yet valid T-SQL. To debug it on this page or in a client:

1. Resolve the Lava layer first — either read the rendered query out of the block, or hand-substitute the `{{ … }}` values with the literals a real page load would supply.
2. Paste the *rendered* query. The house rule that the boilerplate header in a `.lava.sql` file is a **SQL** block comment (`/* … */`) exists for this moment: it survives the render and identifies the query when it is sitting in a client window with no file name.

The `surface-dynamicdata` skill carries the rest of that block's behavior.

## The collaboration loop

1. **Claude drafts** the query to house style, states what it expects the result to look like (row count, grain, which columns may be NULL), and says which workbench fits.
2. **You run it.**
3. **You hand the result back.** Pick the cheapest faithful channel:
    - **Rock's page, Claude has browser tools:** give Claude the page URL and ask it to read the tab. It sees the grid, the notification, and the elapsed time exactly as you do.
    - **Rock's page, no browser tools:** paste the red alert's text verbatim, or the first rows of the grid, or a screenshot.
    - **Desktop client:** save the result set as JSON beside the query and say so — *"I saved the results of `thisQuery.sql` in `thisQuery.json`"*. Claude reads the file directly and can compute over it.
4. **Always include**, whatever the channel: the URL of the page you were on, what you observed versus what you expected, and the error text verbatim if there was one.

What Claude does with a result set: reconcile the row count against the stated grain, look for NULL patterns that indicate a missed JOIN through `PersonAlias`, and check that a half-open date range caught the boundary rows — before touching the query again.

## Related skills

- `format-tsql` — restyles any query to house style before it is run.
- `rock-sql-schema` — the tables, their JOIN affinities, and the PersonAlias rule.
- `surface-dynamicdata` — the block most of these queries end up in, including its own 30-second timeout.
- `surface-lava-tester` — where data corrections are run as `{% modifyentity %}` commands instead of SQL writes.
