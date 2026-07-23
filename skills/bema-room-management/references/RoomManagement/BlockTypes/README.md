# Room Management — BlockTypes

Full-treatment documentation for the 16 BlockTypes shipped by the BEMA Room Management 2.0 plugin. All block types live under the Rock block category **"BEMA Services > Room Management"**.

For a lighter at-a-glance summary (purpose + inputs/outputs), see the plugin [README](../README.md). For plugin table schemas, see [sql-tables/](../sql-tables/README.md).

## Index

| # | BlockType | File | Purpose |
|---|---|---|---|
| 1 | Availability List | [AvailabilityList.md](AvailabilityList.md) | Grid of Locations/Resources with availability over a time range |
| 2 | Conflicting Reservation List | [ReservationList.md](ReservationList.md#conflictingreservationlist) | Grid of reservations that overlap/conflict *(combined with ReservationList)* |
| 3 | Location Layout List | [LocationLayoutList.md](LocationLayoutList.md) | Manage room layouts attached to a Location |
| 4 | My Reservations Lava | [MyReservationsLava.md](MyReservationsLava.md) | Lava-rendered list of reservations the current user submitted or must approve |
| 5 | Question List | [QuestionList.md](QuestionList.md) | Manage ad-hoc questions (Attributes) attached to a Resource or Location |
| 6 | Requestor Change | [RequestorChange.md](RequestorChange.md) | Bulk-reassign the requestor on reservations |
| 7 | Reservation Detail | [ReservationDetail.md](ReservationDetail.md) | Full editor for a single Reservation |
| 8 | Reservation Lava | [ReservationLava.md](ReservationLava.md) | Calendar-style Lava-rendered browser of reservations |
| 9 | Reservation Lava Kiosk | [ReservationLavaKiosk.md](ReservationLavaKiosk.md) | Kiosk view of approved reservations for a given Location |
| 10 | Reservation Linkage Detail | [ReservationLinkageDetail.md](ReservationLinkageDetail.md) | Wizard to link a Reservation to an EventItem/Occurrence |
| 11 | Reservation Linkage List | [ReservationLinkageList.md](ReservationLinkageList.md) | Grid of linkages for a Reservation |
| 12 | Reservation List | [ReservationList.md](ReservationList.md) | Filterable grid of reservations with bulk-email actions |
| 13 | Reservation Type Detail | [ReservationTypeDetail.md](ReservationTypeDetail.md) | Configure a ReservationType |
| 14 | Reservation Type List | [ReservationTypeList.md](ReservationTypeList.md) | List configured ReservationTypes |
| 15 | Resource Detail | [ResourceDetail.md](ResourceDetail.md) | Edit a single Resource |
| 16 | Resource List | [ResourceList.md](ResourceList.md) | Searchable grid of Resources |

## Conventions used in these docs

- **Plugin tables** are linked with `../sql-tables/*.md`.
- **Core Rock tables** are linked with `../../../../rock-sql-schema/references/*.md`.
- Block Attributes, PageParameter reads, LinkedPage declarations, and FK cross-references are sourced from the source `.ascx.cs` files (in `RoomManagement (plugin package)/RoomManagement/`) and the plugin's compiler XML output.
