GitHub:
- SignUpOverview `.ascx`: https://github.com/SparkDevNetwork/Rock/blob/e1f77f73db63027091577d0a3e8d71dd73fa547a/RockWeb/Blocks/Engagement/SignUp/SignUpOverview.ascx
- SignUpOverview `.ascx.cs`: https://github.com/SparkDevNetwork/Rock/blob/e1f77f73db63027091577d0a3e8d71dd73fa547a/RockWeb/Blocks/Engagement/SignUp/SignUpOverview.ascx.cs
- SignUpDetail `.ascx`: https://github.com/SparkDevNetwork/Rock/blob/e1f77f73db63027091577d0a3e8d71dd73fa547a/RockWeb/Blocks/Engagement/SignUp/SignUpDetail.ascx
- SignUpDetail `.ascx.cs`: https://github.com/SparkDevNetwork/Rock/blob/e1f77f73db63027091577d0a3e8d71dd73fa547a/RockWeb/Blocks/Engagement/SignUp/SignUpDetail.ascx.cs
- SignUpOpportunityAttendeeList `.ascx`: https://github.com/SparkDevNetwork/Rock/blob/e1f77f73db63027091577d0a3e8d71dd73fa547a/RockWeb/Blocks/Engagement/SignUp/SignUpOpportunityAttendeeList.ascx
- SignUpOpportunityAttendeeList `.ascx.cs`: https://github.com/SparkDevNetwork/Rock/blob/e1f77f73db63027091577d0a3e8d71dd73fa547a/RockWeb/Blocks/Engagement/SignUp/SignUpOpportunityAttendeeList.ascx.cs

---

## Overview

The Sign-Up system lets people volunteer for specific time-and-place "opportunities" within a project. A project is a Group (with the Sign-Up GroupType), and each opportunity is a Schedule + Location attached to that Group. Three blocks work together: **Sign-Up Overview** lists all opportunities across all projects, **Sign-Up Detail** lets admins configure a single project and its opportunities, and **Sign-Up Opportunity Attendee List** shows the roster of people who signed up for one specific opportunity.

## Table of Contents

1. [Shared Data Model](#shared-data-model)
1. [Sign-Up Overview Block](#sign-up-overview-block)
1. [Sign-Up Detail Block](#sign-up-detail-block)
1. [Reproducing the Overview Grid in SQL](#reproducing-the-overview-grid-in-sql)
1. [Sign-Up Opportunity Attendee List Block](#sign-up-opportunity-attendee-list-block)

---

## Shared Data Model

Both blocks operate on the same underlying entities. The Sign-Up system repurposes the existing Group/Schedule infrastructure with a Sign-Up-specific GroupType.

### The Sign-Up Entity Stack

| Table | Role in Sign-Ups |
|---|---|
| `[Group]` | The **project** container (GroupTypeId = Sign-Up Group or inherits from it) |
| `[GroupType]` | Must be the system Sign-Up GroupType or inherit from it |
| `[GroupLocation]` | Links the project (Group) to a physical **location** |
| `[GroupLocationSchedule]` | Junction: ties a GroupLocation to a **schedule** (creates an "opportunity") |
| `[GroupLocationScheduleConfig]` | Stores opportunity **name + capacity** targets for each GroupLocation+Schedule pair |
| `[Schedule]` | The date/time of the opportunity (custom iCal or named schedule) |
| `[Location]` | The place |
| `[GroupMember]` | A person who has signed up for the project |
| `[GroupMemberAssignment]` | Assigns a GroupMember to a **specific** LocationId + ScheduleId (this is "who signed up for which opportunity") |
| `[GroupRequirement]` | Eligibility criteria to sign up |

### What Is an "Opportunity"?

An opportunity = **one row in `[GroupLocationSchedule]`** (a GroupLocationId + ScheduleId pair), enriched by the corresponding row in `[GroupLocationScheduleConfig]` (which gives it a name and capacity numbers).

There is no standalone "Opportunity" table. The concept is assembled at runtime from the junction of GroupLocation + Schedule + Config.

### How Sign-Ups Are Tracked

When a person signs up for an opportunity:
1. A `[GroupMember]` row is created (or already exists) linking the Person to the Group.
2. A `[GroupMemberAssignment]` row is created with `GroupMemberId`, `LocationId`, `ScheduleId`, and `GroupId`.

The unique index `IX_GroupMemberIdLocationIdScheduleId` on `[GroupMemberAssignment]` enforces: **one assignment per person per opportunity** (GroupMember + Location + Schedule).

### Capacity (Slot Counts)

Capacity lives in `[GroupLocationScheduleConfig]`:

| Column | Meaning |
|---|---|
| `MinimumCapacity` | Minimum desired sign-ups |
| `DesiredCapacity` | Target sign-ups |
| `MaximumCapacity` | Hard cap on sign-ups |

**Slots Filled** = `COUNT(*)` of `[GroupMemberAssignment]` rows matching that `(GroupId, LocationId, ScheduleId)`.

**Slots Available** = `MaximumCapacity - SlotsFilled` (computed at runtime, not stored).

---

## Sign-Up Overview Block

This block shows a **grid of all opportunities** across all sign-up projects.

### Each ROW = one opportunity (Group + Location + Schedule)

The query starts from `[GroupLocation]`, flattens via `SelectMany` over its Schedules, and joins `[GroupLocationScheduleConfig]`:

```csharp
GroupLocationService.Queryable()
    .Where( gl => gl.Group.IsActive
        && ( gl.Group.GroupTypeId == SignUpGroupTypeId
          || gl.Group.GroupType.InheritedGroupTypeId == SignUpGroupTypeId ) )
    .SelectMany( gl => gl.Schedules, ( gl, s ) => new {
        gl.Group,
        GroupLocationId = gl.Id,
        gl.Location,
        Schedule = s,
        Config = gl.GroupLocationScheduleConfigs.FirstOrDefault( c => c.ScheduleId == s.Id )
    } );
```

Participant counts come from a separate `[GroupMemberAssignment]` query grouped by (GroupId, LocationId, ScheduleId).

### Grid Columns

| Column in UI | Property | Source |
|---|---|---|
| **Project Name** | `ProjectName` | `Group.Name` (or `Group.ParentGroup.Name + " > " + Group.Name`) |
| **Schedule** | `FriendlySchedule` | `Schedule.FriendlyScheduleText` (computed from iCal content or Schedule.Name) |
| **Leader Count** | `LeaderCount` | Count of `[GroupMemberAssignment]` rows where the GroupMember's GroupRole `IsLeader = 1` |
| **Participant Count** | `ParticipantCount` | Total count of `[GroupMemberAssignment]` rows for this opportunity |
| **Slots Available** | `SlotsAvailable` | `MaximumCapacity - ParticipantCount` (computed in C#) |

### Grid Data Keys

The grid identifies each row by the composite key: `GroupId`, `LocationId`, `ScheduleId` (plus `GroupLocationId` and row `Guid`).

### Filters

| Filter | Applied To |
|---|---|
| **Schedule Date Range** | `Schedule.EffectiveEndDate >= fromDate` (DB-side), then `NextOrLastStartDateTime` within range (post-materialization) |
| **Parent Group** | `Group.Id = @selectedGroupId` (or `Group.ParentGroupId`) |
| **Slots Available** | Comparison operator applied to the computed `SlotsAvailable` property (post-materialization) |

---

## Sign-Up Detail Block

This block shows the **configuration and opportunity list for a single sign-up project** (one Group).

### View Mode — Opportunities Grid

Each row in the Opportunities grid = one opportunity within this project (same grain as Overview):

| Column in UI | Property | Source |
|---|---|---|
| **Opportunity Name** | `Name` | `GroupLocationScheduleConfig.ConfigurationName` |
| **Date/Time** | `FriendlyDateTime` | `Schedule.FriendlyScheduleText` |
| **Location** | `FriendlyLocation` | `Location.Name` (via GroupLocation → Location) |
| **Sign-Ups** (progress bar) | `ProgressBar` | HTML bar: `SlotsFilled / MaximumCapacity`, colored by Min/Desired/Max thresholds |

### Edit Mode — Project Configuration

When editing, the block writes to:

| Field | Writes To |
|---|---|
| Project Name | `Group.Name` |
| Active | `Group.IsActive` |
| Description | `Group.Description` |
| Group Type | `Group.GroupTypeId` |
| Campus | `Group.CampusId` |
| Record Source | `Group.GroupMemberRecordSourceValueId` |
| Reminder Communication | `Group.ReminderSystemCommunicationId` |
| Reminder Offset | `Group.ReminderOffsetDays` |
| Reminder Details | `Group.ReminderAdditionalDetails` |
| Confirmation Details | `Group.ConfirmationAdditionalDetails` |
| Custom Attributes | `AttributeValue` (entity-type: Group) |

### Adding an Opportunity (modal dialog)

Creates/updates records across multiple tables in a transaction:

1. **Schedule** — Creates a new `[Schedule]` row (custom iCal) or references an existing named schedule.
2. **GroupLocation** — Creates or finds an existing `[GroupLocation]` row for the Group + selected Location.
3. **GroupLocationSchedule** — Adds the Schedule to the GroupLocation's Schedules collection (junction table insert).
4. **GroupLocationScheduleConfig** — Creates the config row with ConfigurationName, MinimumCapacity, DesiredCapacity, MaximumCapacity, ReminderAdditionalDetails, ConfirmationAdditionalDetails.

### Deleting an Opportunity

Cascade deletion in order:
1. Delete `[GroupMemberAssignment]` rows for this (GroupId, LocationId, ScheduleId)
2. Delete orphaned `[GroupMember]` rows (if the member has no remaining assignments)
3. Delete the `[GroupLocationScheduleConfig]` row
4. Remove the Schedule from the GroupLocation's Schedules collection (junction table delete)
5. Delete the `[GroupLocation]` if it has no remaining schedules
6. Delete the `[Schedule]` if it was a custom schedule and is now unreferenced

### Group Requirements

Stored in `[GroupRequirement]` linked to the Group. The block manages:
- Inherited requirements (from GroupType)
- Group-specific requirements

### Member Attributes

Two levels of custom attributes are configurable:
- **Member Attributes** — `[Attribute]` with EntityType = GroupMember, qualifier `GroupId = {this group}`
- **Member Opportunity Attributes** — `[Attribute]` with EntityType = GroupMemberAssignment, qualifier `GroupId = {this group}`

---

## Summary ER Diagram

```
[GroupType]
     ↑
[Group] (the project)
     │
     ├──→ [GroupLocation] ──→ [Location]
     │         │
     │         ├──→ [GroupLocationSchedule] (junction) ──→ [Schedule]
     │         │
     │         └──→ [GroupLocationScheduleConfig]
     │                   (ConfigurationName, Min/Desired/MaxCapacity)
     │
     ├──→ [GroupMember] ──→ [PersonAlias] → [Person]
     │         │
     │         └──→ [GroupMemberAssignment]
     │                   (LocationId, ScheduleId → the specific opportunity)
     │
     └──→ [GroupRequirement] ──→ [GroupRequirementType]
```

---

## Reproducing the Overview Grid in SQL

```sql
DECLARE @input_SignUpGroupTypeId int;
SELECT @input_SignUpGroupTypeId = [Id] FROM [GroupType] WHERE [Guid] = '499B1367-06B3-4FEA-B1C0-A9B05C6164C2';

SELECT
    g.[Id]                                                             AS "GroupId"
  , gl.[Id]                                                            AS "GroupLocationId"
  , l.[Id]                                                             AS "LocationId"
  , s.[Id]                                                             AS "ScheduleId"
  , g.[Name]                                                           AS "ProjectName"
  , COALESCE(glsc.[ConfigurationName], g.[Name])                       AS "OpportunityName"
  , s.[Name]                                                           AS "ScheduleName"
  , l.[Name]                                                           AS "LocationName"
  , glsc.[MinimumCapacity]                                             AS "SlotsMin"
  , glsc.[DesiredCapacity]                                             AS "SlotsDesired"
  , glsc.[MaximumCapacity]                                             AS "SlotsMax"
  , COUNT(gma.[Id])                                                    AS "SlotsFilled"
  , glsc.[MaximumCapacity] - COUNT(gma.[Id])                           AS "SlotsAvailable"
  , SUM(CASE WHEN gr.[IsLeader] = 1 THEN 1 ELSE 0 END)                AS "LeaderCount"
  , SUM(CASE WHEN gr.[IsLeader] = 0 THEN 1 ELSE 0 END)                AS "ParticipantCount"
FROM
    [GroupLocation] gl
    INNER JOIN [Group] g ON g.[Id] = gl.[GroupId]
    INNER JOIN [GroupType] gt ON gt.[Id] = g.[GroupTypeId]
    INNER JOIN [GroupLocationSchedule] gls ON gls.[GroupLocationId] = gl.[Id]
    INNER JOIN [Schedule] s ON s.[Id] = gls.[ScheduleId]
    LEFT JOIN [Location] l ON l.[Id] = gl.[LocationId]
    LEFT JOIN [GroupLocationScheduleConfig] glsc ON glsc.[GroupLocationId] = gl.[Id] AND glsc.[ScheduleId] = s.[Id]
    LEFT JOIN [GroupMemberAssignment] gma ON gma.[GroupId] = g.[Id] AND gma.[LocationId] = gl.[LocationId] AND gma.[ScheduleId] = s.[Id]
    LEFT JOIN [GroupMember] gm ON gm.[Id] = gma.[GroupMemberId]
    LEFT JOIN [GroupTypeRole] gr ON gr.[Id] = gm.[GroupRoleId]
WHERE
    g.[IsActive] = 1
    AND (gt.[Id] = @input_SignUpGroupTypeId OR gt.[InheritedGroupTypeId] = @input_SignUpGroupTypeId)
GROUP BY
    g.[Id]
  , gl.[Id]
  , l.[Id]
  , s.[Id]
  , g.[Name]
  , glsc.[ConfigurationName]
  , s.[Name]
  , l.[Name]
  , glsc.[MinimumCapacity]
  , glsc.[DesiredCapacity]
  , glsc.[MaximumCapacity]
ORDER BY
    g.[Name]
  , s.[Name]
;
```

Note: The system Guid for the Sign-Up GroupType (`499B1367-06B3-4FEA-B1C0-A9B05C6164C2`) is from `Rock.SystemGuid.GroupType.GROUPTYPE_SIGNUP_GROUP`. Verify this matches your Rock instance.

---

## Sign-Up Opportunity Attendee List Block

This block is the **drill-down** from the Overview grid's "Attendee List" link button. It shows the roster of people who signed up for one specific opportunity.

### Opportunity Identification (Page Parameters)

The block identifies the opportunity via three query string parameters:

| Parameter | Maps To |
|---|---|
| `GroupId` | `GroupMemberAssignment.GroupId` / `GroupMember.GroupId` |
| `LocationId` | `GroupMemberAssignment.LocationId` |
| `ScheduleId` | `GroupMemberAssignment.ScheduleId` |

These three values together pinpoint a single opportunity (the same composite key used throughout the Sign-Up system).

### Each ROW = one `[GroupMemberAssignment]` record

The query:

```csharp
GroupMemberAssignmentService.Queryable()
    .Include( gma => gma.GroupMember )
    .Include( gma => gma.GroupMember.GroupRole )
    .Include( gma => gma.GroupMember.Person )
    .Where( gma =>
        gma.GroupMember.GroupId == _groupId
        && gma.LocationId == _locationId
        && gma.ScheduleId == _scheduleId
    );
```

Each row = one person's sign-up for this opportunity, loaded through `[GroupMemberAssignment]` → `[GroupMember]` → `[Person]` + `[GroupTypeRole]`.

### Visible Grid Columns

| Column in UI | Source | SQL Detail |
|---|---|---|
| **Name** (with photo) | `Person.FullName`, `Person.PhotoUrl` | `[GroupMemberAssignment] → [GroupMember] → [Person].NickName + LastName` |
| **Role** | `GroupRole.Name` | `[GroupMember].GroupRoleId → [GroupTypeRole].Name` |
| **Member Status** | `GroupMember.GroupMemberStatus` | `[GroupMember].GroupMemberStatus` (enum: Active/Inactive/Pending) |
| **Dynamic attribute columns** | Merged from GroupMember + GroupMemberAssignment attributes | `[AttributeValue]` keyed by EntityId |

### Export-Only Columns (hidden in UI, included in Excel/CSV export)

| Column | Source |
|---|---|
| Full Name (reversed) | `Person.LastName, NickName` |
| Note | `GroupMember.Note` |
| Nick Name | `Person.NickName` |
| Last Name | `Person.LastName` |
| Birth Date | `Person.BirthDate` |
| Age | `Person.Age` (computed) |
| Email | `Person.Email` |
| Record Status | `Person.RecordStatusValueId` → DefinedValue |
| Gender | `Person.Gender` |
| Is Deceased | `Person.IsDeceased` |
| Home Phone | PhoneNumber lookup by type |
| Cell Phone | PhoneNumber lookup by type |
| Home Address | Family group location lookup |
| Latitude / Longitude | From home address Location |

### Filters

| Filter | Applied To |
|---|---|
| **First Name** | `Person.NickName` or `Person.FirstName` starts with value |
| **Last Name** | `Person.LastName` starts with value |
| **Role** | `GroupMember.GroupRoleId` in selected values |
| **Group Member Status** | `GroupMember.GroupMemberStatus` in selected enum values |
| **Family Campus** | Person's family group (GroupTypeId = Family) has matching `CampusId` |
| **Gender** | `Person.Gender` in selected values |
| **Member Attributes** | `AttributeValue` filter on GroupMember entity |
| **Opportunity Attributes** | `AttributeValue` filter on GroupMemberAssignment entity |

### Delete/Remove Logic

When removing an attendee from an opportunity:

1. Delete the `[GroupMemberAssignment]` row for this person + opportunity.
2. If the `[GroupMember]` has **no remaining assignments**:
   - If GroupType has `EnableGroupHistory = 1` and the member has history → **archive** the GroupMember.
   - Otherwise → **delete** the GroupMember entirely.

### Reproducing This Grid in SQL

```sql
DECLARE @input_GroupId int = 1;
DECLARE @input_LocationId int = 1;
DECLARE @input_ScheduleId int = 1;

SELECT
    gma.[Id]                                               AS "AssignmentId"
  , gm.[Id]                                                AS "GroupMemberId"
  , p.[Id]                                                 AS "PersonId"
  , CONCAT(p.[NickName], ' ', p.[LastName])                AS "FullName"
  , gtr.[Name]                                             AS "Role"
  , gtr.[IsLeader]                                         AS "IsLeader"
  , gm.[GroupMemberStatus]                                 AS "MemberStatus"
  , gm.[Note]                                              AS "Note"
  , p.[Email]                                              AS "Email"
  , p.[Gender]                                             AS "Gender"
  , p.[BirthDate]                                          AS "BirthDate"
FROM
    [GroupMemberAssignment] gma
    INNER JOIN [GroupMember] gm ON gm.[Id] = gma.[GroupMemberId]
    INNER JOIN [Person] p ON p.[Id] = gm.[PersonId]
    INNER JOIN [GroupTypeRole] gtr ON gtr.[Id] = gm.[GroupRoleId]
WHERE
    gma.[GroupId] = @input_GroupId
    AND gma.[LocationId] = @input_LocationId
    AND gma.[ScheduleId] = @input_ScheduleId
ORDER BY
    p.[LastName]
  , p.[NickName]
;
```
