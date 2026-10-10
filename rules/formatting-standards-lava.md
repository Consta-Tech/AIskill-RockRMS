---
trigger: always_on
---
# Formatting Standards — Lava

> **Provenance tier:** `traced` — read from source or official documentation and cited (house convention, no Rock version). Catalogued in the plugin's knowledge manifest; `rockrms-knowledge-current` lists every entry.


Part of the formatting-standards house rules; `formatting-standards.md` holds what applies to every language.

## 2. Lava
Mostly following [Rock Community's Lava Style Guide](https://community.rockrms.com/lava/style), except for a few changes and/or considerations:
<details open><summary>Prepend your Lava variables with a three-character abbreviation of its expected data type</summary>
i want to teach my volunteers that "variables defined by Tim" will be prepended, whereas "variables defined by Spark" will not.

Example:
```
    {% assign var_PersonId = CurrentPerson.Id %}
    {% assign obj_Person = var_PersonId | PersonById %}
```
In the example above, i could teach them that `CurrentPerson` has been defined by Spark, whereas `var_PersonId` and `obj_Person` are variables that i defined for this piece of code.

Most of the times, i just prepend with `var_` because i'm lazy. Sometimes i prepend with the data type in hopes that it'll help the future reader.

The one prefix that is **not** a data type is `input_`. It marks *provenance*: this value originated as input from the EndUser who is using this Page / Block / Application — most often through a PageParameterFilter Block. Because it describes where the value came from rather than what it is, `input_DateRange` may well hold an array while `input_CampusId` holds an integer.

```
    {% assign input_CampusId = 'Global' | PageParameter:'c1' | AsInteger %}
    {% assign input_DateRange = 'Global' | PageParameter:'daterange' | Split:',',false,2 %}
```
</details>

<details><summary>Coerce every <code>input_</code> value before it can reach SQL</summary>

An `input_` value arrives from the URL. Anyone can type anything into a URL. When that value is later interpolated into a `{% sql %}` block or a Dynamic Data query, a coercing filter is the **only** thing standing between a PageParameter and the database — Lava has no parameterized-query equivalent for values spliced into the query text.

The rule is that **every `input_` value passes through a coercing filter before it reaches the query text.** Where that filter sits depends on the type:

- **Numbers and booleans coerce at the assignment** — `AsInteger`, `AsDecimal`, `AsBoolean`. Coerce once, at the top, and the rest of the file can trust the variable.
- **Dates coerce at the interpolation**, because `Date:'yyyy-MM-dd'` is doing double duty: it is both the coercion and the choice of SQL literal format, and the format you want depends on which bound you are writing.

✅ Yes:
```
{% assign input_CampusId = 'Global' | PageParameter:'c1' | AsInteger %}
{% assign input_DateRange = 'Global' | PageParameter:'daterange' | Split:',',false,2 %}
{% assign input_DateStart = input_DateRange[0] %}
...
    {% if input_CampusId and input_CampusId >= 1 %}AND att.[CampusId] = {{ input_CampusId }}{% endif %}
    {% if input_DateStart and input_DateStart != empty %}AND att.[StartDateTime] >= '{{ input_DateStart | Date:'yyyy-MM-dd' }}'{% endif %}
```
❌ No — the raw parameter reaches the query text unfiltered:
```
{% assign input_CampusId = 'Global' | PageParameter:'c1' %}
...
    AND att.[CampusId] = {{ input_CampusId }}
```

**Both halves of the `{% if %}` guard are load-bearing — do not simplify one away.** `AsInteger` returns `null` for anything non-numeric (verified: `'12abc'` and `'1;DROP TABLE'` both yield `null`, with no partial parse), and `null` is falsy — so `and input_CampusId` is what rejects garbage. But `AsInteger` *accepts negatives*, so `?c1=-5` yields `-5`, which is non-null and passes that half on its own; only `>= 1` rejects it. One half rejects non-numbers, the other rejects numbers that aren't plausible Ids. Full measurements in `docs/Lava-Language.md` > "`AsInteger` coercion and failure mode".

Match the filter to the type you intend: `AsInteger` for Ids and counts, `AsDecimal` for money, `Date:'...'` for dates, `AsBoolean` for flags. A free-text parameter that must reach SQL as a string has no coercing filter available — sanitize it explicitly (the Guid `RegExMatch` loop in `_code/Block-DynamicData/PageId_1213/BlockId_14121-Query.lava.sql` is the worked example), or find a way to compare it against an Id instead.
</details>

<details><summary><code>{% capture %}</code> is for multi-line values; build a one-line string with <code>| Append</code></summary>

A value that spans lines needs `{% capture %}`. A value that does not should be one `{% assign %}` with `| Append`, because `capture` preserves every space and newline between its tags — a one-line string written that way is one stray newline away from being wrong, and it costs three tags to do what one filter does.

✅ Yes:
```
{% assign var_MonthStartCandidate = input_Month | Append:'-01' %}
```
❌ No:
```
{% capture var_MonthStartCandidate %}{{ input_Month }}-01{% endcapture %}
```

Inline `capture` is permissible where `Append` has been tried and does not suffice. The worked example is the `{% capture url_* %}` link builders in `_code/Block-DynamicData/PageId_6219/BlockId_15286-FormattedOutput.lava`: each is a single line that switches on an `{% if %}` mid-string, which `Append` cannot express without splitting the assignment across several statements.
</details>

### Lava Tags and Commands
i haven't quite landed on a standard for indenting Tags (especially when mixed with HTML), so this is what i've got thus far:
<details open><summary>Unless the blank space affects the output, use blank spaces for indenting the content between the opening and closing Tags.</summary>

- Blank space does not affect `{% if %}{% endif %}`,
```
{% if var_PersonId != empty %}
    do the thing
{% else %}
    don't do the thing
{% endif %}
```
- but it affects `{% capture %}{% endcapture %}`
```
{% capture var_Something %}
capture this string right here
{% endcapture %}
```
</details>

<details open><summary>Guard with an early-out, not by wrapping the whole file in an <code>{% if %}</code></summary>

When a file renders nothing under some condition, say so at the top and stop. Do not enclose the entire body in `{% if %}...{% endif %}`.

✅ Yes:
```
{% if var_IsCampusView == false %}{% return %}{% endif %}

...the whole template, at the file's own indentation...
```
❌ No:
```
{% if var_IsCampusView %}

...400 lines, with the condition that governs them now off-screen...

{% endif %}
```

Wrapping is permissible where the early-out has been **tried in that context and proven not to work** — and when it is, the `{% if %}` carries an inline comment saying so:
```
{% if var_IsCampusView == false %} //- Need to use this pattern because Early-out with return doesnt work in this context
```
The fallback is fine. Arriving at it without testing is not, and a reader cannot tell the two apart unless the comment is there.

`{% return %}` is documented in `docs/Lava-Language.md` > "Return" as "Stops all Lava processing", and it is the established guard in several Dynamic Data query files — `PageId_1213/BlockId_14121-Query.lava.sql`, `PageId_5794/BlockId_14040-Query.lava.sql`, and `PageId_5855/BlockId_14212-Query.lava.sql` all open with one. So a context where it does not work is the exception, and the comment marking it is a real finding worth leaving behind. The known exception is `PageId_6219/BlockId_15330-Query.lava.sql`, measured 2026-SEP-20. Why it differs has not been pinned down; the likely reason is that its guarded branch still has to emit a `SELECT TOP (0)` for the Block to have any query text to run, which an early `{% return %}` would leave empty.
</details>

### HTML with Lava FOR loops
<details open><summary>When using <code>{% for %}</code> to create list items, follow this indentation pattern:</summary>

Notice there is no indentation between `{% for %}` and `<li>` because that would essentially be two indentations between `<ul>` and `<li>`
```html
<ul>
    {% for var_Group in array_Groups %}
    <li class="list-group-item">
        {{ var_Group.Name }}
    </li>
    {% endfor %}
</ul>
```
</details>
