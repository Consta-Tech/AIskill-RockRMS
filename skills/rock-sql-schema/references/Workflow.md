# Workflow

> **Provenance tier:** `measured` — tested in a live Rock instance (Rock version not recorded). Catalogued in the plugin's knowledge manifest; `rockrms-knowledge-current` lists every entry.



Workflow type definitions, activity and action blueprints, form configuration, runtime instances, and logging.

> For a full index of all Rock RMS SQL table schemas and additional context, see `README.md`.

## Summary

| Table | Description | Key Foreign Keys |
|-------|-------------|------------------|
| WorkflowFormBuilderTemplate | Reusable template for form-builder workflow entry forms | — |
| WorkflowType | Blueprint defining a workflow's activities, settings, and processing rules | Category, WorkflowFormBuilderTemplate |
| WorkflowActivityType | Defines an activity step within a WorkflowType | WorkflowType (CASCADE) |
| WorkflowActionForm | User-facing form configuration for workflow action entry points | DefinedValue (many), SystemCommunication, SystemEmail |
| WorkflowActionFormSection | Logical section grouping within a WorkflowActionForm | WorkflowActionForm (CASCADE), DefinedValue |
| WorkflowActionFormAttribute | Links an Attribute to a form with display and validation settings | WorkflowActionForm (CASCADE), WorkflowActionFormSection, Attribute (CASCADE) |
| WorkflowActionType | Defines a single action step within a WorkflowActivityType | WorkflowActivityType (CASCADE), WorkflowActionForm, EntityType (CASCADE) |
| WorkflowTrigger | Auto-launches a workflow when an entity event occurs | WorkflowType (CASCADE), EntityType |
| Workflow | A running instance of a WorkflowType | WorkflowType (CASCADE), Campus |
| WorkflowActivity | A running instance of a WorkflowActivityType within a Workflow | Workflow (CASCADE), WorkflowActivityType, Group, self-referencing |
| WorkflowAction | A running instance of a WorkflowActionType within a WorkflowActivity | WorkflowActivity (CASCADE), WorkflowActionType |
| WorkflowLog | Timestamped log entries for a Workflow instance | Workflow (CASCADE) |

---

## WorkflowFormBuilderTemplate
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[WorkflowFormBuilderTemplate](

[Id] [int] IDENTITY(1,1) NOT NULL,

[Name] [nvarchar](100) NOT NULL,

[Description] [nvarchar](max) NULL,

[IsActive] [bit] NOT NULL,

[FormHeader] [nvarchar](max) NULL,

[FormFooter] [nvarchar](max) NULL,

[AllowPersonEntry] [bit] NOT NULL,

[PersonEntrySettingsJson] [nvarchar](max) NULL,

[ConfirmationEmailSettingsJson] [nvarchar](max) NULL,

[CompletionSettingsJson] [nvarchar](max) NULL,

[IsLoginRequired] [bit] NOT NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[Guid] [uniqueidentifier] NOT NULL,

[ForeignId] [int] NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignKey] [nvarchar](100) NULL

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[WorkflowFormBuilderTemplate] ADD  CONSTRAINT [PK_dbo.WorkflowFormBuilderTemplate] PRIMARY KEY CLUSTERED 

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[WorkflowFormBuilderTemplate]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[WorkflowFormBuilderTemplate]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[WorkflowFormBuilderTemplate]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[WorkflowFormBuilderTemplate]  WITH CHECK ADD  CONSTRAINT [FK_dbo.WorkflowFormBuilderTemplate_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[WorkflowFormBuilderTemplate] CHECK CONSTRAINT [FK_dbo.WorkflowFormBuilderTemplate_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[WorkflowFormBuilderTemplate]  WITH CHECK ADD  CONSTRAINT [FK_dbo.WorkflowFormBuilderTemplate_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[WorkflowFormBuilderTemplate] CHECK CONSTRAINT [FK_dbo.WorkflowFormBuilderTemplate_dbo.PersonAlias_ModifiedByPersonAliasId]

GO
```

## WorkflowType
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[WorkflowType](

[Id] [int] IDENTITY(1,1) NOT NULL,

[IsSystem] [bit] NOT NULL,

[IsActive] [bit] NULL,

[Name] [nvarchar](100) NOT NULL,

[Description] [nvarchar](max) NULL,

[CategoryId] [int] NULL,

[Order] [int] NOT NULL,

[WorkTerm] [nvarchar](100) NOT NULL,

[ProcessingIntervalSeconds] [int] NULL,

[IsPersisted] [bit] NOT NULL,

[LoggingLevel] [int] NOT NULL,

[Guid] [uniqueidentifier] NOT NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[ForeignKey] [nvarchar](100) NULL,

[IconCssClass] [nvarchar](100) NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL,

[WorkflowIdPrefix] [nvarchar](100) NULL,

[LogRetentionPeriod] [int] NULL,

[CompletedWorkflowRetentionPeriod] [int] NULL,

[SummaryViewText] [nvarchar](max) NULL,

[NoActionMessage] [nvarchar](max) NULL,

[MaxWorkflowAgeDays] [int] NULL,

[FormBuilderTemplateId] [int] NULL,

[IsFormBuilder] [bit] NOT NULL,

[FormBuilderSettingsJson] [nvarchar](max) NULL,

[FormStartDateTime] [datetime] NULL,

[FormEndDateTime] [datetime] NULL,

[WorkflowExpireDateTime] [datetime] NULL,

[IsLoginRequired] [bit] NOT NULL,

[Slug] [nvarchar](400) NULL

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[WorkflowType] ADD  CONSTRAINT [PK_dbo.WorkflowType] PRIMARY KEY CLUSTERED 

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CategoryId] ON [dbo].[WorkflowType]

(

[CategoryId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[WorkflowType]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_FormBuilderTemplateId] ON [dbo].[WorkflowType]

(

[FormBuilderTemplateId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[WorkflowType]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[WorkflowType]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[WorkflowType] ADD  CONSTRAINT [DF_dbo.WorkflowType_IsActive]  DEFAULT ((1)) FOR [IsActive]

GO

ALTER TABLE [dbo].[WorkflowType] ADD  DEFAULT ((0)) FOR [IsFormBuilder]

GO

ALTER TABLE [dbo].[WorkflowType] ADD  DEFAULT ((0)) FOR [IsLoginRequired]

GO

ALTER TABLE [dbo].[WorkflowType]  WITH CHECK ADD  CONSTRAINT [FK_dbo.WorkflowType_dbo.Category_CategoryId] FOREIGN KEY([CategoryId])

REFERENCES [dbo].[Category] ([Id])

GO

ALTER TABLE [dbo].[WorkflowType] CHECK CONSTRAINT [FK_dbo.WorkflowType_dbo.Category_CategoryId]

GO

ALTER TABLE [dbo].[WorkflowType]  WITH CHECK ADD  CONSTRAINT [FK_dbo.WorkflowType_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[WorkflowType] CHECK CONSTRAINT [FK_dbo.WorkflowType_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[WorkflowType]  WITH CHECK ADD  CONSTRAINT [FK_dbo.WorkflowType_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[WorkflowType] CHECK CONSTRAINT [FK_dbo.WorkflowType_dbo.PersonAlias_ModifiedByPersonAliasId]

GO

ALTER TABLE [dbo].[WorkflowType]  WITH CHECK ADD  CONSTRAINT [FK_dbo.WorkflowType_dbo.WorkflowFormBuilderTemplate_FormBuilderTemplateId] FOREIGN KEY([FormBuilderTemplateId])

REFERENCES [dbo].[WorkflowFormBuilderTemplate] ([Id])

GO

ALTER TABLE [dbo].[WorkflowType] CHECK CONSTRAINT [FK_dbo.WorkflowType_dbo.WorkflowFormBuilderTemplate_FormBuilderTemplateId]

GO
```

## WorkflowActivityType
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[WorkflowActivityType](

[Id] [int] IDENTITY(1,1) NOT NULL,

[IsActive] [bit] NULL,

[WorkflowTypeId] [int] NOT NULL,

[Name] [nvarchar](100) NOT NULL,

[Description] [nvarchar](max) NULL,

[IsActivatedWithWorkflow] [bit] NOT NULL,

[Order] [int] NOT NULL,

[Guid] [uniqueidentifier] NOT NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[ForeignKey] [nvarchar](100) NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[WorkflowActivityType] ADD  CONSTRAINT [PK_dbo.WorkflowActivityType] PRIMARY KEY CLUSTERED 

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[WorkflowActivityType]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[WorkflowActivityType]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[WorkflowActivityType]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_WorkflowTypeId] ON [dbo].[WorkflowActivityType]

(

[WorkflowTypeId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[WorkflowActivityType]  WITH CHECK ADD  CONSTRAINT [FK_dbo.WorkflowActivityType_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[WorkflowActivityType] CHECK CONSTRAINT [FK_dbo.WorkflowActivityType_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[WorkflowActivityType]  WITH CHECK ADD  CONSTRAINT [FK_dbo.WorkflowActivityType_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[WorkflowActivityType] CHECK CONSTRAINT [FK_dbo.WorkflowActivityType_dbo.PersonAlias_ModifiedByPersonAliasId]

GO

ALTER TABLE [dbo].[WorkflowActivityType]  WITH CHECK ADD  CONSTRAINT [FK_dbo.WorkflowActivityType_dbo.WorkflowType_WorkflowTypeId] FOREIGN KEY([WorkflowTypeId])

REFERENCES [dbo].[WorkflowType] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[WorkflowActivityType] CHECK CONSTRAINT [FK_dbo.WorkflowActivityType_dbo.WorkflowType_WorkflowTypeId]

GO
```

## WorkflowActionForm
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[WorkflowActionForm](

[Id] [int] IDENTITY(1,1) NOT NULL,

[Header] [nvarchar](max) NULL,

[Footer] [nvarchar](max) NULL,

[Actions] [nvarchar](2000) NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[Guid] [uniqueidentifier] NOT NULL,

[ForeignKey] [nvarchar](100) NULL,

[NotificationSystemEmailId] [int] NULL,

[IncludeActionsInNotification] [bit] NOT NULL,

[ActionAttributeGuid] [uniqueidentifier] NULL,

[AllowNotes] [bit] NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL,

[NotificationSystemCommunicationId] [int] NULL,

[AllowPersonEntry] [bit] NOT NULL,

[PersonEntryPreHtml] [nvarchar](max) NULL,

[PersonEntryPostHtml] [nvarchar](max) NULL,

[PersonEntryCampusIsVisible] [bit] NOT NULL,

[PersonEntryAutofillCurrentPerson] [bit] NOT NULL,

[PersonEntryHideIfCurrentPersonKnown] [bit] NOT NULL,

[PersonEntrySpouseEntryOption] [int] NOT NULL,

[PersonEntryEmailEntryOption] [int] NOT NULL,

[PersonEntryMobilePhoneEntryOption] [int] NOT NULL,

[PersonEntryBirthdateEntryOption] [int] NOT NULL,

[PersonEntryAddressEntryOption] [int] NOT NULL,

[PersonEntryMaritalStatusEntryOption] [int] NOT NULL,

[PersonEntrySpouseLabel] [nvarchar](50) NOT NULL,

[PersonEntryConnectionStatusValueId] [int] NULL,

[PersonEntryRecordStatusValueId] [int] NULL,

[PersonEntryGroupLocationTypeValueId] [int] NULL,

[PersonEntryPersonAttributeGuid] [uniqueidentifier] NULL,

[PersonEntrySpouseAttributeGuid] [uniqueidentifier] NULL,

[PersonEntryFamilyAttributeGuid] [uniqueidentifier] NULL,

[PersonEntryGenderEntryOption] [int] NOT NULL,

[PersonEntryCampusStatusValueId] [int] NULL,

[PersonEntryCampusTypeValueId] [int] NULL,

[PersonEntrySectionTypeValueId] [int] NULL,

[PersonEntryTitle] [nvarchar](500) NULL,

[PersonEntryDescription] [nvarchar](max) NULL,

[PersonEntryShowHeadingSeparator] [bit] NOT NULL,

[PersonEntryRaceEntryOption] [int] NOT NULL,

[PersonEntryEthnicityEntryOption] [int] NOT NULL,

[PersonEntrySmsOptInEntryOption] [int] NOT NULL,

[AdditionalSettingsJson] [nvarchar](max) NULL,

[PersonEntryRecordSourceValueId] [int] NULL

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[WorkflowActionForm] ADD  CONSTRAINT [PK_dbo.WorkflowActionForm] PRIMARY KEY CLUSTERED 

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[WorkflowActionForm]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[WorkflowActionForm]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[WorkflowActionForm]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_NotificationSystemEmailId] ON [dbo].[WorkflowActionForm]

(

[NotificationSystemEmailId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_PersonEntryCampusStatusValueId] ON [dbo].[WorkflowActionForm]

(

[PersonEntryCampusStatusValueId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_PersonEntryCampusTypeValueId] ON [dbo].[WorkflowActionForm]

(

[PersonEntryCampusTypeValueId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_PersonEntryConnectionStatusValueId] ON [dbo].[WorkflowActionForm]

(

[PersonEntryConnectionStatusValueId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_PersonEntryGroupLocationTypeValueId] ON [dbo].[WorkflowActionForm]

(

[PersonEntryGroupLocationTypeValueId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_PersonEntryRecordStatusValueId] ON [dbo].[WorkflowActionForm]

(

[PersonEntryRecordStatusValueId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_PersonEntrySectionTypeValueId] ON [dbo].[WorkflowActionForm]

(

[PersonEntrySectionTypeValueId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[WorkflowActionForm] ADD  DEFAULT ((0)) FOR [IncludeActionsInNotification]

GO

ALTER TABLE [dbo].[WorkflowActionForm] ADD  DEFAULT ((0)) FOR [AllowPersonEntry]

GO

ALTER TABLE [dbo].[WorkflowActionForm] ADD  DEFAULT ((1)) FOR [PersonEntryCampusIsVisible]

GO

ALTER TABLE [dbo].[WorkflowActionForm] ADD  DEFAULT ((1)) FOR [PersonEntryAutofillCurrentPerson]

GO

ALTER TABLE [dbo].[WorkflowActionForm] ADD  CONSTRAINT [df_PersonEntryHideIfCurrentPersonKnown]  DEFAULT ((0)) FOR [PersonEntryHideIfCurrentPersonKnown]

GO

ALTER TABLE [dbo].[WorkflowActionForm] ADD  DEFAULT ((0)) FOR [PersonEntrySpouseEntryOption]

GO

ALTER TABLE [dbo].[WorkflowActionForm] ADD  DEFAULT ((2)) FOR [PersonEntryEmailEntryOption]

GO

ALTER TABLE [dbo].[WorkflowActionForm] ADD  DEFAULT ((0)) FOR [PersonEntryMobilePhoneEntryOption]

GO

ALTER TABLE [dbo].[WorkflowActionForm] ADD  DEFAULT ((0)) FOR [PersonEntryBirthdateEntryOption]

GO

ALTER TABLE [dbo].[WorkflowActionForm] ADD  DEFAULT ((0)) FOR [PersonEntryAddressEntryOption]

GO

ALTER TABLE [dbo].[WorkflowActionForm] ADD  DEFAULT ((0)) FOR [PersonEntryMaritalStatusEntryOption]

GO

ALTER TABLE [dbo].[WorkflowActionForm] ADD  DEFAULT ('Spouse') FOR [PersonEntrySpouseLabel]

GO

ALTER TABLE [dbo].[WorkflowActionForm] ADD  DEFAULT ((2)) FOR [PersonEntryGenderEntryOption]

GO

ALTER TABLE [dbo].[WorkflowActionForm] ADD  DEFAULT ((0)) FOR [PersonEntryShowHeadingSeparator]

GO

ALTER TABLE [dbo].[WorkflowActionForm] ADD  DEFAULT ((0)) FOR [PersonEntryRaceEntryOption]

GO

ALTER TABLE [dbo].[WorkflowActionForm] ADD  DEFAULT ((0)) FOR [PersonEntryEthnicityEntryOption]

GO

ALTER TABLE [dbo].[WorkflowActionForm] ADD  DEFAULT ((0)) FOR [PersonEntrySmsOptInEntryOption]

GO

ALTER TABLE [dbo].[WorkflowActionForm]  WITH CHECK ADD  CONSTRAINT [FK_dbo.WorkflowActionForm_dbo.DefinedValue_PersonEntryCampusStatusValueId] FOREIGN KEY([PersonEntryCampusStatusValueId])

REFERENCES [dbo].[DefinedValue] ([Id])

GO

ALTER TABLE [dbo].[WorkflowActionForm] CHECK CONSTRAINT [FK_dbo.WorkflowActionForm_dbo.DefinedValue_PersonEntryCampusStatusValueId]

GO

ALTER TABLE [dbo].[WorkflowActionForm]  WITH CHECK ADD  CONSTRAINT [FK_dbo.WorkflowActionForm_dbo.DefinedValue_PersonEntryCampusTypeValueId] FOREIGN KEY([PersonEntryCampusTypeValueId])

REFERENCES [dbo].[DefinedValue] ([Id])

GO

ALTER TABLE [dbo].[WorkflowActionForm] CHECK CONSTRAINT [FK_dbo.WorkflowActionForm_dbo.DefinedValue_PersonEntryCampusTypeValueId]

GO

ALTER TABLE [dbo].[WorkflowActionForm]  WITH CHECK ADD  CONSTRAINT [FK_dbo.WorkflowActionForm_dbo.DefinedValue_PersonEntryConnectionStatusValueId] FOREIGN KEY([PersonEntryConnectionStatusValueId])

REFERENCES [dbo].[DefinedValue] ([Id])

GO

ALTER TABLE [dbo].[WorkflowActionForm] CHECK CONSTRAINT [FK_dbo.WorkflowActionForm_dbo.DefinedValue_PersonEntryConnectionStatusValueId]

GO

ALTER TABLE [dbo].[WorkflowActionForm]  WITH CHECK ADD  CONSTRAINT [FK_dbo.WorkflowActionForm_dbo.DefinedValue_PersonEntryGroupLocationTypeValueId] FOREIGN KEY([PersonEntryGroupLocationTypeValueId])

REFERENCES [dbo].[DefinedValue] ([Id])

GO

ALTER TABLE [dbo].[WorkflowActionForm] CHECK CONSTRAINT [FK_dbo.WorkflowActionForm_dbo.DefinedValue_PersonEntryGroupLocationTypeValueId]

GO

ALTER TABLE [dbo].[WorkflowActionForm]  WITH CHECK ADD  CONSTRAINT [FK_dbo.WorkflowActionForm_dbo.DefinedValue_PersonEntryRecordSourceValueId] FOREIGN KEY([PersonEntryRecordSourceValueId])

REFERENCES [dbo].[DefinedValue] ([Id])

GO

ALTER TABLE [dbo].[WorkflowActionForm] CHECK CONSTRAINT [FK_dbo.WorkflowActionForm_dbo.DefinedValue_PersonEntryRecordSourceValueId]

GO

ALTER TABLE [dbo].[WorkflowActionForm]  WITH CHECK ADD  CONSTRAINT [FK_dbo.WorkflowActionForm_dbo.DefinedValue_PersonEntryRecordStatusValueId] FOREIGN KEY([PersonEntryRecordStatusValueId])

REFERENCES [dbo].[DefinedValue] ([Id])

GO

ALTER TABLE [dbo].[WorkflowActionForm] CHECK CONSTRAINT [FK_dbo.WorkflowActionForm_dbo.DefinedValue_PersonEntryRecordStatusValueId]

GO

ALTER TABLE [dbo].[WorkflowActionForm]  WITH CHECK ADD  CONSTRAINT [FK_dbo.WorkflowActionForm_dbo.DefinedValue_PersonEntrySectionTypeValueId] FOREIGN KEY([PersonEntrySectionTypeValueId])

REFERENCES [dbo].[DefinedValue] ([Id])

GO

ALTER TABLE [dbo].[WorkflowActionForm] CHECK CONSTRAINT [FK_dbo.WorkflowActionForm_dbo.DefinedValue_PersonEntrySectionTypeValueId]

GO

ALTER TABLE [dbo].[WorkflowActionForm]  WITH CHECK ADD  CONSTRAINT [FK_dbo.WorkflowActionForm_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[WorkflowActionForm] CHECK CONSTRAINT [FK_dbo.WorkflowActionForm_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[WorkflowActionForm]  WITH CHECK ADD  CONSTRAINT [FK_dbo.WorkflowActionForm_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[WorkflowActionForm] CHECK CONSTRAINT [FK_dbo.WorkflowActionForm_dbo.PersonAlias_ModifiedByPersonAliasId]

GO

ALTER TABLE [dbo].[WorkflowActionForm]  WITH CHECK ADD  CONSTRAINT [FK_dbo.WorkflowActionForm_dbo.SystemCommunication_NotificationSystemCommunicationId] FOREIGN KEY([NotificationSystemCommunicationId])

REFERENCES [dbo].[SystemCommunication] ([Id])

GO

ALTER TABLE [dbo].[WorkflowActionForm] CHECK CONSTRAINT [FK_dbo.WorkflowActionForm_dbo.SystemCommunication_NotificationSystemCommunicationId]

GO

ALTER TABLE [dbo].[WorkflowActionForm]  WITH CHECK ADD  CONSTRAINT [FK_dbo.WorkflowActionForm_dbo.SystemEmail_NotificationSystemEmailId] FOREIGN KEY([NotificationSystemEmailId])

REFERENCES [dbo].[SystemEmail] ([Id])

GO

ALTER TABLE [dbo].[WorkflowActionForm] CHECK CONSTRAINT [FK_dbo.WorkflowActionForm_dbo.SystemEmail_NotificationSystemEmailId]

GO
```

## WorkflowActionFormSection
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[WorkflowActionFormSection](

[Id] [int] IDENTITY(1,1) NOT NULL,

[Title] [nvarchar](500) NULL,

[Description] [nvarchar](max) NULL,

[ShowHeadingSeparator] [bit] NOT NULL,

[SectionVisibilityRulesJSON] [nvarchar](max) NULL,

[Order] [int] NOT NULL,

[WorkflowActionFormId] [int] NOT NULL,

[SectionTypeValueId] [int] NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[Guid] [uniqueidentifier] NOT NULL,

[ForeignId] [int] NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignKey] [nvarchar](100) NULL

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[WorkflowActionFormSection] ADD  CONSTRAINT [PK_dbo.WorkflowActionFormSection] PRIMARY KEY CLUSTERED 

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[WorkflowActionFormSection]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[WorkflowActionFormSection]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[WorkflowActionFormSection]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_SectionTypeValueId] ON [dbo].[WorkflowActionFormSection]

(

[SectionTypeValueId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_WorkflowActionFormId] ON [dbo].[WorkflowActionFormSection]

(

[WorkflowActionFormId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[WorkflowActionFormSection]  WITH CHECK ADD  CONSTRAINT [FK_dbo.WorkflowActionFormSection_dbo.DefinedValue_SectionTypeValueId] FOREIGN KEY([SectionTypeValueId])

REFERENCES [dbo].[DefinedValue] ([Id])

GO

ALTER TABLE [dbo].[WorkflowActionFormSection] CHECK CONSTRAINT [FK_dbo.WorkflowActionFormSection_dbo.DefinedValue_SectionTypeValueId]

GO

ALTER TABLE [dbo].[WorkflowActionFormSection]  WITH CHECK ADD  CONSTRAINT [FK_dbo.WorkflowActionFormSection_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[WorkflowActionFormSection] CHECK CONSTRAINT [FK_dbo.WorkflowActionFormSection_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[WorkflowActionFormSection]  WITH CHECK ADD  CONSTRAINT [FK_dbo.WorkflowActionFormSection_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[WorkflowActionFormSection] CHECK CONSTRAINT [FK_dbo.WorkflowActionFormSection_dbo.PersonAlias_ModifiedByPersonAliasId]

GO

ALTER TABLE [dbo].[WorkflowActionFormSection]  WITH CHECK ADD  CONSTRAINT [FK_dbo.WorkflowActionFormSection_dbo.WorkflowActionForm_WorkflowActionFormId] FOREIGN KEY([WorkflowActionFormId])

REFERENCES [dbo].[WorkflowActionForm] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[WorkflowActionFormSection] CHECK CONSTRAINT [FK_dbo.WorkflowActionFormSection_dbo.WorkflowActionForm_WorkflowActionFormId]

GO
```

## WorkflowActionFormAttribute
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[WorkflowActionFormAttribute](

[Id] [int] IDENTITY(1,1) NOT NULL,

[WorkflowActionFormId] [int] NOT NULL,

[AttributeId] [int] NOT NULL,

[Order] [int] NOT NULL,

[IsVisible] [bit] NOT NULL,

[IsReadOnly] [bit] NOT NULL,

[IsRequired] [bit] NOT NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[Guid] [uniqueidentifier] NOT NULL,

[ForeignKey] [nvarchar](100) NULL,

[HideLabel] [bit] NOT NULL,

[PreHtml] [nvarchar](max) NULL,

[PostHtml] [nvarchar](max) NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL,

[FieldVisibilityRulesJSON] [nvarchar](max) NULL,

[ColumnSize] [int] NULL,

[ActionFormSectionId] [int] NULL

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[WorkflowActionFormAttribute] ADD  CONSTRAINT [PK_dbo.WorkflowActionFormAttribute] PRIMARY KEY CLUSTERED 

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ActionFormSectionId] ON [dbo].[WorkflowActionFormAttribute]

(

[ActionFormSectionId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_AttributeId] ON [dbo].[WorkflowActionFormAttribute]

(

[AttributeId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[WorkflowActionFormAttribute]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[WorkflowActionFormAttribute]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[WorkflowActionFormAttribute]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_WorkflowActionFormId] ON [dbo].[WorkflowActionFormAttribute]

(

[WorkflowActionFormId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[WorkflowActionFormAttribute] ADD  DEFAULT ((0)) FOR [HideLabel]

GO

ALTER TABLE [dbo].[WorkflowActionFormAttribute]  WITH CHECK ADD  CONSTRAINT [FK_dbo.WorkflowActionFormAttribute_dbo.Attribute_AttributeId] FOREIGN KEY([AttributeId])

REFERENCES [dbo].[Attribute] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[WorkflowActionFormAttribute] CHECK CONSTRAINT [FK_dbo.WorkflowActionFormAttribute_dbo.Attribute_AttributeId]

GO

ALTER TABLE [dbo].[WorkflowActionFormAttribute]  WITH CHECK ADD  CONSTRAINT [FK_dbo.WorkflowActionFormAttribute_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[WorkflowActionFormAttribute] CHECK CONSTRAINT [FK_dbo.WorkflowActionFormAttribute_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[WorkflowActionFormAttribute]  WITH CHECK ADD  CONSTRAINT [FK_dbo.WorkflowActionFormAttribute_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[WorkflowActionFormAttribute] CHECK CONSTRAINT [FK_dbo.WorkflowActionFormAttribute_dbo.PersonAlias_ModifiedByPersonAliasId]

GO

ALTER TABLE [dbo].[WorkflowActionFormAttribute]  WITH CHECK ADD  CONSTRAINT [FK_dbo.WorkflowActionFormAttribute_dbo.WorkflowActionForm_WorkflowActionFormId] FOREIGN KEY([WorkflowActionFormId])

REFERENCES [dbo].[WorkflowActionForm] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[WorkflowActionFormAttribute] CHECK CONSTRAINT [FK_dbo.WorkflowActionFormAttribute_dbo.WorkflowActionForm_WorkflowActionFormId]

GO

ALTER TABLE [dbo].[WorkflowActionFormAttribute]  WITH CHECK ADD  CONSTRAINT [FK_dbo.WorkflowActionFormAttribute_dbo.WorkflowActionFormSection_ActionFormSectionId] FOREIGN KEY([ActionFormSectionId])

REFERENCES [dbo].[WorkflowActionFormSection] ([Id])

GO

ALTER TABLE [dbo].[WorkflowActionFormAttribute] CHECK CONSTRAINT [FK_dbo.WorkflowActionFormAttribute_dbo.WorkflowActionFormSection_ActionFormSectionId]

GO
```

## WorkflowActionType
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[WorkflowActionType](

[Id] [int] IDENTITY(1,1) NOT NULL,

[ActivityTypeId] [int] NOT NULL,

[Name] [nvarchar](100) NOT NULL,

[Order] [int] NOT NULL,

[EntityTypeId] [int] NOT NULL,

[IsActionCompletedOnSuccess] [bit] NOT NULL,

[IsActivityCompletedOnSuccess] [bit] NOT NULL,

[Guid] [uniqueidentifier] NOT NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[ForeignKey] [nvarchar](100) NULL,

[WorkflowFormId] [int] NULL,

[CriteriaAttributeGuid] [uniqueidentifier] NULL,

[CriteriaComparisonType] [int] NOT NULL,

[CriteriaValue] [nvarchar](100) NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL,

[IsActionCompletedIfCriteriaUnmet] [bit] NOT NULL

) ON [PRIMARY]

GO

ALTER TABLE [dbo].[WorkflowActionType] ADD  CONSTRAINT [PK_dbo.WorkflowActionType] PRIMARY KEY CLUSTERED 

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ActivityTypeId] ON [dbo].[WorkflowActionType]

(

[ActivityTypeId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[WorkflowActionType]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_EntityTypeId] ON [dbo].[WorkflowActionType]

(

[EntityTypeId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[WorkflowActionType]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[WorkflowActionType]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_WorkflowFormId] ON [dbo].[WorkflowActionType]

(

[WorkflowFormId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[WorkflowActionType] ADD  DEFAULT ((0)) FOR [CriteriaComparisonType]

GO

ALTER TABLE [dbo].[WorkflowActionType] ADD  DEFAULT ((0)) FOR [IsActionCompletedIfCriteriaUnmet]

GO

ALTER TABLE [dbo].[WorkflowActionType]  WITH CHECK ADD  CONSTRAINT [FK_dbo.WorkflowActionType_dbo.EntityType_EntityTypeId] FOREIGN KEY([EntityTypeId])

REFERENCES [dbo].[EntityType] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[WorkflowActionType] CHECK CONSTRAINT [FK_dbo.WorkflowActionType_dbo.EntityType_EntityTypeId]

GO

ALTER TABLE [dbo].[WorkflowActionType]  WITH CHECK ADD  CONSTRAINT [FK_dbo.WorkflowActionType_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[WorkflowActionType] CHECK CONSTRAINT [FK_dbo.WorkflowActionType_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[WorkflowActionType]  WITH CHECK ADD  CONSTRAINT [FK_dbo.WorkflowActionType_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[WorkflowActionType] CHECK CONSTRAINT [FK_dbo.WorkflowActionType_dbo.PersonAlias_ModifiedByPersonAliasId]

GO

ALTER TABLE [dbo].[WorkflowActionType]  WITH CHECK ADD  CONSTRAINT [FK_dbo.WorkflowActionType_dbo.WorkflowActionForm_WorkflowFormId] FOREIGN KEY([WorkflowFormId])

REFERENCES [dbo].[WorkflowActionForm] ([Id])

GO

ALTER TABLE [dbo].[WorkflowActionType] CHECK CONSTRAINT [FK_dbo.WorkflowActionType_dbo.WorkflowActionForm_WorkflowFormId]

GO

ALTER TABLE [dbo].[WorkflowActionType]  WITH CHECK ADD  CONSTRAINT [FK_dbo.WorkflowActionType_dbo.WorkflowActivityType_ActivityTypeId] FOREIGN KEY([ActivityTypeId])

REFERENCES [dbo].[WorkflowActivityType] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[WorkflowActionType] CHECK CONSTRAINT [FK_dbo.WorkflowActionType_dbo.WorkflowActivityType_ActivityTypeId]

GO
```

## WorkflowTrigger
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[WorkflowTrigger](

[Id] [int] IDENTITY(1,1) NOT NULL,

[IsSystem] [bit] NOT NULL,

[EntityTypeId] [int] NOT NULL,

[EntityTypeQualifierColumn] [nvarchar](50) NULL,

[EntityTypeQualifierValue] [nvarchar](200) NULL,

[WorkflowTypeId] [int] NOT NULL,

[WorkflowTriggerType] [int] NOT NULL,

[WorkflowName] [nvarchar](100) NULL,

[Guid] [uniqueidentifier] NOT NULL,

[IsActive] [bit] NULL,

[ForeignKey] [nvarchar](100) NULL,

[EntityTypeQualifierValuePrevious] [nvarchar](200) NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL

) ON [PRIMARY]

GO

ALTER TABLE [dbo].[WorkflowTrigger] ADD  CONSTRAINT [PK_dbo.WorkflowTrigger] PRIMARY KEY CLUSTERED 

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_EntityTypeId] ON [dbo].[WorkflowTrigger]

(

[EntityTypeId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[WorkflowTrigger]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_WorkflowTypeId] ON [dbo].[WorkflowTrigger]

(

[WorkflowTypeId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[WorkflowTrigger]  WITH CHECK ADD  CONSTRAINT [FK_dbo.WorkflowTrigger_dbo.EntityType_EntityTypeId] FOREIGN KEY([EntityTypeId])

REFERENCES [dbo].[EntityType] ([Id])

GO

ALTER TABLE [dbo].[WorkflowTrigger] CHECK CONSTRAINT [FK_dbo.WorkflowTrigger_dbo.EntityType_EntityTypeId]

GO

ALTER TABLE [dbo].[WorkflowTrigger]  WITH CHECK ADD  CONSTRAINT [FK_dbo.WorkflowTrigger_dbo.WorkflowType_WorkflowTypeId] FOREIGN KEY([WorkflowTypeId])

REFERENCES [dbo].[WorkflowType] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[WorkflowTrigger] CHECK CONSTRAINT [FK_dbo.WorkflowTrigger_dbo.WorkflowType_WorkflowTypeId]

GO
```

## Workflow
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[Workflow](

[Id] [int] IDENTITY(1,1) NOT NULL,

[WorkflowTypeId] [int] NOT NULL,

[Name] [nvarchar](250) NOT NULL,

[Description] [nvarchar](max) NULL,

[Status] [nvarchar](100) NOT NULL,

[IsProcessing] [bit] NOT NULL,

[ActivatedDateTime] [datetime] NULL,

[LastProcessedDateTime] [datetime] NULL,

[CompletedDateTime] [datetime] NULL,

[Guid] [uniqueidentifier] NOT NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[ForeignKey] [nvarchar](100) NULL,

[InitiatorPersonAliasId] [int] NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL,

[WorkflowIdNumber] [int] NOT NULL,

[EntityId] [int] NULL,

[EntityTypeId] [int] NULL,

[CampusId] [int] NULL,

[WorkflowId] [nvarchar](max) NULL

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[Workflow] ADD  CONSTRAINT [PK_dbo.Workflow] PRIMARY KEY CLUSTERED 

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CampusId] ON [dbo].[Workflow]

(

[CampusId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[Workflow]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[Workflow]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_InitiatorPersonAliasId] ON [dbo].[Workflow]

(

[InitiatorPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[Workflow]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_WorkflowTypeId] ON [dbo].[Workflow]

(

[WorkflowTypeId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[Workflow] ADD  DEFAULT ((0)) FOR [WorkflowIdNumber]

GO

ALTER TABLE [dbo].[Workflow]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Workflow_dbo.Campus_CampusId] FOREIGN KEY([CampusId])

REFERENCES [dbo].[Campus] ([Id])

GO

ALTER TABLE [dbo].[Workflow] CHECK CONSTRAINT [FK_dbo.Workflow_dbo.Campus_CampusId]

GO

ALTER TABLE [dbo].[Workflow]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Workflow_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[Workflow] CHECK CONSTRAINT [FK_dbo.Workflow_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[Workflow]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Workflow_dbo.PersonAlias_InitiatorPersonAliasId] FOREIGN KEY([InitiatorPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[Workflow] CHECK CONSTRAINT [FK_dbo.Workflow_dbo.PersonAlias_InitiatorPersonAliasId]

GO

ALTER TABLE [dbo].[Workflow]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Workflow_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[Workflow] CHECK CONSTRAINT [FK_dbo.Workflow_dbo.PersonAlias_ModifiedByPersonAliasId]

GO

ALTER TABLE [dbo].[Workflow]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Workflow_dbo.WorkflowType_WorkflowTypeId] FOREIGN KEY([WorkflowTypeId])

REFERENCES [dbo].[WorkflowType] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[Workflow] CHECK CONSTRAINT [FK_dbo.Workflow_dbo.WorkflowType_WorkflowTypeId]

GO
```

## WorkflowActivity
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[WorkflowActivity](

[Id] [int] IDENTITY(1,1) NOT NULL,

[WorkflowId] [int] NOT NULL,

[ActivityTypeId] [int] NOT NULL,

[ActivatedDateTime] [datetime] NULL,

[LastProcessedDateTime] [datetime] NULL,

[CompletedDateTime] [datetime] NULL,

[Guid] [uniqueidentifier] NOT NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[ForeignKey] [nvarchar](100) NULL,

[AssignedPersonAliasId] [int] NULL,

[AssignedGroupId] [int] NULL,

[ActivatedByActivityId] [int] NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL

) ON [PRIMARY]

GO

ALTER TABLE [dbo].[WorkflowActivity] ADD  CONSTRAINT [PK_dbo.WorkflowActivity] PRIMARY KEY CLUSTERED 

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ActivatedByActivityId] ON [dbo].[WorkflowActivity]

(

[ActivatedByActivityId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ActivityTypeId] ON [dbo].[WorkflowActivity]

(

[ActivityTypeId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_AssignedGroupId] ON [dbo].[WorkflowActivity]

(

[AssignedGroupId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_AssignedPersonAliasId] ON [dbo].[WorkflowActivity]

(

[AssignedPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CompletedDateTimeActivatedDateTIme] ON [dbo].[WorkflowActivity]

(

[CompletedDateTime] ASC,

[ActivatedDateTime] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[WorkflowActivity]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[WorkflowActivity]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[WorkflowActivity]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_WorkflowId] ON [dbo].[WorkflowActivity]

(

[WorkflowId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[WorkflowActivity]  WITH CHECK ADD  CONSTRAINT [FK_dbo.WorkflowActivity_dbo.Group_AssignedGroupId] FOREIGN KEY([AssignedGroupId])

REFERENCES [dbo].[Group] ([Id])

GO

ALTER TABLE [dbo].[WorkflowActivity] CHECK CONSTRAINT [FK_dbo.WorkflowActivity_dbo.Group_AssignedGroupId]

GO

ALTER TABLE [dbo].[WorkflowActivity]  WITH CHECK ADD  CONSTRAINT [FK_dbo.WorkflowActivity_dbo.PersonAlias_AssignedPersonAliasId] FOREIGN KEY([AssignedPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[WorkflowActivity] CHECK CONSTRAINT [FK_dbo.WorkflowActivity_dbo.PersonAlias_AssignedPersonAliasId]

GO

ALTER TABLE [dbo].[WorkflowActivity]  WITH CHECK ADD  CONSTRAINT [FK_dbo.WorkflowActivity_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[WorkflowActivity] CHECK CONSTRAINT [FK_dbo.WorkflowActivity_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[WorkflowActivity]  WITH CHECK ADD  CONSTRAINT [FK_dbo.WorkflowActivity_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[WorkflowActivity] CHECK CONSTRAINT [FK_dbo.WorkflowActivity_dbo.PersonAlias_ModifiedByPersonAliasId]

GO

ALTER TABLE [dbo].[WorkflowActivity]  WITH CHECK ADD  CONSTRAINT [FK_dbo.WorkflowActivity_dbo.Workflow_WorkflowId] FOREIGN KEY([WorkflowId])

REFERENCES [dbo].[Workflow] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[WorkflowActivity] CHECK CONSTRAINT [FK_dbo.WorkflowActivity_dbo.Workflow_WorkflowId]

GO

ALTER TABLE [dbo].[WorkflowActivity]  WITH CHECK ADD  CONSTRAINT [FK_dbo.WorkflowActivity_dbo.WorkflowActivity_ActivatedByActivityId] FOREIGN KEY([ActivatedByActivityId])

REFERENCES [dbo].[WorkflowActivity] ([Id])

GO

ALTER TABLE [dbo].[WorkflowActivity] CHECK CONSTRAINT [FK_dbo.WorkflowActivity_dbo.WorkflowActivity_ActivatedByActivityId]

GO

ALTER TABLE [dbo].[WorkflowActivity]  WITH CHECK ADD  CONSTRAINT [FK_dbo.WorkflowActivity_dbo.WorkflowActivityType_ActivityTypeId] FOREIGN KEY([ActivityTypeId])

REFERENCES [dbo].[WorkflowActivityType] ([Id])

GO

ALTER TABLE [dbo].[WorkflowActivity] CHECK CONSTRAINT [FK_dbo.WorkflowActivity_dbo.WorkflowActivityType_ActivityTypeId]

GO
```

## WorkflowAction
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[WorkflowAction](

[Id] [int] IDENTITY(1,1) NOT NULL,

[ActivityId] [int] NOT NULL,

[ActionTypeId] [int] NOT NULL,

[LastProcessedDateTime] [datetime] NULL,

[CompletedDateTime] [datetime] NULL,

[Guid] [uniqueidentifier] NOT NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[ForeignKey] [nvarchar](100) NULL,

[FormAction] [nvarchar](200) NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL

) ON [PRIMARY]

GO

ALTER TABLE [dbo].[WorkflowAction] ADD  CONSTRAINT [PK_dbo.WorkflowAction] PRIMARY KEY CLUSTERED 

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ActionTypeId] ON [dbo].[WorkflowAction]

(

[ActionTypeId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ActivityId] ON [dbo].[WorkflowAction]

(

[ActivityId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CompletedDateTIme] ON [dbo].[WorkflowAction]

(

[CompletedDateTime] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[WorkflowAction]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[WorkflowAction]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[WorkflowAction]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[WorkflowAction]  WITH CHECK ADD  CONSTRAINT [FK_dbo.WorkflowAction_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[WorkflowAction] CHECK CONSTRAINT [FK_dbo.WorkflowAction_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[WorkflowAction]  WITH CHECK ADD  CONSTRAINT [FK_dbo.WorkflowAction_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[WorkflowAction] CHECK CONSTRAINT [FK_dbo.WorkflowAction_dbo.PersonAlias_ModifiedByPersonAliasId]

GO

ALTER TABLE [dbo].[WorkflowAction]  WITH CHECK ADD  CONSTRAINT [FK_dbo.WorkflowAction_dbo.WorkflowActionType_ActionTypeId] FOREIGN KEY([ActionTypeId])

REFERENCES [dbo].[WorkflowActionType] ([Id])

GO

ALTER TABLE [dbo].[WorkflowAction] CHECK CONSTRAINT [FK_dbo.WorkflowAction_dbo.WorkflowActionType_ActionTypeId]

GO

ALTER TABLE [dbo].[WorkflowAction]  WITH CHECK ADD  CONSTRAINT [FK_dbo.WorkflowAction_dbo.WorkflowActivity_ActivityId] FOREIGN KEY([ActivityId])

REFERENCES [dbo].[WorkflowActivity] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[WorkflowAction] CHECK CONSTRAINT [FK_dbo.WorkflowAction_dbo.WorkflowActivity_ActivityId]

GO
```

## WorkflowLog
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[WorkflowLog](

[Id] [int] IDENTITY(1,1) NOT NULL,

[WorkflowId] [int] NOT NULL,

[LogDateTime] [datetime] NOT NULL,

[LogText] [nvarchar](max) NOT NULL

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[WorkflowLog] ADD  CONSTRAINT [PK_dbo.WorkflowLog] PRIMARY KEY CLUSTERED 

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_WorkflowId] ON [dbo].[WorkflowLog]

(

[WorkflowId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[WorkflowLog]  WITH CHECK ADD  CONSTRAINT [FK_dbo.WorkflowLog_dbo.Workflow_WorkflowId] FOREIGN KEY([WorkflowId])

REFERENCES [dbo].[Workflow] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[WorkflowLog] CHECK CONSTRAINT [FK_dbo.WorkflowLog_dbo.Workflow_WorkflowId]

GO
```
