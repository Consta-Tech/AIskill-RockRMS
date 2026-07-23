# Some Formatting Standards
With any programming language that we use, indentation is 4-spaces.


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