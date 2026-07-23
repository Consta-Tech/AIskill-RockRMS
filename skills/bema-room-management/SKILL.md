---
name: bema-room-management
description: Reference for the BEMA Services Room Management 2.0 plugin for Rock RMS (documented at v2.6.5.16) — room/resource reservation domain model, approval-state enums and approval workflows, its block types (Reservation List/Detail/Lava, Availability List, kiosk views), and its SQL tables (_com_bemaservices_RoomManagement_*). Use for any task touching room or resource reservations, reservation approval chains, or the Room Management tables.
---

# BEMA Room Management 2.0

`references/` documents the BEMA Services **Room Management** plugin: a multi-tier room/resource reservation system for Rock (Reservations for Locations and Resources, configurable Initial → Special → Final approval chains, workflow triggers, EventItemOccurrence linkage, door-lock schedules, and PDF reports).

## How to use this skill

Start at [references/RoomManagement/README.md](references/RoomManagement/README.md) — it holds the plugin overview, the domain-model diagram, and the index into the rest of the tree. Then read only the specific file the task needs.

## Directory map

| Path | Covers |
|------|--------|
| [RoomManagement/README.md](references/RoomManagement/README.md) | Plugin overview, domain model diagram, version/namespace facts. |
| [RoomManagement/ApprovalState-Enums.md](references/RoomManagement/ApprovalState-Enums.md) | The ApprovalState enum values and transitions. |
| `RoomManagement/sql-tables/` | CREATE TABLE references for Reservation, ReservationType, Resource, Linkage, Questions, and Workflow tables. |
| `RoomManagement/BlockTypes/` | Behavior notes per plugin block (Reservation List/Detail/Lava, Availability List, Question List, Resource List/Detail, kiosk, and more). |
| `RoomManagement/WorkflowTypes/` | The approval, modification, and notification workflow types the plugin ships. |

## Notes

- Table prefix in SQL: `_com_bemaservices_RoomManagement_*`.
- Cross-links to **core** Rock tables (Person, Campus, Group, Workflow, CalendarEvent, Location) point into the `rock-sql-schema` skill's references — follow them there rather than guessing core schema.
- This skill documents the plugin **as BEMA ships it**. Church-specific deviations from stock behavior live in overlay plugins — if a deviations skill is installed (e.g., `room-management-deviations` from The Summit Church's `rockrms-tsc` plugin), consult it before treating any non-stock behavior as a bug.
