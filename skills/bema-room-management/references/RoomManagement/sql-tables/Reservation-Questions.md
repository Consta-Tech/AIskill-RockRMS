# Reservation Questions

Ad-hoc questions that are appended to a reservation when a specific **Resource** or **Location** is chosen. Each "question" is backed by a Rock Attribute; this table is the mapping between that Attribute and a Resource/Location.

> **Naming caveat.** The C# model class is `ReservationQuestion`, but the SQL table is just `_com_bemaservices_RoomManagement_Question`. Grep the plugin source for either name.

---

## Question

*(C# class: `ReservationQuestion`)*

```sql
CREATE TABLE [dbo].[_com_bemaservices_RoomManagement_Question](
    [Id] [int] IDENTITY(1,1) NOT NULL,
    [LocationId] [int] NULL,
    [ResourceId] [int] NULL,
    [AttributeId] [int] NOT NULL,
    [Guid] [uniqueidentifier] NOT NULL,
    [CreatedDateTime] [datetime] NULL,
    [ModifiedDateTime] [datetime] NULL,
    [CreatedByPersonAliasId] [int] NULL,
    [ModifiedByPersonAliasId] [int] NULL,
    [ForeignKey] [nvarchar](50) NULL,
    [ForeignGuid] [uniqueidentifier] NULL,
    [ForeignId] [int] NULL
) ON [PRIMARY]
;

ALTER TABLE [dbo].[_com_bemaservices_RoomManagement_Question]
    ADD CONSTRAINT [PK__com_bemaservices_RoomManagement_Question] PRIMARY KEY CLUSTERED ([Id] ASC)
;
```

### Columns

| Column | Type | Notes |
|---|---|---|
| `Id` | int (PK, identity) | Primary key. |
| `LocationId` | int (FK, NULL) | FK → [Location](../../../../rock-sql-schema/references/database-structure-tables.md#location). Set when the question is attached to a Location. |
| `ResourceId` | int (FK, NULL) | FK → [Resource](Resource-and-Layout.md#resource). Set when the question is attached to a Resource. |
| `AttributeId` | int (FK, NOT NULL) | FK → [Attribute](../../../../rock-sql-schema/references/Attribute-and-Value.md#attribute). The Attribute that defines the question's field type, name, and qualifiers. |
| `Guid`, audit columns | — | Standard Rock. |

### Foreign keys

| Column | References |
|---|---|
| `LocationId` | [Location](../../../../rock-sql-schema/references/database-structure-tables.md#location) |
| `ResourceId` | [Resource](Resource-and-Layout.md#resource) |
| `AttributeId` | [Attribute](../../../../rock-sql-schema/references/Attribute-and-Value.md#attribute) |
| `CreatedByPersonAliasId`, `ModifiedByPersonAliasId` | [PersonAlias](../../../../rock-sql-schema/references/Person-and-PersonAlias.md#personalias) |

### Invariant

A Question hangs off **either** a Resource **or** a Location — never both, and not neither. The C# code in `QuestionList.ascx.cs` filters the grid on whichever `PageParameter` is present (`ResourceId` xor `LocationId`). There is no DB check constraint enforcing this; the plugin enforces it at the application layer.

### How the answer is stored

When a user fills in a question on a reservation form, the answer goes into the standard `[AttributeValue]` table:

- `AttributeValue.AttributeId` = this row's `AttributeId`
- `AttributeValue.EntityId` = the `Reservation.Id` (or `ReservationLocation.Id` / `ReservationResource.Id`, depending on scope)

See [Attribute-and-Value.md](../../../../rock-sql-schema/references/Attribute-and-Value.md) for the underlying Rock schema.
