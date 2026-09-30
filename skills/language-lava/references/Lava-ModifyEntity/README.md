# Lava ModifyEntity

This directory collects notes about esoteric knowledge regarding `{% modifyentity %}` Lava commands — behaviors that aren't obvious from the language reference. Most were learned through testing in Rock; a few are read from the Rock source, and those say so explicitly at the top of the page.

For the language-level reference (parameters, property/attribute syntax, defensive rules, return-value shape), see [`../Lava-Language.md`](../Lava-Language.md) > "Modify Entity Command".

## Command-level mechanism

- [`DbTransaction.md`](DbTransaction.md) — `{% dbtransaction %}`: which commands participate, output suppression on rollback, short-circuit behavior, and the `{% sql %}` interaction

## Per-entity notes

- [`Schedule.md`](Schedule.md) — Creating a Schedule via `{% modifyschedule id:'0' %}`
- [`AttendanceOccurrence.md`](AttendanceOccurrence.md) — Creating an AttendanceOccurrence via `{% modifyattendanceoccurrence id:'0' %}`

## Cross-cutting findings

### Two kinds of rollback (Source-derived, August 2026)

Rollback shows up in two distinct scopes, and they are easy to conflate:

1. **Implicit, per-block.** A single `{% modifyentity %}` block is already atomic on its own. When one declaration inside it fails, the whole block is abandoned — see the `ParentReservationId` case in [`../Lava-Language.md`](../Lava-Language.md) > "Setting Entity Attributes", where a rejected `[[ attribute ]]` rolled back the entire Reservation create. You get this for free; you do not opt into it.

2. **Explicit, across blocks.** `{% dbtransaction %}` extends that atomicity across *several* commands, so a create-then-reference sequence cannot leave a half-built record behind. This is the one you have to ask for.

The distinction matters because Defensive Rule 1 pushes you toward splitting work into multiple `{% modifyentity %}` blocks, which is precisely what removes the implicit guarantee. Mutually exclusive branches do not need a transaction — only one of them runs. Sequentially dependent writes do. See [`DbTransaction.md`](DbTransaction.md).


### Empty `[[ property ]]` body writes a true SQL `NULL` to a nullable column (Tested May 2026)

Leaving the body of a `[[ property name:'X' ]][[ endproperty ]]` declaration empty — no value between the opening and closing tags — writes a true SQL `NULL` to the column. Not `0`, not the empty string, not a sentinel.

Verified on the nullable foreign-key column `[Group].[GroupAdministratorPersonAliasId]` while building the Sending-Coordinator clear path on PageId 6074 (the `commit-group-coordinator` endpoint of the `audit-signup-attendance` Lava Application). After the empty-body write:

```sql
SELECT [GroupAdministratorPersonAliasId]
FROM [Group]
WHERE [Id] = 787756 ;
-- result: NULL
```

The full clear branch:

```
{% modifygroup id:'{{ var_GroupId }}' return:'modify_Group' securityenabled:'false' %}
    [[ property name:'GroupAdministratorPersonAliasId' ]][[ endproperty ]]
{% endmodifygroup %}
```

**Why this matters:** It removes the need to fall back to a raw `{% sql %}UPDATE [Group] SET [GroupAdministratorPersonAliasId] = NULL WHERE [Id] = @GroupId{% endsql %}` for clear-style operations. Going through `{% modifyentity %}` keeps Rock's `SaveHook` chain and `[History]` audit row intact; the raw SQL path bypasses both.

**How to apply:**

Because the `[[ property ]]` bracket parser scans the raw body *before* Lava substitution (the same rule that makes `{% if %}` around a `[[ property ]]` line a no-op), you cannot conditionally choose between "empty body" and "value body" inside a single `{% modifyentity %}` block. Branch the **whole** block:

```
{% if var_IsClear %}
{% modifygroup id:'{{ var_GroupId }}' return:'modify_Group' securityenabled:'false' %}
    [[ property name:'GroupAdministratorPersonAliasId' ]][[ endproperty ]]
{% endmodifygroup %}
{% else %}
{% modifygroup id:'{{ var_GroupId }}' return:'modify_Group' securityenabled:'false' %}
    [[ property name:'GroupAdministratorPersonAliasId' ]]{{ var_PersonAliasId }}[[ endproperty ]]
{% endmodifygroup %}
{% endif %}
```

**Untested adjacencies (still open):**

- Nullable strings (e.g. `[Group].[Description]`) — likely same behavior, not yet verified personally.
- Required (`NOT NULL`) columns — empty body presumably writes the empty string or fails the save; don't infer from this finding.
- Custom Attributes via `[[ attribute key:'X' ]][[ endattribute ]]` — separate parser path that stores values as strings on `[AttributeValue]`. **Partially settled (Tested September 2026):** a declaration whose body *renders* to an empty string — `[[ attribute key:'DietaryRestrictions' ]]{{ var_Empty }}[[ endattribute ]]` — writes the empty string through rather than being skipped. Verified by clearing a DefinedValue multi-select Person Attribute from a Lava Application Endpoint and reading `[AttributeValue].[Value]` back as `''` with a fresh `[ModifiedDateTime]`. This is what makes a self-service "untick everything to clear it" flow possible at all.

  Still untested for attributes: a **literally** empty body (`[[ attribute key:'X' ]][[ endattribute ]]`, no Lava expression between the tags). Because the bracket parser scans the raw body before substitution, that is a different input to the parser than a body that renders empty — do not infer one from the other. Note also that for a qualifier-scoped attribute the literally-empty form fails outright for an unrelated reason; see [`../Lava-Language.md`](../Lava-Language.md) > "Setting Entity Attributes".

### Setting `Guid` via `[[ property name:'Guid' ]]` fails with a cast error (Tested April 2026)

Attempting to set the `Guid` property on a new entity via `[[ property name:'Guid' ]]{{ var_Guid }}[[ endproperty ]]` produces:

> Error setting property Guid to '...'. Error: Invalid cast from 'System.String' to 'System.Guid'.

Reproduced on a minimal `{% modifyschedule id:'0' %}` example with no other properties set. Applies to every entity type, not just Schedule. The `| AsGuid` filter is unlikely to help, because `{{ var_Guid }}` inside the property tags is rendered as a string regardless of the underlying variable's type.

**Workaround:** Don't set the `Guid` property explicitly. `{% modifyentity %}` auto-generates one on create, and the new entity's `Id` can be read directly from the named return — no SQL re-read needed:

```
{% modifyschedule id:'0' securityenabled:'false' return:'modify_NewSchedule' %}
    [[ property name:'iCalendarContent' ]]{{ var_iCal }}[[ endproperty ]]
{% endmodifyschedule %}

{% if modify_NewSchedule.Success == true %}
    {% assign var_NewScheduleId = modify_NewSchedule.Schedule.Id %}
{% endif %}
```
