# Wiring a PageParameterFilter to a Dynamic Data block

> **Provenance tier:** `measured` — tested in a live Rock instance (Rock version not recorded). Catalogued in the plugin's knowledge manifest; `rockrms-knowledge-current` lists every entry.



The **PageParameterFilter** block renders form controls whose values become query-string parameters; the Dynamic Data block on the same page reads them with `'Global' | PageParameter:'key'`. Nothing links the two blocks directly — the URL is the contract.

## PageParameterFilter settings that affect the Dynamic Data block

| Setting | Effect on the Dynamic Data block |
|---|---|
| **Filter Selection Action** = *Apply Filters* | Selections apply when the user clicks the button (versus on every change). |
| **Enable Legacy Reload** = `False` | A filter change is two XHRs (`GetUpdatedFilters`, then `GetDynamicData`). The query string is updated in place and the Dynamic Data block **re-renders from the server without a page load** — its Lava template's `<script>` blocks run again. |
| **Enable Legacy Reload** = `True` | A full page navigation. Ordinary fresh load. |
| Each filter's **Key** | The query-string key the Dynamic Data query reads. Keep keys short and stable; they are part of every link the page carries. |

Both re-render paths were measured 2026-08-12; the details, including what happens to `htmx.process()` on each path, are in `DynamicData-With-Htmx.md`.

## Value shapes by field type

The field type chosen for a filter decides what arrives in the query string, and therefore how the query's Lava layer parses it. Record the field type next to each parameter in the query's boilerplate (**PageParameters consumed**) — the shape is not recoverable from the key name.

| Field type | Arrives as | Parse |
|---|---|---|
| Campus, Defined Value, single-select pickers | one Id | `\| AsInteger`, then guard with `{% if input_X and input_X >= 1 %}` |
| Date | `yyyy-MM-dd` | `\| Date:'yyyy-MM-dd'` **at the interpolation**, choosing the bound's literal format there |
| Date Range | `start,end` (either side may be empty) | `\| Split:',',false,2`, then `[0]` and `[1]`; each side filters independently; the upper bound is `<` the *next* day |
| Sliding Date Range | a slider expression (`Last\|7\|Day\|\|`) | `'Global' \| PageParameter:'key','RawValue' \| DateRangeFromSlidingFormat`, then `.StartDate` / `.EndDate` |
| Multi-select pickers (accounts, groups, …) | comma-delimited **Guids** | Split, then keep only tokens matching a Guid `RegExMatch`, then re-join — see below |
| Boolean / toggle | `True` / `False` | `\| AsBoolean` |
| Free text | anything | No coercing filter exists. Either compare it against an Id instead, or sanitize explicitly before it can reach SQL |

The `'RawValue'` second argument to `PageParameter` returns the stored value unformatted; it is what a Sliding Date Range and Guid lists need.

### Sanitizing a Guid list

A multi-select filter delivers Guids as free text. Keep only the tokens that *are* Guids:

```
{% capture guidExpression %}^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}${% endcapture %}
{% assign input_AccountGuids = 'Global' | PageParameter:'Accounts','RawValue' %}
{% if input_AccountGuids != empty and input_AccountGuids != null %}
    {% assign array_Tokens = input_AccountGuids | Split:',',false %}
    {%- capture var_CleanGuids -%}
    {%- for var_Token in array_Tokens -%}
        {%- assign var_IsGuid = var_Token | RegExMatch:guidExpression -%}
        {%- if var_IsGuid == true -%}{{ var_Token }}{%- unless forloop.last -%},{%- endunless -%}{%- endif -%}
    {%- endfor -%}
    {%- endcapture -%}
{% endif %}
```

Then `DECLARE @str_AccountGuids varchar(3000) = '{{ var_CleanGuids }}';` and split it in SQL. (Whitespace control inside this capture is the point: the value is a SQL literal.)

## Keep Query Parameters empty

The block's own **Query Parameters** setting (`param=value;…`) is Rock's alternative route for the same values. When the Lava layer reads the parameters and writes coerced literals, leave the setting **empty** — otherwise the two routes disagree about what an absent parameter means, and only the Lava route runs the coercion guard.

## Driving a re-render from a block of your own

The PageParameterFilter block is not required. The Obsidian Dynamic Data block subscribes to `PageMessages.QueryStringChanged` on Obsidian's browser bus and, on that message, calls `GetDynamicData` with the message's `URLSearchParams` as page-parameter overrides — so `'Global' | PageParameter` in the query sees the new values with no navigation. A filter row you render yourself (a Lava Application Content block, an HTML Content block) can publish that message after `history.pushState`. The snippet, the merge semantics of overrides (they **merge onto** the original page load's parameters; send a key empty to clear it), and the fallbacks for Back/Forward and a missing module are in `DynamicData-With-Htmx.md` → "Driving the soft path from your own block".

Two simpler alternatives when interactivity is not needed:

- **Self-written navigation** — the template renders its own links as relative query strings (see `Current-Url-Is-BlockActions.md`). A full page load per click, no second block.
- **A PageParameterFilter with Legacy Reload on** — the stock experience, one page load per Apply.
