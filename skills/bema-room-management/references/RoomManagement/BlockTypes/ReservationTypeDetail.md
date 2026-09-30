# Reservation Type Detail

> **Provenance tier:** `traced` — read from source or official documentation and cited (Rock v18.2.4). Catalogued in the plugin's knowledge manifest; `/rockrms:knowledge-current` lists every entry.



**Plugin**: BEMA Services — Room Management 2.0 (v2.6.5.16)
**Source file**: `RoomManagement (plugin package)/RoomManagement/ReservationTypeDetail.ascx.cs`
**Rock Category**: BEMA Services > Room Management

## Purpose

The add/edit detail block for a [`ReservationType`](../sql-tables/Reservation-and-Type.md#reservationtype). A Reservation Type is the admin-configured template that controls **how** a reservation of that type behaves — which contact details are required, which approval chain it flows through, which ministries/workflow triggers/reservable-location-types apply, and which dynamic attributes it gets.

One block, four child-collection editors in one big form:

1. **Attributes** — dynamic attributes added to `Reservation` entity, qualified by this `ReservationType.Id`.
2. **Approval Groups** — security groups that act as Initial / Final / Special approvers (optionally per-campus).
3. **Ministries** — the list of `ReservationMinistry` options that will appear on reservations of this type.
4. **Workflow Triggers** — workflow launches tied to reservation lifecycle events.

## Block Attributes

*(None — this block has no block-level attributes.)*

## Page Parameters

| Parameter | Use |
|---|---|
| `ReservationTypeId` | Integer. `0` or missing → Add mode. Otherwise → View/Edit mode for the specified type. |

## ReservationType Fields Edited

| Group | Field | UI control |
|---|---|---|
| General | `Name` | `tbName` |
| General | `Description` | `tbDescription` |
| General | `IconCssClass` | `tbIconCssClass` (default `fa fa-compress` on Add) |
| General | `IsActive` | `cbActive` (default `true` on Add) |
| General | `DoorLockInstructions` | `tbDoorLockInstructions` (seeded with `DefaultValue.DefaultDoorLockInstructionText` on Add) |
| Defaults | `DefaultSetupTime`, `DefaultCleanupTime` | number boxes (minutes) |
| Defaults | `DefaultReservationDuration` | `nbDefaultEndDate` (default `7305` minutes ≈ 5 days) |
| Defaults | `MaximumReservationDuration` | `nbMaxEndDate` |
| Required-fields toggles | `IsContactDetailsRequired`, `IsCampusRequired`, `IsNumberAttendingRequired`, `IsSetupTimeRequired` | checkboxes |
| Booking behavior | `IsReservationBookedOnApproval` | checkbox |
| Door locks | `DisplayReservationDoorLockSchedules` | checkbox |
| Contact | `ContactPhoneTypeValueId` | `dvpPhoneNumberTypes` bound to `PERSON_PHONE_TYPE` DefinedType |
| Requirements | `LocationRequirement` | radio list, `ReservationTypeRequirement` enum (default `Allow`) |
| Requirements | `ResourceRequirement` | radio list, `ReservationTypeRequirement` enum (default `Allow`) |
| Reservable locations | `ReservationLocationTypes` *(collection)* | `dvpReservableLocationTypes` bound to `LOCATION_TYPE` DefinedType, multi-select. On Add, all DefinedValues are pre-selected. |

## Child Collections — managed via `ViewState`

Each grid uses a JSON-serialized ViewState list. Edits go into the list; grids rebind from the list. Saves persist the whole list in one pass.

| ViewState key | Collection type | UI |
|---|---|---|
| `AttributesState` | `List<Rock.Model.Attribute>` | `gAttributes` + `dlgAttribute` |
| `ReservationApprovalGroupsState` | `List<ReservationApprovalGroup>` | `gApprovalGroups` + `dlgApprovalGroups` |
| `ReservationMinistriesState` | `List<ReservationMinistry>` | `gMinistries` + `dlgMinistries` |
| `ReservationWorkflowTriggersState` | `List<ReservationWorkflowTrigger>` | `gWorkflowTriggers` + `dlgWorkflowTrigger` |

### Attribute grid

- Uses `AttributeEditor` (`edtAttributes`) with `ReservedKeyNames` set from other attributes in state (prevents duplicate keys).
- `AllowSearchVisible = true` — surface the "Allow Search" toggle in the field-type picker.
- New attributes default to `FieldType = TEXT`.
- Supports reorder via `GridReorder`. Order numbers are re-sequenced via `ReOrderAttributes` after each save.

### Approval Group dialog

| Field | Source |
|---|---|
| Security Role | `ddlSecurityGroup` — only `Group.IsSecurityRole = true` groups. |
| Campus (optional) | `cpCampus`. |
| Approval Type | `ddlApprovalType` — bound to the `ApprovalGroupType` enum. |

See [`ReservationApprovalGroup`](../sql-tables/Reservation-Workflow.md#reservationapprovalgroup) for how `ApprovalGroupType` (`Initial` / `Final` / `Special`) drives the reservation approval flow.

### Ministry dialog

Only one field: `tbMinistryName`. See [`ReservationMinistry`](../sql-tables/Reservation-and-Type.md#reservationministry).

### Workflow Trigger dialog

| Field | Source |
|---|---|
| Trigger Type | `ddlTriggerType` — bound to `ReservationWorkflowTriggerType` enum (`ReservationCreated`, `Manual`, `StateChanged`, `ReservationUpdated`). |
| Workflow Type | `ddlWorkflowType` — only types the current person can `VIEW`. |
| Primary / Secondary Qualifier | Only visible on `StateChanged`; both bound to `ReservationApprovalState` enum with a blank option. Rendered as "From" and "To". |

`QualifierValue` is stored as `|{Primary}|{Secondary}|` for state-change triggers; empty otherwise. See [`ReservationWorkflowTrigger`](../sql-tables/Reservation-Workflow.md#reservationworkflowtrigger) for the persisted shape.

## Save Flow

`btnSave_Click` is a single path that handles both Add and Edit:

1. If `ReservationTypeId == 0`, construct a new `ReservationType` and add it. Otherwise load it eagerly with `"ReservationMinistries, ReservationWorkflowTriggers"`.
2. **Deletes first** — for each child collection, find DB rows whose Guid isn't in the corresponding ViewState list and delete them via the collection's service. Same pattern for `ReservationLocationTypes` (compared against `dvpReservableLocationTypes.SelectedValuesAsInt`).
3. **Upserts** — for each item in the state lists, find-by-Guid on the navigation collection and either `CopyPropertiesFrom` into the existing row or instantiate a new one and `Add` to the navigation collection.
4. **Validation**: if `reservationType.IsValid == false`, the save short-circuits — controls render their own error messages.
5. **`WrapTransaction`** starts:
   - `rockContext.SaveChanges()`.
   - `Helper.SaveAttributeEdits(AttributesState, Reservation.EntityTypeId, "ReservationTypeId", reservationType.Id.ToString(), rockContext)` — persists the dynamic attributes against the `Reservation` entity, qualified by this `ReservationType.Id`.
   - **Self-privilege**: reload the just-saved `reservationType` and, for each of `VIEW` / `EDIT` / `ADMINISTRATE`, if the current person isn't already authorized, call `AllowPerson(...)` to grant them. This means whoever first creates (or saves without being explicitly authorized on) the type automatically gets full rights on it.
6. Call `ReservationWorkflowTriggerService.RemoveCachedTriggers()` to invalidate the service's in-memory trigger cache.
7. Reload the page with `ReservationTypeId` in the query string.

## Delete Flow

`btnDeleteConfirm_Click` is destructive and cascades aggressively:

1. **Authorization**: requires `ADMINISTRATE` on the type. If missing, shows a modal alert and returns.
2. Uses `DeleteRange` on these collections (scoped to this `ReservationType.Id`):
   - `ReservationApprovalGroup` (this type only)
   - `ReservationMinistry` (this type only)
   - `ReservationWorkflowTrigger` (this type only)
   - `ReservationLocationType` (this type only)
   - `ReservationResource` joined through `Reservation.ReservationTypeId` — i.e., **every resource assigned to every reservation of this type**
   - `ReservationLocation` joined through `Reservation.ReservationTypeId`
   - `Reservation` rows of this type
   - Finally, the `ReservationType` itself
3. Single `SaveChanges()`, then `RemoveCachedTriggers()`, then `NavigateToParentPage()`.

**Deleting a Reservation Type deletes every reservation of that type plus all their child rows.** There is no soft-delete path. Operators should deactivate (`IsActive = false`) instead of deleting.

## Authorization

| Action | Required |
|---|---|
| View | block-level read (any user who can load the page) |
| Edit / Add / Save | `ADMINISTRATE` on the type, or `UserCanAdministrate` on the block |
| Delete | `ADMINISTRATE` on the type (enforced at click-time, not just UI-level) |

- If the current user is not admin-authorized, `btnEdit`/`btnDelete`/`btnSecurity` are all hidden and `ShowReadonlyDetails` is forced.
- `btnSecurity.Visible = false` is hard-coded on first pass with a "Security won't be enabled until 1.3.1/1.4" comment — then unconditionally re-enabled a few lines later when admin rights are confirmed. So the comment is stale but harmless.

## Read-only vs Edit

- View mode (`ShowReadonlyDetails`) renders only Name (as title) and `Description.ScrubHtmlAndConvertCrLfToBr()`. Child collections are **not** rendered in read-only view.
- Entering Edit (`ShowEditDetails`) hydrates all four state lists from the DB and binds every grid.

## Linked Pages / Navigation

- **After save**: `NavigateToPage(RockPage.Guid, { ReservationTypeId = ... })` — reloads the same page with the new/saved id.
- **After delete**: `NavigateToParentPage()`.
- **After cancel on Add**: `NavigateToParentPage()`.
- **After cancel on Edit**: switch back to `ShowReadonlyDetails()` in place.

## Notable Behaviors

- **`LoadViewState` is tolerant of empty state** — all four state lists start as empty lists when the ViewState entry is blank, avoiding NREs on first load.
- **`LoadStateDetails` filters attributes by EntityTypeQualifier string comparison**: `EntityTypeQualifierColumn = "ReservationTypeId"` and `EntityTypeQualifierValue = {Id}.ToString()`. Straightforward but means renaming/duplicating the qualifier column would orphan attributes.
- **`dvpReservableLocationTypes` defaults to "all" on Add**: if the type is new *or* no location types are selected, every `LOCATION_TYPE` defined value is pre-selected. Users then uncheck the ones they don't want.
- **Workflow trigger validation uses a `try/catch { }`** around `WorkflowType = ...Get(...)`. Failures are swallowed silently — `WorkflowTypeId` is then assigned regardless, so an invalid id still gets saved.
- **Grid dialog state is tracked via `hfActiveDialog`** (uppercased, trimmed). `ShowDialog`/`HideDialog` switch on the string. The case block `"RESERVATIONMINISTRIES"` in `ShowDialog` is ordered *after* Attributes and Approval Groups — the two dialogs are mutually exclusive because `hfActiveDialog` holds at most one value.
- **`hfAddMinistryGuid` is reused by the Approval Group dialog** — the approval-group editor stashes the in-edit row Guid in `hfAddMinistryGuid` rather than a dedicated hidden field. Consequence: if you open the ministry dialog after closing the approval-group dialog, the ministry dialog sees an approval-group's Guid first. Because the ministry code only reads `hfAddMinistryGuid` after setting it in `gMinistries_ShowEdit`, this doesn't cause a visible bug — but it's a foot-gun.
- **Attribute reordering uses O(n²)-style index shifting** (`SortAttributes`). Fine at the list sizes this block handles.
- **Saving a reservation type that the user couldn't previously admin auto-grants them full rights** (see Save Flow step 5). Consequence: a user with only block-level edit rights can still save changes that retroactively self-grant ADMINISTRATE.
- **`BlockUpdated` re-renders the readonly view** — covers the edge case where the block's own configuration changes mid-edit.
