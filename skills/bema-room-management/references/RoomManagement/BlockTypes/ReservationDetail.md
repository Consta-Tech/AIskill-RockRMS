# Reservation Detail

> **Provenance tier:** `traced` — read from source or official documentation and cited (Rock v18.2.4). Catalogued in the plugin's knowledge manifest; `/rockrms:knowledge-current` lists every entry.



**Plugin**: BEMA Services — Room Management 2.0 (v2.6.5.16)
**Source file**: `RoomManagement (plugin package)/RoomManagement/ReservationDetail.ascx.cs` (~4468 lines — by far the largest block in the plugin)
**Rock Category**: BEMA Services > Room Management

## Purpose

The central add/edit/view block for a single [`Reservation`](../sql-tables/Reservation-and-Type.md#reservation). This is the page staff land on when they click a row in [Reservation List](ReservationList.md) or drill in from [Reservation Lava](ReservationLava.md).

One block, many responsibilities:

1. Create a new reservation or edit an existing one (contact, schedule, setup/cleanup, ministry, notes, campus, photo).
2. Attach **locations** (with per-location `LocationLayout` selection and per-location attribute answers).
3. Attach **resources** (with quantity, optional parent location, and per-resource attribute answers).
4. Attach **door lock schedules** (start/end time offsets relative to the reservation's schedule).
5. Drive the **approval state machine**: Submit → PendingInitial → PendingSpecial → PendingFinal → Approved, plus Request Changes / Deny / Override / Cancel paths, plus per-row resource/location approval.
6. Manually launch `Manual` workflow triggers configured on this reservation's `ReservationType`.
7. Copy an existing reservation as a template for a new one.
8. Render a read-only view with all of the above, filtered by per-collection `VIEW` authorization on the underlying attributes.

## Block Attributes

| Attribute (Display Name) | Type | Default | Key |
|---|---|---|---|
| Workflow Entry Page | LinkedPage | `Rock.SystemGuid.Page.WORKFLOW_ENTRY` | `WorkflowEntryPage` |
| Location Detail Template | LavaField | Image + `{{ Location \| Attribute:'RoomManagement_RoomDetails' }}` block | `LocationDetailTemplate` |
| Is Additional Info Expanded | BooleanField | `false` | `IsAdditionalInfoExpanded` |

- `LocationDetailTemplate` renders in `lLocationDetails` inside the Location editor modal, merged with `{{ Location }}`.
- `IsAdditionalInfoExpanded` controls the initial `Expanded` state of `wpAdditionalInfo` in edit mode.

## Page Parameters

### Read on initial load

| Parameter | Use |
|---|---|
| `ReservationId` | Integer. `0` or missing → Add mode; otherwise View/Edit mode. |
| `ParentCategoryId` | Fallback navigation if no NavigateToParentPage is defined. |

### Pre-population parameters (only used when `ReservationId = 0`)

`GenerateNewReservation` reads these to seed a new reservation. All are optional.

| Parameter | Seeds |
|---|---|
| `ReservationTypeId` | `ReservationType` |
| `Name` | `Reservation.Name` |
| `ScheduleId` | `Reservation.Schedule.iCalendarContent` (looked up from core Rock `Schedule`) |
| `SetupTime`, `CleanupTime` | `SetupTime`, `CleanupTime` (minutes) |
| `CampusId` | `CampusId` |
| `MinistryId` | `ReservationMinistryId` |
| `NumberAttending` | `NumberAttending` |
| `PhotoId` | `PhotoId` |
| `EventContactPersonAliasId` | `EventContactPersonAliasId` + phone/email hydration |
| `AdministrativeContactPersonAliasId` | `AdministrativeContactPersonAliasId` (defaults to `CurrentPersonAliasId` if missing) |
| `Note` | `Note` |
| `LocationId` | Single `ReservationLocation` |
| `LocationIds` | Comma-delimited — one `ReservationLocation` per id |
| `ResourceId` | Single `ReservationResource` (+ calls `AddAttachedLocations` for its parent location) |
| `ResourceIds` | Comma-delimited — one `ReservationResource` per id (+ attached locations each) |
| `ForeignKey`, `ForeignId`, `ForeignGuid` | Set on the reservation in `btnSave_Click` so external systems can correlate. |

## Authorization

| Action | Required |
|---|---|
| View reservation | Block-level read |
| Standard Edit (Name, Schedule, contacts, add/remove locations/resources/door-locks, notes) | `HasStandardEditRights` — creator, admin contact, event contact, someone with block-level `EDIT`, someone who satisfies `CheckEditAfterApprovalRights` |
| Approve at current state | `HasApprovalRightsToState` — is in the `InitialApprovalGroup`/`FinalApprovalGroup` of the reservation's type for the current state |
| Per-resource / per-location approve | `CanPersonApproveReservationResource(...)` / `CanPersonApproveReservationLocation(...)` — checks resource/location approval groups |
| Override | `HasApprovalRights( ..., OverrideApprovalGroup )` |
| Cancel | `HasStandardEditRights && ApprovalState != Cancelled` |
| Delete | `ADMINISTRATE` on the reservation type — enforced at click-time |

## Approval State Machine

The block surfaces eight action buttons. Each calls `SaveReservationChanges( reservation, rockContext )` which in turn bundles a `WrapTransaction`, `HistoryService.SaveChanges`, `LaunchWorkflow( reservation, StateChanged )`, and a page reload.

| Button | From state(s) | To state | Extra side effects |
|---|---|---|---|
| `btnSubmit` | Draft, ChangesNeeded | PendingInitialApproval | If `AreLocationOrResourceChangesNeeded` → go to ChangesNeeded instead. |
| `btnApprove` | PendingInitialApproval | PendingSpecialApproval | Sets `InitialApprovalDateTime` + `InitialApprovalPersonAliasId`. |
| `btnApprove` | PendingFinalApproval | Approved | Sets `FinalApprovalDateTime` + `FinalApprovalPersonAliasId`, `ApproverAliasId`. |
| `gViewResources_ApproveClick` | PendingSpecialApproval (per-row) | `ReservationResource.ApprovalState = Approved` | If `AreAllLocationsAndResourcesApproved` → reservation → PendingFinalApproval + `SpecialApprovalDateTime` / `SpecialApprovalPersonAliasId`. |
| `gViewLocations_ApproveClick` | PendingSpecialApproval (per-row) | `ReservationLocation.ApprovalState = Approved` | Same cascade as resources. |
| `btnRequestChanges` | any except ChangesNeeded | ChangesNeeded | — |
| `btnDeny` | any except Denied | Denied | — |
| `gViewResources_DenyClick` | per-row | `ReservationResource.ApprovalState = Denied`; reservation → ChangesNeeded | — |
| `gViewLocations_DenyClick` | per-row | `ReservationLocation.ApprovalState = Denied`; reservation → ChangesNeeded | — |
| `btnOverride` | any | Approved | Sets override fields. |
| `btnCancelReservation` | any except Cancelled | Cancelled | — |
| `hfApprovalState_ValueChanged` | (dialog radio) Approved | auto-approves each resource/location the current person `CanPersonApprove*`. | Fired when the user toggles the approval radio in the edit dialog. |

### Visibility rules in read-only mode

| Button | `Visible = ...` |
|---|---|
| `btnApprove` | `hasApprovalRightsToState && !nbError && (state == PendingInitial \|\| PendingFinal)` |
| `btnRequestChanges` | `hasApprovalRightsToState && state != ChangesNeeded` |
| `btnDeny` | `hasApprovalRightsToState && state != Denied` |
| `btnOverride` | `HasApprovalRights( ..., OverrideApprovalGroup )` |
| `btnCancelReservation` | `hasStandardEditRights && state != Cancelled` |
| `btnSubmit` | `(hasStandardEditRights \|\| hasApprovalRightsToState) && (state == Draft \|\| state == ChangesNeeded)` |
| `btnEdit` | `hasStandardEditRights` (wider when in FinalApprovalGroup + Approved, which permits re-edit) |
| `btnDelete`, `btnSecurity`, `btnCopy` | `ADMINISTRATE` on the type |

## Child Collections — managed via `ViewState`

| ViewState key | Type | UI |
|---|---|---|
| `LocationsState` | `List<ReservationLocationSummary>` | `gLocations` / `gViewLocations` + `dlgReservationLocation` |
| `ResourcesState` | `List<ReservationResourceSummary>` | `gResources` / `gViewResources` + `dlgReservationResource` |
| `DoorLockSchedulesState` | `List<ReservationDoorLockSchedule>` | `gDoorLockSchedules` + `dlgReservationDoorLockSchedule` |

`ReservationLocationSummary` and `ReservationResourceSummary` are private subclasses adding `IsNew` and (for resources) `ReservationLocationGuid` + computed `LocationName`. JSON-serialized into ViewState.

Dynamic attributes (on Reservation, ReservationLocation, ReservationResource) are stored inside the entities themselves, not in a dedicated state list — they round-trip via the JSON serialization of the state collections and are rehydrated via `LoadReservationLocationAttributes` / `LoadReservationResourceAttributes` each bind.

### Location dialog (`dlgReservationLocation`)

| Field | Source | Notes |
|---|---|---|
| Location | `slpLocation` | Filtered by reservation type's `ReservationLocationTypes` and user's `EDIT` authorization on the Location. |
| Layout | `gLocationLayouts` | Radio-select grid of active `LocationLayout` rows for the chosen Location. Shown only if layouts exist. |
| Detail pane | `lLocationDetails` | Renders `LocationDetailTemplate` Lava with `{{ Location }}`. |
| Conflicts | `nbLocationConflicts` | Calls `ReservationService.BuildLocationConflictHtmlList(...)`; also blocks duplicate adds and invalid location types. |

### Resource dialog (`dlgReservationResource`)

| Field | Source | Notes |
|---|---|---|
| Resource | `srpResource` | ResourcePicker. On select → `LoadResourcePopup`. |
| Location | `ddlReservationLocation` | Hidden when the resource has a hardcoded `Resource.Location`; else populated from `LocationsState`. |
| Quantity | `nbQuantity` | Max = `resource.Quantity - already-used-quantity`. Disabled when 0 available. Hidden entirely when `Resource.Quantity` is null (unbounded). |
| Note | `nbResourceNote` | Shows `resource.Note` if set (informational, read-only). |
| Conflicts | `nbResourceConflicts` | Calls `ReservationService.BuildResourceConflictHtmlList(...)`; also blocks duplicate adds (same resource+location pair). |

### Door Lock Schedule dialog (`dlgReservationDoorLockSchedule`)

| Field | Source |
|---|---|
| Start day offset | `nbStartDayOffset` (integer, days before/after reservation's first occurrence) |
| Start time | `tpStartTime` |
| End day offset | `nbEndDayOffset` |
| End time | `tpEndTime` |
| Note | `tbReservationDoorLockScheduleNote` |

Stored as minute-offsets (`StartTimeOffset`, `EndTimeOffset`) computed as `((date + time + dayOffset) - reservation.FirstStartDateTime).TotalMinutes`. If start > end, shows `nbDoorLockError` and refuses to save.

## Save Flow

`btnSave_Click` → `SaveReservationChanges`:

1. **Concurrency guard** — reload the reservation fresh; if `reservation.ReservationModifiedDateTime > ModifiedDateTime` (the one hidden on the page), abort with a warning. Prevents blind-over-write when two admins edit at once.
2. **Required-field validation** (server-side, even though fields are marked required client-side):
   - If `ReservationType.LocationRequirement == Require` and `LocationsState` is empty → error.
   - If `ReservationType.ResourceRequirement == Require` and `ResourcesState` is empty → error.
   - Schedule required.
   - `UpdateScheduleWithMaxEndDate` enforces `MaximumReservationDuration`.
   - No unresolved conflicts (re-runs `GenerateConflictInfo` as a guard).
3. **Photo bookkeeping** — if the photo changed, mark the *old* photo `IsTemporary = true` (eligible for cleanup) and mark the *new* photo `IsTemporary = false`. Rock's standard temporary-binary-file cleanup handles the eventual delete.
4. **Build the reservation** — copy fields from controls; apply state transitions from approval buttons. `BuildOldReservation` captures pre-save snapshot for history diffing.
5. **Diff-delete** each child collection — `LocationsState` vs DB rows, same for resources and door-locks. `CopyPropertiesFrom` onto existing rows, `Add` to navigation collections for new rows.
6. **WrapTransaction** starts:
   - `rockContext.SaveChanges()` (the reservation + navigation collection deletes/upserts).
   - Per-location and per-resource `SaveAttributeValues()`.
   - `reservation.SaveAttributeValues( rockContext )`.
   - `HistoryService.SaveChanges(...)` with category `Rock.SystemGuid.Category.HISTORY_RESERVATION_CHANGES` (Guid looked up via `CategoryCache.Read`).
7. **`LaunchWorkflow( reservation, StateChanged )`** — fires every configured `StateChanged` trigger on this reservation's type whose `QualifierValue = |{fromState}|{toState}|`.
8. **Redirect** — reload the same page with `ReservationId` set to the (possibly new) id.

### Manual workflow launch

Outside the save path, `rptWorkflows` lists every `ReservationType.ReservationWorkflowTriggers` row with `TriggerType = Manual`. Each has a "Launch" button → `btnTrigger_Click`:

1. Finds the `ReservationWorkflowTrigger`, instantiates its `WorkflowType`.
2. Calls `WorkflowService.Process(...)`. On success:
   - Persists a `ReservationWorkflow` row linking the reservation, the trigger, and the resulting `Workflow.Id`.
   - If the workflow has an **active entry form** for the current person → redirect to `WorkflowEntryPage?WorkflowTypeId=...&WorkflowId=...`.
   - Else → show `mdWorkflowLaunched` modal with "A '{name}' workflow has been started."
3. On processing error → modal shows "Workflow Processing Error(s): <ul><li>...</li></ul>".

## Copy Flow

`btnCopy_Click`:

1. Authorization check: `ADMINISTRATE` on the type.
2. Call `ReservationService.GetNewFromTemplate( sourceId )` — returns a detached `Reservation` with `Id = 0` and all child collections re-pointed.
3. Append `" (Copy)"` to `Name`.
4. Re-Guid every `ReservationLocation`, `ReservationResource`, and `ReservationDoorLockSchedule` (they carry Guids that must be unique).
5. Maintain a **location-Guid mapping** (`oldGuid → newGuid`) so resources that were parented by `ReservationLocationGuid` still point to the correct (new) reservation location after re-Guiding.
6. Persist with a fresh `SaveChanges` in the current rockContext.
7. Redirect to the new reservation in edit mode.

**Note**: Copy does not copy attribute values for the child rows — only the entity shells. Attribute values would need to be separately persisted; this is a known limitation of `GetNewFromTemplate`.

## Delete Flow

`btnDelete_Click` → `btnDeleteConfirm_Click`:

1. Authorization: `ADMINISTRATE` on the type. Else modal alert and return.
2. `ReservationService.Delete( reservation )` — the service cascades through `ReservationLocation`, `ReservationResource`, `ReservationDoorLockSchedule`, `ReservationWorkflow`, attribute values.
3. `SaveChanges()` then `NavigateToParentPage()`.

## Read-only vs Edit Mode

`ShowReadonlyDetails( reservationId )` renders:
- Header block (name, state badge, contact info, reservation/event datetime descriptions).
- Campus chip (if present), Ministry chip.
- Locations grid (`gViewLocations`) — adds per-row Approve/Deny columns if the current person `CanPersonApproveReservationLocation`.
- Resources grid (`gViewResources`) — same per-row approval columns.
- Door lock schedules list (if `ReservationType.DisplayReservationDoorLockSchedules`).
- `phViewLocationAnswers` + `phViewResourceAnswers` — read-only attribute values, filtered by `Authorization.VIEW`.
- `phViewAttributes` — reservation-level attribute display values (filtered similarly).
- Workflow trigger "Launch" buttons for `Manual` triggers.
- The action-button strip (Submit / Approve / Request Changes / Deny / Override / Cancel / Edit / Copy / Delete / Security) based on the visibility rules above.
- ICS download button — inline Lava + JavaScript that generates an iCalendar file client-side from `sbSchedule.iCalendarContent`.

`ShowEditDetails( reservation )` reveals the full edit form, binds all four state collections, and calls `LoadPickers` + `LoadAdditionalInfo` + `SetRequiredFieldsBasedOnReservationType`.

## Notable Behaviors

- **`BuildLocationQuestions` / `BuildResourceQuestions`** render per-row dynamic attribute edit controls with a custom control id format `attribute_field_{AttributeId}_resource_{ReservationResourceGuid.replace('-','_')}` — lets one page host N copies of the same attribute. Rock's standard `AddEditControls` would collide on ids without this scheme.
- **`LoadReservationLocationAttributes` / `LoadReservationResourceAttributes`** are called before every bind — cheaper than persisting the loaded attributes into ViewState.
- **`AddAttachedResources`** / **`AddAttachedLocations`** — when a location is picked, any `Resource.Location = thisLocation && IsActive` are auto-added to the reservation; when a resource with an attached location is picked, that location is auto-added. `RemoveLocation` conversely removes all resources that were attached to that location **or** assigned to that `ReservationLocation.Guid`.
- **Resource quantity math is stateful**: the Quantity picker's max = `Resource.Quantity - sum(other reservations' usage in the same window) - sum(this reservation's other rows of the same resource)`. The block doesn't track this incrementally — every dialog open calls `GetAvailableResourceQuantity` fresh.
- **Resource approval state is preserved on quantity decrease**: if a resource row is already Approved and you *decrease* quantity, `ApprovalState` stays Approved. Any other change resets to Unapproved. This lets an approver reduce an overbooked resource without restarting approval.
- **`hfApprovalState_ValueChanged` auto-approves**: when the user picks "Approved" in the dialog radio, it also flips every resource/location the user has approval rights on to Approved in one shot. Convenient for admins, but means the final `ApproverAliasId` captures one person even though the per-row approval might have logically taken multiple.
- **Concurrency check uses reservation-level modified dt, not per-row**: two admins editing different resources on the same reservation will still collide because the check is on `Reservation.ModifiedDateTime`.
- **`lLocationDetails` Lava runs every dialog open** — LocationDetailTemplate is not cached. If the template is expensive, the modal feels slow.
- **Door lock times are minute-offsets**, so daylight savings transitions or zone changes could shift the effective time. The block stores the offsets as computed at-save-time and replays them at-lock-time.
- **Malformed img tag**: near line 2079 the inline Lava for the photo thumbnail has `<img src='...' height='100 />` (mismatched quote). Browsers tolerate it — but worth fixing if the file is ever cleaned up.
- **`Hydrate` is overloaded three times** (locations, resources, door-lock schedules) — each reloads the navigation properties after ViewState deserialization, since only ids survive the JSON round-trip.
- **Manual workflow launch error-handling swallows exceptions silently via `List<string> workflowErrors`** — if `Process` returns false, errors surface in `mdWorkflowLaunched`; but if `Process` itself throws (uncaught), the page will 500. Same pattern as `LaunchWorkflow` which is called from save.
- **Security button toggle**: `btnSecurity` is set to `EntityType: Reservation` so the security editor scopes to this specific reservation entity.
- **`SetRequiredFieldsBasedOnReservationType`** makes Campus, NumberAttending, SetupTime, and ContactDetails client-side-required based on the type's `IsCampusRequired` / `IsNumberAttendingRequired` / `IsSetupTimeRequired` / `IsContactDetailsRequired` flags. Server-side the fields are always rendered; the enforcement is CSS + JS.
- **`EvaluateLocationAndResourceChanges`** diffs the incoming edit against the pre-save snapshot and, if any location/resource changed or any schedule/setup/cleanup changed, routes the save through the `ChangesNeeded` branch instead of honoring the requested state transition. This is what protects approvers from silent schedule-bump edits.
- **`LoadPickers`**: `slpLocation` shows only locations of a type in `ReservationType.ReservationLocationTypes` (or all if the type list is empty); `srpResource` filters to resources whose `Resource.Location` is either null or in `LocationsState`.
