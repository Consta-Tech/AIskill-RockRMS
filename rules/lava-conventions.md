---
trigger: always_on
---
# Lava Coding Conventions

> **Provenance tier:** `traced` — read from source or official documentation and cited (house convention, no Rock version). Catalogued in the plugin's knowledge manifest; `rockrms-knowledge-current` lists every entry.



## `{% modifyentity %}` Commands

When writing `{% modifyentity %}` commands (E.g.: `modifygroup`, `modifygroupmember`, `modifyperson`, etc.), follow the four defensive rules below. Full documentation, tested behaviors, and examples are in the `language-lava` skill: `references/Lava-Language.md` > "Modify Entity Command", plus per-entity notes in `references/Lava-ModifyEntity/`.

1. **Separate blocks for separate fields.** Never put properties for mutually exclusive actions in the same `{% modifyentity %}` block. Each action gets its own block, guarded by an external `{% if %}`.

2. **One declaration per property.** Within a single block, each `[[ property ]]` should appear exactly once. Use `{% if %}` to control the *value* between the tags, not whether the declaration exists.

3. **Named return variables.** Always use `return:'modify_DescriptiveName'` on every `{% modifyentity %}` block. Never rely on the default `ModifyResult`. Check the named result directly (e.g., `modify_IsActive.Success == true`).

4. **Wrap dependent writes in a transaction.** When two or more entity writes must succeed or fail together — most often a create-then-reference sequence — wrap them in `{% dbtransaction %}` so a mid-sequence failure cannot leave a half-built record behind.

```lava
{% dbtransaction %}
    {% modifygroup id:'0' securityenabled:'false' return:'modify_NewGroup' %}
        ...
    {% endmodifygroup %}

    {% modifygroupmember id:'0' securityenabled:'false' return:'modify_NewMember' %}
        [[ property name:'GroupId' ]]{{ modify_NewGroup.Group.Id }}[[ endproperty ]]
        ...
    {% endmodifygroupmember %}
{% enddbtransaction %}

{% if TransactionResult.Success == false %}
    ...error markup...
{% endif %}
```

Three things this rule depends on, all of which are easy to get wrong:

- **Error markup goes outside the block.** Content rendered between `{% dbtransaction %}` and `{% enddbtransaction %}` is discarded entirely on rollback, so an `{% if %}` placed inside can never report the failure it was written for.
- **`TransactionResult` is the diagnosis, not the inner returns.** There is no `return:` parameter on `{% dbtransaction %}` — the key is hardcoded, and `return:'foo'` fails silently. Keep named returns on the inner blocks for reading back a created `Id`, but read `TransactionResult.ErrorMessage` (piped through `| Trim`) when something fails: once one write fails, later blocks are skipped and their named returns are never assigned.
- **This does not replace Rule 1.** Mutually exclusive branches still get separate externally-guarded blocks and need no transaction — only one of them runs. Rule 4 is for writes that are *sequentially dependent*, which is the case Rule 1 creates.

Only `{% modifyentity %}` and `{% deleteentity %}` participate. A raw `{% sql %}` write inside the block shares the connection but cannot report failure, so it commits silently when it writes the wrong thing — never let a `{% sql %}` write carry a business rule inside a transaction.

Use `forcerollback:'true'` to dry-run a sequence; note that it suppresses the block's output entirely, so inspect `TransactionResult` afterward. Parameter reference in the `language-lava` skill's `Lava-Language.md` > "DB Transaction Command"; full mechanism and provenance in its `Lava-ModifyEntity/DbTransaction.md`.

## `{% sql %}` Inside a Lava Application Endpoint

**Declare an explicit `timeout:`**, in seconds, **whenever the query's measured worst case approaches or exceeds the 30-second default.** Below that, omit it — `timeout:'30'` only restates the default, and writing it on a fast query is noise that makes the genuinely long-running queries harder to spot.

```lava
{% sql return:'array_Roster' timeout:'60' pCamp:'{{ var_Camp }}' %}
    ...
{% endsql %}
```

The point of the rule is *sizing*, not ceremony. A point lookup on an indexed column needs no declaration; a recurrence expansion over a large date range needs one, sized from what you actually measured.

This is the *only* safeguard available. When a `{% sql %}` times out, Rock discards the entire rendered template and returns the string `Lava Error: (Block: sql) Execution Timeout Expired.` with an HTTP **200** — so no `{% if %}`, `{% capture %}`, or fallback markup anywhere in that endpoint can catch it, and no client-side error handler keyed on HTTP status will fire either.

Do not build interception machinery for this. With `timeout:` sized correctly, a timeout means a genuine outage, not a routine condition. Tested behavior and the full rationale are in the `surface-helix` skill's `Lava-with-Helix.md` > "`{% sql %}` Timeout Inside an Endpoint".

Separately, `{% if obj == null %}` after `{% assign obj = array_X | First %}` is still worth writing — it catches an empty result set, which is a different and far more common condition.
