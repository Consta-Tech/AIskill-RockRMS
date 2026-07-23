# Room Management — Plugin Tables

Schema documentation for the 14 SQL tables created by the BEMA Room Management 2.0 plugin. All tables use the prefix `_com_bemaservices_RoomManagement_*`.

Tables are grouped by **JOIN affinity** — tables that are commonly queried together live in the same file.

> For core Rock tables referenced by the plugin (`Person`, `PersonAlias`, `Location`, `Schedule`, `Campus`, etc.), see the `rock-sql-schema` skill (`skills/rock-sql-schema/references/`).

## File Index

| File | Tables | Grouping Rationale |
|------|--------|--------------------|
| [Reservation-and-Type.md](Reservation-and-Type.md) | Reservation, ReservationType, ReservationMinistry, ReservationLocation, ReservationLocationType, ReservationResource, ReservationDoorLockSchedule | The core reservation entity, its type, and all per-reservation child rows (locations, resources, door-lock schedules) |
| [Reservation-Linkage.md](Reservation-Linkage.md) | ReservationLinkage | Junction between Reservation and EventItemOccurrence |
| [Reservation-Questions.md](Reservation-Questions.md) | Question *(C# class `ReservationQuestion`)* | Ad-hoc Attribute-backed questions attached to a Resource or Location |
| [Reservation-Workflow.md](Reservation-Workflow.md) | ReservationWorkflow, ReservationWorkflowTrigger, ReservationApprovalGroup | Workflow triggers and approval groups attached to a ReservationType; runtime workflow instances attached to a Reservation |
| [Resource-and-Layout.md](Resource-and-Layout.md) | Resource, LocationLayout | Reusable Resources (items people can reserve) and per-Location layout presets |

## Enum quick reference

These C# enums are stored as `int` columns. **Values below were corroborated against BEMA's source on GitHub — most enums use the C# default (0-indexed, increment by 1), but the two child `ApprovalState` enums explicitly start at 1.**

| Enum | Column | Values |
|------|--------|--------|
| `ReservationApprovalState` | `Reservation.ApprovalState` | 0=Draft, 1=PendingInitialApproval, 2=Approved, 3=Denied, 4=ChangesNeeded, 5=PendingFinalApproval, 6=PendingSpecialApproval, 7=Cancelled |
| `ReservationLocationApprovalState` | `ReservationLocation.ApprovalState` | **1**=Unapproved, **2**=Approved, **3**=Denied — see [ApprovalState-Enums.md](../ApprovalState-Enums.md) |
| `ReservationResourceApprovalState` | `ReservationResource.ApprovalState` | **1**=Unapproved, **2**=Approved, **3**=Denied — same shape as the Location enum |
| `ReservationWorkflowTriggerType` | `ReservationWorkflowTrigger.TriggerType` | 0=ReservationCreated, 1=ReservationUpdated, 2=StateChanged, 3=Manual |
| `ApprovalGroupType` | `ReservationApprovalGroup.ApprovalGroupType` | 0=InitialApprovalGroup, 1=FinalApprovalGroup, 2=OverrideApprovalGroup |
| `ReservationTypeRequirement` | ReservationType-level requirement flags (SetupTime/CleanupTime/NumberAttending) | 0=Hide, 1=Allow, 2=Require |

> ⚠ **The two child `ApprovalState` enums are 1-indexed — they do NOT have a `0` value.** The parent's `Approved=2` and `Denied=3` happen to coincide with the children's, which is a trap; the rest of the parent's values (`Draft`, `Pending*`, `ChangesNeeded`, `Cancelled`) do not exist on children. See [ApprovalState-Enums.md](../ApprovalState-Enums.md) for the full table, the SQL idioms that depend on these values, and the canonical render-side case statement for child rows.

## Naming caveat

The C# class `ReservationQuestion` corresponds to the SQL table **`_com_bemaservices_RoomManagement_Question`** — not `_ReservationQuestion`. All other C# model classes match their table name (minus the prefix).
