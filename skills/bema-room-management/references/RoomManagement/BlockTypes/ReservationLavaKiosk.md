# Reservation Lava Kiosk

> **Provenance tier:** `traced` — read from source or official documentation and cited (Rock v18.2.4). Catalogued in the plugin's knowledge manifest; `/rockrms:knowledge-current` lists every entry.



**Plugin**: BEMA Services — Room Management 2.0 (v2.6.5.16)
**Source file**: `RoomManagement (plugin package)/RoomManagement/ReservationLavaKiosk.ascx.cs`
**Rock Category**: BEMA Services > Room Management

## Purpose

Read-only kiosk page showing **today's approved reservations for one Location**. Meant to be displayed outside a room (tablet, wall monitor) so people walking by can see what's scheduled for that space today.

## Block Attributes

| Attribute (Display Name) | Type | Default | Key |
|---|---|---|---|
| Lava Template | CodeEditorField (Lava, required) | `{% include '~/Plugins/com_bemaservices/RoomManagement/Assets/Lava/ReservationKiosk.lava' %}` | `LavaTemplate` |
| Enable Debug | BooleanField | `false` | `EnableDebug` |

`ReservationKiosk.lava` is documented in the [plugin README](../README.md#lava-asset-templates).

## Page Parameters

| Parameter | Use |
|---|---|
| `LocationId` | Integer (required). Which Location to show. `0` or missing → block shows an error message "Please pass in a valid LocationId" and renders nothing. |

## Data Flow

### Reads

- [`Location`](../../../../rock-sql-schema/references/database-structure-tables.md#location) — to get `Location.Name` for the Lava merge fields.
- [`Reservation`](../sql-tables/Reservation-and-Type.md#reservation) — via `ReservationService.Queryable(ReservationQueryOptions)` with:
    - `LocationIds = [LocationId]`
    - `ApprovalStates = [Approved]`
- The returned reservations are hydrated via `qry.GetReservationSummaries(today, today, includeAttributes=true)` — this plugin extension pivots the reservation into a `ReservationSummary` projection that includes the first occurrence's date/time, resources, locations, requester alias, etc.

### Writes

*(None.)*

### Lava merge fields

| Merge field | Type | Notes |
|---|---|---|
| `CurrentPerson` | `Person` | Standard Rock. |
| `Location` | string | The name of the Location (from `Location.Name`). Note: this is a **string**, not a Location object. |
| `ReservationSummaries` | list-of-lists | Reservations grouped by `EventStartDateTime.Date`, inner lists ordered by time. |

Each reservation inside `ReservationSummaries` has these properties (from the anonymous projection):

| Property | Notes |
|---|---|
| `Id`, `ReservationType`, `ReservationName`, `Note` | Direct passthrough. |
| `ApprovalState` | String form via `ConvertToString()`. |
| `Locations`, `Resources` | From `ReservationLocations` / `ReservationResources`. |
| `CalendarDate` | `EventStartDateTime.ToLongDateString()`. |
| `EventStartDateTime`, `EventEndDateTime`, `ReservationStartDateTime`, `ReservationEndDateTime` | Raw datetimes. |
| `EventDateTimeDescription` | **`EventTimeDescription` with `"a"` → `" AM"` and `"p"` → `" PM"`** — brittle: if a person's name in the description contains "a" or "p", it will be mangled. |
| `ReservationDateTimeDescription` | Unmodified. |
| `SetupPhotoId` | For inline `<img src="/GetImage.ashx?id={SetupPhotoId}">`. |
| `RequesterAlias`, `EventContactPersonAlias` | `PersonAlias` entities. |
| `EventContactEmail`, `EventContactPhoneNumber` | Strings. |
| `MinistryName` | `ReservationMinistry.Name` or empty string. |

## Linked Pages

*(None.)*

## Notable Behaviors

- **"Today only"** is hard-coded — `filterStartDateTime = filterEndDateTime = RockDateTime.Today`. Rolls over at midnight. There is no block attribute to widen the window.
- **`LocationName` is persisted in ViewState** so the Lava template keeps showing the name across postbacks even though `LocationService.Get()` is only called on the first load.
- Debug info: when `EnableDebug = true` AND the current user has EDIT permission on the block, the standard `lavaDebugInfo()` dump is appended to the output.
- The `btnSubmit_Click` simply calls `BindData(...)` again — likely a "refresh" button on the kiosk.
- There are two functionally-identical helper methods `ShowWarning` and `ShowError`. Only `ShowWarning`/`ShowError` are defined; neither is actually called from anywhere in the file — they're dead code in this block.
