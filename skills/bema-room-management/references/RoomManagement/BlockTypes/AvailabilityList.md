# Availability List

> **Provenance tier:** `traced` — read from source or official documentation and cited (Rock v18.2.4). Catalogued in the plugin's knowledge manifest; `/rockrms:knowledge-current` lists every entry.



**Plugin**: BEMA Services — Room Management 2.0 (v2.6.5.16)
**Source file**: `RoomManagement (plugin package)/RoomManagement/AvailabilityList.ascx.cs`
**Rock Category**: BEMA Services > Room Management

## Purpose

"What's free?" browser. Lets staff pick a date/time window and see, for either **Resources** OR **Locations** (not both at once), which are available and which are booked — including who has them booked and when.

The block has a radio toggle at the top: "Resource" vs "Location". It swaps which grid is visible and which filters apply.

## Block Attributes

| Attribute (Display Name) | Type | Default | Key |
|---|---|---|---|
| Detail Page | LinkedPage | *(none)* | *(default)* |

## Page Parameters

*(None read by this block. It emits `ResourceId` or `LocationId` when navigating to the detail page, depending on which grid row was clicked.)*

## Grid Filters (persisted per-user per-block via `gfSettings`)

| Filter | Applies to | Notes |
|---|---|---|
| Selected Entity | `rblResourceLocation` | `"Resource"` or `"Location"` — toggles which grid is shown. |
| Start Time | `dtpStartDateTime` | Defaults to `Today` when empty. |
| End Time | `dtpEndDateTime` | Defaults to `Today + 1 month` when empty. |
| Resource Category | `cpResource` | Resource mode only. Resource must have this `CategoryId`. |
| Parent Location | `lipLocation` | Location mode only. Includes the picked Location **and** all descendants. |
| Expected Occupants | `nbMaxOccupants` | Location mode only. `Location.FirmRoomThreshold >= value`. |
| Campus | `cpCampus` | Both modes. Resource mode: `Resource.CampusId IN (selected)`. Location mode: includes the Campus's root Location and descendants. |

## Data Flow

### Reads

- [`Resource`](../sql-tables/Resource-and-Layout.md#resource) (in Resource mode) via `ResourceService.Queryable()`.
- [`Location`](../../../../rock-sql-schema/references/database-structure-tables.md#location) (in Location mode) via `LocationService.Queryable()` + `LocationService.GetAllDescendents(...)` for tree expansion.
- [`Reservation`](../sql-tables/Reservation-and-Type.md#reservation) via `ReservationService.Queryable(ReservationQueryOptions)` with:
    - `ApprovalStates` = `[Approved, PendingInitialApproval, PendingSpecialApproval, PendingFinalApproval, ChangesNeeded]` (i.e., everything that *could* reasonably still consume the slot — **excludes** Draft, Cancelled, Denied)
    - Resource mode: `ResourceIds` = selected resources' Ids.
    - Location mode: `LocationIds` = selected locations' Ids.
- Then resolved via `qry.GetReservationSummaries(start, end, false)` to get per-day occupancy.

### Writes

*(None — purely a browse/search block.)*

## Per-row Availability Logic

### Resource row (Resource mode)

1. Sum `ReservationResource.Quantity` across **every reservation overlapping the window** (excluding `ReservationResourceApprovalState.Denied`). Overlap check uses `(startA > filterStart OR endA > filterStart) AND (startA < filterEnd OR endA < filterEnd)`.
2. `IsAvailable = (resource.Quantity - summedReserved) > 0` (or `true` if `Quantity IS NULL`).
3. `Availability` cell:
    - Available → `"{remaining} Available"`.
    - Unavailable → list of reservation names + time descriptions separated by `</br></br>`.

### Location row (Location mode)

1. A Location is "unavailable" if **any** matching reservation's `ReservationLocation.ApprovalState != Denied` points at this Location Id.
2. `IsAvailable = !anyOverlappingReservation`.
3. `Availability` cell:
    - Available → `"Available"`.
    - Unavailable → list of reservation names + time descriptions separated by `</br></br>`.
4. The Name cell also lists any Resources whose `Resource.LocationId` equals this Location (so staff know what's pre-staged there). Format: `Location Name<small>{newline}Resource (Qty){newline}...</small>`.

## Linked Pages

| Key | Display name | Query string passed |
|---|---|---|
| `DetailPage` | Detail Page | `ResourceId` (Resource grid click) **or** `LocationId` (Location grid click) |

Both grids point at the same `DetailPage` attribute, so the page expects a detail block that can handle either parameter (typically not both at once).

## Notable Behaviors

- **Deduplication of resource quantity sums**: `.DistinctBy(r => r.Id).Sum(...)` — a single reservation with multiple reservation-resource rows for the same resource is counted once across the reservation's quantity, not once per row. If two different reservations both use the same resource pool within the window, both are summed.
- **Campus → Location expansion**: the Campus filter resolves each Campus's `LocationId` (via `CampusCache`) then calls `LocationService.GetAllDescendents(...)` to include every child Location. If a Campus has no root Location, its filter entry contributes nothing.
- **EntityTypeId is wired for dynamic attribute columns** on both grids (`Resource` and `Location`).
- **Filter defaults on fresh view**: no Start Time = today; no End Time = today + 1 month.
- Pending approval states are treated as booked for availability purposes — the rationale is that a "Pending" reservation is a soft hold and booking over it would create a conflict.
