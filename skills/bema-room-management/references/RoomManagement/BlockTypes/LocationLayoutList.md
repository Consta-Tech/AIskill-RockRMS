# Location Layout List

> **Provenance tier:** `traced` — read from source or official documentation and cited (Rock v18.2.4). Catalogued in the plugin's knowledge manifest; `rockrms-knowledge-current` lists every entry.



**Plugin**: BEMA Services — Room Management 2.0 (v2.6.5.16)
**Source file**: `RoomManagement (plugin package)/RoomManagement/LocationLayoutList.ascx.cs`
**Rock Category**: BEMA Services > Room Management

## Purpose

Secondary block (implements `ISecondaryBlock`) intended to sit on a Location Detail page. Administrators use it to add, edit, reorder, and delete the layout presets (`LocationLayout` rows) belonging to one Location (e.g., "Theater / 200 chairs", "Rounds / 120 people").

## Block Attributes

| Attribute (Display Name) | Type | Default | Key |
|---|---|---|---|
| Layout Image Height | IntegerField | `150` | `LayoutImageHeight` |

Controls the `<img>` tag height for layout photos rendered in the grid's "LayoutPhoto" column.

## Page Parameters

| Parameter | Use |
|---|---|
| `LocationId` | Integer. Which Location's layouts to display. `0` or missing → empty list (block shows no rows). |

## Data Flow

### Reads

- [`LocationLayout`](../sql-tables/Resource-and-Layout.md#locationlayout) — `LocationLayoutService.Queryable().Where(l => l.LocationId == LocationId)`.

### Writes

On **Save** (modal form): writes to [`LocationLayout`](../sql-tables/Resource-and-Layout.md#locationlayout):

| Field | Source control |
|---|---|
| `LocationId` | page param `LocationId` (new rows only) |
| `Name` | `tbName` |
| `Description` | `tbDescription` |
| `IsActive` | `cbIsActive` |
| `IsDefault` | `cbIsDefault` |
| `LayoutPhotoId` | `iuPhoto` |

Also writes to **`BinaryFile`** (core Rock): previous photo (if replaced) is flagged `IsTemporary = true`; new photo is flagged `IsTemporary = false`.

On **Delete**: finds all [`ReservationLocation`](../sql-tables/Reservation-and-Type.md#reservationlocation) rows whose `LocationLayoutId` matches the deleted layout and **clears their FK to null** before deleting the layout. This is the plugin's "orphan protection" — reservations that referenced this layout lose the layout selection but the reservations themselves survive.

All writes use `RockContext.WrapTransaction(...)`.

## Linked Pages

*(None — editing happens in a modal on the same page.)*

## Notable Behaviors

- **"At most one default" enforcement is done here in code, not at the DB level.** When the user saves a layout with `IsDefault = true`, the block loads every other `LocationLayout` for the same `LocationId`, sets their `IsDefault = false`, and then saves. Two layouts can still end up both `IsDefault = true` if rows are edited concurrently outside this block or written directly to the DB.
- **`ISecondaryBlock`** — implements `SetVisible(bool)`. Host blocks (such as a Location Detail block) can call this to hide the layout grid when they are in a mode where secondary content should be invisible.
- The grid allows sort/reorder via `rGrid.GridRebind`, but there is no explicit custom ordering column on `LocationLayout` — display order is whatever `LocationLayoutService.Queryable()` returns (effectively Id order).
- Layout photo thumbnail URL: `/GetImage.ashx?id={LayoutPhotoId}`, with the height attribute pulled from the block attribute.
