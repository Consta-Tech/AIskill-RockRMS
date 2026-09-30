# Creating an AttendanceOccurrence via `{% modifyattendanceoccurrence id:'0' %}`

> **Provenance tier:** `measured` — tested in a live Rock instance (Rock v18.2). Catalogued in the plugin's knowledge manifest; `/rockrms:knowledge-current` lists every entry.



Notes on what is (and isn't) required when creating an `[AttendanceOccurrence]` row through the `{% modifyattendanceoccurrence %}` Lava command, with the `id` parameter set to `'0'` to signal "create new".

## Source references

DB schema: [`skills/rock-sql-schema/references/Attendance.md`](../../../rock-sql-schema/references/Attendance.md) — search for `CREATE TABLE [dbo].[AttendanceOccurrence]`.

For the language-level reference (parameters, property/attribute syntax, defensive rules, return-value shape), see [`../Lava-Language.md`](../Lava-Language.md) > "Modify Entity Command".

## TL;DR

You can create an `AttendanceOccurrence` row by setting **only** these four properties — every other non-nullable column auto-populates via Rock's `PreSaveChanges` hook (or the column's DB DEFAULT):

```lava
{% modifyattendanceoccurrence id:'0' securityenabled:'false' return:'modify_AO' %}
    [[ property name:'GroupId' ]]{{ var_GroupId }}[[ endproperty ]]
    [[ property name:'LocationId' ]]{{ var_LocationId }}[[ endproperty ]]
    [[ property name:'ScheduleId' ]]{{ var_ScheduleId }}[[ endproperty ]]
    [[ property name:'OccurrenceDate' ]]{{ var_OccurrenceDateISO }}[[ endproperty ]]
{% endmodifyattendanceoccurrence %}

{% if modify_AO.Success == true %}
    {% assign var_NewOccurrenceId = modify_AO.AttendanceOccurrence.Id %}
{% endif %}
```

## Auto-populated columns (Tested May 2026)

Verified during Phase A of the `Audit SignUp Attendance` Lava Application. All three of the schema's non-nullable "computed" columns populate automatically on create:

| Column | Type | NULL | Default | Populated by |
|---|---|---|---|---|
| `[SundayDate]` | `date` | NOT NULL | `'1753-01-01'` | Rock's `PreSaveChanges` derives from `[OccurrenceDate]` (rounds up to the following Sunday). |
| `[OccurrenceDateKey]` | `int` | NOT NULL | `0` | Rock's `PreSaveChanges` derives from `[OccurrenceDate]` (`yyyyMMdd`-as-int format). |
| `[RootGroupTypeId]` | `int` | NULL | (none) | Rock's `PreSaveChanges` walks `[Group].[GroupTypeId]` → `[GroupType]`'s root via `InheritedGroupTypeId` chain. For Sign-Up Groups inheriting from the Sign-Up GroupType, this lands on the Sign-Up `[GroupType].[Id]`. |

Confirm with a post-write SELECT:

```sql
SELECT
    ao.[Id]
  , ao.[OccurrenceDate]
  , ao.[SundayDate]
  , ao.[OccurrenceDateKey]
  , ao.[RootGroupTypeId]
  , gt.[Name] AS "RootGroupTypeName"
FROM
    [AttendanceOccurrence] ao
    LEFT JOIN [GroupType] gt ON gt.[Id] = ao.[RootGroupTypeId]
WHERE
    ao.[Id] = @input_NewAOId
;
```

Expected: `[SundayDate]` is the Sunday on/after `[OccurrenceDate]`, `[OccurrenceDateKey]` matches `[OccurrenceDate]` formatted as `yyyyMMdd`, and `[RootGroupTypeId]` is the Sign-Up GroupType row (or whichever root applies for the parent Group).

## Idempotency — `IX_GroupId_LocationID_ScheduleID_Date`

A unique non-clustered index on `(GroupId, LocationId, ScheduleId, OccurrenceDate)` prevents duplicate AO rows for the same grain. Re-creating with the same four values raises a SQL Server unique-constraint violation — `modify_AO.Success == false` with `ErrorMessage` mentioning the index name.

Idempotent-write pattern: read first, write only when missing.

```lava
{% sql return:'array_Existing' GroupId:'{{ var_GroupId }}' ... %}
    SELECT TOP 1 ao.[Id]
    FROM [AttendanceOccurrence] ao
    WHERE ao.[GroupId] = @GroupId
      AND ao.[LocationId] = @LocationId
      AND ao.[ScheduleId] = @ScheduleId
      AND ao.[OccurrenceDate] = CAST(@OccurrenceDate AS date)
    ;
{% endsql %}
{% assign var_ExistingId = array_Existing | First | Property:'Id' %}

{% if var_ExistingId == null or var_ExistingId == '' %}
    {% modifyattendanceoccurrence id:'0' ... %}
        ...
    {% endmodifyattendanceoccurrence %}
{% endif %}
```

This pattern is used by both `create-occurrence.lava` (interactive create) and the *Create Missing AttendanceOccurrences for Sign-Up Opportunities (v1.0)* WorkflowType (nightly bulk create) — see the WorkflowType's own documentation (not yet included in this skill pack).

## What you should NOT set

- `[SundayDate]`, `[OccurrenceDateKey]`, `[RootGroupTypeId]` — auto-populated; explicit values risk drift from Rock's derivation logic.

  **`[OccurrenceDateKey]` verified at scale, 27-AUG-2026:** across all 220,039 `[AttendanceOccurrence]` rows, not one key is left at the `0` default, disagrees with its own `[OccurrenceDate]`, or fails to resolve in `[AnalyticsSourceDate]`. The derivation documented above holds everywhere in this database (verified with a DateKey-integrity probe query).

  That clean result is worth contrasting with the tables where the same check fails, because the difference is *how the rows were written*, not which column they hold: `[MetricValue].[MetricValueDateKey]` has 37 month/day transpositions in six single-day batches, and `[FinancialPledge]` has 2,769 pledges whose keys were never derived at all plus 410 off by a year. Every one of those looks like a bulk or raw-SQL write rather than an entity save — and `PreSaveChanges` does not fire on a `{% sql %}` INSERT. So the warning above is not theoretical: it is the exact failure mode observed on two sibling tables, and the reason this one is clean is that its rows go through the entity path.
- `[Guid]` — auto-generated. Setting it explicitly fails with an `Invalid cast from System.String to System.Guid` error (see the cross-cutting note in [`README.md`](README.md)).
- `[CreatedDateTime]`, `[ModifiedDateTime]`, `[CreatedByPersonAliasId]`, `[ModifiedByPersonAliasId]` — Rock's audit hooks populate these.
- `[DidNotOccur]` on create — leave NULL (will appear as NULL in subsequent queries; treat as `0` for state derivation, as `list-opportunities` does via `ISNULL(ao.[DidNotOccur], 0)`).

## What you CAN set on update (`id:'<numeric>'`)

The same four-property write path applies for updates — but the typical use case is toggling `[DidNotOccur]`, not modifying the grain itself. `mark-didnotoccur.lava` is the reference:

```lava
{% modifyattendanceoccurrence id:'{{ var_OccurrenceId }}' securityenabled:'false' return:'modify_AO' %}
    [[ property name:'DidNotOccur' ]]{{ var_Value | AsBoolean }}[[ endproperty ]]
{% endmodifyattendanceoccurrence %}
```

Note the `| AsBoolean` filter on the value — `[DidNotOccur]` is a `bit` C# `bool` property, and the property-bracket parser rejects `'0'` / `'1'` as "not a boolean" (per `feedback_modifyentity-boolean-needs-asboolean`).
