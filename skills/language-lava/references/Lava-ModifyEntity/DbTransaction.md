# `{% dbtransaction %}` — Mechanism

Wraps a group of entity writes so that they either all commit or all roll back.

For the language-level reference (parameters, `TransactionResult` shape, basic usage), see [`../Lava-Language.md`](../Lava-Language.md) > "DB Transaction Command". This file documents the *mechanism* — the behaviors that are not obvious from the parameter list and that change how you have to write the surrounding template.

**Availability:** the command itself is v18.0. The `enablecontextisolation` parameter is v19.3, which is **not** available on our instance (last recorded version: v18.2.4, see [`../RockShop-Plugins/BEMA/RoomManagement/README.md`](../RockShop-Plugins/BEMA/RoomManagement/README.md)). Everything below describes the default `enablecontextisolation:'false'` path unless stated otherwise.

> **Provenance:** the findings on this page are **source-derived, not empirically tested** — read from the Rock source at commit `ba526de456e010e9802853a111e07c79dbb73ecc` (`develop`, 2026-08-18) rather than observed in a running Rock instance. Where a claim is an inference rather than a direct reading of the code, it says so inline. Re-verify against Rock's rendering before relying on any of it. Relevant files:
>
> - `Rock/Lava/Blocks/DbTransaction.cs`
> - `Rock/Lava/Blocks/Internal/DbTransactionResult.cs`
> - `Rock/Lava/Blocks/RockEntityModifyBlock.cs`
> - `Rock/Lava/Blocks/RockEntityDeleteBlock.cs`
> - `Rock/Lava/Blocks/SqlBlock.cs`


## How participation works

`DbTransaction.OnRender` opens a transaction on the RockContext it pulls out of the Lava context, then publishes a shared result object into an *internal* context field:

```csharp
context.SetInternalField( "rock_dbtransaction", transactionResult );

using ( var dbContextTransaction = rockContext.Database.BeginTransaction() )
```

A command participates in the transaction **only if it looks for that `rock_dbtransaction` field**. Exactly three files in the Rock source reference it: `DbTransaction.cs` (which sets it) and the two entity blocks (which read it). The class comment states the rule outright:

> Other blocks, tags and filters must specifically support being used inside a transaction in order to take advantage of the commit/rollback behavior.

So the participation roster is:

| Command | Participates? |
|---|---|
| `{% modifyentity %}` (`modifygroup`, `modifyperson`, …) | Yes — `RockEntityModifyBlock` |
| `{% deleteentity %}` (`deletegroup`, `deletereservation`, …) | Yes — `RockEntityDeleteBlock` |
| `{% sql %}` | Partially — see below |
| Everything else | No |

Note that `{% deleteentity %}` **does** participate. Rock's own documentation says transactions are "supported exclusively for encapsulating Modify Entity commands," but `RockEntityDeleteBlock` carries the identical participation code. Treat delete commands as transactional.


## Rollback suppresses all output from inside the block

This is the behavior most likely to bite, and it is not mentioned in Rock's documentation at all.

The block's inner content is rendered into a throwaway `StringWriter` first. That buffer is only flushed to the real output on **commit**:

```csharp
using ( TextWriter innerContentWriter = new StringWriter() )
{
    base.OnRender( context, innerContentWriter );
    output = innerContentWriter.ToString();
}

context.SetMergeField( "TransactionResult", transactionResult );

if ( transactionResult.Success == false || settings["forcerollback"].AsBoolean() )
{
    dbContextTransaction.Rollback();
}
else
{
    dbContextTransaction.Commit();
    result.Write( output );   //- only reached on commit
}
```

Three consequences:

1. **All error-handling markup must live outside the block.** Anything you write between `{% dbtransaction %}` and `{% enddbtransaction %}` is discarded when the transaction fails — including the `{% if %}` that was supposed to report the failure. Rock's sample template happens to get this right; it never explains that it is mandatory.

2. **`forcerollback:'true'` always renders nothing.** Since the flag forces the rollback branch, the block emits an empty string on every run. A dry run cannot print anything from inside itself; inspect `TransactionResult` after `{% enddbtransaction %}` instead.

3. **`TransactionResult` is always available after the block**, on both paths — `SetMergeField` runs before the commit/rollback branch. This is the one thing you can rely on reading.


## Failure short-circuits every later block

Both entity blocks open with the same guard, before doing any work:

```csharp
// Check that we're not in a db transaction where one db execution has already failed. In this
// case there is no reason for us to process as we'll just be rolled back and it's likely we
// won't have the data we need to run this update.
if ( context.GetInternalField( "rock_dbtransaction" ) is DbTransactionResult transactionResult )
{
    if ( !transactionResult.Success )
    {
        return;
    }
}
```

That `return` happens **before** the block builds its return object. So once any write in the transaction fails, every subsequent `{% modifyentity %}` / `{% deleteentity %}` in the block is skipped and **its named return variable is never assigned**.

The practical difference matters when you are debugging:

```lava
{% dbtransaction %}
    {% modifygroup id:'0' return:'modify_NewGroup' %}
        ...
    {% endmodifygroup %}

    {% modifygroupmember id:'0' return:'modify_NewMember' %}
        ...
    {% endmodifygroupmember %}
{% enddbtransaction %}
```

If `modify_NewGroup` fails, then `modify_NewMember` is not `Success == false` — it is **undefined**. Both are falsy, so a `{% if modify_NewMember.Success == true %}` gate still behaves correctly, but `modify_NewMember.ErrorMessage` renders blank rather than explaining anything. Read `TransactionResult.ErrorMessage` for the diagnosis, not the individual block's return.

Note also that this guard is what makes the "create Group, then add GroupMember referencing it" pattern safe: the second block does not run at all against a Group that was never created.


## `ErrorMessage` and `ValidationErrors` accumulate

When a participating block fails, it appends to the shared result rather than replacing it:

```csharp
transactionResultUpdate.Success = false;
transactionResultUpdate.ValidationErrors.AddRange( _result.ValidationErrors );
transactionResultUpdate.ErrorMessage += $" {_result.ErrorMessage}";
```

`ErrorMessage` starts as `string.Empty` and is concatenated with a **leading space** per failure. Because of the short-circuit above, in practice only one block can fail per transaction — but the accumulating shape means `TransactionResult.ErrorMessage` may carry a leading space. Pipe it through `| Trim` before displaying.

`ValidationErrors` is a `List<ValidationError>`, each item exposing `ErrorMessage` and `SourceControl`.


## `{% sql %}` — enlisted for rollback, invisible for failure detection

`{% sql %}` is the asymmetric case, and the asymmetry runs in the dangerous direction.

**It shares the connection.** `SqlBlock` resolves its context the same way `DbTransaction` does — `LavaHelper.GetRockContextFromLavaContext( context )` — and executes writes through that context:

```csharp
var rockContext = LavaHelper.GetRockContextFromLavaContext( context );
...
numOfRowsAffected = rockContext.Database.ExecuteSqlCommand( sql, sqlParameters.ToArray() );
```

Because the transaction was opened via `rockContext.Database.BeginTransaction()` on that same context, an `ExecuteSqlCommand` issued inside the block should enlist in the ambient transaction and roll back with it. **This is an inference from EF6 semantics plus the shared context, not a tested observation** — verify before relying on it.

**It cannot report failure.** `SqlBlock` never touches `rock_dbtransaction`. So:

- A `{% sql %}` that throws does not set `TransactionResult.Success = false`. It raises an exception, which propagates out of the `using` block; `DbContextTransaction.Dispose()` then rolls back the uncommitted transaction. The rollback happens, but as an exception path, not a clean `TransactionResult` you can branch on.
- A `{% sql %}` write that *succeeds at the database level but writes the wrong thing* leaves `Success == true`, and **the transaction commits**. No entity-level validation runs. Nothing catches it.

The rule that follows: do not use a raw `{% sql %}` write to carry a business rule inside a transaction. Route writes through `{% modifyentity %}`, which participates properly — and which also keeps Rock's `SaveHook` chain and `[History]` audit rows intact (see [`README.md`](README.md) > "Empty `[[ property ]]` body writes a true SQL `NULL`" for the same argument in a different context). A `{% sql %}` **select** inside the block is unremarkable and reads the uncommitted state, which is usually what you want.


## Attribute values did not roll back (Tested September 2026)

The participation table above is about *commands*. Within a participating command, entity **properties** and
entity **Attributes** were observed to behave differently.

A `{% dbtransaction %}` containing `{% modifyperson %}`, `{% modifyregistration %}` and
`{% modifyregistrationregistrant %}` failed on the last block (an unresolvable Attribute key). Afterwards:

| Written inside the transaction | Survived the rollback? |
|---|---|
| `[Registration]` and `[RegistrationRegistrant]` rows | No — correctly rolled back, neither row existed |
| The Person's `T-ShirtSize` and `DietaryRestrictions` `[AttributeValue]` rows | **Yes — the new values persisted** |

Every one of those writes was inside the same block, through `{% modifyentity %}` commands that do participate.

**Mechanism not confirmed.** The likely explanation is that Rock saves `[AttributeValue]` rows through a
different context from the entity rows, so they commit independently of the transaction opened on the
`rockContext` — but that is an inference from the observed behavior, not something read from source. It has not
been traced through `Rock/Attribute/Helper.cs` or the `SaveAttributeValues` path.

**What to design against:** treat `{% dbtransaction %}` as protecting **entity rows, not their AttributeValues**.
A create-then-reference sequence is still safe. A sequence whose correctness depends on attribute writes reverting
together with the rows they hang off is not, and should not be written until this is traced properly.

In the case observed the leak was benign — the Person Attribute writes were idempotent and were what the EndUser
had asked for regardless of whether the registration completed — but that was luck, not design.


## Security: no checkbox, by design

`DbTransaction` does not implement `ILavaSecured` — it has no `RequiredPermissionKey`. That is why it has no checkbox under a Block's Enabled Lava Commands, the same situation as `renderlavaendpoint`.

The command is therefore ungated: any template that can run Lava can open a transaction. All actual authorization comes from the commands *inside* it — `RockEntityModifyBlock` and `SqlBlock` both do implement `ILavaSecured` and are checked individually. Wrapping a modify command in a transaction neither grants nor requires any additional permission.


## Interaction with `enablecontextisolation` (v19.3, unavailable here)

When enabled, the block creates a brand-new RockContext and swaps it into the Lava context field for the duration, restoring the original in a `finally`:

```csharp
originalRockContext = context?.GetInternalField( LavaHelper.RockContextFieldKey, null ) as RockContext;
rockContext = RockApp.Current.CreateRockContext();
context.SetInternalField( LavaHelper.RockContextFieldKey, rockContext );
```

Since participating blocks resolve their context through that same field, they follow the swap — the isolation applies to everything inside, `{% sql %}` included. Its stated purpose is to stop a failed transaction from poisoning subsequent transaction statements in the same render. Not usable on v18.2.


## Open questions

- **Mostly not tested against a live Rock instance.** Every claim here is read from source, except the
  attribute-value rollback finding above, which is a live observation with an unconfirmed mechanism. The output-suppression behavior and the `{% sql %}` enlistment inference are the two most worth confirming empirically before writing production templates against them.
- **Nested `{% dbtransaction %}` blocks.** `SetInternalField( "rock_dbtransaction", … )` would be overwritten by an inner block with no save/restore (unlike the RockContext swap, which *is* restored). Behavior on nesting is unknown; avoid it.
- **Timeout inside a Lava Application Endpoint.** A `{% sql %}` timeout discards the entire rendered template and returns HTTP 200 (see the `surface-helix` skill's `Lava-with-Helix.md` > "`{% sql %}` Timeout Inside an Endpoint"). What happens to a transaction that is open when that fires has not been determined.
- **`AutoDetectChangesEnabled`.** `RockEntityModifyBlock` sets `rockContext.Configuration.AutoDetectChangesEnabled = true` on every render, noting that entity *read* commands disable it. Whether interleaving `{% group %}` reads with `{% modifygroup %}` writes inside one transaction has any ordering consequence is untested.
- These findings are pinned to commit `ba526de456e010e9802853a111e07c79dbb73ecc`. Re-verify against current Rock source before relying on them in a different Rock version.
