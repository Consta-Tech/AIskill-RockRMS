# Room Management 2.0

**Plugin**: BEMA Services — Room Management 2.0
**Package version documented**: v2.6.5.16
**Namespace**: `com.bemaservices.RoomManagement`
**Table prefix**: `_com_bemaservices_RoomManagement_*`
**Rock version observed**: v18.2.4
**Rock block category**: `BEMA Services > Room Management`

## What the plugin does

Adds a multi-tier **room/resource reservation** system to Rock. Staff can:

- Submit **Reservations** for one or more **Locations** (rooms, fields, etc.) and **Resources** (tables, chairs, vehicles, portable equipment, etc.), optionally per-**Campus** and per-**Ministry**.
- Route each reservation through a configurable approval chain (Initial → Special → Final), with optional Override and Per-Resource / Per-Location approval.
- Attach dynamic attribute questions to **ReservationType**, **Resource**, and **Location**.
- Fire Rock Workflows on lifecycle events (`ReservationCreated`, `ReservationUpdated`, `StateChanged`, `Manual`).
- Link a Reservation to a core-Rock **EventItemOccurrence** (public event listing) via a 4-step wizard.
- Generate **door lock schedules** (minute-offset from the reservation's first occurrence).
- Browse reservations via filterable grids, Lava-rendered calendar/report views, and a Location-scoped kiosk view.
- Generate PDF reports (setup sheets, schedules) via pluggable `ReportTemplate` components.

## Domain model

```
                                ┌────────────────────┐
                                │   ReservationType  │──────────────┐
                                │  (approval config, │              │
                                │   default setup,   │              │
                                │   required fields, │              │
                                │   dynamic attrs)   │              │
                                └────────┬───────────┘              │
                                         │ 1                        │ 1
                                         │                          │
                                         │ *                        │ *
                      ┌──────────────────┴────────┐         ┌───────┴──────────────────┐
                      │    ReservationMinistry    │         │  ReservationApprovalGroup│
                      └───────────────────────────┘         │  (Group IsSecurityRole=1)│
                                         │                  │  type=Initial/Final/Spec │
                                         │                  └──────────────────────────┘
                                         │
                                         │ *
                                         ▼
┌──────────────────┐      ┌──────────────────────────────┐     ┌──────────────────────┐
│  core Rock       │  1   │            Reservation       │  *  │  ReservationLinkage  │ 1
│  Schedule        │──────┤  (state machine, contacts,   │────▶│                      │────▶ core Rock
│  (iCal)          │      │   approval dates/persons,    │     └──────────────────────┘      EventItemOccurrence
└──────────────────┘      │   setup/cleanup, campus,     │
                          │   ministry, photo, note)     │
                          └───┬───────┬───────┬──────────┘
                              │       │       │
                              │1*     │1*     │1*
                              ▼       ▼       ▼
                  ┌───────────────┐ ┌───────────────────┐ ┌───────────────────────────┐
                  │ReservationLoc │ │ReservationResource│ │ReservationDoorLockSchedule│
                  │(per-row appr  │ │(per-row approval, │ │(start/end minute offsets) │
                  │LocationLayout)│ │ qty, parent loc)  │ │                           │
                  └───────┬───────┘ └────────┬──────────┘ └───────────────────────────┘
                          │ *                │ *
                          ▼                  ▼
                  ┌─────────────────┐   ┌──────────────────┐
                  │ core Rock       │   │ Resource         │
                  │ Location        │◀──┤ (LocationId FK,  │
                  │ + LocationLayout│   │  Quantity, photo)│
                  └─────────────────┘   └──────────────────┘

                  ReservationType ──1:*── ReservationWorkflowTrigger ──1:*── ReservationWorkflow ──1:1── core Rock Workflow
                                         (TriggerType, QualifierValue)      (runtime instance per reservation)

                  Resource, ReservationType, Location ──1:*── Question  (dynamic Rock Attribute rows,
                                                                         entity-qualified per row)
```

## BlockTypes (16)

See [BlockTypes/README.md](BlockTypes/README.md) for the full index. Quick grouping:

### Configuration

- [ReservationTypeList](BlockTypes/ReservationTypeList.md), [ReservationTypeDetail](BlockTypes/ReservationTypeDetail.md) — manage `ReservationType` and its approval chain / ministries / workflow triggers / dynamic attributes.
- [ResourceList](BlockTypes/ResourceList.md), [ResourceDetail](BlockTypes/ResourceDetail.md) — manage the `Resource` catalog.
- [LocationLayoutList](BlockTypes/LocationLayoutList.md) — manage room layout presets attached to a Location.
- [QuestionList](BlockTypes/QuestionList.md) — manage ad-hoc `Attribute`-backed questions for ReservationType / Resource / Location.

### Day-to-day use

- [ReservationLava](BlockTypes/ReservationLava.md) — the main calendar browser (Day/Week/Month/Year, with per-person preferences).
- [ReservationList](BlockTypes/ReservationList.md) — filterable admin grid + bulk email.
- [ConflictingReservationList](BlockTypes/ConflictingReservationList.md) — same grid narrowed to scheduling clashes.
- [ReservationDetail](BlockTypes/ReservationDetail.md) — full editor for a single reservation, including the approval state machine, per-row approvals, and manual workflow launch.
- [ReservationLinkageList](BlockTypes/ReservationLinkageList.md), [ReservationLinkageDetail](BlockTypes/ReservationLinkageDetail.md) — link a reservation to a public EventItemOccurrence.
- [AvailabilityList](BlockTypes/AvailabilityList.md) — compare booked/available time across Locations and Resources.
- [MyReservationsLava](BlockTypes/MyReservationsLava.md) — Lava-rendered personal list for the current user.
- [ReservationLavaKiosk](BlockTypes/ReservationLavaKiosk.md) — Location-scoped kiosk view (today's reservations for this room).
- [RequestorChange](BlockTypes/RequestorChange.md) — bulk-reassign the admin contact on a set of reservations.

## WorkflowTypes (4)

The plugin ships four `WorkflowType` definitions for reservation-lifecycle automation. Wiring is per-`ReservationType` via [`ReservationWorkflowTrigger`](sql-tables/Reservation-Workflow.md#reservationworkflowtrigger), not hard-coded.

| WorkflowType | Role | File |
|---|---|---|
| Approval Process | State-machine orchestrator (Initial → Special → Final approval gates). | [WorkflowTypes/ApprovalProcess.md](WorkflowTypes/ApprovalProcess.md) |
| Modification Process | Re-classifies an edit by a non-approver and bumps `ApprovalState` back if the change is significant. | [WorkflowTypes/ModificationProcess.md](WorkflowTypes/ModificationProcess.md) |
| Reminder Notification | "Your reservation is coming up" email to the event contact. Fired by an external Rock Job. | [WorkflowTypes/ReminderNotification.md](WorkflowTypes/ReminderNotification.md) |
| Special Approval Notification | Per-Resource / per-Location escalation email. Launched from inside Approval Process. | [WorkflowTypes/SpecialApprovalNotification.md](WorkflowTypes/SpecialApprovalNotification.md) |

For the trigger architecture, the parallel-instantiation behavior, and conventions shared across all four, see [WorkflowTypes/README.md](WorkflowTypes/README.md).

## ApprovalState enums

Three distinct enums govern reservation/child approval. See [ApprovalState-Enums.md](ApprovalState-Enums.md) for the full table — the parent `Reservation.ApprovalState` is 0-indexed (8 values) but the child `ReservationLocation.ApprovalState` and `ReservationResource.ApprovalState` are **1-indexed** (3 values, no `0`). The trap is that `Approved=2` and `Denied=3` coincide across all three enums.

## Plugin SQL tables (14)

See [sql-tables/README.md](sql-tables/README.md) for schema documentation. Grouped by JOIN affinity:

| File | Tables |
|---|---|
| [Reservation-and-Type.md](sql-tables/Reservation-and-Type.md) | `Reservation`, `ReservationType`, `ReservationMinistry`, `ReservationLocation`, `ReservationLocationType`, `ReservationResource`, `ReservationDoorLockSchedule` |
| [Reservation-Linkage.md](sql-tables/Reservation-Linkage.md) | `ReservationLinkage` |
| [Reservation-Questions.md](sql-tables/Reservation-Questions.md) | `Question` (C# `ReservationQuestion`) |
| [Reservation-Workflow.md](sql-tables/Reservation-Workflow.md) | `ReservationWorkflow`, `ReservationWorkflowTrigger`, `ReservationApprovalGroup` |
| [Resource-and-Layout.md](sql-tables/Resource-and-Layout.md) | `Resource`, `LocationLayout` |

## Core Rock tables consumed

The plugin reads or writes these tables from core Rock (documented in the `rock-sql-schema` skill (`skills/rock-sql-schema/references/`)):

| Table | Used by |
|---|---|
| `Person`, `PersonAlias` | Contact fields on `Reservation`, approval/audit fields, approval group membership. |
| `Group` | `ReservationApprovalGroup` points at Groups with `IsSecurityRole = 1`. |
| `Location` | `ReservationLocation.LocationId`, `Resource.LocationId`, `LocationLayout.LocationId`. |
| `Campus` | `Reservation.CampusId`, approval-group scoping. |
| `Schedule` | `Reservation.ScheduleId` (iCalendarContent). |
| `DefinedType` / `DefinedValue` | Phone type picker (`PERSON_PHONE_TYPE`), location types (`LOCATION_TYPE`), audience types (`MARKETING_CAMPAIGN_AUDIENCE_TYPE`), plus two plugin DefinedTypes for Reservation Views and Printable Reports. |
| `EventCalendar`, `EventItem`, `EventItemOccurrence`, `EventCalendarItem`, `EventItemAudience` | Created/linked by [ReservationLinkageDetail](BlockTypes/ReservationLinkageDetail.md). |
| `Workflow`, `WorkflowType` | Launched by `ReservationWorkflowTrigger`. Stored runtime instance on `ReservationWorkflow`. |
| `Communication`, `CommunicationRecipient` | Written by [ReservationList](BlockTypes/ReservationList.md) bulk-email. |
| `Attribute`, `AttributeValue` | Dynamic attributes on `Reservation` / `ReservationLocation` / `ReservationResource`, qualified by `ReservationTypeId` / entity-type where appropriate. |
| `BinaryFile` | `Reservation.PhotoId`, `Resource.PhotoId`, `EventItem.PhotoId`. |
| `History` | All reservation edits logged to category `HISTORY_RESERVATION_CHANGES`. |

## Lava asset templates

The plugin ships Lava templates as DefinedValue options. Staff select one per block; each block reads the `Lava` + `LavaCommands` attributes off the chosen DefinedValue and renders. Files live in `Assets/Lava/` in the source package:

| File | Typically used on |
|---|---|
| `EventReport.lava` | Printable Reservation Reports — per-event summary |
| `LocationBasedView.lava` | Reservation Views — location-grouped layout |
| `LocationReport.lava` | Printable Reservation Reports — per-location summary |
| `MyReservationsSortable.lava` | [MyReservationsLava](BlockTypes/MyReservationsLava.md) block |
| `Reservation.lava` | [ReservationDetail](BlockTypes/ReservationDetail.md) view mode (legacy) |
| `ReservationCalendar.lava` | Reservation Views — calendar-grid layout |
| `ReservationKiosk.lava` | [ReservationLavaKiosk](BlockTypes/ReservationLavaKiosk.md) block |
| `ReservationNew.lava` | Reservation Views — new "card" layout |
| `ReservationReport.lava`, `ReservationReportCampus.lava`, `ReservationReport-LateSubmissions.lava` | Printable Reservation Reports — general-purpose schedule |
| `ReservationTabs.lava` | Reservation Views — tabbed layout |
| `VueCalendar.lava` | Reservation Views — Vue-powered calendar (newer) |

`Assets/Scripts/` ships `circle-progress.js`, `event-calendar.js`, `moment.js`. `Assets/Styles/` ships `event-calendar.css` and `print.css`.

## Authorization model at a glance

Rock entity-level authorization (`IsAuthorized`) is used throughout. Key patterns:

| Entity | Scope |
|---|---|
| `ReservationType` | `VIEW` / `EDIT` / `ADMINISTRATE` control who can view/add/edit/delete reservations of that type. |
| `Reservation` | Inherits from type; also honors `CreatedByPersonAliasId`, `EventContactPersonAliasId`, `AdministrativeContactPersonAliasId` as "implicit owner" checks (`HasStandardEditRights`). |
| `Resource`, `Location` | Rock standard — used for resource/location picker filtering, per-location layout picker, and per-calendar authoring in the Linkage wizard. |
| `ReservationApprovalGroup` | Membership in these security Groups drives `HasApprovalRightsToState` and the per-row approve buttons via `CanPersonApproveReservationResource` / `CanPersonApproveReservationLocation`. |

## Known quirks (cross-block)

- **Self-privilege on ReservationType save** — see [ReservationTypeDetail.md](BlockTypes/ReservationTypeDetail.md#save-flow). Saving auto-grants the current person VIEW/EDIT/ADMINISTRATE on the type. Consequence: a user with only block-level edit rights can retroactively self-grant ADMINISTRATE by saving.
- **Ministry filter is Name-based** — across [ReservationList](BlockTypes/ReservationList.md), [ReservationLava](BlockTypes/ReservationLava.md), and [RequestorChange](BlockTypes/RequestorChange.md), ministries are `DistinctBy(Name)`. Two rows sharing a name count as one.
- **Location filter expands both up and down the tree** — unusual; most Rock filters only descend. See [ReservationList.md](BlockTypes/ReservationList.md#grid-filters-persisted-per-user-per-block-via-gfsettings).
- **Deleting a ReservationType cascades to every reservation of that type** and all their child rows (resources, locations, door-locks). No soft-delete. Prefer `IsActive = false`. See [ReservationTypeDetail.md](BlockTypes/ReservationTypeDetail.md#delete-flow).
- **Concurrency check at reservation save is per-reservation, not per-child** — two admins editing different resources on the same reservation will still collide.
- **`Session["CurrentCalendars"]` leaks across tabs** in the Linkage wizard (session-scoped state in a wizard-style block). See [ReservationLinkageDetail.md](BlockTypes/ReservationLinkageDetail.md#sessioncurrentcalendars-caveat).

## Repository structure

```
skills/bema-room-management/references/RoomManagement/
    README.md                    ← you are here
    ApprovalState-Enums.md       ← canonical reference for the three ApprovalState enums
    BlockTypes/
        README.md                ← index of 16 BlockTypes
        {BlockName}.md           ← one file per block (ReservationDetail, ReservationLava, etc.)
    sql-tables/
        README.md                ← index of 14 plugin tables
        {Group}.md               ← 5 grouped schema files
    WorkflowTypes/
        README.md                ← trigger architecture + parallel-instantiation behavior
        {WorkflowName}.md        ← one file per WorkflowType (4 total)
```

This tree documents the plugin **as BEMA ships it**. Church-specific deviations from stock behavior are documented in overlay plugins instead (e.g., the `room-management-deviations` skill in The Summit Church's `rockrms-tsc` plugin) — if such a skill is installed, consult it before treating non-stock behavior as a bug.

Plugin-internal table links use `../sql-tables/*.md`. Core Rock table links use `../../../../rock-sql-schema/references/*.md` (from `references/RoomManagement/BlockTypes/` up to `skills/`, then into the `rock-sql-schema` skill).
