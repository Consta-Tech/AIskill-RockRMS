---
name: format-tsql
description: Format a T-SQL query according to house style. Use for formatting, cleaning up, or restyling any T-SQL or Rock RMS SQL query.
allowed-tools: Read Write
---

Format the following T-SQL query according to the style rules below. Preserve all logic exactly — only formatting changes, never rewrite or optimize the query. Do not add or remove any columns, conditions, or joins.

## Query to format

$ARGUMENTS

## Style Rules

### Keywords
- All SQL keywords in UPPERCASE (SELECT, FROM, WHERE, JOIN, ON, AND, OR, INSERT, UPDATE, DECLARE, CAST, etc.)
- Exception: data types are always lowercase (int, bit, varchar, nvarchar, char, datetime, decimal, float, uniqueidentifier, etc.)

### Indentation
- 4 spaces per indent level
- Clause keywords (SELECT, FROM, WHERE, GROUP BY, ORDER BY, HAVING) start at column 0
- Continuation of a clause is indented 4 spaces

### SELECT lists and column lists (SELECT, GROUP BY, ORDER BY, etc.)
- Each column on its own line
- Leading comma style, but aligned so the table alias (not the comma) is the anchor column:
  - First column: 4 spaces of indent, no comma
  - Subsequent columns: 2 spaces, comma, 1 space (so the alias/column content aligns with the first row)
- Example:
  ```sql
  SELECT
      g.[Id]
    , g.[Name]
    , g.[Description]
  FROM
      [Group] g
  ```

### Aliases
- Every table must have an alias, even when there are no JOINs
- Always use the AS keyword for column aliases
- Column aliases use double-quotes: `g.[ColumnName] AS "AliasName"`
- Column aliasing is optional — only alias columns when it aids clarity or is already present in the original query
- Table aliases use no quotes and no AS keyword

### WHERE conditions
- AND / OR at the start of each new line
- Example:
  ```sql
  WHERE
      g.[IsActive] = 1
      AND g.[GroupTypeId] = 12
      AND g.[Name] IS NOT NULL
  ```

### JOINs
- JOIN type and table on one line, ON condition on the same line
- Do not filter inline with JOINs — conditions that filter rows belong in the WHERE clause, not the ON clause
- Exception: a condition may remain in the ON clause if it is necessary to guarantee the correct cardinality of the join
- When a join requires only one AND for cardinality, keep everything on the same line:
  ```sql
  LEFT JOIN [GroupTypeRole] gtr ON gtr.[Id] = gm.[GroupRoleId] AND gtr.[GroupTypeId] = g.[GroupTypeId]
  ```
- When a join requires more than one AND for cardinality, put each condition on its own line, indented under the JOIN:
  ```sql
  LEFT JOIN [GroupTypeRole] gtr ON gtr.[Id] = gm.[GroupRoleId]
      AND gtr.[GroupTypeId] = g.[GroupTypeId]
      AND gtr.[IsLeader] = gm.[IsLeader]
  ```
- Move filter conditions to the WHERE clause:
  ```sql
  -- Wrong: LEFT JOIN [Person] p ON p.[Id] = gm.[PersonId] AND p.[IsActive] = 1
  -- Right: Move p.[IsActive] = 1 to the WHERE clause instead
  ```

### Functions & Expressions
- Prefer CONCAT() over the + operator for string concatenation
- Only use + for concatenation if it meaningfully improves readability in a specific expression

### Subqueries and query organization — in order of preference
1. Table variables (preferred)
2. Subqueries (acceptable)
3. CTEs (last resort — only keep if already present and restructuring would change behavior)

If CTEs are present, give each CTE its own clearly separated line block.

### Column and table references
- Always wrap column and table names in square brackets: `[ColumnName]`, `[TableName]`
- Always prefix columns with the table alias: `g.[ColumnName]`

**General**
- Preserve all logic exactly — only formatting changes, never rewrite or optimize the query
- Do not add or remove any columns, conditions, or joins
- Do not omit any semicolons, even when optional
- End the query with a semicolon on its own line

Return only the formatted query with no explanation unless the user asks for one.
