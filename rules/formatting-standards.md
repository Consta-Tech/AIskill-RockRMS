---
trigger: always_on
---
# Formatting Standards

> **Provenance tier:** `traced` — read from source or official documentation and cited (house convention, no Rock version). Catalogued in the plugin's knowledge manifest; `rockrms-knowledge-current` lists every entry.

With any programming language that we use, indentation is 4-spaces.

This file holds what applies to every language. The language-specific standards are in their own files, auto-loaded alongside this one: `formatting-standards-sql.md`, `formatting-standards-lava.md`, and `formatting-standards-workflowtypes.md`.

<details open><summary>The boilerplate is the first thing in the file. Nothing goes above it.</summary>

Whatever the language, the boilerplate comment block opens the file. The about-documentation house rule says what goes *in* it; this says where it *sits*.

The case that gets this wrong is a `.lava.sql` file, where the Lava layer has to resolve the PageParameters before the SQL can use them. That ordering is a constraint on the *code*, not on the header — the header still comes first, and the Lava preamble sits between it and the SQL body.

✅ Yes:
```
/****************************************************************************************

    Path:
    _code/Block-DynamicData/PageId_6219/BlockId_15330-Query.lava.sql
    ...

****************************************************************************************/
{% assign input_Month = 'Global' | PageParameter:'Month' %}
...
DECLARE @date_MonthStart date = '{{ var_MonthStart | Date:'yyyy-MM-dd' }}';
```
❌ No — the reader meets the code before they are told what the file is:
```
{% assign input_Month = 'Global' | PageParameter:'Month' %}
...
/****************************************************************************************

    Path:
    _code/Block-DynamicData/PageId_6219/BlockId_15330-Query.lava.sql
```
</details>

<details open><summary>Dates go big-to-small: ISO in code, <code>YYYY-MON-DD</code> in prose</summary>

Year first, then month, then day — everywhere, including for clients in the United States. Day-first and month-first orders are each someone's default, and a date like `04-09` is read both ways; year-first is read one way.

- **In code** (Lava, SQL, JavaScript values, literals, and format strings), use ISO `yyyy-MM-dd`.
- **In prose** (boilerplate notes, READMEs, `docs/`, and Description fields in Rock), use `YYYY-MON-DD` with a three-letter month: `2026-OCT-01`. The spelled-out month is what tells an American reader that this is year-month-day, not a typo of their own `MM-DD-YYYY`.

✅ Yes:
```
    i copy+pasted this on 2024-APR-09
```
```
{% assign var_WindowStartDate = 'Now' | DateAdd:-90,'d' | Date:'yyyy-MM-dd' %}
```
❌ No:
```
    i copy+pasted this on 09-APR-2024
    i copy+pasted this on 04/09/2024
```
</details>
