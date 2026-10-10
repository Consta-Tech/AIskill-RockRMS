# Reservation Workflow

> **Provenance tier:** `measured` — tested in a live Rock instance (Rock v18.2.4). Catalogued in the plugin's knowledge manifest; `rockrms-knowledge-current` lists every entry.



Three tables that handle automation and approval routing:

- **ReservationWorkflowTrigger** — *(configuration)* on a ReservationType, declares "when X happens, run Workflow Y". Lives on ReservationType.
- **ReservationWorkflow** — *(runtime)* a launched workflow instance tied to a specific Reservation. Written when a trigger fires.
- **ReservationApprovalGroup** — *(configuration)* declares which Rock [Group](../../../../rock-sql-schema/references/Group.md) can provide initial/final/override approval for reservations of a given ReservationType (optionally scoped by Campus).

---

## ReservationWorkflowTrigger

Configuration row on a ReservationType. When a reservation matching `TriggerType` (+ optional `QualifierValue`) occurs, the plugin launches a new Workflow of `WorkflowTypeId`.

```sql
CREATE TABLE [dbo].[_com_bemaservices_RoomManagement_ReservationWorkflowTrigger](
    [Id] [int] IDENTITY(1,1) NOT NULL,
    [WorkflowTypeId] [int] NOT NULL,
    [TriggerType] [int] NOT NULL,
    [QualifierValue] [nvarchar](max) NULL,
    [CreatedDateTime] [datetime] NULL,
    [ModifiedDateTime] [datetime] NULL,
    [CreatedByPersonAliasId] [int] NULL,
    [ModifiedByPersonAliasId] [int] NULL,
    [Guid] [uniqueidentifier] NOT NULL,
    [ForeignKey] [nvarchar](100) NULL,
    [ForeignGuid] [uniqueidentifier] NULL,
    [ForeignId] [int] NULL,
    [ReservationTypeId] [int] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
;

ALTER TABLE [dbo].[_com_bemaservices_RoomManagement_ReservationWorkflowTrigger]
    ADD CONSTRAINT [PK__com_bemaservices_RoomManagement_ReservationWorkflowTrigger] PRIMARY KEY CLUSTERED ([Id] ASC)
;
```

### Columns

| Column | Type | Notes |
|---|---|---|
| `Id` | int (PK, identity) | Primary key. |
| `WorkflowTypeId` | int (FK, NOT NULL) | FK → [WorkflowType](../../../../rock-sql-schema/references/Workflow.md#workflowtype). `ON DELETE CASCADE`. The workflow that will be launched. |
| `TriggerType` | int (NOT NULL) | Enum `ReservationWorkflowTriggerType`: 0=ReservationCreated, 1=ReservationUpdated, 2=StateChanged, 3=Manual. |
| `QualifierValue` | nvarchar(max) | Trigger-specific qualifier string. For `StateChanged`, this is a "from state\|to state" qualifier (e.g., `PendingInitialApproval\|Approved`). |
| `Guid`, audit columns | — | Standard Rock. |
| `ReservationTypeId` | int (FK, NOT NULL) | FK → [ReservationType](Reservation-and-Type.md#reservationtype). |

### Foreign keys

| Column | References |
|---|---|
| `ReservationTypeId` | [ReservationType](Reservation-and-Type.md#reservationtype) |
| `WorkflowTypeId` | [WorkflowType](../../../../rock-sql-schema/references/Workflow.md#workflowtype) *(CASCADE)* |
| `CreatedByPersonAliasId`, `ModifiedByPersonAliasId` | [PersonAlias](../../../../rock-sql-schema/references/Person-and-PersonAlias.md#personalias) |

---

## ReservationWorkflow

Runtime row — one per workflow instance that has been launched by a trigger. Links the launched `Workflow` back to its `Reservation` and the originating `ReservationWorkflowTrigger`.

```sql
CREATE TABLE [dbo].[_com_bemaservices_RoomManagement_ReservationWorkflow](
    [Id] [int] IDENTITY(1,1) NOT NULL,
    [ReservationId] [int] NOT NULL,
    [ReservationWorkflowTriggerId] [int] NULL,
    [WorkflowId] [int] NOT NULL,
    [TriggerType] [int] NOT NULL,
    [TriggerQualifier] [nvarchar](max) NULL,
    [CreatedDateTime] [datetime] NULL,
    [ModifiedDateTime] [datetime] NULL,
    [CreatedByPersonAliasId] [int] NULL,
    [ModifiedByPersonAliasId] [int] NULL,
    [Guid] [uniqueidentifier] NOT NULL,
    [ForeignKey] [nvarchar](100) NULL,
    [ForeignGuid] [uniqueidentifier] NULL,
    [ForeignId] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
;

ALTER TABLE [dbo].[_com_bemaservices_RoomManagement_ReservationWorkflow]
    ADD CONSTRAINT [PK__com_bemaservices_RoomManagement_ReservationWorkflow] PRIMARY KEY CLUSTERED ([Id] ASC)
;
```

### Columns

| Column | Type | Notes |
|---|---|---|
| `Id` | int (PK, identity) | Primary key. |
| `ReservationId` | int (FK, NOT NULL) | FK → [Reservation](Reservation-and-Type.md#reservation). `ON DELETE CASCADE`. |
| `ReservationWorkflowTriggerId` | int (NULL) | **Not FK-constrained.** References the [ReservationWorkflowTrigger](#reservationworkflowtrigger) row that caused this launch. NULL if the workflow was launched outside the trigger path (e.g., manually). |
| `WorkflowId` | int (FK, NOT NULL) | FK → [Workflow](../../../../rock-sql-schema/references/Workflow.md#workflow). `ON DELETE CASCADE`. The actual Rock Workflow instance. |
| `TriggerType` | int (NOT NULL) | Snapshot of the trigger type at launch (same enum as `ReservationWorkflowTrigger.TriggerType`). |
| `TriggerQualifier` | nvarchar(max) | Snapshot of the trigger qualifier. |
| `Guid`, audit columns | — | Standard Rock. |

### Foreign keys

| Column | References |
|---|---|
| `ReservationId` | [Reservation](Reservation-and-Type.md#reservation) *(CASCADE)* |
| `WorkflowId` | [Workflow](../../../../rock-sql-schema/references/Workflow.md#workflow) *(CASCADE)* |
| `CreatedByPersonAliasId`, `ModifiedByPersonAliasId` | [PersonAlias](../../../../rock-sql-schema/references/Person-and-PersonAlias.md#personalias) |

---

## ReservationApprovalGroup

Declares which Rock [Group](../../../../rock-sql-schema/references/Group.md) can approve a reservation of a given `ReservationType`, and at which stage. Optionally campus-scoped.

The single `ApprovalGroupType` column picks the stage; each ReservationType can have multiple rows (e.g., a separate Initial group per Campus + a single Final group church-wide).

```sql
CREATE TABLE [dbo].[_com_bemaservices_RoomManagement_ReservationApprovalGroup](
    [Id] [int] IDENTITY(1,1) NOT NULL,
    [ReservationTypeId] [int] NOT NULL,
    [ApprovalGroupId] [int] NOT NULL,
    [ApprovalGroupType] [int] NOT NULL,
    [CampusId] [int] NULL,
    [Guid] [uniqueidentifier] NOT NULL,
    [CreatedDateTime] [datetime] NULL,
    [ModifiedDateTime] [datetime] NULL,
    [CreatedByPersonAliasId] [int] NULL,
    [ModifiedByPersonAliasId] [int] NULL,
    [ForeignKey] [nvarchar](50) NULL,
    [ForeignGuid] [uniqueidentifier] NULL,
    [ForeignId] [int] NULL
) ON [PRIMARY]
;

ALTER TABLE [dbo].[_com_bemaservices_RoomManagement_ReservationApprovalGroup]
    ADD CONSTRAINT [PK__com_bemaservices_RoomManagement_ReservationApprovalGroup] PRIMARY KEY CLUSTERED ([Id] ASC)
;
```

### Columns

| Column | Type | Notes |
|---|---|---|
| `Id` | int (PK, identity) | Primary key. |
| `ReservationTypeId` | int (FK, NOT NULL) | FK → [ReservationType](Reservation-and-Type.md#reservationtype). `ON DELETE CASCADE`. |
| `ApprovalGroupId` | int (FK, NOT NULL) | FK → [Group](../../../../rock-sql-schema/references/Group.md). `ON DELETE CASCADE`. The group whose members can approve. |
| `ApprovalGroupType` | int (NOT NULL) | Enum `ApprovalGroupType`: 0=InitialApprovalGroup, 1=FinalApprovalGroup, 2=OverrideApprovalGroup. |
| `CampusId` | int (FK, NULL) | FK → [Campus](../../../../rock-sql-schema/references/Campus.md). `ON DELETE CASCADE`. When set, the rule only applies to reservations at this campus. When NULL, it applies church-wide. |
| `Guid`, audit columns | — | Standard Rock. |

### Foreign keys

| Column | References |
|---|---|
| `ReservationTypeId` | [ReservationType](Reservation-and-Type.md#reservationtype) *(CASCADE)* |
| `ApprovalGroupId` | [Group](../../../../rock-sql-schema/references/Group.md) *(CASCADE)* |
| `CampusId` | [Campus](../../../../rock-sql-schema/references/Campus.md) *(CASCADE)* |
| `CreatedByPersonAliasId`, `ModifiedByPersonAliasId` | [PersonAlias](../../../../rock-sql-schema/references/Person-and-PersonAlias.md#personalias) |

### Relation to ReservationType columns

`ReservationType` itself has `InitialApprovalGroupId`, `FinalApprovalGroupId`, `OverrideApprovalGroupId`, and `SuperAdminGroupId` columns. `ReservationApprovalGroup` is the more flexible mechanism — it lets you define *multiple* approval groups per stage and scope them by campus. The single-column defaults on ReservationType are the fallback when no per-campus row applies.
