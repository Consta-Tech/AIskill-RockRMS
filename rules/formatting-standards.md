# Some Formatting Standards

> **Provenance tier:** `traced` — read from source or official documentation and cited (house convention, no Rock version). Catalogued in the plugin's knowledge manifest; `/rockrms:knowledge-current` lists every entry.


With any programming language that we use, indentation is 4-spaces.

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


## 1. SQL
Mostly following [Rock Community's SQL Style Guide](https://community.rockrms.com/developer/sql-style-guide), except for a few changes and/or considerations:
<details open><summary>When listing Table Columns, align the Table Alias, not the comma</summary>

✅ Yes:
```sql
SELECT
    g.[Id]
  , g.[Name]
  , g.[Description]
  , g.[Guid]
FROM
    [Group] g
WHERE
    g.[Id] = 1
;
```
❌ No:
```sql
SELECT
    g.[Id]
    , g.[Name]
    , g.[Description]
    , g.[Guid]
FROM
    [Group] g
WHERE
    g.[Id] = 1
;

```
</details>

<details><summary>When concatenating, use <code>CONCAT()</code>, please do not use the <code>+</code> operator</summary>

✅ Yes:
```sql
SELECT
    g.[Id]
  , CONCAT(g.[Name], ' Group')
  , g.[Guid]
FROM
    [Group] g
WHERE
    g.[Id] = 1
;
```
❌ No:
```sql
SELECT
    g.[Id]
  , g.[Name] + ' Group'
  , g.[Guid]
FROM
    [Group] g
WHERE
    g.[Id] = 1
;
```
</details>

<details><summary>When aliasing Columns, use double-quotes rather than square brackets</summary>
(it helps my syntax-highlighting to be more readable on VSC and ADS)

✅ Yes:
```sql
SELECT
    p.[Id]
  , CONCAT(p.[NickName], ' ', p.[LastName]) AS "Person Name"
  , p.[AgeClassification]
FROM
    [Person] p
WHERE
    p.[Id] = 1
;
```
❌ No:
```sql
SELECT
    p.[Id]
  , CONCAT(p.[NickName], ' ', p.[LastName]) AS [Person Name]
  , p.[AgeClassification]
FROM
    [Person] p
WHERE
    p.[Id] = 1
;
```
</details>

<details><summary>Use Uppercase for all keywords except data-types.</summary>

✅ Yes:
```sql
DECLARE @input_ConnOppId int = 1;

SELECT
    co.[Id] AS "ConnOppId"
  , CAST(co.[IsActive] AS bit) AS "ConnOppIsActive"
FROM
    [ConnectionOpportunity] co
WHERE
    co.[Id] = @input_ConnOppId
;
```
❌ No:
```sql
DECLARE @input_ConnOppId INT = 1;

SELECT
    co.[Id] AS "ConnOppId"
  , CAST(co.[IsActive] AS BIT) AS "ConnOppIsActive"
FROM
    [ConnectionOpportunity] co
WHERE
    co.[Id] = @input_ConnOppId
;
```
The `table` in a table-type variable declaration counts as a data type, not a keyword:

✅ Yes:
```sql
DECLARE @FilteredRows table (
    [Id] int NOT NULL PRIMARY KEY
);
```
❌ No:
```sql
DECLARE @FilteredRows TABLE (
    [Id] int NOT NULL PRIMARY KEY
);
```
Constraint keywords inside the declaration (`NOT NULL`, `PRIMARY KEY`, `IDENTITY`) remain UPPERCASE.
</details>

<details><summary>When joining Tables, keep the <code>JOIN</code> and <code>ON</code> keywords in the same line</summary>

✅ Yes:
```sql
SELECT
    gm.[Id]
FROM
    [GroupMember] gm
    LEFT JOIN [Person] p ON p.[Id] = gm.[PersonId]
    LEFT JOIN [PersonAlias] pa ON pa.[Id] = gm.[CreatedByPersonAliasId]
WHERE
    gm.[GroupId] = 1
;
```
❌ No:
```sql
SELECT
    gm.[Id]
FROM
    [GroupMember] gm
    LEFT JOIN [Person] p
    ON p[Id] = gm.[PersonId]
    LEFT JOIN [PersonAlias] pa
    ON pa.[Id] = gm.[CreatedByPersonAliasId]
WHERE
    gm.[GroupId] = 1
;
```
❌ No:
```sql
SELECT
    gm.[Id]
FROM
    [GroupMember] gm
LEFT JOIN
    [Person] p
    ON p.[Id] = gm.[PersonId]
LEFT JOIN
    [PersonAlias] pa
    ON pa.[Id] = gm.[CreatedByPersonAliasId]
WHERE
    gm.[GroupId] = 1
;
```
</details>

<details><summary>On that same note, if the <code>JOIN</code> <code>ON</code> needs an <code>AND</code>, also keep that in the same line</summary>

✅ Yes:
```sql
SELECT
    gm.[Id]
FROM
    [GroupMember] gm
    LEFT JOIN [PersonAlias] pa1 ON pa1.[Id] = gm.[CreatedByPersonAliasId] AND pa1.[PersonId] = pa1.[AliasPersonId]
    LEFT JOIN [PersonAlias] pa2 ON pa2.[Id] = gm.[ModifiedByPersonAliasId] AND pa2.[PersonId] = pa2.[AliasPersonId]
WHERE
    gm.[GroupId] = 1
;
```
❌ No:
```sql
SELECT
    gm.[Id]
FROM
    [GroupMember] gm
    LEFT JOIN [PersonAlias] pa1 ON pa1.[Id] = gm.[CreatedByPersonAliasId]
    AND pa1.[PersonId] = pa1.[AliasPersonId]
    LEFT JOIN [PersonAlias] pa2 ON pa2.[Id] = gm.[ModifiedByPersonAliasId]
    AND pa2.[PersonId] = pa2.[AliasPersonId]
WHERE
    gm.[GroupId] = 1
;
```
</details>

<details><summary>Every Table gets an Alias, and every Column is Alias-qualified</summary>

This holds even when the statement touches only one table and there is nothing to disambiguate. The payoff is that a one-table query stays diff-friendly on the day someone adds a JOIN to it.

✅ Yes:
```sql
INSERT INTO @ParticipantGroupIds ([GroupId])
SELECT
    g.[Id]
FROM
    [Group] g
WHERE
    g.[GroupTypeId] = @GroupTypeId_VBS
;
```
❌ No:
```sql
INSERT INTO @ParticipantGroupIds ([GroupId])
SELECT
    [Id]
FROM
    [Group]
WHERE
    [GroupTypeId] = 221
;
```
</details>

<details><summary>Naming an Alias: initialism first, expand only when it clashes</summary>

The default is the initialism of the table name: `[GroupMember] gm`, `[GroupTypeRole] gtr`, `[PersonAlias] pa`, `[DataView] dv`. For a single-word table, that means the first letter: `[Group] g`, `[Person] p`.

Expand to the first three letters of each word when the initialism is already taken, is ambiguous within this file, or is simply unreadable: `[AttendanceOccurrence] attocc`, `[DefinedValue] defval`, `[CommunicationRecipient] comrec`.

Expansion is contagious within a file. If `[Streak]`, `[StreakType]`, `[Step]`, and `[StepType]` all appear in one query, `s` and `st` stop being readable and the whole family expands: `str`, `strtype`, `s`, `stype`.

The settled aliases are listed in the `rock-sql-schema` skill's `README.md` > "Canonical Table Aliases". That list is a reference, not a contract — it should cover roughly 90% of what you write, and the remaining 10% is the author's call. When you settle on an alias for a table that isn't listed there yet, add it.
</details>

<details><summary>Keep the <code>AND</code> on its own line — unless the filter is gated by Lava</summary>

A static predicate gets a bare `AND` on its own line, acting as a visual separator between filters.

✅ Yes:
```sql
WHERE
    g.[GroupTypeId] = @GroupTypeId_VBS
    AND
    g.[CreatedDateTime] >= @date_WindowStart
    AND
    g.[CreatedDateTime] < @date_WindowEnd
;
```
❌ No — two predicates sharing one line. A two-sided range written this way is exactly where an off-by-one boundary hides:
```sql
WHERE
    g.[GroupTypeId] = @GroupTypeId_VBS
    AND
    g.[CreatedDateTime] >= @date_WindowStart AND g.[CreatedDateTime] < @date_WindowEnd
;
```

The exception is a predicate gated by a Lava `{% if %}`. There, the `AND` belongs **inside** the tag, on the same line as the filter it governs — otherwise a bare `AND` is left stranded whenever the condition is false.

✅ Yes:
```sql
WHERE
    att.[DidAttend] = 1
    {% if input_CampusId and input_CampusId >= 1 %}AND att.[CampusId] = {{ input_CampusId }}{% endif %}
;
```
</details>

<details><summary>Date ranges are half-open</summary>

Write the lower bound as `>=` and the upper bound as `<` against the *next* day. Never close the upper bound.

✅ Yes:
```sql
WHERE
    att.[StartDateTime] >= @date_RangeStart
    AND
    att.[StartDateTime] < DATEADD(day, 1, @date_RangeEnd)
;
```
✅ Yes, the same idea when the bound arrives from Lava:
```
    {% if input_date2 and input_date2 != empty %}AND att.[StartDateTime] < '{{ input_date2 | DateAdd:1,'d' | Date:'yyyy-MM-dd' }}'{% endif %}
```
❌ No:
```sql
    AND att.[StartDateTime] <= '2026-08-18T23:59:59'   -- silently drops the last second of the range
    AND att.[StartDateTime] <= '2026-08-18'            -- silently drops the entire day
```

`datetime` carries roughly 3ms of precision, so a bound of `23:59:59` discards every row in the final second. And comparing a `datetime` column against a bare `'yyyy-MM-dd'` literal resolves that literal to midnight, which discards the whole day. Both failures are invisible — the query returns rows, just not all of them.
</details>

<details><summary>A hardcoded Id either gets hoisted, or gets a comment. Never neither.</summary>

**Hoist** to a commented `DECLARE` when the value is used more than once, or when it is a tunable. **Leave it inline** with a trailing `--` comment when it is used once and is structural.

The tie-break: *if you would ever want to change it without reading the query, hoist it.*

✅ Yes — a tunable, used as a pair:
```sql
DECLARE @date_WindowStart date = '2026-01-01'; -- The VBS season being reported on
DECLARE @date_WindowEnd   date = '2027-01-01'; -- Exclusive upper bound
```
✅ Yes — used once, structural:
```sql
WHERE
    com.[Status] = 3 --'0' is "Transient", '1' is "Draft", '2' is "PendingApproval", '3' is "Approved"
;
```
❌ No:
```sql
WHERE
    g.[GroupTypeId] = 221
;
```
</details>

<details><summary>Don't wrap a filtered Column in a function</summary>

✅ Yes:
```sql
WHERE
    g.[Name] = 'VBS Lite'
;
```
❌ No:
```sql
WHERE
    LTRIM(RTRIM(g.[Name])) = 'VBS Lite'
;
```

Wrapping the column makes the predicate non-sargable: SQL Server can no longer seek an index on that column and falls back to scanning. That is harmless on a lookup returning one row and expensive on a filter over a large table — and you rarely know which one you have written a year later.

Where trimming genuinely is needed, `TRIM()` says it in one call instead of two.
</details>

<details><summary>Aliasing Columns inside an <code>INSERT INTO ... SELECT</code></summary>

The column list on the `INSERT INTO ... ( ... )` line is what binds. Aliases inside the `SELECT` are discarded, so they exist purely to be read. Write one only where the alias is the clearest available name for the expression.

✅ Yes — the aggregates need a name, the plain columns already have one:
```sql
INSERT INTO @GroupedRows ([AttendeePersonId], [VBSCampusId], [AttendanceCount])
SELECT
    fil.[AttendeePersonId]
  , MAX(fil.[VBSCampusId]) AS "VBSCampusId"
  , COUNT(DISTINCT CAST(fil.[VBSAttendanceDateTime] AS date)) AS "AttendanceCount"
FROM
    @FilteredRows fil
GROUP BY
    fil.[AttendeePersonId]
;
```
❌ No — aliasing a column that already states its own name:
```sql
INSERT INTO @FilteredRows ([AttendanceId], [AttendeePersonId])
SELECT
    att.[Id] AS "AttendanceId"
  , attendee.[PersonId] AS "AttendeePersonId"
...
```

Column aliases in a **final** `SELECT` are a different matter entirely — those become the Grid's column headers and are always written.
</details>

<details><summary>A JOIN whose Alias is never referenced needs an inline comment</summary>

If an alias appears nowhere in the `SELECT`, `WHERE`, `GROUP BY`, or `ORDER BY`, then the JOIN is there for its cardinality effect alone. That is permissible, but it has to say so out loud — otherwise the next reader deletes it as dead weight and quietly changes the result set.

✅ Yes:
```sql
    -- This INNER JOIN is mainly to ensure I exclude rows where [LocationId] is NULL
    INNER JOIN [Location] loc ON loc.[Id] = attocc.[LocationId]
```
❌ No:
```sql
    INNER JOIN [Location] loc ON loc.[Id] = attocc.[LocationId]
```
</details>

### CTEs, Table Variables, and Temp Tables
When a query needs an intermediate result set, choose the tool in this order:
1. IF the query must recurse to identify ancestry, the default tool is a CTE. ELSE, proceed to #2.
    - Exception: when the hierarchy data can contain cycles (e.g. `GroupTypeAssociation` in check-in trees), a recursive CTE will exhaust MAXRECURSION. Use a visited-set WHILE loop over a table-type variable instead.
2. Default to a table-type variable that is declared and then populated with an `INSERT INTO`. Do not resort to Temp Tables unless there is a significant improvement in query duration.
3. IF there is a significant improvement between using a table-type variable and using a temp table, then it is permissible to use a temp table. However, it must be a local temp table (e.g. `#TempTable`), never a global temp table (e.g. `##TempTable`), and it must always be explicitly dropped within that same file.
4. Never use global temp tables.
5. Inline subqueries (scalar subqueries, `OUTER APPLY` / `CROSS APPLY` blocks, `IN (SELECT ...)` lists) are acceptable anywhere. They are expressions within a statement, not intermediate result sets, so the ordering above does not apply to them.

Non-recursive CTEs are not used — even for single-statement column layering (e.g. computing verdict columns, then a flag derived from them, then a ranking over the flag). Stage the rows in a table-type variable and compute the derived columns with a follow-up `UPDATE`.


### Staged Query Structure
Most reporting queries read best when they are staged: **filter** first into raw table-type variables, **group** second, and **format** last. The final `SELECT` should be a projection plus label lookups — no filtering, no aggregation left in it.

Two kinds of table-type variable show up, and they are labelled differently:

1. **Seed / lookup tables** hold an Id set that the pipeline filters against. They are *not* numbered. Each gets a one-line comment saying what it holds.
2. **Pipeline stages** are the filter → group → output progression. They *are* numbered, and the number carries **no denominator** — `Stage 1`, never `Stage 1 of 3` — so that adding a stage later doesn't mean editing every other comment.

Each stage's comment states the contract **for that file**. Do not inherit the sentence from a previous query: if `Stage 1` claims "all filtering happens here" while a business rule is actually applied in `Stage 2`, the comment is worse than no comment at all.

```sql
-- Holds the GroupIds being excluded by name
DECLARE @ExcludedGroupIds table (
    [GroupId] int PRIMARY KEY
);

-- Stage 1: @FilteredRows — one row per Attendance record. All filtering happens here.
DECLARE @FilteredRows table (
    [AttendanceId] int PRIMARY KEY
  , ...
);

-- Stage 2: @GroupedRows — collapse to one row per Person.
DECLARE @GroupedRows table (
    [AttendeePersonId] int
  , ...
);

-- Stage 3: Final output — projection and label lookups only.
SELECT
    ...
```

Name a table-type variable for the **role it plays in the pipeline** (`@FilteredRows`, `@GroupedRows`, `@ExcludedGroupIds`) rather than by a type prefix. An imperative name is fine wherever it reads better than the noun phrase would.

Any aggregate that silently picks a winner needs an inline comment naming the tie-break. `MAX()` over a value that is *supposed* to be constant per group is the common case — it is a real decision about what happens to the person who attended at two campuses, and it should not be left implicit.

<br>


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

**Both halves of the `{% if %}` guard are load-bearing — do not simplify one away.** `AsInteger` returns `null` for anything non-numeric (verified: `'12abc'` and `'1;DROP TABLE'` both yield `null`, with no partial parse), and `null` is falsy — so `and input_CampusId` is what rejects garbage. But `AsInteger` *accepts negatives*, so `?c1=-5` yields `-5`, which is non-null and passes that half on its own; only `>= 1` rejects it. One half rejects non-numbers, the other rejects numbers that aren't plausible Ids. Full measurements in the `language-lava` skill's `Lava-Language.md` > "`AsInteger` coercion and failure mode".

Match the filter to the type you intend: `AsInteger` for Ids and counts, `AsDecimal` for money, `Date:'...'` for dates, `AsBoolean` for flags. A free-text parameter that must reach SQL as a string has no coercing filter available — sanitize it explicitly (the Guid `RegExMatch` loop in the `surface-dynamicdata` skill's `PageParameterFilter-Wiring.md` is the worked example), or find a way to compare it against an Id instead.
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

Inline `capture` is permissible where `Append` has been tried and does not suffice. The worked example is the `{% capture url_* %}` link builders in the `surface-dynamicdata` skill's `Current-Url-Is-BlockActions.md`: each is a single line that switches on an `{% if %}` mid-string, which `Append` cannot express without splitting the assignment across several statements.
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

`{% return %}` is documented in the `language-lava` skill's `Lava-Language.md` > "Return" as "Stops all Lava processing", and it is the established guard at the top of Dynamic Data query files. So a context where it does not work is the exception, and the comment marking it is a real finding worth leaving behind. The known exception (measured 20-SEP-2026) is a Dynamic Data query whose guarded branch must still emit a `SELECT TOP (0)` so the block has query text to run — an early `{% return %}` would leave it empty. See the `surface-dynamicdata` skill, "Guarding".
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

<br>

## 3. Workflow Types
When configuring WorkflowTypes, i have some conventions i'd like to follow:
1. As a rule of thumb, most WorkflowTypes should have at least two Activities: one named "START" and one named "FINISH"
    - "START" is the Activity that sets any Attributes that are needed for the execution of this WorkflowType,
    - "FINISH" is the Activity that contains the 'Complete Workflow' Action.
    - Every other Activity can be named with normal capitalization, no need for all-caps.
1. Every Action should be named with a verb at the beginning. Example:
    - Activate Activity
    - Set Person Attributes
    - Complete Workflow
    - etc
1. When the name of an Action contains the name of an Activity, use square-brackets. Example:
    - Activate [FINISH]
    - Activate [Loop]
    - etc
1. When the name of an Action contains the Key (not Name) of a Workflow Attribute or Activity Attribute, use parentheses. Example:
    - Set (var_Person) from CurrentPerson
    - Send SMS to (var_Person) with (memo_Message)
    - Add Note to (obj_Person_Submitter)
    - etc
1. When naming a WorkflowType, it's (v1.0)
    - Modifying the WorkflowType doesn't necessarily increment the version label if it's a small change.
    - If it's a big change, it increments the version dot (from v1.0 to v1.1) and add a Note to the ChangeLog.
    - If it's a change so big that it cannot be done by modifying the WorkflowType, and rather we must create a new WorkflowType that replaces this one, then the new WorkflowType gets a new version number (v2.0) and the previous WorkflowType gets archived.
<br>
<hr>