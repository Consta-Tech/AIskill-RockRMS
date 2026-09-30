> **Provenance tier:** `traced` — read from source or official documentation and cited (Rock version not recorded). Catalogued in the plugin's knowledge manifest; `/rockrms:knowledge-current` lists every entry.

GitHub:
- The frontend `.obs` file: https://github.com/SparkDevNetwork/Rock/blob/795e516ca60145a7670faa2b72d570743447c2fc/Rock.JavaScript.Obsidian.Blocks/src/CheckIn/checkInScheduleBuilder.obs
- the C# backend: https://github.com/SparkDevNetwork/Rock/blob/795e516ca60145a7670faa2b72d570743447c2fc/Rock.Blocks/CheckIn/CheckInScheduleBuilder.cs

---

## Data Model Breakdown

### Each ROW = one `[GroupLocation]` record

The grid queries `[GroupLocation]` (schema: `GroupLocation-and-GroupSchedule.md` in the `rock-sql-schema` skill). Each row represents a single `GroupLocation.Id` — a pairing of one `[Group]` + one `[Location]`.

| Column in UI | Source | SQL Detail |
|---|---|---|
| **Group** (main text) | `GroupService.GroupAncestorPathName(GroupId)` | Walks up `[Group].ParentGroupId` to build a path like `"Volunteer > Nursery > Age 0-1"` |
| **Group** (small text) | `CheckinAreaPath` for the Group's `GroupTypeId` | Walks the `[GroupType]` check-in hierarchy — e.g. `"Weekly Service Check-in > Children's"` |
| **Location** (main text) | `[Location].Name` | Direct lookup via `[GroupLocation].LocationId → [Location].Id` |
| **Location** (small text) | Parent location ancestry | Walks up `[Location].ParentLocationId` chain — e.g. `"Main Campus > Building A > Floor 1"` |

### Each COLUMN (after Group + Location) = one `[Schedule]` record

The schedules shown as columns come from `[Schedule]` filtered by:
- `[Schedule].IsActive = 1`
- `[Schedule].CheckInStartOffsetMinutes IS NOT NULL` (must be check-in enabled)
- `[Schedule].CategoryId` matches the selected Schedule Category filter (from `[Category]`)

### Each CELL (checkbox) = presence/absence of a row in `[GroupLocationSchedule]`

This is the junction table (same schema file). It has only two columns:

```
[GroupLocationSchedule]
├── GroupLocationId (FK → GroupLocation.Id)
└── ScheduleId     (FK → Schedule.Id)
```

- **Checked** = a row exists with that `(GroupLocationId, ScheduleId)` pair
- **Unchecked** = no such row exists
- **Save** adds/removes rows from this table via EF's many-to-many navigation property `GroupLocation.Schedules`

### The Filters

| Filter | What it does |
|---|---|
| **Group Type** | Restricts rows to `GroupLocation` records where the `Group.GroupTypeId` equals (or is a descendant of) a GroupType with `GroupTypePurposeValueId` = "Check-in Template" |
| **Area** | Further narrows to a specific descendant `[GroupType]` within the check-in hierarchy |
| **Parent Location** | Restricts rows to `GroupLocation` records whose `Location` is a descendant of the selected `[Location].ParentLocationId` |
| **Schedule Category** | Controls which `[Schedule]` records appear as columns (via `Schedule.CategoryId → Category.Id`) |

### Summary ER Diagram

```
[GroupType]  ←──  [Group]  ──→  [GroupLocation]  ←──→  [GroupLocationSchedule]  ←──→  [Schedule]  ──→  [Category]
                                      │
                                      ↓
                                 [Location]
```

The block is essentially a matrix editor for the `[GroupLocationSchedule]` junction table, with rows driven by `[GroupLocation]` and columns driven by `[Schedule]`.