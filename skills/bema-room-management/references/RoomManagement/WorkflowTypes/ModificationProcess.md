# Modification Process WorkflowType

> **Provenance tier:** `traced` — read from source or official documentation and cited (Rock v18.2.4). Catalogued in the plugin's knowledge manifest; `rockrms-knowledge-current` lists every entry.



| Field | Vanilla value |
|---|---|
| `WorkflowType.Name` | `Modification Process` |
| `Description` | "A workflow that changes the reservation's approval status if it was modified by someone not in an approval group." |
| `WorkTerm` | `Approval Update` |
| `ProcessingIntervalSeconds` | `28800` (8h) |
| `IsPersisted` | `True` |
| `IconCssClass` | `fa fa-list-ol` |
| Receives `Entity` = | `Reservation` |

## Purpose

When someone *modifies* an already-approved (or in-progress) reservation, decide whether the modification is significant enough to **revert** it back to an earlier approval gate. If so, clear the corresponding approver/timestamp fields and write the new `ApprovalState`.

## Triggered by (typical)

`ReservationUpdated` on every `[Reservation]` save.

## Workflow Attributes

| Key | Purpose |
|---|---|
| `Reservation` | The Reservation being modified (Object reference). |
| `ApprovalState` | The Reservation's current ApprovalState (string). |
| `ReservationType`, `Campus` | Used by `GetApprovalGroup` to resolve the approval groups for this reservation. |
| `InitialApprovalGroup`, `FinalApprovalGroup` | Approval groups for the Reservation's `(Type, Campus)`. |
| `PreviousModifiedDateTime` | Used to scope the History query — what changed *since* this date. |
| `ReservationChanges` | List of column-level changes from `[History]` (Verb / ValueName / OldValue / NewValue). |
| `ModifierInApprovalGroup` | "Yes"/"No" — does `Reservation.ModifiedByPersonAliasId` belong to any approval group? |
| `NewApprovalState` | Computed target state (Pending Initial / Special / Final, or blank). |
| `ApprovalLevel` | Integer 1/2/3 corresponding to NewApprovalState — used in Change Approval Status to know how far back to clear. |
| `IsStatusUpdated` | Boolean guard preventing false-positive bumps. |

## Activity flow

### Activity 0: "Set Attributes" — the detective

Runs in this order:

1. **Hydrate** — `Set Reservation From Entity`, `Set Reservation Type`, `Set Campus`, `Set Initial Approval Group`, `Set Final Approval Group`, `Set Approval State`.
2. **`Check if Modifier is in an Approval Group`** — runs SQL against `_com_bemaservices_RoomManagement_ReservationApprovalGroup` joined to `[GroupMember]` to see if `Reservation.ModifiedByPersonAliasId` belongs to any approval group for this reservation's `(Type, Campus)`. Sets `ModifierInApprovalGroup` to `Yes`/`No`.
3. **`End Workflow if Modifier in Approval Group`** — if `Yes`, `CompleteWorkflow`. **This is the self-suppression guard** that prevents Modification Process from interfering when an approver edits a reservation they're authorized to approve.
4. **`Set Reservation Changes`** — runs a SQL/Lava query against the Rock `[History]` table (filtered to `CategoryGuid = '806E96DE-3744-4F56-B12F-787F36A1CEB5'`, "Reservation Changes") to extract every column-level change since `PreviousModifiedDateTime`.
5. **`Set New Approval State`** — a Lava classifier with **two keyword lists**:
    - `initialApprovalGroupIncludedKeywords = 'Schedule,Campus'` — these changes force a full re-approval starting from Initial.
    - `finalApprovalGroupExcludedKeywords = 'Reservation,Name,Event Contact,Event Contact Phone Number,Event Contact Email,Administrative Contact,…'` — these changes are cosmetic and **don't** trigger re-approval.

    Anything else falls back to a Final-Approval re-trigger. Walks the change list and sets `NewApprovalState` to one of: `Pending Initial Approval` / `Pending Special Approval` / `Pending Final Approval`, or blank if no significant changes.
6. **`Set Approval Level`** — translates `NewApprovalState` into integer 1/2/3.
7. **`Set Is Status Updated`** — guards against false positives by comparing current state to the new one.
8. **`Close Workflow if No Change`** — if `NewApprovalState` is blank, end.
9. **`Activate Change Approval Status Activity`**.

### Activity 1: "Change Approval Status" — surgical reverts

For each level, two `SetEntityProperty` actions clear the matching approver+timestamp pair *only if* `ApprovalLevel` matches:

| `ApprovalLevel` | Actions that fire |
|---|---|
| `3` (revert to Final) | `Clear Final Approval Date`, `Clear Final Approver`. |
| `2` (revert to Special) | `Clear Special Approval Date`, `Clear Special Approver`. |
| `1` (revert to Initial) | `Clear Initial Approval Date Time`, `Clear Initial Approver`. |

Then:

- **`Set Reservation Status`** — uses the BEMA `SetReservationApprovalState` action with `ApprovalStateAttribute = NewApprovalState`. This writes `Reservation.ApprovalState` to the new state.
- **`Close Workflow`**.

The write in `Set Reservation Status` triggers a fresh save on the Reservation, which fires the `StateChanged` trigger and launches a new [Approval Process](ApprovalProcess.md) run on the new state.

## Design intent

- **The two keyword lists are the heart of this workflow.** BEMA's policy is *"editing the schedule or campus invalidates everything; editing contact info invalidates nothing; everything else just needs Final re-approval."* If you want different policies, edit the Lava in the `Set New Approval State` action.
- **The modifier-in-approval-group guard prevents the workflow from undoing approvers' work.** This guard is also what coordinates with Approval Process when both fire from the same save (an approver clicking "Approve" triggers both `ReservationUpdated` and `StateChanged`; this workflow bows out and lets Approval Process do its job). See [README § Parallel instantiation](README.md#parallel-instantiation-can-two-workflows-run-at-once-on-the-same-reservation).
- **The level-aware clears keep the audit trail intact** — reverting to Final only clears Final fields; the Initial+Special timestamps remain so future re-approvals know what was previously approved.

## See also

- [`ReservationApprovalGroup` schema](../sql-tables/Reservation-Workflow.md#reservationapprovalgroup) — the table queried by `Check if Modifier is in an Approval Group`.
- [Approval Process](ApprovalProcess.md) — the workflow re-triggered by this one's `Set Reservation Status` action.
- [ApprovalState enums](../ApprovalState-Enums.md) — the integer-vs-string mapping used by `Set Approval Level`.
