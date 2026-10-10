# Reservation Type List

> **Provenance tier:** `traced` — read from source or official documentation and cited (Rock v18.2.4). Catalogued in the plugin's knowledge manifest; `rockrms-knowledge-current` lists every entry.



**Plugin**: BEMA Services — Room Management 2.0 (v2.6.5.16)
**Source file**: `RoomManagement (plugin package)/RoomManagement/ReservationTypeList.ascx.cs`
**Rock Category**: BEMA Services > Room Management

## Purpose

Lists all configured `ReservationType` rows. Used by administrators to browse and edit reservation types (e.g., "Staff Meeting", "Wedding", "Youth Event") before clicking through to [Reservation Type Detail](ReservationTypeDetail.md). Non-administrators only see types they're authorized to VIEW.

## Block Attributes

*(None — only a LinkedPage.)*

## Page Parameters

*(None read by this block. It emits `ReservationTypeId` when navigating to the detail page.)*

## Data Flow

- **Reads from**: [`ReservationType`](../sql-tables/Reservation-and-Type.md#reservationtype) via `ReservationTypeService.Queryable()`, ordered by `Name`.
- **Writes**: nothing directly — all edits happen in the detail page.
- **Security filter**: each candidate type must pass `UserCanEdit` OR `ReservationType.IsAuthorized(VIEW, CurrentPerson)`.

## Linked Pages

| Key | Display name | Query string passed | Default |
|---|---|---|---|
| `DetailPage` | Detail Page | `ReservationTypeId` (0 for "Add") | *(none — required)* |

## Notable Behaviors

- The **Add** link (`lbAddReservationType`) is hidden unless `UserCanAdministrate = true`.
- Clicking a type fires `rptReservationTypes_ItemCommand`, which navigates with `ReservationTypeId = {that Id}`.
- The block is a **Repeater** (`rptReservationTypes`), not a Rock Grid — there are no built-in filters or sort dropdowns.
