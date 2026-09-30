# My Reservations Lava

> **Provenance tier:** `traced` — read from source or official documentation and cited (Rock v18.2.4). Catalogued in the plugin's knowledge manifest; `/rockrms:knowledge-current` lists every entry.



**Plugin**: BEMA Services — Room Management 2.0 (v2.6.5.16)
**Source file**: `RoomManagement (plugin package)/RoomManagement/MyReservationsLava.ascx.cs`
**Rock Category**: BEMA Services > Room Management
**BlockType Guid**: `0D2E85E7-5881-42C4-9CB1-6F8830BB620B`

## Purpose

Displays the current user's reservations as a Lava-rendered list. The block can switch between two roles:

- **Assigned To** (default) — reservations this person is responsible for approving.
- **Initiated** — reservations this person submitted / is a contact for.

And two time slices:

- **Upcoming** (default) — `LastOccurrenceEndDateTime >= now`
- **Past** — `LastOccurrenceEndDateTime < now`

## Block Attributes

| Attribute (Display Name) | Type | Default | Key |
|---|---|---|---|
| Role | CustomRadioListField (`0^Assigned To,1^Initiated`) | `0` (Assigned To) | *(default)* |
| Status | CustomRadioListField (`0^Upcoming,1^Past`) | `0` (Upcoming) | *(default)* |
| Contents | CodeEditorField (Lava, not required) | `{% include '~/Plugins/com_bemaservices/RoomManagement/Assets/Lava/MyReservationsSortable.lava' %}` | *(default)* |
| Set Panel Title | TextField | *(empty)* | *(default)* |
| Set Panel Icon | TextField | *(empty)* | *(default)* |

The **Contents** attribute's default value is the ships-with-the-plugin `MyReservationsSortable.lava` template. That template is documented in the [plugin README's Lava assets section](../README.md#lava-asset-templates).

## Page Parameters

*(None read by this block.)*

## Data Flow

- **Reads from**: [`Reservation`](../sql-tables/Reservation-and-Type.md#reservation) via `ReservationService.Queryable(ReservationQueryOptions)`, where:
    - `Role = Initiated` → `ReservationQueryOptions.ReservationsByPersonId = CurrentPerson.Id`
    - `Role = Assigned To` → `ReservationQueryOptions.ApprovalsByPersonId = CurrentPerson.Id`
- **Writes**: nothing.

### Lava merge fields

| Merge field | Type | Source |
|---|---|---|
| `Role` | string (`"0"` or `"1"`) | Block attribute |
| `Status` | string (`"0"` or `"1"`) | Block attribute |
| `Reservations` | list of `Reservation` (sorted by `NextStartDateTime`) | DB query + filter |
| `PanelTitle` | string | Block attribute |
| `PanelIcon` | string | Block attribute |

## Linked Pages

*(None.)*

## Notable Behaviors

- On exception the block writes a generic "Error Getting Reservations" message and logs the exception via `LogException`.
- `~/` and `~~/` inside the Lava template are pre-resolved to the current app root / theme root before the template runs (standard Rock Lava block convention).
- The default template is sortable (name comes from `MyReservationsSortable.lava`) — swapping in a different Lava template is supported.
