# Approval Process WorkflowType

> **Provenance tier:** `traced` — read from source or official documentation and cited (Rock v18.2.4). Catalogued in the plugin's knowledge manifest; `rockrms-knowledge-current` lists every entry.



| Field | Vanilla value |
|---|---|
| `WorkflowType.Name` | `Approval Process` |
| `Description` | "A workflow that sends an email to the party responsible for the next step in the room reservation approval process." |
| `WorkTerm` | `Approval Request` |
| `ProcessingIntervalSeconds` | `28800` (8h) |
| `IsPersisted` | `True` |
| `IconCssClass` | `fa fa-list-ol` |
| Receives `Entity` = | `Reservation` |

## Purpose

Drive a reservation through Initial → Special → Final approval gates, send the right notifications at each gate, and write `Reservation.ApprovalState` as gates open and close. This is the workhorse of the four WorkflowTypes and the only one that touches all eight reservation states.

## Triggered by (typical)

`ReservationCreated` and `StateChanged` (any → any). The workflow handles **exactly one transition per run** — it gets re-launched each time `ApprovalState` changes, so the lifecycle is a series of independent workflow runs, one per state transition.

## Workflow Attributes

| Key | Purpose |
|---|---|
| `Reservation` | The Reservation being processed (Object reference). |
| `ApprovalState` | String mirror of `Reservation.ApprovalState` — the activity router keys off this. |
| `ReservationType`, `Campus` | Inputs to the BEMA `GetApprovalGroup` action that resolves Initial/Final approval groups. |
| `InitialApprovalGroup`, `FinalApprovalGroup` | Resolved groups to notify at each gate. |
| `Requester`, `EventContact`, `AdminContact` | People to email (resolved from Reservation properties). |
| `InitialApprovalDateTime`, `SpecialApprovalDateTime`, `FinalApprovalDateTime` | Snapshots of when each gate completed — used to short-circuit if already approved. |
| `GroupsNotified` | Counter set by Lava during Pending Special Approval to detect "no special groups configured". |
| `InitialSpecialApprovalRemindersSent` | Boolean guard so the 14-day delay loop only happens once. |

## Activity flow (state-machine dispatcher)

The first activity, "Set Attributes and Launch State Activity", is the only one with `IsActivatedWithWorkflow=True`. It hydrates working memory from the Reservation, then dispatches to exactly one of eight state activities based on `ApprovalState`. The dispatched state activity does its work and `CompleteWorkflow`s.

### Activity 0: "Set Attributes and Launch State Activity"

1. **Hydrate Workflow Attributes from Entity** — `Set Reservation Type`, `Set Campus`, `Set Reservation From Entity`, `Set Event Contact from Entity`, `Set Admin Contact From Entity`, `Set Approval State From Entity`, `Set Initial/Special/Final Approval Date Time`.
2. **Resolve approval groups** — `Set Initial Approval Group` and `Set Final Approval Group` call `com.bemaservices.RoomManagement.Workflow.Actions.Reservations.GetApprovalGroup` to look up groups by `(ReservationType, Campus)`.
3. **Rename the workflow** — `Set Workflow Name`: `<Reservation Name> (ID:<id>): <ApprovalState>`.
4. **Dispatch** — eight `ActivateActivity` actions, each gated `Run-If: ApprovalState == "<state name>"`. Exactly one fires.
5. **Fallback** — `Complete Workflow if No Matching Approval State` ends the workflow if the dispatch missed.

### State activities (one fires, then the workflow completes)

| State (string) | Activity behavior |
|---|---|
| `Draft` | `Complete Workflow`. Drafts don't notify anyone. |
| `PendingInitialApproval` | If no `InitialApprovalGroup` is configured for `(ReservationType, Campus)` → bump state to `PendingSpecialApproval` (=6) via `SetReservationApprovalState` and end. If `InitialApprovalDateTime` is already set → also end. Otherwise email the Initial Approval Group. *(Vanilla ships the email action as `Active=False`; orgs enable + customize before use.)* |
| `PendingSpecialApproval` | The most complex state activity — see [§ Pending Special Approval](#pending-special-approval) below. |
| `PendingFinalApproval` | Same shape as Pending Initial: short-circuit on missing group / already-approved, otherwise email the Final Approval Group. *(Same `Active=False` quirk on the Send Email action.)* |
| `Approved` | Cascades approval down to all child Locations (`SetReservationLocationsApprovalStates`) and Resources (`SetReservationResourcesApprovalStates`) with `ApprovalState=2` (Approved). Emails Admin Contact + Event Contact. |
| `ChangesNeeded` | Emails Admin Contact + Event Contact with the "needs changes" template. No state writes. |
| `Denied` | Cascades `ApprovalState=3` (Denied) to all child Locations and Resources. Emails Admin + Event Contact. |
| `Cancelled` | `Complete Workflow`. |

#### Pending Special Approval

(Integer enum value: `6`.)

1. **`Delay 14 Days if Notifications Already Sent`** — if `InitialSpecialApprovalRemindersSent == "Yes"`, parks the workflow for 20160 minutes (14 days). On wake, the same activity continues, sending fresh reminders.
2. **`Send Notifications to Any Special Approval Groups`** — Lava that walks each `ReservationResource` and `ReservationLocation` on the Reservation, identifies those with their own `ApprovalGroupId` set, and launches a [Special Approval Notification](SpecialApprovalNotification.md) workflow per item, counting them in `GroupsNotified`.
3. **`Mark Initial Notifications as Sent`** — sets `InitialSpecialApprovalRemindersSent = "Yes"`.
4. **`Complete Workflow If Approval State Has Changed Since Activity Started`** — guards against acting on stale state.
5. **`Set Resource States` / `Set Location States`** — bumps non-special-approval children (those *without* their own `ApprovalGroupId`) to `Approved` (=2) via the BEMA `Set...ApprovalStates` actions, with `IgnoreResourcesWithApprovalGroups: True` / `IgnoreLocationsWithApprovalGroups: True`.
6. **`Activate Send Special Approval Reminders if Any Special Approval Groups`** — if `GroupsNotified > 0`, re-activates *this same activity* to set up the 14-day reminder loop.
7. **`Set Special Approval Date If Blank`** — writes `Reservation.SpecialApprovalDateTime = Now` if blank.
8. **`Set Reservation to Pending Final Approval If No Special Approval Groups`** — if `GroupsNotified == 0`, advances the parent Reservation state to `PendingFinalApproval` (=5) via `SetReservationApprovalState`.
9. **`End Workflow If No Special Approval Groups`** — `CompleteWorkflow` if no special groups exist.

## Design intent

- **State-routed, not sequential.** Whichever ApprovalState the Reservation currently has determines which single activity runs. The same workflow gets re-launched each time the state changes.
- **Approval-group lookups live in Rock config, not the workflow.** The BEMA `GetApprovalGroup` action resolves `(ReservationType, Campus) → (InitialGroup, FinalGroup)` from the [`ReservationApprovalGroup`](../sql-tables/Reservation-Workflow.md#reservationapprovalgroup) table, so updating who-can-approve-what is a config change, not a workflow change.
- **The 14-day reminder loop in "Pending Special Approval" is the only async/parked path.** While parked, the Reservation can be edited and another workflow can launch alongside; see [README § Parallel instantiation](README.md#parallel-instantiation-can-two-workflows-run-at-once-on-the-same-reservation).
- **Send Email actions in the two "Pending …" gates ship `Active=False`.** BEMA leaves them as scaffolding — orgs are expected to wire up sender / customize templates before enabling.

## See also

- [ApprovalState enums](../ApprovalState-Enums.md) — the integer-vs-string mapping used throughout this workflow.
- [Special Approval Notification](SpecialApprovalNotification.md) — the per-item email launched from the Pending Special Approval activity.
- [Modification Process](ModificationProcess.md) — the workflow that may write `Reservation.ApprovalState`, re-triggering this one.
- [ReservationDetail block — Approval State Machine](../BlockTypes/ReservationDetail.md#approval-state-machine) — the UI side of state transitions.
