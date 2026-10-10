# Registration

> **Provenance tier:** `measured` — tested in a live Rock instance (Rock version not recorded). Catalogued in the plugin's knowledge manifest; `rockrms-knowledge-current` lists every entry.



Registration tables support Rock's event registration framework — reusable templates that define forms, fees, discounts, and placement rules; instances that represent specific offerings with dates and capacity; and runtime records that capture each registration submission, its registrants, and their fee charges.

> For a full index of all Rock RMS SQL table schemas and additional context, see `README.md`.

## Summary

| Table | Description | Key Foreign Keys |
|-------|-------------|------------------|
| RegistrationTemplate | Reusable blueprint defining registration behavior, costs, forms, and email templates | Category, GroupType, FinancialGateway, WorkflowType |
| RegistrationTemplateForm | Ordered form sections within a registration template | RegistrationTemplate (CASCADE) |
| RegistrationTemplateFormField | Individual fields on a registration form, sourced from person fields or attributes | RegistrationTemplateForm (CASCADE), Attribute |
| RegistrationTemplateFee | Fee definitions attached to a registration template | RegistrationTemplate (CASCADE) |
| RegistrationTemplateFeeItem | Individual cost options within a multi-option fee | RegistrationTemplateFee (CASCADE) |
| RegistrationTemplateDiscount | Discount codes with percentage or flat-amount reductions | RegistrationTemplate (CASCADE) |
| RegistrationTemplatePlacement | Group placement configurations for assigning registrants to groups | RegistrationTemplate (CASCADE), GroupType |
| RegistrationInstance | A specific offering of a registration template with dates, capacity, and cost overrides | RegistrationTemplate (CASCADE), FinancialAccount |
| Registration | A single registration submission by a registrar, potentially covering multiple registrants | RegistrationInstance, RegistrationTemplate, Group, Campus (CASCADE) |
| RegistrationSession | Tracks in-progress registration sessions for metering and timeout management | RegistrationInstance, Registration |
| RegistrationRegistrant | An individual person registered within a registration | Registration (CASCADE), RegistrationTemplate, GroupMember |
| RegistrationRegistrantFee | Fee charges applied to an individual registrant | RegistrationRegistrant (CASCADE), RegistrationTemplateFee, RegistrationTemplateFeeItem |

---

## RegistrationTemplate
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[RegistrationTemplate](

[Id] [int] IDENTITY(1,1) NOT NULL,

[Name] [nvarchar](100) NOT NULL,

[CategoryId] [int] NULL,

[GroupTypeId] [int] NULL,

[GroupMemberRoleId] [int] NULL,

[GroupMemberStatus] [int] NOT NULL,

[FeeTerm] [nvarchar](100) NULL,

[RegistrantTerm] [nvarchar](100) NULL,

[RegistrationTerm] [nvarchar](100) NULL,

[DiscountCodeTerm] [nvarchar](100) NULL,

[ConfirmationEmailTemplate] [nvarchar](max) NULL,

[ReminderEmailTemplate] [nvarchar](max) NULL,

[Cost] [decimal](18, 2) NOT NULL,

[MinimumInitialPayment] [decimal](18, 2) NULL,

[LoginRequired] [bit] NOT NULL,

[RegistrantsSameFamily] [int] NOT NULL,

[RequestEntryName] [nvarchar](max) NULL,

[SuccessTitle] [nvarchar](max) NULL,

[SuccessText] [nvarchar](max) NULL,

[AllowMultipleRegistrants] [bit] NOT NULL,

[MaxRegistrants] [int] NULL,

[FinancialGatewayId] [int] NULL,

[IsActive] [bit] NOT NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[Guid] [uniqueidentifier] NOT NULL,

[ForeignKey] [nvarchar](100) NULL,

[Notify] [int] NOT NULL,

[ConfirmationFromName] [nvarchar](200) NULL,

[ConfirmationFromEmail] [nvarchar](200) NULL,

[ConfirmationSubject] [nvarchar](200) NULL,

[ReminderFromName] [nvarchar](200) NULL,

[ReminderFromEmail] [nvarchar](200) NULL,

[ReminderSubject] [nvarchar](200) NULL,

[AddPersonNote] [bit] NOT NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL,

[AllowGroupPlacement] [bit] NOT NULL,

[SetCostOnInstance] [bit] NULL,

[PaymentReminderFromName] [nvarchar](200) NULL,

[PaymentReminderFromEmail] [nvarchar](200) NULL,

[PaymentReminderSubject] [nvarchar](200) NULL,

[PaymentReminderEmailTemplate] [nvarchar](max) NULL,

[PaymentReminderTimeSpan] [int] NULL,

[AllowExternalRegistrationUpdates] [bit] NOT NULL,

[BatchNamePrefix] [nvarchar](max) NULL,

[RegistrationWorkflowTypeId] [int] NULL,

[RequiredSignatureDocumentTemplateId] [int] NULL,

[SignatureDocumentAction] [int] NOT NULL,

[ShowCurrentFamilyMembers] [bit] NOT NULL,

[WaitListEnabled] [bit] NOT NULL,

[WaitListTransitionFromName] [nvarchar](200) NULL,

[WaitListTransitionFromEmail] [nvarchar](200) NULL,

[WaitListTransitionSubject] [nvarchar](200) NULL,

[WaitListTransitionEmailTemplate] [nvarchar](max) NULL,

[RegistrationInstructions] [nvarchar](max) NULL,

[RegistrarOption] [int] NOT NULL,

[DefaultPayment] [decimal](18, 2) NULL,

[RegistrationAttributeTitleStart] [nvarchar](200) NULL,

[RegistrationAttributeTitleEnd] [nvarchar](200) NULL,

[Description] [nvarchar](max) NOT NULL,

[IsRegistrationMeteringEnabled] [bit] NOT NULL,

[RegistrantWorkflowTypeId] [int] NULL,

[ShowSmsOptIn] [bit] NOT NULL,

[IsPaymentPlanAllowed] [bit] NOT NULL,

[PaymentPlanFrequencyValueIds] [nvarchar](50) NULL,

[ConnectionStatusValueId] [int] NULL,

[RegistrantRecordSourceValueId] [int] NULL

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[RegistrationTemplate] ADD  CONSTRAINT [PK_dbo.RegistrationTemplate] PRIMARY KEY CLUSTERED 

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CategoryId] ON [dbo].[RegistrationTemplate]

(

[CategoryId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ConnectionStatusValueId] ON [dbo].[RegistrationTemplate]

(

[ConnectionStatusValueId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[RegistrationTemplate]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_FinancialGatewayId] ON [dbo].[RegistrationTemplate]

(

[FinancialGatewayId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_GroupTypeId] ON [dbo].[RegistrationTemplate]

(

[GroupTypeId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[RegistrationTemplate]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[RegistrationTemplate]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_RegistrantWorkflowTypeId] ON [dbo].[RegistrationTemplate]

(

[RegistrantWorkflowTypeId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_RegistrationWorkflowTypeId] ON [dbo].[RegistrationTemplate]

(

[RegistrationWorkflowTypeId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_RequiredSignatureDocumentTemplateId] ON [dbo].[RegistrationTemplate]

(

[RequiredSignatureDocumentTemplateId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[RegistrationTemplate] ADD  DEFAULT ((0)) FOR [Notify]

GO

ALTER TABLE [dbo].[RegistrationTemplate] ADD  DEFAULT ((0)) FOR [AddPersonNote]

GO

ALTER TABLE [dbo].[RegistrationTemplate] ADD  DEFAULT ((0)) FOR [AllowGroupPlacement]

GO

ALTER TABLE [dbo].[RegistrationTemplate] ADD  DEFAULT ((0)) FOR [AllowExternalRegistrationUpdates]

GO

ALTER TABLE [dbo].[RegistrationTemplate] ADD  DEFAULT ((0)) FOR [SignatureDocumentAction]

GO

ALTER TABLE [dbo].[RegistrationTemplate] ADD  DEFAULT ((0)) FOR [ShowCurrentFamilyMembers]

GO

ALTER TABLE [dbo].[RegistrationTemplate] ADD  DEFAULT ((0)) FOR [WaitListEnabled]

GO

ALTER TABLE [dbo].[RegistrationTemplate] ADD  DEFAULT ((0)) FOR [RegistrarOption]

GO

ALTER TABLE [dbo].[RegistrationTemplate] ADD  DEFAULT ((0)) FOR [IsRegistrationMeteringEnabled]

GO

ALTER TABLE [dbo].[RegistrationTemplate] ADD  DEFAULT ((0)) FOR [ShowSmsOptIn]

GO

ALTER TABLE [dbo].[RegistrationTemplate] ADD  DEFAULT ((0)) FOR [IsPaymentPlanAllowed]

GO

ALTER TABLE [dbo].[RegistrationTemplate]  WITH CHECK ADD  CONSTRAINT [FK_dbo.RegistrationTemplate_dbo.Category_CategoryId] FOREIGN KEY([CategoryId])

REFERENCES [dbo].[Category] ([Id])

GO

ALTER TABLE [dbo].[RegistrationTemplate] CHECK CONSTRAINT [FK_dbo.RegistrationTemplate_dbo.Category_CategoryId]

GO

ALTER TABLE [dbo].[RegistrationTemplate]  WITH CHECK ADD  CONSTRAINT [FK_dbo.RegistrationTemplate_dbo.DefinedValue_ConnectionStatusValueId] FOREIGN KEY([ConnectionStatusValueId])

REFERENCES [dbo].[DefinedValue] ([Id])

GO

ALTER TABLE [dbo].[RegistrationTemplate] CHECK CONSTRAINT [FK_dbo.RegistrationTemplate_dbo.DefinedValue_ConnectionStatusValueId]

GO

ALTER TABLE [dbo].[RegistrationTemplate]  WITH CHECK ADD  CONSTRAINT [FK_dbo.RegistrationTemplate_dbo.DefinedValue_RegistrantRecordSourceValueId] FOREIGN KEY([RegistrantRecordSourceValueId])

REFERENCES [dbo].[DefinedValue] ([Id])

GO

ALTER TABLE [dbo].[RegistrationTemplate] CHECK CONSTRAINT [FK_dbo.RegistrationTemplate_dbo.DefinedValue_RegistrantRecordSourceValueId]

GO

ALTER TABLE [dbo].[RegistrationTemplate]  WITH CHECK ADD  CONSTRAINT [FK_dbo.RegistrationTemplate_dbo.FinancialGateway_FinancialGatewayId] FOREIGN KEY([FinancialGatewayId])

REFERENCES [dbo].[FinancialGateway] ([Id])

GO

ALTER TABLE [dbo].[RegistrationTemplate] CHECK CONSTRAINT [FK_dbo.RegistrationTemplate_dbo.FinancialGateway_FinancialGatewayId]

GO

ALTER TABLE [dbo].[RegistrationTemplate]  WITH CHECK ADD  CONSTRAINT [FK_dbo.RegistrationTemplate_dbo.GroupType_GroupTypeId] FOREIGN KEY([GroupTypeId])

REFERENCES [dbo].[GroupType] ([Id])

GO

ALTER TABLE [dbo].[RegistrationTemplate] CHECK CONSTRAINT [FK_dbo.RegistrationTemplate_dbo.GroupType_GroupTypeId]

GO

ALTER TABLE [dbo].[RegistrationTemplate]  WITH CHECK ADD  CONSTRAINT [FK_dbo.RegistrationTemplate_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[RegistrationTemplate] CHECK CONSTRAINT [FK_dbo.RegistrationTemplate_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[RegistrationTemplate]  WITH CHECK ADD  CONSTRAINT [FK_dbo.RegistrationTemplate_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[RegistrationTemplate] CHECK CONSTRAINT [FK_dbo.RegistrationTemplate_dbo.PersonAlias_ModifiedByPersonAliasId]

GO

ALTER TABLE [dbo].[RegistrationTemplate]  WITH CHECK ADD  CONSTRAINT [FK_dbo.RegistrationTemplate_dbo.SignatureDocumentType_RequiredSignatureDocumentTypeId] FOREIGN KEY([RequiredSignatureDocumentTemplateId])

REFERENCES [dbo].[SignatureDocumentTemplate] ([Id])

GO

ALTER TABLE [dbo].[RegistrationTemplate] CHECK CONSTRAINT [FK_dbo.RegistrationTemplate_dbo.SignatureDocumentType_RequiredSignatureDocumentTypeId]

GO

ALTER TABLE [dbo].[RegistrationTemplate]  WITH CHECK ADD  CONSTRAINT [FK_dbo.RegistrationTemplate_dbo.WorkflowType_RegistrantWorkflowTypeId] FOREIGN KEY([RegistrantWorkflowTypeId])

REFERENCES [dbo].[WorkflowType] ([Id])

GO

ALTER TABLE [dbo].[RegistrationTemplate] CHECK CONSTRAINT [FK_dbo.RegistrationTemplate_dbo.WorkflowType_RegistrantWorkflowTypeId]

GO

ALTER TABLE [dbo].[RegistrationTemplate]  WITH CHECK ADD  CONSTRAINT [FK_dbo.RegistrationTemplate_dbo.WorkflowType_RegistrationWorkflowTypeId] FOREIGN KEY([RegistrationWorkflowTypeId])

REFERENCES [dbo].[WorkflowType] ([Id])

GO

ALTER TABLE [dbo].[RegistrationTemplate] CHECK CONSTRAINT [FK_dbo.RegistrationTemplate_dbo.WorkflowType_RegistrationWorkflowTypeId]

GO
```

## RegistrationTemplateForm
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[RegistrationTemplateForm](

[Id] [int] IDENTITY(1,1) NOT NULL,

[Name] [nvarchar](100) NOT NULL,

[RegistrationTemplateId] [int] NOT NULL,

[Order] [int] NOT NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[Guid] [uniqueidentifier] NOT NULL,

[ForeignKey] [nvarchar](100) NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL

) ON [PRIMARY]

GO

ALTER TABLE [dbo].[RegistrationTemplateForm] ADD  CONSTRAINT [PK_dbo.RegistrationTemplateForm] PRIMARY KEY CLUSTERED 

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[RegistrationTemplateForm]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[RegistrationTemplateForm]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[RegistrationTemplateForm]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_RegistrationTemplateId] ON [dbo].[RegistrationTemplateForm]

(

[RegistrationTemplateId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[RegistrationTemplateForm]  WITH CHECK ADD  CONSTRAINT [FK_dbo.RegistrationTemplateForm_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[RegistrationTemplateForm] CHECK CONSTRAINT [FK_dbo.RegistrationTemplateForm_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[RegistrationTemplateForm]  WITH CHECK ADD  CONSTRAINT [FK_dbo.RegistrationTemplateForm_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[RegistrationTemplateForm] CHECK CONSTRAINT [FK_dbo.RegistrationTemplateForm_dbo.PersonAlias_ModifiedByPersonAliasId]

GO

ALTER TABLE [dbo].[RegistrationTemplateForm]  WITH CHECK ADD  CONSTRAINT [FK_dbo.RegistrationTemplateForm_dbo.RegistrationTemplate_RegistrationTemplateId] FOREIGN KEY([RegistrationTemplateId])

REFERENCES [dbo].[RegistrationTemplate] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[RegistrationTemplateForm] CHECK CONSTRAINT [FK_dbo.RegistrationTemplateForm_dbo.RegistrationTemplate_RegistrationTemplateId]

GO
```

## RegistrationTemplateFormField
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[RegistrationTemplateFormField](

[Id] [int] IDENTITY(1,1) NOT NULL,

[RegistrationTemplateFormId] [int] NOT NULL,

[FieldSource] [int] NOT NULL,

[PersonFieldType] [int] NOT NULL,

[AttributeId] [int] NULL,

[IsSharedValue] [bit] NOT NULL,

[ShowCurrentValue] [bit] NOT NULL,

[PreText] [nvarchar](max) NULL,

[PostText] [nvarchar](max) NULL,

[IsGridField] [bit] NOT NULL,

[IsRequired] [bit] NOT NULL,

[Order] [int] NOT NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[Guid] [uniqueidentifier] NOT NULL,

[ForeignKey] [nvarchar](100) NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL,

[IsInternal] [bit] NOT NULL,

[ShowOnWaitlist] [bit] NOT NULL,

[FieldVisibilityRulesJSON] [nvarchar](max) NULL,

[IsLockedIfValuesExist] [bit] NOT NULL

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[RegistrationTemplateFormField] ADD  CONSTRAINT [PK_dbo.RegistrationTemplateFormField] PRIMARY KEY CLUSTERED 

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_AttributeId] ON [dbo].[RegistrationTemplateFormField]

(

[AttributeId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[RegistrationTemplateFormField]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[RegistrationTemplateFormField]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[RegistrationTemplateFormField]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_RegistrationTemplateFormId] ON [dbo].[RegistrationTemplateFormField]

(

[RegistrationTemplateFormId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[RegistrationTemplateFormField] ADD  DEFAULT ((0)) FOR [IsInternal]

GO

ALTER TABLE [dbo].[RegistrationTemplateFormField] ADD  DEFAULT ((0)) FOR [ShowOnWaitlist]

GO

ALTER TABLE [dbo].[RegistrationTemplateFormField] ADD  DEFAULT ((0)) FOR [IsLockedIfValuesExist]

GO

ALTER TABLE [dbo].[RegistrationTemplateFormField]  WITH CHECK ADD  CONSTRAINT [FK_dbo.RegistrationTemplateFormField_dbo.Attribute_AttributeId] FOREIGN KEY([AttributeId])

REFERENCES [dbo].[Attribute] ([Id])

GO

ALTER TABLE [dbo].[RegistrationTemplateFormField] CHECK CONSTRAINT [FK_dbo.RegistrationTemplateFormField_dbo.Attribute_AttributeId]

GO

ALTER TABLE [dbo].[RegistrationTemplateFormField]  WITH CHECK ADD  CONSTRAINT [FK_dbo.RegistrationTemplateFormField_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[RegistrationTemplateFormField] CHECK CONSTRAINT [FK_dbo.RegistrationTemplateFormField_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[RegistrationTemplateFormField]  WITH CHECK ADD  CONSTRAINT [FK_dbo.RegistrationTemplateFormField_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[RegistrationTemplateFormField] CHECK CONSTRAINT [FK_dbo.RegistrationTemplateFormField_dbo.PersonAlias_ModifiedByPersonAliasId]

GO

ALTER TABLE [dbo].[RegistrationTemplateFormField]  WITH CHECK ADD  CONSTRAINT [FK_dbo.RegistrationTemplateFormField_dbo.RegistrationTemplateForm_RegistrationTemplateFormId] FOREIGN KEY([RegistrationTemplateFormId])

REFERENCES [dbo].[RegistrationTemplateForm] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[RegistrationTemplateFormField] CHECK CONSTRAINT [FK_dbo.RegistrationTemplateFormField_dbo.RegistrationTemplateForm_RegistrationTemplateFormId]

GO
```

## RegistrationTemplateFee
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[RegistrationTemplateFee](

[Id] [int] IDENTITY(1,1) NOT NULL,

[Name] [nvarchar](100) NOT NULL,

[RegistrationTemplateId] [int] NOT NULL,

[FeeType] [int] NOT NULL,

[CostValue] [nvarchar](400) NULL,

[DiscountApplies] [bit] NOT NULL,

[AllowMultiple] [bit] NOT NULL,

[Order] [int] NOT NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[Guid] [uniqueidentifier] NOT NULL,

[ForeignKey] [nvarchar](100) NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL,

[IsActive] [bit] NOT NULL,

[IsRequired] [bit] NOT NULL,

[HideWhenNoneRemaining] [bit] NOT NULL

) ON [PRIMARY]

GO

ALTER TABLE [dbo].[RegistrationTemplateFee] ADD  CONSTRAINT [PK_dbo.RegistrationTemplateFee] PRIMARY KEY CLUSTERED 

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[RegistrationTemplateFee]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[RegistrationTemplateFee]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[RegistrationTemplateFee]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_RegistrationTemplateId] ON [dbo].[RegistrationTemplateFee]

(

[RegistrationTemplateId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[RegistrationTemplateFee] ADD  DEFAULT ((0)) FOR [IsActive]

GO

ALTER TABLE [dbo].[RegistrationTemplateFee] ADD  DEFAULT ((0)) FOR [IsRequired]

GO

ALTER TABLE [dbo].[RegistrationTemplateFee] ADD  DEFAULT ((0)) FOR [HideWhenNoneRemaining]

GO

ALTER TABLE [dbo].[RegistrationTemplateFee]  WITH CHECK ADD  CONSTRAINT [FK_dbo.RegistrationTemplateFee_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[RegistrationTemplateFee] CHECK CONSTRAINT [FK_dbo.RegistrationTemplateFee_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[RegistrationTemplateFee]  WITH CHECK ADD  CONSTRAINT [FK_dbo.RegistrationTemplateFee_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[RegistrationTemplateFee] CHECK CONSTRAINT [FK_dbo.RegistrationTemplateFee_dbo.PersonAlias_ModifiedByPersonAliasId]

GO

ALTER TABLE [dbo].[RegistrationTemplateFee]  WITH CHECK ADD  CONSTRAINT [FK_dbo.RegistrationTemplateFee_dbo.RegistrationTemplate_RegistrationTemplateId] FOREIGN KEY([RegistrationTemplateId])

REFERENCES [dbo].[RegistrationTemplate] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[RegistrationTemplateFee] CHECK CONSTRAINT [FK_dbo.RegistrationTemplateFee_dbo.RegistrationTemplate_RegistrationTemplateId]

GO
```

## RegistrationTemplateFeeItem
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[RegistrationTemplateFeeItem](

[Id] [int] IDENTITY(1,1) NOT NULL,

[RegistrationTemplateFeeId] [int] NOT NULL,

[Order] [int] NOT NULL,

[IsActive] [bit] NOT NULL,

[Name] [nvarchar](100) NOT NULL,

[Cost] [decimal](18, 2) NOT NULL,

[MaximumUsageCount] [int] NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[Guid] [uniqueidentifier] NOT NULL,

[ForeignId] [int] NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignKey] [nvarchar](100) NULL

) ON [PRIMARY]

GO

ALTER TABLE [dbo].[RegistrationTemplateFeeItem] ADD  CONSTRAINT [PK_dbo.RegistrationTemplateFeeItem] PRIMARY KEY CLUSTERED 

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[RegistrationTemplateFeeItem]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[RegistrationTemplateFeeItem]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[RegistrationTemplateFeeItem]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_RegistrationTemplateFeeId] ON [dbo].[RegistrationTemplateFeeItem]

(

[RegistrationTemplateFeeId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[RegistrationTemplateFeeItem]  WITH CHECK ADD  CONSTRAINT [FK_dbo.RegistrationTemplateFeeItem_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[RegistrationTemplateFeeItem] CHECK CONSTRAINT [FK_dbo.RegistrationTemplateFeeItem_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[RegistrationTemplateFeeItem]  WITH CHECK ADD  CONSTRAINT [FK_dbo.RegistrationTemplateFeeItem_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[RegistrationTemplateFeeItem] CHECK CONSTRAINT [FK_dbo.RegistrationTemplateFeeItem_dbo.PersonAlias_ModifiedByPersonAliasId]

GO

ALTER TABLE [dbo].[RegistrationTemplateFeeItem]  WITH CHECK ADD  CONSTRAINT [FK_dbo.RegistrationTemplateFeeItem_dbo.RegistrationTemplateFee_RegistrationTemplateFeeId] FOREIGN KEY([RegistrationTemplateFeeId])

REFERENCES [dbo].[RegistrationTemplateFee] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[RegistrationTemplateFeeItem] CHECK CONSTRAINT [FK_dbo.RegistrationTemplateFeeItem_dbo.RegistrationTemplateFee_RegistrationTemplateFeeId]

GO
```

## RegistrationTemplateDiscount
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[RegistrationTemplateDiscount](

[Id] [int] IDENTITY(1,1) NOT NULL,

[Code] [nvarchar](100) NOT NULL,

[RegistrationTemplateId] [int] NOT NULL,

[DiscountPercentage] [decimal](18, 2) NOT NULL,

[DiscountAmount] [decimal](18, 2) NOT NULL,

[Order] [int] NOT NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[Guid] [uniqueidentifier] NOT NULL,

[ForeignKey] [nvarchar](100) NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL,

[MaxUsage] [int] NULL,

[MaxRegistrants] [int] NULL,

[MinRegistrants] [int] NULL,

[StartDate] [datetime] NULL,

[EndDate] [datetime] NULL,

[AutoApplyDiscount] [bit] NOT NULL

) ON [PRIMARY]

GO

ALTER TABLE [dbo].[RegistrationTemplateDiscount] ADD  CONSTRAINT [PK_dbo.RegistrationTemplateDiscount] PRIMARY KEY CLUSTERED 

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[RegistrationTemplateDiscount]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[RegistrationTemplateDiscount]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[RegistrationTemplateDiscount]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_RegistrationTemplateId] ON [dbo].[RegistrationTemplateDiscount]

(

[RegistrationTemplateId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[RegistrationTemplateDiscount] ADD  DEFAULT ((0)) FOR [AutoApplyDiscount]

GO

ALTER TABLE [dbo].[RegistrationTemplateDiscount]  WITH CHECK ADD  CONSTRAINT [FK_dbo.RegistrationTemplateDiscount_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[RegistrationTemplateDiscount] CHECK CONSTRAINT [FK_dbo.RegistrationTemplateDiscount_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[RegistrationTemplateDiscount]  WITH CHECK ADD  CONSTRAINT [FK_dbo.RegistrationTemplateDiscount_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[RegistrationTemplateDiscount] CHECK CONSTRAINT [FK_dbo.RegistrationTemplateDiscount_dbo.PersonAlias_ModifiedByPersonAliasId]

GO

ALTER TABLE [dbo].[RegistrationTemplateDiscount]  WITH CHECK ADD  CONSTRAINT [FK_dbo.RegistrationTemplateDiscount_dbo.RegistrationTemplate_RegistrationTemplateId] FOREIGN KEY([RegistrationTemplateId])

REFERENCES [dbo].[RegistrationTemplate] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[RegistrationTemplateDiscount] CHECK CONSTRAINT [FK_dbo.RegistrationTemplateDiscount_dbo.RegistrationTemplate_RegistrationTemplateId]

GO
```

## RegistrationTemplatePlacement
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[RegistrationTemplatePlacement](

[Id] [int] IDENTITY(1,1) NOT NULL,

[Name] [nvarchar](100) NOT NULL,

[RegistrationTemplateId] [int] NOT NULL,

[GroupTypeId] [int] NOT NULL,

[Order] [int] NOT NULL,

[IconCssClass] [nvarchar](100) NULL,

[AllowMultiplePlacements] [bit] NOT NULL,

[IsInternal] [bit] NOT NULL,

[Cost] [decimal](18, 2) NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[Guid] [uniqueidentifier] NOT NULL,

[ForeignId] [int] NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignKey] [nvarchar](100) NULL

) ON [PRIMARY]

GO

ALTER TABLE [dbo].[RegistrationTemplatePlacement] ADD  CONSTRAINT [PK_dbo.RegistrationTemplatePlacement] PRIMARY KEY CLUSTERED 

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[RegistrationTemplatePlacement]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_GroupTypeId] ON [dbo].[RegistrationTemplatePlacement]

(

[GroupTypeId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[RegistrationTemplatePlacement]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[RegistrationTemplatePlacement]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_RegistrationTemplateId] ON [dbo].[RegistrationTemplatePlacement]

(

[RegistrationTemplateId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[RegistrationTemplatePlacement]  WITH CHECK ADD  CONSTRAINT [FK_dbo.RegistrationTemplatePlacement_dbo.GroupType_GroupTypeId] FOREIGN KEY([GroupTypeId])

REFERENCES [dbo].[GroupType] ([Id])

GO

ALTER TABLE [dbo].[RegistrationTemplatePlacement] CHECK CONSTRAINT [FK_dbo.RegistrationTemplatePlacement_dbo.GroupType_GroupTypeId]

GO

ALTER TABLE [dbo].[RegistrationTemplatePlacement]  WITH CHECK ADD  CONSTRAINT [FK_dbo.RegistrationTemplatePlacement_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[RegistrationTemplatePlacement] CHECK CONSTRAINT [FK_dbo.RegistrationTemplatePlacement_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[RegistrationTemplatePlacement]  WITH CHECK ADD  CONSTRAINT [FK_dbo.RegistrationTemplatePlacement_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[RegistrationTemplatePlacement] CHECK CONSTRAINT [FK_dbo.RegistrationTemplatePlacement_dbo.PersonAlias_ModifiedByPersonAliasId]

GO

ALTER TABLE [dbo].[RegistrationTemplatePlacement]  WITH CHECK ADD  CONSTRAINT [FK_dbo.RegistrationTemplatePlacement_dbo.RegistrationTemplate_RegistrationTemplateId] FOREIGN KEY([RegistrationTemplateId])

REFERENCES [dbo].[RegistrationTemplate] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[RegistrationTemplatePlacement] CHECK CONSTRAINT [FK_dbo.RegistrationTemplatePlacement_dbo.RegistrationTemplate_RegistrationTemplateId]

GO
```

## RegistrationInstance
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[RegistrationInstance](

[Id] [int] IDENTITY(1,1) NOT NULL,

[Name] [nvarchar](100) NOT NULL,

[RegistrationTemplateId] [int] NOT NULL,

[StartDateTime] [datetime] NULL,

[EndDateTime] [datetime] NULL,

[Details] [nvarchar](max) NULL,

[MaxAttendees] [int] NULL,

[AccountId] [int] NULL,

[IsActive] [bit] NOT NULL,

[ContactEmail] [nvarchar](200) NULL,

[AdditionalReminderDetails] [nvarchar](max) NULL,

[AdditionalConfirmationDetails] [nvarchar](max) NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[Guid] [uniqueidentifier] NOT NULL,

[ForeignKey] [nvarchar](100) NULL,

[SendReminderDateTime] [datetime] NULL,

[ReminderSent] [bit] NOT NULL,

[ContactPhone] [nvarchar](50) NULL,

[ContactPersonAliasId] [int] NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL,

[Cost] [decimal](18, 2) NULL,

[MinimumInitialPayment] [decimal](18, 2) NULL,

[RegistrationWorkflowTypeId] [int] NULL,

[RegistrationInstructions] [nvarchar](max) NULL,

[DefaultPayment] [decimal](18, 2) NULL,

[ExternalGatewayMerchantId] [int] NULL,

[ExternalGatewayFundId] [int] NULL,

[RegistrationMeteringThreshold] [int] NULL,

[TimeoutIsEnabled] [bit] NOT NULL,

[TimeoutLengthMinutes] [int] NULL,

[TimeoutThreshold] [int] NULL,

[PaymentDeadlineDate] [date] NULL,

[RegistrantRecordSourceValueId] [int] NULL

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[RegistrationInstance] ADD  CONSTRAINT [PK_dbo.RegistrationInstance] PRIMARY KEY CLUSTERED 

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_AccountId] ON [dbo].[RegistrationInstance]

(

[AccountId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ContactPersonAliasId] ON [dbo].[RegistrationInstance]

(

[ContactPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[RegistrationInstance]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[RegistrationInstance]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[RegistrationInstance]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_RegistrationTemplateId] ON [dbo].[RegistrationInstance]

(

[RegistrationTemplateId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_RegistrationWorkflowTypeId] ON [dbo].[RegistrationInstance]

(

[RegistrationWorkflowTypeId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[RegistrationInstance] ADD  DEFAULT ((0)) FOR [ReminderSent]

GO

ALTER TABLE [dbo].[RegistrationInstance] ADD  DEFAULT ((0)) FOR [TimeoutIsEnabled]

GO

ALTER TABLE [dbo].[RegistrationInstance]  WITH CHECK ADD  CONSTRAINT [FK_dbo.RegistrationInstance_dbo.DefinedValue_RegistrantRecordSourceValueId] FOREIGN KEY([RegistrantRecordSourceValueId])

REFERENCES [dbo].[DefinedValue] ([Id])

GO

ALTER TABLE [dbo].[RegistrationInstance] CHECK CONSTRAINT [FK_dbo.RegistrationInstance_dbo.DefinedValue_RegistrantRecordSourceValueId]

GO

ALTER TABLE [dbo].[RegistrationInstance]  WITH CHECK ADD  CONSTRAINT [FK_dbo.RegistrationInstance_dbo.FinancialAccount_AccountId] FOREIGN KEY([AccountId])

REFERENCES [dbo].[FinancialAccount] ([Id])

GO

ALTER TABLE [dbo].[RegistrationInstance] CHECK CONSTRAINT [FK_dbo.RegistrationInstance_dbo.FinancialAccount_AccountId]

GO

ALTER TABLE [dbo].[RegistrationInstance]  WITH CHECK ADD  CONSTRAINT [FK_dbo.RegistrationInstance_dbo.PersonAlias_ContactPersonAliasId] FOREIGN KEY([ContactPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[RegistrationInstance] CHECK CONSTRAINT [FK_dbo.RegistrationInstance_dbo.PersonAlias_ContactPersonAliasId]

GO

ALTER TABLE [dbo].[RegistrationInstance]  WITH CHECK ADD  CONSTRAINT [FK_dbo.RegistrationInstance_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[RegistrationInstance] CHECK CONSTRAINT [FK_dbo.RegistrationInstance_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[RegistrationInstance]  WITH CHECK ADD  CONSTRAINT [FK_dbo.RegistrationInstance_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[RegistrationInstance] CHECK CONSTRAINT [FK_dbo.RegistrationInstance_dbo.PersonAlias_ModifiedByPersonAliasId]

GO

ALTER TABLE [dbo].[RegistrationInstance]  WITH CHECK ADD  CONSTRAINT [FK_dbo.RegistrationInstance_dbo.RegistrationTemplate_RegistrationTemplateId] FOREIGN KEY([RegistrationTemplateId])

REFERENCES [dbo].[RegistrationTemplate] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[RegistrationInstance] CHECK CONSTRAINT [FK_dbo.RegistrationInstance_dbo.RegistrationTemplate_RegistrationTemplateId]

GO

ALTER TABLE [dbo].[RegistrationInstance]  WITH CHECK ADD  CONSTRAINT [FK_dbo.RegistrationInstance_dbo.WorkflowType_RegistrationWorkflowTypeId] FOREIGN KEY([RegistrationWorkflowTypeId])

REFERENCES [dbo].[WorkflowType] ([Id])

GO

ALTER TABLE [dbo].[RegistrationInstance] CHECK CONSTRAINT [FK_dbo.RegistrationInstance_dbo.WorkflowType_RegistrationWorkflowTypeId]

GO
```

## Registration
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[Registration](

[Id] [int] IDENTITY(1,1) NOT NULL,

[RegistrationInstanceId] [int] NOT NULL,

[PersonAliasId] [int] NULL,

[FirstName] [nvarchar](50) NULL,

[LastName] [nvarchar](50) NULL,

[ConfirmationEmail] [nvarchar](75) NULL,

[GroupId] [int] NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[Guid] [uniqueidentifier] NOT NULL,

[ForeignKey] [nvarchar](100) NULL,

[DiscountCode] [nvarchar](100) NULL,

[DiscountPercentage] [decimal](18, 2) NOT NULL,

[DiscountAmount] [decimal](18, 2) NOT NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL,

[IsTemporary] [bit] NOT NULL,

[LastPaymentReminderDateTime] [datetime] NULL,

[CreatedDateKey] [int] NULL,

[CampusId] [int] NULL,

[PaymentPlanFinancialScheduledTransactionId] [int] NULL,

[RegistrationTemplateId] [int] NULL

) ON [PRIMARY]

GO

ALTER TABLE [dbo].[Registration] ADD  CONSTRAINT [PK_dbo.Registration] PRIMARY KEY CLUSTERED 

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CampusId] ON [dbo].[Registration]

(

[CampusId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[Registration]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedDateKey] ON [dbo].[Registration]

(

[CreatedDateKey] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_GroupId] ON [dbo].[Registration]

(

[GroupId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[Registration]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[Registration]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_PaymentPlanFinancialScheduledTransactionId] ON [dbo].[Registration]

(

[PaymentPlanFinancialScheduledTransactionId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_PersonAliasId] ON [dbo].[Registration]

(

[PersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_RegistrationInstanceId] ON [dbo].[Registration]

(

[RegistrationInstanceId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[Registration] ADD  DEFAULT ((0)) FOR [DiscountPercentage]

GO

ALTER TABLE [dbo].[Registration] ADD  DEFAULT ((0)) FOR [DiscountAmount]

GO

ALTER TABLE [dbo].[Registration] ADD  DEFAULT ((0)) FOR [IsTemporary]

GO

ALTER TABLE [dbo].[Registration]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Registration_dbo.Campus_CampusId] FOREIGN KEY([CampusId])

REFERENCES [dbo].[Campus] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[Registration] CHECK CONSTRAINT [FK_dbo.Registration_dbo.Campus_CampusId]

GO

ALTER TABLE [dbo].[Registration]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Registration_dbo.FinancialScheduledTransaction_PaymentPlanFinancialScheduledTransactionId] FOREIGN KEY([PaymentPlanFinancialScheduledTransactionId])

REFERENCES [dbo].[FinancialScheduledTransaction] ([Id])

GO

ALTER TABLE [dbo].[Registration] CHECK CONSTRAINT [FK_dbo.Registration_dbo.FinancialScheduledTransaction_PaymentPlanFinancialScheduledTransactionId]

GO

ALTER TABLE [dbo].[Registration]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Registration_dbo.Group_GroupId] FOREIGN KEY([GroupId])

REFERENCES [dbo].[Group] ([Id])

GO

ALTER TABLE [dbo].[Registration] CHECK CONSTRAINT [FK_dbo.Registration_dbo.Group_GroupId]

GO

ALTER TABLE [dbo].[Registration]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Registration_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[Registration] CHECK CONSTRAINT [FK_dbo.Registration_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[Registration]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Registration_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[Registration] CHECK CONSTRAINT [FK_dbo.Registration_dbo.PersonAlias_ModifiedByPersonAliasId]

GO

ALTER TABLE [dbo].[Registration]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Registration_dbo.PersonAlias_PersonAliasId] FOREIGN KEY([PersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[Registration] CHECK CONSTRAINT [FK_dbo.Registration_dbo.PersonAlias_PersonAliasId]

GO

ALTER TABLE [dbo].[Registration]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Registration_dbo.RegistrationInstance_RegistrationInstanceId] FOREIGN KEY([RegistrationInstanceId])

REFERENCES [dbo].[RegistrationInstance] ([Id])

GO

ALTER TABLE [dbo].[Registration] CHECK CONSTRAINT [FK_dbo.Registration_dbo.RegistrationInstance_RegistrationInstanceId]

GO

ALTER TABLE [dbo].[Registration]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Registration_dbo.RegistrationTemplate_RegistrationTemplateId] FOREIGN KEY([RegistrationTemplateId])

REFERENCES [dbo].[RegistrationTemplate] ([Id])

GO

ALTER TABLE [dbo].[Registration] CHECK CONSTRAINT [FK_dbo.Registration_dbo.RegistrationTemplate_RegistrationTemplateId]

GO
```

## RegistrationSession
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[RegistrationSession](

[Id] [int] IDENTITY(1,1) NOT NULL,

[RegistrationInstanceId] [int] NOT NULL,

[RegistrationCount] [int] NOT NULL,

[SessionStartDateTime] [datetime] NOT NULL,

[ExpirationDateTime] [datetime] NOT NULL,

[ClientIpAddress] [nvarchar](45) NULL,

[RegistrationData] [nvarchar](max) NULL,

[PaymentGatewayReference] [nvarchar](36) NULL,

[SessionStatus] [int] NOT NULL,

[RegistrationId] [int] NULL,

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

ALTER TABLE [dbo].[RegistrationSession] ADD  CONSTRAINT [PK_dbo.RegistrationSession] PRIMARY KEY CLUSTERED 

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[RegistrationSession]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[RegistrationSession]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[RegistrationSession]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_RegistrationId] ON [dbo].[RegistrationSession]

(

[RegistrationId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_RegistrationInstanceId] ON [dbo].[RegistrationSession]

(

[RegistrationInstanceId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[RegistrationSession]  WITH CHECK ADD  CONSTRAINT [FK_dbo.RegistrationSession_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[RegistrationSession] CHECK CONSTRAINT [FK_dbo.RegistrationSession_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[RegistrationSession]  WITH CHECK ADD  CONSTRAINT [FK_dbo.RegistrationSession_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[RegistrationSession] CHECK CONSTRAINT [FK_dbo.RegistrationSession_dbo.PersonAlias_ModifiedByPersonAliasId]

GO

ALTER TABLE [dbo].[RegistrationSession]  WITH CHECK ADD  CONSTRAINT [FK_dbo.RegistrationSession_dbo.Registration_RegistrationId] FOREIGN KEY([RegistrationId])

REFERENCES [dbo].[Registration] ([Id])

GO

ALTER TABLE [dbo].[RegistrationSession] CHECK CONSTRAINT [FK_dbo.RegistrationSession_dbo.Registration_RegistrationId]

GO

ALTER TABLE [dbo].[RegistrationSession]  WITH CHECK ADD  CONSTRAINT [FK_dbo.RegistrationSession_dbo.RegistrationInstance_RegistrationInstanceId] FOREIGN KEY([RegistrationInstanceId])

REFERENCES [dbo].[RegistrationInstance] ([Id])

GO

ALTER TABLE [dbo].[RegistrationSession] CHECK CONSTRAINT [FK_dbo.RegistrationSession_dbo.RegistrationInstance_RegistrationInstanceId]

GO
```

## RegistrationRegistrant
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[RegistrationRegistrant](

[Id] [int] IDENTITY(1,1) NOT NULL,

[RegistrationId] [int] NOT NULL,

[PersonAliasId] [int] NULL,

[GroupMemberId] [int] NULL,

[Cost] [decimal](18, 2) NOT NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[Guid] [uniqueidentifier] NOT NULL,

[ForeignKey] [nvarchar](100) NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL,

[OnWaitList] [bit] NOT NULL,

[DiscountApplies] [bit] NOT NULL,

[RegistrationTemplateId] [int] NOT NULL,

[SignatureDocumentId] [int] NULL

) ON [PRIMARY]

GO

ALTER TABLE [dbo].[RegistrationRegistrant] ADD  CONSTRAINT [PK_dbo.RegistrationRegistrant] PRIMARY KEY CLUSTERED 

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[RegistrationRegistrant]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_GroupMemberId] ON [dbo].[RegistrationRegistrant]

(

[GroupMemberId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[RegistrationRegistrant]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[RegistrationRegistrant]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_PersonAliasId] ON [dbo].[RegistrationRegistrant]

(

[PersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_RegistrationId] ON [dbo].[RegistrationRegistrant]

(

[RegistrationId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_RegistrationTemplateId] ON [dbo].[RegistrationRegistrant]

(

[RegistrationTemplateId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_SignatureDocumentId] ON [dbo].[RegistrationRegistrant]

(

[SignatureDocumentId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[RegistrationRegistrant] ADD  DEFAULT ((0)) FOR [OnWaitList]

GO

ALTER TABLE [dbo].[RegistrationRegistrant] ADD  DEFAULT ((0)) FOR [DiscountApplies]

GO

ALTER TABLE [dbo].[RegistrationRegistrant]  WITH CHECK ADD  CONSTRAINT [FK_dbo.RegistrationRegistrant_dbo.GroupMember_GroupMemberId] FOREIGN KEY([GroupMemberId])

REFERENCES [dbo].[GroupMember] ([Id])

GO

ALTER TABLE [dbo].[RegistrationRegistrant] CHECK CONSTRAINT [FK_dbo.RegistrationRegistrant_dbo.GroupMember_GroupMemberId]

GO

ALTER TABLE [dbo].[RegistrationRegistrant]  WITH CHECK ADD  CONSTRAINT [FK_dbo.RegistrationRegistrant_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[RegistrationRegistrant] CHECK CONSTRAINT [FK_dbo.RegistrationRegistrant_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[RegistrationRegistrant]  WITH CHECK ADD  CONSTRAINT [FK_dbo.RegistrationRegistrant_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[RegistrationRegistrant] CHECK CONSTRAINT [FK_dbo.RegistrationRegistrant_dbo.PersonAlias_ModifiedByPersonAliasId]

GO

ALTER TABLE [dbo].[RegistrationRegistrant]  WITH CHECK ADD  CONSTRAINT [FK_dbo.RegistrationRegistrant_dbo.PersonAlias_PersonAliasId] FOREIGN KEY([PersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[RegistrationRegistrant] CHECK CONSTRAINT [FK_dbo.RegistrationRegistrant_dbo.PersonAlias_PersonAliasId]

GO

ALTER TABLE [dbo].[RegistrationRegistrant]  WITH CHECK ADD  CONSTRAINT [FK_dbo.RegistrationRegistrant_dbo.Registration_RegistrationId] FOREIGN KEY([RegistrationId])

REFERENCES [dbo].[Registration] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[RegistrationRegistrant] CHECK CONSTRAINT [FK_dbo.RegistrationRegistrant_dbo.Registration_RegistrationId]

GO

ALTER TABLE [dbo].[RegistrationRegistrant]  WITH CHECK ADD  CONSTRAINT [FK_dbo.RegistrationRegistrant_dbo.RegistrationTemplate_RegistrationTemplateId] FOREIGN KEY([RegistrationTemplateId])

REFERENCES [dbo].[RegistrationTemplate] ([Id])

GO

ALTER TABLE [dbo].[RegistrationRegistrant] CHECK CONSTRAINT [FK_dbo.RegistrationRegistrant_dbo.RegistrationTemplate_RegistrationTemplateId]

GO

ALTER TABLE [dbo].[RegistrationRegistrant]  WITH CHECK ADD  CONSTRAINT [FK_dbo.RegistrationRegistrant_dbo.SignatureDocument_SignatureDocumentId] FOREIGN KEY([SignatureDocumentId])

REFERENCES [dbo].[SignatureDocument] ([Id])

GO

ALTER TABLE [dbo].[RegistrationRegistrant] CHECK CONSTRAINT [FK_dbo.RegistrationRegistrant_dbo.SignatureDocument_SignatureDocumentId]

GO
```

## RegistrationRegistrantFee
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[RegistrationRegistrantFee](

[Id] [int] IDENTITY(1,1) NOT NULL,

[RegistrationRegistrantId] [int] NOT NULL,

[RegistrationTemplateFeeId] [int] NOT NULL,

[Quantity] [int] NOT NULL,

[Cost] [decimal](18, 2) NOT NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[Guid] [uniqueidentifier] NOT NULL,

[ForeignKey] [nvarchar](100) NULL,

[Option] [nvarchar](max) NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL,

[RegistrationTemplateFeeItemId] [int] NULL

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[RegistrationRegistrantFee] ADD  CONSTRAINT [PK_dbo.RegistrationRegistrantFee] PRIMARY KEY CLUSTERED 

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[RegistrationRegistrantFee]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[RegistrationRegistrantFee]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[RegistrationRegistrantFee]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_RegistrationRegistrantId] ON [dbo].[RegistrationRegistrantFee]

(

[RegistrationRegistrantId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_RegistrationTemplateFeeId] ON [dbo].[RegistrationRegistrantFee]

(

[RegistrationTemplateFeeId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_RegistrationTemplateFeeItemId] ON [dbo].[RegistrationRegistrantFee]

(

[RegistrationTemplateFeeItemId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[RegistrationRegistrantFee]  WITH CHECK ADD  CONSTRAINT [FK_dbo.RegistrationRegistrantFee_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[RegistrationRegistrantFee] CHECK CONSTRAINT [FK_dbo.RegistrationRegistrantFee_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[RegistrationRegistrantFee]  WITH CHECK ADD  CONSTRAINT [FK_dbo.RegistrationRegistrantFee_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[RegistrationRegistrantFee] CHECK CONSTRAINT [FK_dbo.RegistrationRegistrantFee_dbo.PersonAlias_ModifiedByPersonAliasId]

GO

ALTER TABLE [dbo].[RegistrationRegistrantFee]  WITH CHECK ADD  CONSTRAINT [FK_dbo.RegistrationRegistrantFee_dbo.RegistrationRegistrant_RegistrationRegistrantId] FOREIGN KEY([RegistrationRegistrantId])

REFERENCES [dbo].[RegistrationRegistrant] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[RegistrationRegistrantFee] CHECK CONSTRAINT [FK_dbo.RegistrationRegistrantFee_dbo.RegistrationRegistrant_RegistrationRegistrantId]

GO

ALTER TABLE [dbo].[RegistrationRegistrantFee]  WITH CHECK ADD  CONSTRAINT [FK_dbo.RegistrationRegistrantFee_dbo.RegistrationTemplateFee_RegistrationTemplateFeeId] FOREIGN KEY([RegistrationTemplateFeeId])

REFERENCES [dbo].[RegistrationTemplateFee] ([Id])

GO

ALTER TABLE [dbo].[RegistrationRegistrantFee] CHECK CONSTRAINT [FK_dbo.RegistrationRegistrantFee_dbo.RegistrationTemplateFee_RegistrationTemplateFeeId]

GO

ALTER TABLE [dbo].[RegistrationRegistrantFee]  WITH CHECK ADD  CONSTRAINT [FK_dbo.RegistrationRegistrantFee_dbo.RegistrationTemplateFeeItem_RegistrationTemplateFeeItemId] FOREIGN KEY([RegistrationTemplateFeeItemId])

REFERENCES [dbo].[RegistrationTemplateFeeItem] ([Id])

GO

ALTER TABLE [dbo].[RegistrationRegistrantFee] CHECK CONSTRAINT [FK_dbo.RegistrationRegistrantFee_dbo.RegistrationTemplateFeeItem_RegistrationTemplateFeeItemId]

GO
```
