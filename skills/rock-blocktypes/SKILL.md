---
name: rock-blocktypes
description: Tested behavior notes for specific Rock RMS block types — Group Attendance (List/Detail), Sign-Up (Overview/Detail/Attendee List), and Check-in Schedule Builder — plus Quartz cron expressions for Service Jobs and the Property-vs-Attribute distinction on Rock entities. Use when configuring these blocks, writing code that reads or writes their underlying tables, scheduling Service Jobs, or deciding whether an entity field is a Property or an Attribute.
---

# Rock RMS Block Types & Entity Fundamentals

`references/` contains behavior notes for specific core-Rock block types (traced against Rock's source on GitHub, with links to the exact `.obs`/`.ascx`/`.cs` files) plus two cross-cutting fundamentals.

Read only the file(s) relevant to the task.

## File Index

| File | Covers |
|------|--------|
| [GroupAttendance.md](references/GroupAttendance.md) | Group Attendance List + Detail blocks — how sessions (`[AttendanceOccurrence]`) and per-person records (`[Attendance]`) power the grids, and how the blocks read/write them. |
| [SignUp.md](references/SignUp.md) | Sign-Up Overview / Detail / Opportunity Attendee List blocks — projects as Groups with the Sign-Up GroupType, opportunities as Schedule + Location pairs. |
| [checkinScheduleBuilder.md](references/checkinScheduleBuilder.md) | Check-in Schedule Builder block — each grid row is a `[GroupLocation]`, columns are `[Schedule]` pairings. |
| [CronExpression.md](references/CronExpression.md) | Quartz-style 7-field cron expressions used by Rock Service Jobs (Seconds through Year), with field reference and examples. |
| [Rock-Attribute-Property.md](references/Rock-Attribute-Property.md) | Property vs Attribute — core-model columns vs EAV custom fields, and how each behaves in SQL, Lava, and the Rock UI. |

## Related skills

- `rock-sql-schema` — full CREATE TABLE references for the tables these blocks read and write (`Attendance.md`, `GroupLocation-and-GroupSchedule.md`, `Attribute-and-Value.md`, `database-structure-tables.md` for Schedule/ServiceJob).
