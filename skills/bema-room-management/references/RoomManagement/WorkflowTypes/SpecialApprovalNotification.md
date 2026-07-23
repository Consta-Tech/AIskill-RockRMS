# Special Approval Notification WorkflowType

| Field | Vanilla value |
|---|---|
| `WorkflowType.Name` | `Special Approval Notification` |
| `Description` | *(blank)* |
| `WorkTerm` | `Work` *(generic Rock default — never customized in vanilla)* |
| `ProcessingIntervalSeconds` | `28800` (8h) |
| `IsPersisted` | `True` |
| `IconCssClass` | `fa fa-list-ol` |
| Receives `Entity` = | *(none — driven by Workflow Attributes)* |

## Purpose

Send a single email to a single approval group about a single Resource or Location on a Reservation that requires *special* approval — i.e., where the Resource or Location has its own attached `ApprovalGroupId`, separate from the Reservation's overall ReservationType groups.

## Triggered by

**Not** triggered via [`ReservationWorkflowTrigger`](../sql-tables/Reservation-Workflow.md#reservationworkflowtrigger). It is launched **from inside [Approval Process](ApprovalProcess.md#pending-special-approval)'s "Pending Special Approval" activity** — once per special-approval Resource and once per special-approval Location. The launching Lava (the `Send Notifications to Any Special Approval Groups` action in Approval Process) iterates the children needing special approval and instantiates this workflow with three pieces of state.

## Workflow Attributes

| Key | Purpose |
|---|---|
| `reservation` | The Reservation needing approval. |
| `approvalgroup` | The single Group that owns this Resource/Location. |
| `relevantitem` | A URL-encoded string identifying which Resource or Location is the subject of this email. |

(Note: keys are lowercase, unlike the other three vanilla workflows. This is BEMA's choice — likely an early-version convention they didn't standardize.)

## Activity flow

### Activity 0: "Start"

Two actions:

1. **`Decrypt Relevant Items`** — Lava: `{{ Workflow | Attribute:'relevantitem' | UrlDecode }}`. Decodes the item label.
2. **`Send Notification Email`** — emails the Approval Group with subject `Special Approval Needed: {relevantitem} for {reservation}`.

## Design intent

- **Pure email sender, no decisioning.** All the "should we email" logic lives upstream in Approval Process's Pending Special Approval activity.
- **`relevantitem` is URL-encoded** because Lava string concatenation can produce values with quotes/ampersands that confuse the workflow launcher; the parent encodes them and this workflow decodes.
- **Designed to be fired many times in quick succession** — one per special-approval child on a Reservation.

## See also

- [Approval Process — Pending Special Approval](ApprovalProcess.md#pending-special-approval) — the activity that launches this workflow.
