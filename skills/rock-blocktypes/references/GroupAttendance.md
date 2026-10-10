> **Provenance tier:** `traced` — read from source or official documentation and cited (Rock version not recorded). Catalogued in the plugin's knowledge manifest; `rockrms-knowledge-current` lists every entry.

GitHub (Obsidian):
- groupAttendanceList `.obs`: https://github.com/SparkDevNetwork/Rock/blob/a792f29bf6fc5941d7e7f1451f5c8b5880385451/Rock.JavaScript.Obsidian.Blocks/src/Group/groupAttendanceList.obs
- GroupAttendanceList `.cs`: https://github.com/SparkDevNetwork/Rock/blob/a792f29bf6fc5941d7e7f1451f5c8b5880385451/Rock.Blocks/Group/GroupAttendanceList.cs
- groupAttendanceDetail `.obs`: https://github.com/SparkDevNetwork/Rock/blob/a792f29bf6fc5941d7e7f1451f5c8b5880385451/Rock.JavaScript.Obsidian.Blocks/src/Group/groupAttendanceDetail.obs
- GroupAttendanceDetail `.cs`: https://github.com/SparkDevNetwork/Rock/blob/a792f29bf6fc5941d7e7f1451f5c8b5880385451/Rock.Blocks/Group/GroupAttendanceDetail.cs

GitHub (legacy WebForms):
- GroupAttendanceList `.ascx`: https://github.com/SparkDevNetwork/Rock/blob/2e803729696c9e88f95541d5bcc5f56f702a9c72/RockWeb/Blocks/Groups/GroupAttendanceList.ascx
- GroupAttendanceList `.ascx.cs`: https://github.com/SparkDevNetwork/Rock/blob/2e803729696c9e88f95541d5bcc5f56f702a9c72/RockWeb/Blocks/Groups/GroupAttendanceList.ascx.cs

---

## Overview

The Group Attendance system tracks meeting sessions and per-person attendance for a group. **Group Attendance List** shows a grid of sessions (one row per date/location/schedule), and **Group Attendance Detail** is the drill-down where you mark who attended a specific session. The two tables that power everything are `[AttendanceOccurrence]` (the session) and `[Attendance]` (each person's record within that session).

## Table of Contents

1. [Shared Data Model](#shared-data-model)
1. [Group Attendance List Block](#group-attendance-list-block)
1. [Reproducing the List Grid in SQL](#reproducing-the-list-grid-in-sql)
1. [Group Attendance Detail Block](#group-attendance-detail-block)
1. [Reproducing the Detail Roster in SQL](#reproducing-the-detail-roster-in-sql)

---

## Shared Data Model

### The Two Core Tables

| Table | Grain | Role |
|---|---|---|
| `[AttendanceOccurrence]` | One row per Group + Location + Schedule + Date | The **session** — "this group met at this place on this date" |
| `[Attendance]` | One row per person per occurrence | The **roster entry** — "this person did/didn't attend this session" |

The unique index `IX_GroupId_LocationID_ScheduleID_Date` on `[AttendanceOccurrence]` enforces: **one occurrence per Group + Location + Schedule + Date.**

### ER Diagram

```
[Group]  ←──  [AttendanceOccurrence]  ──→  [Location]
                       │       │
                       │       └──→  [Schedule]
                       │
                       ↓  (1-to-many)
                  [Attendance]  ──→  [PersonAlias]  ──→  [Person]
```

### Key Fields on `[AttendanceOccurrence]`

| Column | Type | Description |
|---|---|---|
| `GroupId` | `int` | FK → Group |
| `LocationId` | `int` | FK → Location (nullable) |
| `ScheduleId` | `int` | FK → Schedule (nullable) |
| `OccurrenceDate` | `date` | The meeting date |
| `DidNotOccur` | `bit` | "We Didn't Meet" flag |
| `Notes` | `nvarchar(max)` | Session notes |
| `AttendanceTypeValueId` | `int` | FK → DefinedValue (the "Check-in Attendance Types" DefinedType) |

### Key Fields on `[Attendance]`

| Column | Type | Description |
|---|---|---|
| `OccurrenceId` | `int` | FK → AttendanceOccurrence |
| `PersonAliasId` | `int` | FK → PersonAlias (who) |
| `DidAttend` | `bit` (nullable) | **Three states:** `1` = attended, `0` = did not attend, `NULL` = not yet recorded |
| `StartDateTime` | `datetime` | Timestamp (from schedule or occurrence date) |
| `CampusId` | `int` | FK → Campus (person's campus at time of attendance) |

### Computed Properties (NOT stored in DB)

These exist as `[NotMapped]` properties on the `AttendanceOccurrence` entity. They are derived in C# from child `[Attendance]` rows — no SQL column exists for them.

| Property | How Computed |
|---|---|
| `AttendanceEntered` | `true` if any child `[Attendance]` has `DidAttend IS NOT NULL`, **OR** `DidNotOccur = 1` |
| `DidAttendCount` | Count of child `[Attendance]` where `DidAttend = 1` |
| `AttendanceRate` | `DidAttendCount ÷ expectedAttendees` (expected = group members whose attendance was evaluated) |

---

## Group Attendance List Block

Shows a grid of all sessions for a group. Both the Obsidian and legacy WebForms versions use the same service method: `AttendanceOccurrenceService.GetGroupOccurrences(group, fromDate, toDate, locationIds, scheduleIds)`.

### Each ROW = one `[AttendanceOccurrence]` record

Rows are projected into an `AttendanceOccurrenceRow` POCO:

```csharp
public class AttendanceOccurrenceRow
{
    public int OccurrenceId { get; set; }
    public DateTime OccurrenceDate { get; set; }
    public int? LocationId { get; set; }
    public string LocationName { get; set; }
    public int? ParentLocationId { get; set; }
    public string ParentLocationPath { get; set; }
    public int? ScheduleId { get; set; }
    public string ScheduleName { get; set; }
    public TimeSpan StartTime { get; set; }
    public bool AttendanceEntered { get; set; }
    public bool DidNotOccur { get; set; }
    public int DidAttendCount { get; set; }
    public double AttendanceRate { get; set; }
    public string Notes { get; set; }
    public string AttendanceType { get; set; }
}
```

Note: `GetGroupOccurrences` can return **virtual occurrences** (generated from the group's schedule for dates with no persisted occurrence yet). These have `OccurrenceId == 0` and receive a composite key format (`"0|YYYY-MM-dd|scheduleId|locationId"`) in the Obsidian version.

### Grid Columns

| Column in UI | Source | Stored vs. Computed |
|---|---|---|
| **Date** | `AttendanceOccurrence.OccurrenceDate` | Stored (`[date]`) |
| **Location** (main + parent path) | `Location.Name` via `ao.LocationId`, parent via `Location.ParentLocationId` ancestry | Stored (joined) |
| **Schedule** | `Schedule.Name` via `ao.ScheduleId` | Stored (joined) |
| **Attendance Entered** | `AttendanceOccurrence.AttendanceEntered` | **Computed** |
| **Didn't Meet** | `AttendanceOccurrence.DidNotOccur` | Stored (`[bit]`) |
| **Attendance Count** | `AttendanceOccurrence.DidAttendCount` | **Computed** |
| **Percent Attended** | `AttendanceOccurrence.AttendanceRate` | **Computed** |
| **Notes** | `AttendanceOccurrence.Notes` | Stored (`[nvarchar](max)`) |
| **Attendance Type** | `AttendanceOccurrence.AttendanceTypeValueId` → DefinedValue | Stored (`[int]`, FK) |

### Filters

| Filter | Applied To | Note |
|---|---|---|
| **Date Range** | `ao.OccurrenceDate BETWEEN @fromDate AND @toDate` | Defaults to last 3 months |
| **Location** | `ao.LocationId IN (selected + descendant ids)` | Prefix `"P"` = parent location with descendants |
| **Schedule** | `ao.ScheduleId = @selectedScheduleId` | |
| **Campus** | `Location.CampusId` | Applied **post-query** in C#, not in the DB query |

### Row Actions

| Action | What Happens |
|---|---|
| **Enter Attendance** | Navigates to Group Attendance Detail for this occurrence |
| **Delete** | Deletes the `[AttendanceOccurrence]` row (cascades to child `[Attendance]` rows) |

---

## Reproducing the List Grid in SQL

```sql
DECLARE @input_GroupId int = 1;
DECLARE @input_FromDate date = '2026-01-01';
DECLARE @input_ToDate date = '2026-12-31';

SELECT
    ao.[Id]
  , ao.[OccurrenceDate]                                    AS "Date"
  , l.[Name]                                               AS "Location"
  , s.[Name]                                               AS "Schedule"
  , CAST(ao.[DidNotOccur] AS bit)                          AS "DidntMeet"
  , ao.[Notes]                                             AS "Notes"
  , ao.[AttendanceTypeValueId]                             AS "AttendanceTypeValueId"
  , SUM(CASE WHEN a.[DidAttend] = 1 THEN 1 ELSE 0 END)    AS "AttendanceCount"
  , COUNT(a.[Id])                                          AS "AttendanceRowCount"
FROM
    [AttendanceOccurrence] ao
    LEFT JOIN [Location] l ON l.[Id] = ao.[LocationId]
    LEFT JOIN [Schedule] s ON s.[Id] = ao.[ScheduleId]
    LEFT JOIN [Attendance] a ON a.[OccurrenceId] = ao.[Id]
WHERE
    ao.[GroupId] = @input_GroupId
    AND ao.[OccurrenceDate] BETWEEN @input_FromDate AND @input_ToDate
GROUP BY
    ao.[Id]
  , ao.[OccurrenceDate]
  , l.[Name]
  , s.[Name]
  , ao.[DidNotOccur]
  , ao.[Notes]
  , ao.[AttendanceTypeValueId]
ORDER BY
    ao.[OccurrenceDate] DESC
;
```

`AttendanceEntered` requires business logic (OR with `DidNotOccur`) and `AttendanceRate` requires an expected-attendee denominator, which is why Rock computes them in C# rather than SQL.

---

## Group Attendance Detail Block

This is the drill-down from the List grid's "Enter Attendance" action. It shows the roster for **one specific `[AttendanceOccurrence]`** and lets you mark each person as attended or not.

### Identifying the Occurrence

The block accepts these page parameters (in priority order):

| Parameter | Lookup |
|---|---|
| `OccurrenceId` | Direct ID or hashed IdKey → `AttendanceOccurrence.Id` |
| `AttendanceOccurrenceGuid` | GUID → `AttendanceOccurrence.Guid` |
| `Date` (or `Occurrence`) + `LocationId` + `ScheduleId` | Composite lookup against group's occurrences |

If no matching occurrence exists, the block creates a **new** `[AttendanceOccurrence]` row on save.

### Each ROW = one person in the roster

The roster merges two data sources:

1. **Existing attendees** — `[Attendance]` rows for this occurrence where `DidAttend IS NOT NULL`
2. **Prospective attendees** — active `[GroupMember]` rows for this group who don't have an `[Attendance]` record yet

These are deduplicated by `PersonAliasId` and rendered via Lava templates into `GroupAttendanceDetailAttendanceBag`:

| Field | Source |
|---|---|
| **Name / Photo** | `Person.NickName`, `Person.LastName`, Lava-rendered `ItemTemplate` |
| **Did Attend** toggle | `Attendance.DidAttend` (true/false/null) |
| **Role(s)** | `GroupMember.GroupRole.Name` (a person can hold multiple roles) |
| **Campus** | `Person.PrimaryCampusId` (for campus-based filtering in the UI) |

### Save Operations

The Detail block uses **auto-save** — each action immediately writes to the database, not a batch submit:

| User Action | Block Action | Table Written | What Changes |
|---|---|---|---|
| Toggle a person's attendance | `MarkAttendance` | `[Attendance]` | Creates or updates `DidAttend` for one person |
| Check "We Did Not Meet" | `UpdateDidNotOccur` | `[AttendanceOccurrence]` + `[Attendance]` | Sets `DidNotOccur = 1` and nullifies all `DidAttend` values |
| Uncheck "We Did Not Meet" | `UpdateDidNotOccur` | `[AttendanceOccurrence]` + `[Attendance]` | Sets `DidNotOccur = 0` and creates `DidAttend = 0` for all group members |
| Edit notes | `UpdateNotes` | `[AttendanceOccurrence]` | Updates `Notes` column |
| Change attendance type | `UpdateAttendanceOccurrenceType` | `[AttendanceOccurrence]` | Updates `AttendanceTypeValueId` |
| Add a person | `GetOrCreate` | `[Attendance]` (+ optionally `[GroupMember]`) | Creates attendance row; optionally adds person to the group |

### "We Did Not Meet" — Data Implications

When `DidNotOccur` is toggled, the cascade affects child `[Attendance]` rows:

- **Checking it** → All `[Attendance].DidAttend` values for this occurrence are set to `NULL`. The occurrence still exists, but no attendance decisions are recorded.
- **Unchecking it** → `[Attendance]` rows are created (or updated) for every active group member with `DidAttend = 0` (a clean slate of "not yet attended").

This is why the List grid's `AttendanceEntered` computed property checks `DidNotOccur` as an OR condition — an occurrence marked "didn't meet" counts as "attendance has been addressed."

### The Three States of `[Attendance].DidAttend`

| Value | Meaning | UI State |
|---|---|---|
| `1` (true) | Person attended | Checked/green |
| `0` (false) | Person did not attend | Unchecked/explicit no |
| `NULL` | No decision recorded yet | Neutral/unrecorded |

This three-state model is important: `NULL` means "we haven't taken attendance yet" (or "Did Not Meet" was set), while `0` means "we took attendance and this person was absent."

---

## Reproducing the Detail Roster in SQL

```sql
DECLARE @input_OccurrenceId int = 1;

SELECT
    a.[Id]                                                 AS "AttendanceId"
  , pa.[PersonId]                                          AS "PersonId"
  , a.[PersonAliasId]                                      AS "PersonAliasId"
  , CONCAT(p.[NickName], ' ', p.[LastName])                AS "FullName"
  , a.[DidAttend]                                          AS "DidAttend"
  , gtr.[Name]                                             AS "Role"
  , a.[StartDateTime]                                      AS "StartDateTime"
  , ao.[DidNotOccur]                                       AS "OccurrenceDidNotOccur"
  , ao.[Notes]                                             AS "OccurrenceNotes"
FROM
    [Attendance] a
    INNER JOIN [AttendanceOccurrence] ao ON ao.[Id] = a.[OccurrenceId]
    INNER JOIN [PersonAlias] pa ON pa.[Id] = a.[PersonAliasId]
    INNER JOIN [Person] p ON p.[Id] = pa.[PersonId]
    LEFT JOIN [GroupMember] gm ON gm.[PersonId] = p.[Id] AND gm.[GroupId] = ao.[GroupId]
    LEFT JOIN [GroupTypeRole] gtr ON gtr.[Id] = gm.[GroupRoleId]
WHERE
    a.[OccurrenceId] = @input_OccurrenceId
ORDER BY
    p.[LastName]
  , p.[NickName]
;
```

Note: This only shows people who already have an `[Attendance]` row. The Detail block also displays active group members who have no attendance record yet (prospective attendees). To include those, UNION with `[GroupMember]` rows not already in the result.
