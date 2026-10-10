# Requestor Change

> **Provenance tier:** `traced` — read from source or official documentation and cited (Rock v18.2.4). Catalogued in the plugin's knowledge manifest; `rockrms-knowledge-current` lists every entry.



**Plugin**: BEMA Services — Room Management 2.0 (v2.6.5.16)
**Source file**: `RoomManagement (plugin package)/RoomManagement/RequestorChange.ascx.cs`
**Rock Category**: BEMA Services > Room Management

## Purpose

Bulk-reassign the "requestor" (and/or event contact, and/or administrative contact) on every Reservation owned by one person over to another person. Useful when staff leave or swap responsibilities and there are dozens of existing reservations to re-home.

## Block Attributes

*(None.)*

## Page Parameters

| Parameter | Use |
|---|---|
| `PersonGuid` | If present, pre-populates the "old requestor" picker (`ppOld`) from `PersonAliasService.Get(Guid)`. |

## Data Flow

### Reads

- [`PersonAlias`](../../../../rock-sql-schema/references/Person-and-PersonAlias.md#personalias) — to resolve the pre-populated old-requestor person from `PersonGuid`.
- [`ReservationMinistry`](../sql-tables/Reservation-and-Type.md#reservationministry) — populates the Ministry checkbox-list filter (distinct by name, ordered by name).
- [`Reservation`](../sql-tables/Reservation-and-Type.md#reservation) — finds reservations where *any selected role* has a `PersonAliasId` belonging to the old person's alias list (`oldPerson.Aliases`).

### Writes

On click of **Change**, for each matching `Reservation`, sets whichever of these columns were selected:

| Selected role | Column updated |
|---|---|
| Requester | `Reservation.RequesterAliasId` |
| EventContact | `Reservation.EventContactPersonAliasId` |
| AdminContact | `Reservation.AdministrativeContactPersonAliasId` |

The new value is the **new person's primary alias id** (`newPerson.PrimaryAliasId`).

All writes happen inside a single `RockContext.SaveChanges()` call.

## Linked Pages

*(None.)*

## Notable Behaviors

- The old-person lookup uses `PersonService.Get(PersonId)`, but the reservation match is done against the full alias list (`oldPerson.Aliases`) so historical aliases are covered — important when people have been merged.
- Ministry filter: if any ministry names are selected, the match is further restricted to reservations whose `ReservationMinistry.Name` is in the selected set. Matching is done by **name**, not Id, because the checkbox-list is built with `DistinctBy(rmc => rmc.Name)` — two ReservationMinistry rows with the same name (across different ReservationTypes) will be treated as one.
- Role-selection and ministry-selection are checkbox-lists; both are OR within themselves (so selecting Requester and AdminContact changes reservations where the old person was *either*), and the role filter is combined with the ministry filter via AND.
- Validation: both old and new person pickers must be populated, otherwise an error notification is shown and nothing is written.
- Errors are caught broadly and surface as a generic "An error occurred." notification (no logging call in this block).
