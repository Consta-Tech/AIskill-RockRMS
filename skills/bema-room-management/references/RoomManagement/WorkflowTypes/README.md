# Room Management — WorkflowTypes

The plugin ships four `WorkflowType` definitions that handle reservation-lifecycle automation. They are templates — orgs can rename or fork them, and the actual wiring (which lifecycle event fires which workflow) lives in the per-`ReservationType` [`ReservationWorkflowTrigger`](../sql-tables/Reservation-Workflow.md#reservationworkflowtrigger) config table.

These docs describe the **vanilla intent** as exported from BEMA's published WorkflowType definitions.

## Index

| WorkflowType | Role | File |
|---|---|---|
| Approval Process | The state-machine orchestrator that drives a reservation through Initial → Special → Final approval gates. | [ApprovalProcess.md](ApprovalProcess.md) |
| Modification Process | Detects when a non-approver edits an already-approved reservation and decides whether to bump it back to a re-approval state. | [ModificationProcess.md](ModificationProcess.md) |
| Reminder Notification | Sends a reminder email to the event contact about an upcoming reservation. | [ReminderNotification.md](ReminderNotification.md) |
| Special Approval Notification | Sends a single email about a single Resource/Location that requires special approval. Launched from inside Approval Process. | [SpecialApprovalNotification.md](SpecialApprovalNotification.md) |

## How the four workflows collaborate

```
                   ┌───────────────────────────────────────────┐
   New Reservation │  APPROVAL PROCESS                         │
   submitted ───▶  │  (state-machine "master")                 │
                   │   reads Reservation.ApprovalState         │
                   │   activates 1 of 8 state activities       │
                   └─────────────┬─────────────────────────────┘
                                 │ may launch (one per child
                                 │ Resource/Location requiring
                                 │ special approval)
                                 ▼
                   ┌───────────────────────────────────────────┐
                   │  SPECIAL APPROVAL NOTIFICATION            │
                   │   one email per Resource/Location         │
                   └───────────────────────────────────────────┘

   Reservation     ┌───────────────────────────────────────────┐
   edited ──────▶  │  MODIFICATION PROCESS                     │
   after approval  │   classify changes; if significant,       │
                   │   write a NEW ApprovalState that          │
                   │   re-triggers Approval Process            │
                   └───────────────────────────────────────────┘

   Cron / Job      ┌───────────────────────────────────────────┐
   Reservation     │  REMINDER NOTIFICATION                    │
   approaching ─▶  │   "you have a reservation coming up"      │
                   └───────────────────────────────────────────┘
```

## Trigger architecture

There is **no hard-coded** "creating a Reservation launches Approval Process." The wiring lives in [`ReservationWorkflowTrigger`](../sql-tables/Reservation-Workflow.md#reservationworkflowtrigger) — a per-`ReservationType` config table that maps each lifecycle event to a `WorkflowType`. A Rock admin populates this table per reservation type via the "Workflow Triggers" panel on each [ReservationType](../BlockTypes/ReservationTypeDetail.md).

### Trigger types

(Enum: `com.bemaservices.RoomManagement.Model.ReservationWorkflowTriggerType`)

| Value | Name | Fires when… | QualifierValue |
|---|---|---|---|
| 0 | `ReservationCreated` | A new `[Reservation]` row is inserted. | (none) |
| 1 | `ReservationUpdated` | A `[Reservation]` row is updated. | (none) |
| 2 | `StateChanged` | `Reservation.ApprovalState` changes. | `\|FromState\|ToState\|` — either side blank means "any". |
| 3 | `Manual` | A user clicks a Manual-trigger button on the [ReservationDetail](../BlockTypes/ReservationDetail.md) page. | (button label / CSS class) |

### Wiring conventions (typical)

| WorkflowType | Typically wired to |
|---|---|
| Approval Process | `ReservationCreated` and `StateChanged` (any → any). The state machine handles each transition as a separate workflow run. |
| Modification Process | `ReservationUpdated`. |
| Reminder Notification | (none — fired by an external Rock Job on a schedule). |
| Special Approval Notification | (none — launched by Lava inside Approval Process's "Pending Special Approval" activity). |

### Verifying the bindings on a Rock instance

```sql
SELECT
    rt.[Name] AS "ReservationType"
  , wt.[Name] AS "WorkflowType"
  , rwt.[TriggerType]
  , rwt.[QualifierValue]
FROM
    [_com_bemaservices_RoomManagement_ReservationWorkflowTrigger] rwt
    JOIN [_com_bemaservices_RoomManagement_ReservationType] rt ON rt.[Id] = rwt.[ReservationTypeId]
    JOIN [WorkflowType] wt ON wt.[Id] = rwt.[WorkflowTypeId]
ORDER BY
    rt.[Name]
  , wt.[Name]
;
```

Each launched workflow is also logged into [`ReservationWorkflow`](../sql-tables/Reservation-Workflow.md#reservationworkflow), tied to both the `Reservation` and the `ReservationWorkflowTrigger` that fired it.

## Parallel instantiation: can two workflows run at once on the same Reservation?

**Yes — structurally, two workflows can be live on the same Reservation simultaneously.** A single save can match more than one trigger:

| Save scenario | `ReservationUpdated` matches? | `StateChanged` matches? |
|---|---|---|
| Approver clicks "Approve" (writes `ApprovalState=Approved`) | Yes | Yes |
| Non-approver edits Schedule/Campus, no state change | Yes | No |
| Modification Process writes a new `ApprovalState` | Yes | Yes |

When both match, BEMA's SaveHook calls `Workflow.Activate(...)` for both `WorkflowType`s back-to-back; both workflow rows are persisted and active.

The intent isn't "run them in parallel and let them race" — it's that **Modification Process self-suppresses for approvers** via its action `Set Attributes / End Workflow if Modifier in Approval Group`. So:

- An approver clicking "Approve" → both triggers fire → Approval Process runs the "Approved" cascade; Modification Process launches but exits immediately.
- A non-approver editing fields → only Modification Process runs; if the change is significant it writes a new `ApprovalState`, which re-triggers Approval Process on the *next* save.

The intended flow is therefore a **chain**, not a parallel pair:

```
non-approver edits Reservation
    │
    ▼
ReservationUpdated trigger ──▶ Modification Process
                                       │
                                       ├─ classify changes
                                       ├─ if significant, write
                                       │  Reservation.ApprovalState = PendingInitial/Special/Final
                                       │
                                       ▼
                                 (that write triggers a new save)
                                       │
                                       ▼
                              StateChanged trigger ──▶ Approval Process
                                                              │
                                                              ▼
                                                        handle the new state
```

### Genuine concurrency: the 14-day delay

The only path where a workflow can be **parked** (and therefore truly concurrent with a fresh launch) is the Approval Process "Pending Special Approval" activity's `Delay 14 Days if Notifications Already Sent` action. While that workflow is delayed (rechecked every 8h via `ProcessingIntervalSeconds`), the underlying Reservation can be edited and a new Modification Process or Approval Process can launch alongside it. The design relies on:

- The state machine's idempotence — each Approval Process run handles only its own current state.
- Modification Process's modifier-in-approval-group self-suppression.
- Last-writer-wins on `ApprovalState` SQL writes (no row-level locking).

If the [`ReservationApprovalGroup`](../sql-tables/Reservation-Workflow.md#reservationapprovalgroup) config is wrong, the modifier-in-approval-group lookup misses real approvers and Modification Process can incorrectly bump approved reservations back to a re-approval state.

## Conventions across all four workflows

1. Each WorkflowType has a `Set Attributes` activity at `Order=0` with `IsActivatedWithWorkflow=True`. All other activities have `IsActivatedWithWorkflow=False` and are reached only via `ActivateActivity`.
2. There is no separate "FINISH" activity. `CompleteWorkflow` is invoked inline at the end of each branch. (Differs from the in-house WorkflowType naming convention in `.claude/rules/formatting-standards.md` § 3.)
3. They lean on a custom BEMA action library — `com.bemaservices.RoomManagement.Workflow.Actions.Reservations.*` — for `GetApprovalGroup`, `SetReservationApprovalState`, `SetReservationLocationsApprovalStates`, and `SetReservationResourcesApprovalStates`. Without the BEMA DLL, none of the workflows function.
4. All four use `ProcessingIntervalSeconds: 28800` (8 hours) — the cadence at which delayed/parked workflows resume processing.
5. Several `Send Email` actions ship as `Active=False` template scaffolding — BEMA expects each org to fill in senders / customize before enabling.

## See also

- [`ReservationWorkflowTrigger` schema](../sql-tables/Reservation-Workflow.md#reservationworkflowtrigger) — the trigger config table.
- [`ReservationWorkflow` schema](../sql-tables/Reservation-Workflow.md#reservationworkflow) — the runtime instance log.
- [`ReservationApprovalGroup` schema](../sql-tables/Reservation-Workflow.md#reservationapprovalgroup) — the approval-group config queried by `GetApprovalGroup` and the modifier-in-approval-group check.
- [ReservationDetail block — Approval State Machine](../BlockTypes/ReservationDetail.md#approval-state-machine) — how the UI buttons drive state transitions.
- [ReservationTypeDetail block](../BlockTypes/ReservationTypeDetail.md) — where the trigger bindings are configured.
- [ApprovalState enums](../ApprovalState-Enums.md) — the three state enums (parent and two children).
