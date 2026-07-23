# Question List

**Plugin**: BEMA Services — Room Management 2.0 (v2.6.5.16)
**Source file**: `RoomManagement (plugin package)/RoomManagement/QuestionList.ascx.cs`
**Rock Category**: BEMA Services > Room Management

## Purpose

Secondary block (implements `ISecondaryBlock`) that sits on either a [Resource Detail](ResourceDetail.md) page **or** a Location Detail page. Lets administrators add / edit / reorder / delete the custom Questions that staff are asked whenever that Resource or Location is added to a reservation. Also supports **Copy Questions From…** — clone an entire Question set from another Resource or Location in one click.

A "Question" is a thin `ReservationQuestion` row that points at a core Rock `Attribute`. When a reservation adds the Resource/Location, Rock's EntityType attribute machinery auto-exposes all the Attribute rows pointed at by those `ReservationQuestion` records.

## Block Attributes

*(None.)*

## Page Parameters

| Parameter | Use |
|---|---|
| `ResourceId` | Integer. If present & non-zero, questions belong to this [`Resource`](../sql-tables/Resource-and-Layout.md#resource). |
| `LocationId` | Integer. If present & non-zero, questions belong to this [`Location`](../../../../rock-sql-schema/references/database-structure-tables.md#location). |

The block precedence is `ResourceId` first, then `LocationId` — if both are supplied, `ResourceId` wins and `LocationId` is ignored. If neither is set, the grid renders empty.

## Data Flow

### Reads

- [`Question`](../sql-tables/Reservation-Questions.md#question) — via `ReservationQuestionService.Queryable()` filtered by whichever of `ResourceId`/`LocationId` is set.
- The linked `Attribute` (core Rock) is loaded with each question (used for Order, Name, FieldType columns in the grid).
- For the **Copy From** picker: `ResourceService.Queryable()` for all other resources, grouped by Campus name.

### Writes

On **Save** (modal Question editor) — writes to [`Question`](../sql-tables/Reservation-Questions.md#question) and to core `Attribute`:

| ReservationQuestion field | Value |
|---|---|
| `ResourceId` OR `LocationId` | page param |
| `AttributeId` | Id of the Attribute row saved in the same transaction |

| Attribute field | Value |
|---|---|
| `EntityTypeId` | `RESERVATION_RESOURCE` or `RESERVATION_LOCATION` (from plugin's `SystemGuid.EntityType`) |
| `Key` | Auto-generated: `Q{Order}_ResourceId{Id}` or `Q{Order}_LocationId{Id}`; uniqueness enforced by suffixing a counter |
| `AbbreviatedName` | Derived from Name if blank (truncated to 100 chars) |
| *(other Attribute props)* | Via `AttributeEditor.GetAttributeProperties(attribute)` |

On **Delete** — deletes the `ReservationQuestion` row and also deletes its linked core `Attribute` row.

On **Reorder** (grid drag-and-drop) — calls `AttributeService.Reorder(...)` to re-number the `Attribute.Order` column, then saves.

On **Copy Questions From** — clones the source `ReservationQuestion` + `Attribute` + every `AttributeQualifier` child row, re-keys the attribute for this owner, and inserts. Reassigns `CreatedByPersonAliasId` / `ModifiedByPersonAliasId` to the current user.

### Copy flow details

```
source ReservationQuestion
    └─ source Attribute
        └─ source AttributeQualifiers[]

→ cloned ReservationQuestion (new Guid, Id=0, FK switched to this owner)
    └─ cloned Attribute (new Guid, Id=0, new Key, new EntityTypeId)
        └─ cloned AttributeQualifiers[] (new Guid, Id=0 each)
```

Key collisions are handled by appending an integer suffix: `Q5_ResourceId12`, `Q5_ResourceId121`, `Q5_ResourceId122`, etc.

## Linked Pages

*(None — editing is in-modal.)*

## Notable Behaviors

- **Cache invalidation**: `EntityTypeAttributesCache.Clear()` is called after save and after bulk-copy — otherwise new questions would not surface on existing reservation forms.
- **Security field**: the grid's built-in Security column targets `EntityTypeCache.Get(typeof(Rock.Model.Attribute)).Id`, i.e., clicking Security on a row opens the standard Rock attribute-security dialog for that Question's underlying Attribute.
- **`ISecondaryBlock`** — implements `SetVisible(bool)`, so the Resource/Location detail block can hide Questions when the parent is in Add mode (no parent Id yet).
- **Reserved key names**: when editing, every *other* Question's Attribute Key is added to the editor's reserved list so the user cannot pick a duplicate Key. `IsKeyEditable = false` — the key is always auto-generated, never hand-edited.
- **Copy source picker** is grouped by Campus name (HTML `optgroup`). Resources without a Campus name show under the blank-string group.
- **Two-writer race**: `CopyQuestionAttributes` calls `rockContext.SaveChanges()` twice per cloned question (once to get the new Attribute.Id, then again to save the Question pointing at it). If an exception fires mid-loop, partial copies will persist.
- **Field type hint**: the commented-out block at the bottom of `ShowEdit` shows the author originally intended to restrict Question FieldTypes to Text, Memo, Date, Single-Select. That restriction is **not currently enforced** — every Field Type is allowed.
