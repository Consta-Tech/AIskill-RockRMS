# Resource Detail

> **Provenance tier:** `traced` — read from source or official documentation and cited (Rock v18.2.4). Catalogued in the plugin's knowledge manifest; `/rockrms:knowledge-current` lists every entry.



**Plugin**: BEMA Services — Room Management 2.0 (v2.6.5.16)
**Source file**: `RoomManagement (plugin package)/RoomManagement/ResourceDetail.ascx.cs`
**Rock Category**: BEMA Services > Room Management

## Purpose

Add / edit / delete a single [`Resource`](../sql-tables/Resource-and-Layout.md#resource) row. Reached by clicking a row in [Resource List](ResourceList.md) (or the Add button there).

## Block Attributes

*(None.)*

## Page Parameters

| Parameter | Use |
|---|---|
| `ResourceId` | Integer. `0` or missing = Add mode; otherwise the Resource to edit. |

## Data Flow

### Reads

- [`Resource`](../sql-tables/Resource-and-Layout.md#resource) — loaded by `ResourceService.Get(resourceId)` when editing.
- [`Campus`](../../../../rock-sql-schema/references/Campus.md) — populates the Campus dropdown (`CampusCache.All()`).

### Writes

On **Save** / **Save Then Add**, writes to [`Resource`](../sql-tables/Resource-and-Layout.md#resource):

| Field | Source control |
|---|---|
| `Name` | `tbName` |
| `IsActive` | `cbIsActive` |
| `CategoryId` | `cpCategory` (category picker) |
| `CampusId` | `ddlCampus` |
| `LocationId` | `lpLocationPicker` (null if cleared) |
| `Quantity` | `nbQuantity` |
| `Note` | `tbNote` |
| `ApprovalGroupId` | `gpApprovalGroup` (group picker) |
| `PhotoId` | `fuPhoto` (binary file upload) |

Also writes to **`BinaryFile`** (core Rock):
- Old photo (if replaced) is marked `IsTemporary = true` so Rock's cleanup job can reclaim it.
- New photo is marked `IsTemporary = false` once the resource save succeeds.

On **Delete** (`btnDelete_Click`), calls `ResourceService.CanDelete()` first; if it returns false, shows a modal with the reason and does nothing. Otherwise deletes the row.

All writes are wrapped in a single `RockContext.WrapTransaction(...)` so the resource + photo-flag updates commit atomically.

## Linked Pages

*(None configured on this block — it uses `NavigateToParentPage()` after save/cancel/delete, so the parent page handles the return URL.)*

## Notable Behaviors

- **Save Then Add** (`btnSaveThenAdd`) is visible only in Add mode. It saves and then re-opens the form in Add mode so the user can chain-add multiple resources. `resetCampus: false` is passed so the Campus dropdown retains its options list (but the selected value clears naturally because `resource.Id = 0`).
- The block calls `HideSecondaryBlocks(false)` when editing an existing resource (and `true` when in Add mode). This is how the sister [`QuestionList`](QuestionList.md) block on the same page gets hidden for new-resource adds — `ResourceId` must exist before questions can be attached.
- Breadcrumbs show `resource.Name` or "New Resource".
- Validation is standard `Page.IsValid` — no custom validators. The Category picker returns 0 for "unselected" and that 0 is written to `CategoryId`.
