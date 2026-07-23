# Property vs Attribute in Rock RMS

Every Rock entity — Person, Group, GroupMember, Campus, etc. — has two kinds of data fields: **Properties** and **Attributes**. They behave differently in SQL, Lava, and the Rock UI, so understanding the distinction is foundational to working with Rock's data model.


## The Core Idea

**Properties** are fields defined on the entity's C# model class. They are part of Rock's core codebase and ship with Rock itself (or are added via core migrations). Most properties correspond directly to a column on the entity's database table — `Person.NickName`, `Group.Name`, `Group.IsActive` — but some are computed or derived in C# code without a backing column (see [Properties Are Not Strictly 1:1 with Table Columns](#properties-are-not-strictly-11-with-table-columns) below).

**Attributes** are custom fields defined through Rock's admin UI (or via code/migrations). They are stored in the generic `[Attribute]` / `[AttributeValue]` tables using an Entity-Attribute-Value (EAV) pattern. When an admin adds an "Employer" field to Person, or a "Start Date" field to a specific Group Type, those are attributes.

| | Property | Attribute |
|---|---|---|
| **Defined by** | Rock's C# entity model (core schema) | Admin UI or plugin migrations |
| **Storage** | Usually a column on the entity's own table; some are computed in C# | Row in `[AttributeValue]`, linked back to the entity by `EntityId` |
| **Data type** | SQL column type (`int`, `nvarchar`, `bit`, etc.) | Always `nvarchar(max)` in `[AttributeValue].[Value]`; interpreted by the FieldType |
| **Schema changes** | Requires a code migration to add/remove | No schema changes — just rows in `[Attribute]` and `[AttributeValue]` |
| **Rock Admin UI** | Not directly visible as "fields" in the admin | Visible and editable in Entity Attributes, Group Type settings, etc. |


### Properties Are Not Strictly 1:1 with Table Columns

For the vast majority of day-to-day Rock development, you can safely think of properties as table columns. But there is a subtle distinction worth knowing:

- **Every SQL table column** on the entity's table **is** available as a property on the C# model. The column is the backing store for that property.
- **Not every property** on the C# model **has** a corresponding SQL table column. Some properties are computed or derived in code.

For example, the `[Person]` table has columns for `[NickName]`, `[LastName]`, `[BirthDay]`, `[BirthMonth]`, and `[BirthYear]` — but the Person entity also exposes properties like `FullName` (computed from name fields), `PhotoUrl` (derived from the `PhotoId` foreign key), and `GradeOffset` (derived from graduation year). These computed properties are available in Lava via dot notation (`{{ Person.FullName }}`, `{{ Person.PhotoUrl }}`), but you will not find a `[FullName]`, `[PhotoUrl]`, or `[GradeOffset]` column in the `[Person]` table, and they are not directly usable in SQL.

**When does this matter?**
- When writing SQL and expecting every Lava-accessible property to have a column — it might not.
- When using `expression:` in entity commands — it operates against C# model properties, which includes computed ones that don't exist in SQL.
- When debugging why a property visible in Lava doesn't appear in the table schema.

**The authoritative reference** for what properties an entity has is the **Model Map**, which ships with every Rock instance at Settings > Power Tools > Model Map (default route: `/admin/power-tools/model-map`). The Model Map shows all properties on each entity's C# model — including computed ones that have no backing column.


## Why It Matters

The distinction affects almost everything a Rock developer does:

1. **How you read data** — Properties use dot notation; attributes use the `| Attribute:` filter.
2. **How you write data** — Properties use `[[ property ]]`; attributes use `[[ attribute ]]`.
3. **How you query data** — Properties are direct column references in SQL; attributes require a JOIN to `[AttributeValue]`.
4. **How you filter data** — Some Lava filtering methods work with both; others only support properties.
5. **Performance** — Property lookups are column reads; attribute lookups involve an EAV JOIN pattern.


## Examples Using Real Rock Fields

To ground the distinction, here are real fields on the Person entity:

| Field | Type | Why |
|---|---|---|
| `NickName` | Property (column) | Column on `[Person]` — ships with Rock |
| `LastName` | Property (column) | Column on `[Person]` — ships with Rock |
| `Email` | Property (column) | Column on `[Person]` — ships with Rock |
| `Gender` | Property (column) | Column on `[Person]` — ships with Rock |
| `FullName` | Property (computed) | Derived in C# from name fields — no `[FullName]` column exists |
| `PhotoUrl` | Property (computed) | Derived in C# from `PhotoId` — no `[PhotoUrl]` column exists |
| `GradeOffset` | Property (computed) | Derived in C# from `GraduationYear` — no `[GradeOffset]` column exists |
| `Employer` | Attribute | Custom field defined in Rock admin — stored in `[AttributeValue]` |
| `BaptismDate` | Attribute | Custom field — not a column on `[Person]` |
| `FirstVisit` | Attribute | Custom field — stored as a string in `[AttributeValue]` |

And for Group:

| Field | Type | Why |
|---|---|---|
| `Name` | Property | Column on `[Group]` |
| `IsActive` | Property | Column on `[Group]` |
| `IsArchived` | Property | Column on `[Group]` |
| *(custom fields per GroupType)* | Attribute | Scoped by `EntityTypeQualifierColumn = 'GroupTypeId'` |


## Context-by-Context Reference


### Reading in Lava

**Properties** are accessed with dot notation:
```
{{ Person.NickName }}
{{ Group.Name }}
{{ Group.IsActive }}
```

**Attributes** are accessed with the `| Attribute:` filter:
```
{{ Person | Attribute:'Employer' }}
{{ Person | Attribute:'FirstVisit' }}
{{ Group | Attribute:'StartDate' }}
```

The `| Attribute:` filter accepts an optional second parameter that controls the return format:
- `{{ entity | Attribute:'Key' }}` — Returns the formatted display value (default).
- `{{ entity | Attribute:'Key','RawValue' }}` — Returns the raw stored string (useful for GUIDs, IDs, date values that need further processing).
- `{{ entity | Attribute:'Key','Object' }}` — Returns the resolved entity object (e.g., a Campus object from a Campus attribute).

> See [Rock Community - Attribute Filters](https://community.rockrms.com/lava/filters/attribute-filters) for full documentation.


### Writing in Lava (Modify Entity Command)

Properties and attributes have separate declaration syntax within `{% modifyentity %}`:

```
{% modifyperson id:'{{ var_PersonId }}' return:'modify_Person' %}
    [[ property name:'NickName' ]]{{ var_NewNickName }}[[ endproperty ]]
    [[ attribute key:'Employer' ]]{{ var_NewEmployer }}[[ endattribute ]]
{% endmodifyperson %}
```

Both can appear in the same block, but the `[[ property ]]` and `[[ attribute ]]` tags use different identifiers:
- Properties use `name:` — the C# property name (case-sensitive).
- Attributes use `key:` — the attribute key defined in Rock admin.

> For defensive rules around `{% modifyentity %}`, see `skills/language-lava/references/Lava-Language.md` > "Modify Entity Command".


### Filtering in Lava Entity Commands

The `where:` parameter works with **both** properties and attributes transparently:
```
{% person where:'LastName == "Decker" && Employer == "Rock Solid Church"' %}
```
Rock resolves whether each key is a property or attribute behind the scenes.

The `expression:` parameter supports **only** properties (including navigation properties), **not** attributes:
```
{% person expression:'PhoneNumbers.Count() > 1' %}
```

> See `skills/language-lava/references/Lava-Language.md` > "Entity Commands" for the full parameter reference.


### Querying in SQL

**Properties** are straightforward column references:
```sql
SELECT
    p.[NickName]
  , p.[LastName]
  , p.[Email]
FROM
    [Person] p
WHERE
    p.[Id] = @PersonId
;
```

**Attributes** require a JOIN through the EAV tables:
```sql
SELECT
    p.[NickName]
  , p.[LastName]
  , av.[Value] AS "Employer"
FROM
    [Person] p
    LEFT JOIN [AttributeValue] av ON av.[EntityId] = p.[Id] AND av.[AttributeId] = {AttributeId}
WHERE
    p.[Id] = @PersonId
;
```

> For the full table schemas, see `skills/rock-sql-schema/references/Attribute-and-Value.md`.


## Quick-Reference Decision Table

| I want to... | Property | Attribute |
|---|---|---|
| **Read in Lava** | `{{ entity.PropertyName }}` | `{{ entity \| Attribute:'Key' }}` |
| **Read raw value in Lava** | *(same as above)* | `{{ entity \| Attribute:'Key','RawValue' }}` |
| **Write in Lava** | `[[ property name:'Name' ]]` | `[[ attribute key:'Key' ]]` |
| **Filter with `where:`** | Yes | Yes |
| **Filter with `expression:`** | Yes | No |
| **Query in SQL** | `t.[ColumnName]` | JOIN `[AttributeValue]` on `EntityId` + `AttributeId` |
| **Know what's available** | Model Map (`/admin/power-tools/model-map`) for all properties; table CREATE script for column-backed ones | Check Rock Admin > Entity Attributes (or query `[Attribute]` table) |
