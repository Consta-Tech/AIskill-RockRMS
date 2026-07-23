# Finance

Financial accounts, payment gateways, transactions, pledges, scheduled giving, alerting, analytics, and benevolence.

> For a full index of all Rock RMS SQL table schemas and additional context, see `README.md`.

## Summary

| Table | Description | Key Foreign Keys |
|-------|-------------|------------------|
| FinancialGateway | Payment gateway configuration | EntityType |
| FinancialAccount | Hierarchical chart of accounts for giving | Campus, DefinedValue, BinaryFile, self-referencing |
| FinancialStatementTemplate | Giving statement report templates | BinaryFile |
| FinancialBatch | Groups transactions into processing batches | Campus |
| FinancialPaymentDetail | Payment method details (card, ACH, etc.) | DefinedValue (many), FinancialPersonSavedAccount (SET NULL), Location |
| FinancialPersonBankAccount | Hashed bank account lookup for duplicate detection | PersonAlias (CASCADE) |
| FinancialPersonSavedAccount | Saved payment methods for a person | FinancialGateway, FinancialPaymentDetail, Group, PersonAlias |
| FinancialPledge | Giving pledges tied to an account over a date range | FinancialAccount, DefinedValue, Group, PersonAlias |
| FinancialScheduledTransaction | Recurring giving schedule definition | FinancialGateway, FinancialPaymentDetail, DefinedValue (many), PersonAlias |
| FinancialScheduledTransactionDetail | Line items within a scheduled transaction | FinancialScheduledTransaction (CASCADE), FinancialAccount, EntityType |
| FinancialTransaction | Individual financial transaction | FinancialBatch, FinancialGateway, FinancialPaymentDetail, FinancialScheduledTransaction, DefinedValue (many) |
| FinancialTransactionDetail | Line items within a transaction | FinancialTransaction (CASCADE), FinancialAccount, EntityType |
| FinancialTransactionImage | Scanned check or receipt images | FinancialTransaction (CASCADE), BinaryFile |
| FinancialTransactionRefund | Refund details as a 1:1 extension of a transaction | FinancialTransaction (CASCADE, shared PK), DefinedValue |
| FinancialTransactionAlertType | Rules for detecting giving pattern anomalies | Campus, FinancialAccount, ConnectionOpportunity, DataView, WorkflowType, SystemCommunication, Group |
| FinancialTransactionAlert | Generated alerts from anomaly detection rules | FinancialTransaction (CASCADE), FinancialTransactionAlertType (CASCADE), PersonAlias |
| AnalyticsSourceFinancialTransaction | Denormalized analytics fact table for financial reporting | — |
| BenevolenceType | Benevolence program type definitions | — |
| BenevolenceWorkflow | Workflow triggers for benevolence events | BenevolenceType (CASCADE), WorkflowType (CASCADE) |
| BenevolenceRequest | Individual benevolence assistance requests | BenevolenceType, Campus, DefinedValue, Location, PersonAlias |
| BenevolenceResult | Outcomes and amounts disbursed per request | BenevolenceRequest (CASCADE), DefinedValue |
| BenevolenceRequestDocument | File attachments for a benevolence request | BenevolenceRequest (CASCADE), BinaryFile |

---

## FinancialGateway
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[FinancialGateway](

[Id] [int] IDENTITY(1,1) NOT NULL,

[Name] [nvarchar](50) NOT NULL,

[Description] [nvarchar](max) NULL,

[EntityTypeId] [int] NOT NULL,

[BatchTimeOffsetTicks] [bigint] NOT NULL,

[IsActive] [bit] NOT NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[Guid] [uniqueidentifier] NOT NULL,

[ForeignKey] [nvarchar](100) NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL,

[BatchDayOfWeek] [int] NULL

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[FinancialGateway] ADD  CONSTRAINT [PK_dbo.FinancialGateway] PRIMARY KEY CLUSTERED 

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[FinancialGateway]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_EntityTypeId] ON [dbo].[FinancialGateway]

(

[EntityTypeId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[FinancialGateway]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[FinancialGateway]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[FinancialGateway]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialGateway_dbo.EntityType_EntityTypeId] FOREIGN KEY([EntityTypeId])

REFERENCES [dbo].[EntityType] ([Id])

GO

ALTER TABLE [dbo].[FinancialGateway] CHECK CONSTRAINT [FK_dbo.FinancialGateway_dbo.EntityType_EntityTypeId]

GO

ALTER TABLE [dbo].[FinancialGateway]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialGateway_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[FinancialGateway] CHECK CONSTRAINT [FK_dbo.FinancialGateway_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[FinancialGateway]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialGateway_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[FinancialGateway] CHECK CONSTRAINT [FK_dbo.FinancialGateway_dbo.PersonAlias_ModifiedByPersonAliasId]

GO
```

## FinancialAccount
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[FinancialAccount](

[Id] [int] IDENTITY(1,1) NOT NULL,

[ParentAccountId] [int] NULL,

[CampusId] [int] NULL,

[Name] [nvarchar](50) NOT NULL,

[PublicName] [nvarchar](50) NULL,

[Description] [nvarchar](max) NULL,

[IsTaxDeductible] [bit] NOT NULL,

[GlCode] [nvarchar](50) NULL,

[Order] [int] NOT NULL,

[IsActive] [bit] NOT NULL,

[StartDate] [date] NULL,

[EndDate] [date] NULL,

[AccountTypeValueId] [int] NULL,

[Guid] [uniqueidentifier] NOT NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[ForeignKey] [nvarchar](100) NULL,

[ImageBinaryFileId] [int] NULL,

[Url] [nvarchar](max) NULL,

[PublicDescription] [nvarchar](max) NULL,

[IsPublic] [bit] NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL,

[UsesCampusChildAccounts] [bit] NOT NULL

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[FinancialAccount] ADD  CONSTRAINT [PK_dbo.FinancialAccount] PRIMARY KEY CLUSTERED 

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_AccountTypeValueId] ON [dbo].[FinancialAccount]

(

[AccountTypeValueId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CampusId] ON [dbo].[FinancialAccount]

(

[CampusId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[FinancialAccount]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[FinancialAccount]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ImageBinaryFileId] ON [dbo].[FinancialAccount]

(

[ImageBinaryFileId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[FinancialAccount]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ParentAccountId] ON [dbo].[FinancialAccount]

(

[ParentAccountId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[FinancialAccount] ADD  DEFAULT ((0)) FOR [UsesCampusChildAccounts]

GO

ALTER TABLE [dbo].[FinancialAccount]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialAccount_dbo.BinaryFile_ImageBinaryFileId] FOREIGN KEY([ImageBinaryFileId])

REFERENCES [dbo].[BinaryFile] ([Id])

GO

ALTER TABLE [dbo].[FinancialAccount] CHECK CONSTRAINT [FK_dbo.FinancialAccount_dbo.BinaryFile_ImageBinaryFileId]

GO

ALTER TABLE [dbo].[FinancialAccount]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialAccount_dbo.Campus_CampusId] FOREIGN KEY([CampusId])

REFERENCES [dbo].[Campus] ([Id])

GO

ALTER TABLE [dbo].[FinancialAccount] CHECK CONSTRAINT [FK_dbo.FinancialAccount_dbo.Campus_CampusId]

GO

ALTER TABLE [dbo].[FinancialAccount]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialAccount_dbo.DefinedValue_AccountTypeValueId] FOREIGN KEY([AccountTypeValueId])

REFERENCES [dbo].[DefinedValue] ([Id])

GO

ALTER TABLE [dbo].[FinancialAccount] CHECK CONSTRAINT [FK_dbo.FinancialAccount_dbo.DefinedValue_AccountTypeValueId]

GO

ALTER TABLE [dbo].[FinancialAccount]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialAccount_dbo.FinancialAccount_ParentAccountId] FOREIGN KEY([ParentAccountId])

REFERENCES [dbo].[FinancialAccount] ([Id])

GO

ALTER TABLE [dbo].[FinancialAccount] CHECK CONSTRAINT [FK_dbo.FinancialAccount_dbo.FinancialAccount_ParentAccountId]

GO

ALTER TABLE [dbo].[FinancialAccount]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialAccount_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[FinancialAccount] CHECK CONSTRAINT [FK_dbo.FinancialAccount_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[FinancialAccount]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialAccount_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[FinancialAccount] CHECK CONSTRAINT [FK_dbo.FinancialAccount_dbo.PersonAlias_ModifiedByPersonAliasId]

GO
```

## FinancialStatementTemplate
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[FinancialStatementTemplate](

[Id] [int] IDENTITY(1,1) NOT NULL,

[Name] [nvarchar](50) NOT NULL,

[Description] [nvarchar](max) NULL,

[IsActive] [bit] NOT NULL,

[ReportTemplate] [nvarchar](max) NULL,

[LogoBinaryFileId] [int] NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[Guid] [uniqueidentifier] NOT NULL,

[ForeignId] [int] NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignKey] [nvarchar](100) NULL,

[ReportSettingsJson] [nvarchar](max) NULL,

[FooterSettingsJson] [nvarchar](max) NULL

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[FinancialStatementTemplate] ADD  CONSTRAINT [PK_dbo.FinancialStatementTemplate] PRIMARY KEY CLUSTERED 

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[FinancialStatementTemplate]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[FinancialStatementTemplate]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_LogoBinaryFileId] ON [dbo].[FinancialStatementTemplate]

(

[LogoBinaryFileId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[FinancialStatementTemplate]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[FinancialStatementTemplate]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialStatementTemplate_dbo.BinaryFile_LogoBinaryFileId] FOREIGN KEY([LogoBinaryFileId])

REFERENCES [dbo].[BinaryFile] ([Id])

GO

ALTER TABLE [dbo].[FinancialStatementTemplate] CHECK CONSTRAINT [FK_dbo.FinancialStatementTemplate_dbo.BinaryFile_LogoBinaryFileId]

GO

ALTER TABLE [dbo].[FinancialStatementTemplate]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialStatementTemplate_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[FinancialStatementTemplate] CHECK CONSTRAINT [FK_dbo.FinancialStatementTemplate_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[FinancialStatementTemplate]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialStatementTemplate_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[FinancialStatementTemplate] CHECK CONSTRAINT [FK_dbo.FinancialStatementTemplate_dbo.PersonAlias_ModifiedByPersonAliasId]

GO
```

## FinancialBatch
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[FinancialBatch](

[Id] [int] IDENTITY(1,1) NOT NULL,

[Name] [nvarchar](50) NOT NULL,

[BatchStartDateTime] [datetime] NULL,

[BatchEndDateTime] [datetime] NULL,

[Status] [int] NOT NULL,

[CampusId] [int] NULL,

[AccountingSystemCode] [nvarchar](100) NULL,

[ControlAmount] [decimal](18, 2) NOT NULL,

[Guid] [uniqueidentifier] NOT NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[ForeignKey] [nvarchar](100) NULL,

[Note] [nvarchar](max) NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL,

[IsAutomated] [bit] NOT NULL,

[ControlItemCount] [int] NULL,

[RemoteSettlementBatchUrl] [nvarchar](300) NULL,

[RemoteSettlementBatchKey] [nvarchar](50) NULL,

[RemoteSettlementAmount] [decimal](18, 2) NULL

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[FinancialBatch] ADD  CONSTRAINT [PK_dbo.FinancialBatch] PRIMARY KEY CLUSTERED 

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_BatchStartDateTime] ON [dbo].[FinancialBatch]

(

[BatchStartDateTime] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CampusId] ON [dbo].[FinancialBatch]

(

[CampusId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[FinancialBatch]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[FinancialBatch]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[FinancialBatch]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

SET ANSI_PADDING ON

GO

CREATE NONCLUSTERED INDEX [IX_Status_Name_BatchStartDateTime_BatchEndDateTime] ON [dbo].[FinancialBatch]

(

[Status] ASC,

[Name] ASC,

[BatchStartDateTime] ASC,

[BatchEndDateTime] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[FinancialBatch] ADD  DEFAULT ((0)) FOR [IsAutomated]

GO

ALTER TABLE [dbo].[FinancialBatch]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialBatch_dbo.Campus_CampusId] FOREIGN KEY([CampusId])

REFERENCES [dbo].[Campus] ([Id])

GO

ALTER TABLE [dbo].[FinancialBatch] CHECK CONSTRAINT [FK_dbo.FinancialBatch_dbo.Campus_CampusId]

GO

ALTER TABLE [dbo].[FinancialBatch]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialBatch_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[FinancialBatch] CHECK CONSTRAINT [FK_dbo.FinancialBatch_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[FinancialBatch]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialBatch_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[FinancialBatch] CHECK CONSTRAINT [FK_dbo.FinancialBatch_dbo.PersonAlias_ModifiedByPersonAliasId]

GO
```

## FinancialPaymentDetail
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[FinancialPaymentDetail](

[Id] [int] IDENTITY(1,1) NOT NULL,

[AccountNumberMasked] [nvarchar](max) NULL,

[CurrencyTypeValueId] [int] NULL,

[CreditCardTypeValueId] [int] NULL,

[NameOnCardEncrypted] [nvarchar](256) NULL,

[ExpirationMonthEncrypted] [nvarchar](256) NULL,

[ExpirationYearEncrypted] [nvarchar](256) NULL,

[BillingLocationId] [int] NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[Guid] [uniqueidentifier] NOT NULL,

[ForeignKey] [nvarchar](100) NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL,

[GatewayPersonIdentifier] [nvarchar](50) NULL,

[FinancialPersonSavedAccountId] [int] NULL,

[NameOnCard] [nvarchar](max) NULL,

[CardExpirationDate] [datetime] NULL,

[ExpirationMonth] [int] NULL,

[ExpirationYear] [int] NULL

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[FinancialPaymentDetail] ADD  CONSTRAINT [PK_dbo.FinancialPaymentDetail] PRIMARY KEY CLUSTERED 

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_BillingLocationId] ON [dbo].[FinancialPaymentDetail]

(

[BillingLocationId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[FinancialPaymentDetail]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreditCardTypeValueId] ON [dbo].[FinancialPaymentDetail]

(

[CreditCardTypeValueId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CurrencyTypeValueId] ON [dbo].[FinancialPaymentDetail]

(

[CurrencyTypeValueId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_FinancialPersonSavedAccountId] ON [dbo].[FinancialPaymentDetail]

(

[FinancialPersonSavedAccountId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[FinancialPaymentDetail]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[FinancialPaymentDetail]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[FinancialPaymentDetail]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialPaymentDetail_dbo.DefinedValue_CreditCardTypeValueId] FOREIGN KEY([CreditCardTypeValueId])

REFERENCES [dbo].[DefinedValue] ([Id])

GO

ALTER TABLE [dbo].[FinancialPaymentDetail] CHECK CONSTRAINT [FK_dbo.FinancialPaymentDetail_dbo.DefinedValue_CreditCardTypeValueId]

GO

ALTER TABLE [dbo].[FinancialPaymentDetail]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialPaymentDetail_dbo.DefinedValue_CurrencyTypeValueId] FOREIGN KEY([CurrencyTypeValueId])

REFERENCES [dbo].[DefinedValue] ([Id])

GO

ALTER TABLE [dbo].[FinancialPaymentDetail] CHECK CONSTRAINT [FK_dbo.FinancialPaymentDetail_dbo.DefinedValue_CurrencyTypeValueId]

GO

ALTER TABLE [dbo].[FinancialPaymentDetail]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialPaymentDetail_dbo.FinancialPersonSavedAccount] FOREIGN KEY([FinancialPersonSavedAccountId])

REFERENCES [dbo].[FinancialPersonSavedAccount] ([Id])

ON DELETE SET NULL

GO

ALTER TABLE [dbo].[FinancialPaymentDetail] CHECK CONSTRAINT [FK_dbo.FinancialPaymentDetail_dbo.FinancialPersonSavedAccount]

GO

ALTER TABLE [dbo].[FinancialPaymentDetail]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialPaymentDetail_dbo.Location_BillingLocationId] FOREIGN KEY([BillingLocationId])

REFERENCES [dbo].[Location] ([Id])

GO

ALTER TABLE [dbo].[FinancialPaymentDetail] CHECK CONSTRAINT [FK_dbo.FinancialPaymentDetail_dbo.Location_BillingLocationId]

GO

ALTER TABLE [dbo].[FinancialPaymentDetail]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialPaymentDetail_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[FinancialPaymentDetail] CHECK CONSTRAINT [FK_dbo.FinancialPaymentDetail_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[FinancialPaymentDetail]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialPaymentDetail_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[FinancialPaymentDetail] CHECK CONSTRAINT [FK_dbo.FinancialPaymentDetail_dbo.PersonAlias_ModifiedByPersonAliasId]

GO
```

## FinancialPersonBankAccount
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[FinancialPersonBankAccount](

[Id] [int] IDENTITY(1,1) NOT NULL,

[AccountNumberSecured] [nvarchar](128) NOT NULL,

[Guid] [uniqueidentifier] NOT NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[ForeignKey] [nvarchar](100) NULL,

[AccountNumberMasked] [nvarchar](max) NOT NULL,

[PersonAliasId] [int] NOT NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[FinancialPersonBankAccount] ADD  CONSTRAINT [PK_dbo.FinancialPersonBankAccount] PRIMARY KEY CLUSTERED 

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

SET ANSI_PADDING ON

GO

CREATE NONCLUSTERED INDEX [IX_AccountNumberSecured] ON [dbo].[FinancialPersonBankAccount]

(

[AccountNumberSecured] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[FinancialPersonBankAccount]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[FinancialPersonBankAccount]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[FinancialPersonBankAccount]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_PersonAliasId] ON [dbo].[FinancialPersonBankAccount]

(

[PersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[FinancialPersonBankAccount] ADD  DEFAULT ('') FOR [AccountNumberMasked]

GO

ALTER TABLE [dbo].[FinancialPersonBankAccount] ADD  DEFAULT ((0)) FOR [PersonAliasId]

GO

ALTER TABLE [dbo].[FinancialPersonBankAccount]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialPersonBankAccount_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[FinancialPersonBankAccount] CHECK CONSTRAINT [FK_dbo.FinancialPersonBankAccount_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[FinancialPersonBankAccount]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialPersonBankAccount_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[FinancialPersonBankAccount] CHECK CONSTRAINT [FK_dbo.FinancialPersonBankAccount_dbo.PersonAlias_ModifiedByPersonAliasId]

GO

ALTER TABLE [dbo].[FinancialPersonBankAccount]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialPersonBankAccount_dbo.PersonAlias_PersonAliasId] FOREIGN KEY([PersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[FinancialPersonBankAccount] CHECK CONSTRAINT [FK_dbo.FinancialPersonBankAccount_dbo.PersonAlias_PersonAliasId]

GO
```

## FinancialPersonSavedAccount
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[FinancialPersonSavedAccount](

[Id] [int] IDENTITY(1,1) NOT NULL,

[ReferenceNumber] [nvarchar](max) NULL,

[Name] [nvarchar](50) NOT NULL,

[Guid] [uniqueidentifier] NOT NULL,

[TransactionCode] [nvarchar](50) NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[ForeignKey] [nvarchar](100) NULL,

[PersonAliasId] [int] NULL,

[GroupId] [int] NULL,

[FinancialGatewayId] [int] NULL,

[FinancialPaymentDetailId] [int] NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL,

[GatewayPersonIdentifier] [nvarchar](50) NULL,

[IsSystem] [bit] NOT NULL,

[IsDefault] [bit] NOT NULL,

[PreferredForeignCurrencyCodeValueId] [int] NULL,

[LastErrorCode] [nvarchar](200) NULL,

[LastErrorCodeDateTime] [datetime] NULL

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[FinancialPersonSavedAccount] ADD  CONSTRAINT [PK_dbo.FinancialPersonSavedAccount] PRIMARY KEY CLUSTERED 

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[FinancialPersonSavedAccount]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_FinancialGatewayId] ON [dbo].[FinancialPersonSavedAccount]

(

[FinancialGatewayId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_FinancialPaymentDetailId] ON [dbo].[FinancialPersonSavedAccount]

(

[FinancialPaymentDetailId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_GroupId] ON [dbo].[FinancialPersonSavedAccount]

(

[GroupId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[FinancialPersonSavedAccount]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[FinancialPersonSavedAccount]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_PersonAliasId] ON [dbo].[FinancialPersonSavedAccount]

(

[PersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[FinancialPersonSavedAccount] ADD  DEFAULT ((0)) FOR [PersonAliasId]

GO

ALTER TABLE [dbo].[FinancialPersonSavedAccount] ADD  DEFAULT ((0)) FOR [IsSystem]

GO

ALTER TABLE [dbo].[FinancialPersonSavedAccount] ADD  DEFAULT ((0)) FOR [IsDefault]

GO

ALTER TABLE [dbo].[FinancialPersonSavedAccount]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialPersonSavedAccount_dbo.FinancialGateway_FinancialGatewayId] FOREIGN KEY([FinancialGatewayId])

REFERENCES [dbo].[FinancialGateway] ([Id])

GO

ALTER TABLE [dbo].[FinancialPersonSavedAccount] CHECK CONSTRAINT [FK_dbo.FinancialPersonSavedAccount_dbo.FinancialGateway_FinancialGatewayId]

GO

ALTER TABLE [dbo].[FinancialPersonSavedAccount]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialPersonSavedAccount_dbo.FinancialPaymentDetail_FinancialPaymentDetailId] FOREIGN KEY([FinancialPaymentDetailId])

REFERENCES [dbo].[FinancialPaymentDetail] ([Id])

GO

ALTER TABLE [dbo].[FinancialPersonSavedAccount] CHECK CONSTRAINT [FK_dbo.FinancialPersonSavedAccount_dbo.FinancialPaymentDetail_FinancialPaymentDetailId]

GO

ALTER TABLE [dbo].[FinancialPersonSavedAccount]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialPersonSavedAccount_dbo.Group_GroupId] FOREIGN KEY([GroupId])

REFERENCES [dbo].[Group] ([Id])

GO

ALTER TABLE [dbo].[FinancialPersonSavedAccount] CHECK CONSTRAINT [FK_dbo.FinancialPersonSavedAccount_dbo.Group_GroupId]

GO

ALTER TABLE [dbo].[FinancialPersonSavedAccount]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialPersonSavedAccount_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[FinancialPersonSavedAccount] CHECK CONSTRAINT [FK_dbo.FinancialPersonSavedAccount_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[FinancialPersonSavedAccount]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialPersonSavedAccount_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[FinancialPersonSavedAccount] CHECK CONSTRAINT [FK_dbo.FinancialPersonSavedAccount_dbo.PersonAlias_ModifiedByPersonAliasId]

GO

ALTER TABLE [dbo].[FinancialPersonSavedAccount]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialPersonSavedAccount_dbo.PersonAlias_PersonAliasId] FOREIGN KEY([PersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[FinancialPersonSavedAccount] CHECK CONSTRAINT [FK_dbo.FinancialPersonSavedAccount_dbo.PersonAlias_PersonAliasId]

GO
```

## FinancialPledge
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[FinancialPledge](

[Id] [int] IDENTITY(1,1) NOT NULL,

[AccountId] [int] NULL,

[TotalAmount] [decimal](18, 2) NOT NULL,

[PledgeFrequencyValueId] [int] NULL,

[StartDate] [date] NOT NULL,

[EndDate] [date] NOT NULL,

[Guid] [uniqueidentifier] NOT NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[ForeignKey] [nvarchar](100) NULL,

[PersonAliasId] [int] NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL,

[GroupId] [int] NULL,

[StartDateKey] [int] NOT NULL,

[EndDateKey] [int] NOT NULL

) ON [PRIMARY]

GO

ALTER TABLE [dbo].[FinancialPledge] ADD  CONSTRAINT [PK_dbo.FinancialPledge] PRIMARY KEY CLUSTERED 

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_AccountId] ON [dbo].[FinancialPledge]

(

[AccountId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[FinancialPledge]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_EndDateKey] ON [dbo].[FinancialPledge]

(

[EndDateKey] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_GroupId] ON [dbo].[FinancialPledge]

(

[GroupId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[FinancialPledge]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[FinancialPledge]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_PersonAliasId] ON [dbo].[FinancialPledge]

(

[PersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_PledgeFrequencyValueId] ON [dbo].[FinancialPledge]

(

[PledgeFrequencyValueId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_StartDateKey] ON [dbo].[FinancialPledge]

(

[StartDateKey] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[FinancialPledge] ADD  DEFAULT ((0)) FOR [StartDateKey]

GO

ALTER TABLE [dbo].[FinancialPledge] ADD  DEFAULT ((0)) FOR [EndDateKey]

GO

ALTER TABLE [dbo].[FinancialPledge]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialPledge_dbo.DefinedValue_PledgeFrequencyValueId] FOREIGN KEY([PledgeFrequencyValueId])

REFERENCES [dbo].[DefinedValue] ([Id])

GO

ALTER TABLE [dbo].[FinancialPledge] CHECK CONSTRAINT [FK_dbo.FinancialPledge_dbo.DefinedValue_PledgeFrequencyValueId]

GO

ALTER TABLE [dbo].[FinancialPledge]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialPledge_dbo.FinancialAccount_AccountId] FOREIGN KEY([AccountId])

REFERENCES [dbo].[FinancialAccount] ([Id])

GO

ALTER TABLE [dbo].[FinancialPledge] CHECK CONSTRAINT [FK_dbo.FinancialPledge_dbo.FinancialAccount_AccountId]

GO

ALTER TABLE [dbo].[FinancialPledge]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialPledge_dbo.Group_GroupId] FOREIGN KEY([GroupId])

REFERENCES [dbo].[Group] ([Id])

GO

ALTER TABLE [dbo].[FinancialPledge] CHECK CONSTRAINT [FK_dbo.FinancialPledge_dbo.Group_GroupId]

GO

ALTER TABLE [dbo].[FinancialPledge]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialPledge_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[FinancialPledge] CHECK CONSTRAINT [FK_dbo.FinancialPledge_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[FinancialPledge]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialPledge_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[FinancialPledge] CHECK CONSTRAINT [FK_dbo.FinancialPledge_dbo.PersonAlias_ModifiedByPersonAliasId]

GO

ALTER TABLE [dbo].[FinancialPledge]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialPledge_dbo.PersonAlias_PersonAliasId] FOREIGN KEY([PersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[FinancialPledge] CHECK CONSTRAINT [FK_dbo.FinancialPledge_dbo.PersonAlias_PersonAliasId]

GO
```

## FinancialScheduledTransaction
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[FinancialScheduledTransaction](

[Id] [int] IDENTITY(1,1) NOT NULL,

[TransactionFrequencyValueId] [int] NOT NULL,

[StartDate] [date] NOT NULL,

[EndDate] [date] NULL,

[NumberOfPayments] [int] NULL,

[NextPaymentDate] [date] NULL,

[LastStatusUpdateDateTime] [datetime] NULL,

[IsActive] [bit] NOT NULL,

[TransactionCode] [nvarchar](50) NULL,

[GatewayScheduleId] [nvarchar](max) NULL,

[CardReminderDate] [date] NULL,

[LastRemindedDate] [date] NULL,

[Guid] [uniqueidentifier] NOT NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[ForeignKey] [nvarchar](100) NULL,

[AuthorizedPersonAliasId] [int] NOT NULL,

[FinancialGatewayId] [int] NULL,

[FinancialPaymentDetailId] [int] NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL,

[SourceTypeValueId] [int] NULL,

[TransactionTypeValueId] [int] NULL,

[Summary] [nvarchar](max) NULL,

[ForeignCurrencyCodeValueId] [int] NULL,

[InactivateDateTime] [datetime] NULL,

[Status] [int] NULL,

[StatusMessage] [nvarchar](200) NULL,

[PreviousGatewayScheduleIdsJson] [nvarchar](max) NULL

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[FinancialScheduledTransaction] ADD  CONSTRAINT [PK_dbo.FinancialScheduledTransaction] PRIMARY KEY CLUSTERED 

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_AuthorizedPersonAliasId] ON [dbo].[FinancialScheduledTransaction]

(

[AuthorizedPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[FinancialScheduledTransaction]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_FinancialGatewayId] ON [dbo].[FinancialScheduledTransaction]

(

[FinancialGatewayId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_FinancialPaymentDetailId] ON [dbo].[FinancialScheduledTransaction]

(

[FinancialPaymentDetailId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ForeignCurrencyCodeValueId] ON [dbo].[FinancialScheduledTransaction]

(

[ForeignCurrencyCodeValueId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[FinancialScheduledTransaction]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[FinancialScheduledTransaction]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_SourceTypeValueId] ON [dbo].[FinancialScheduledTransaction]

(

[SourceTypeValueId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_TransactionFrequencyValueId] ON [dbo].[FinancialScheduledTransaction]

(

[TransactionFrequencyValueId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_TransactionTypeValueId] ON [dbo].[FinancialScheduledTransaction]

(

[TransactionTypeValueId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[FinancialScheduledTransaction] ADD  DEFAULT ((0)) FOR [AuthorizedPersonAliasId]

GO

ALTER TABLE [dbo].[FinancialScheduledTransaction]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialScheduledTransaction_dbo.DefinedValue_ForeignCurrencyCodeValueId] FOREIGN KEY([ForeignCurrencyCodeValueId])

REFERENCES [dbo].[DefinedValue] ([Id])

GO

ALTER TABLE [dbo].[FinancialScheduledTransaction] CHECK CONSTRAINT [FK_dbo.FinancialScheduledTransaction_dbo.DefinedValue_ForeignCurrencyCodeValueId]

GO

ALTER TABLE [dbo].[FinancialScheduledTransaction]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialScheduledTransaction_dbo.DefinedValue_SourceTypeValueId] FOREIGN KEY([SourceTypeValueId])

REFERENCES [dbo].[DefinedValue] ([Id])

GO

ALTER TABLE [dbo].[FinancialScheduledTransaction] CHECK CONSTRAINT [FK_dbo.FinancialScheduledTransaction_dbo.DefinedValue_SourceTypeValueId]

GO

ALTER TABLE [dbo].[FinancialScheduledTransaction]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialScheduledTransaction_dbo.DefinedValue_TransactionFrequencyValueId] FOREIGN KEY([TransactionFrequencyValueId])

REFERENCES [dbo].[DefinedValue] ([Id])

GO

ALTER TABLE [dbo].[FinancialScheduledTransaction] CHECK CONSTRAINT [FK_dbo.FinancialScheduledTransaction_dbo.DefinedValue_TransactionFrequencyValueId]

GO

ALTER TABLE [dbo].[FinancialScheduledTransaction]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialScheduledTransaction_dbo.DefinedValue_TransactionTypeValueId] FOREIGN KEY([TransactionTypeValueId])

REFERENCES [dbo].[DefinedValue] ([Id])

GO

ALTER TABLE [dbo].[FinancialScheduledTransaction] CHECK CONSTRAINT [FK_dbo.FinancialScheduledTransaction_dbo.DefinedValue_TransactionTypeValueId]

GO

ALTER TABLE [dbo].[FinancialScheduledTransaction]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialScheduledTransaction_dbo.FinancialGateway_FinancialGatewayId] FOREIGN KEY([FinancialGatewayId])

REFERENCES [dbo].[FinancialGateway] ([Id])

GO

ALTER TABLE [dbo].[FinancialScheduledTransaction] CHECK CONSTRAINT [FK_dbo.FinancialScheduledTransaction_dbo.FinancialGateway_FinancialGatewayId]

GO

ALTER TABLE [dbo].[FinancialScheduledTransaction]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialScheduledTransaction_dbo.FinancialPaymentDetail_FinancialPaymentDetailId] FOREIGN KEY([FinancialPaymentDetailId])

REFERENCES [dbo].[FinancialPaymentDetail] ([Id])

GO

ALTER TABLE [dbo].[FinancialScheduledTransaction] CHECK CONSTRAINT [FK_dbo.FinancialScheduledTransaction_dbo.FinancialPaymentDetail_FinancialPaymentDetailId]

GO

ALTER TABLE [dbo].[FinancialScheduledTransaction]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialScheduledTransaction_dbo.PersonAlias_AuthorizedPersonAliasId] FOREIGN KEY([AuthorizedPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[FinancialScheduledTransaction] CHECK CONSTRAINT [FK_dbo.FinancialScheduledTransaction_dbo.PersonAlias_AuthorizedPersonAliasId]

GO

ALTER TABLE [dbo].[FinancialScheduledTransaction]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialScheduledTransaction_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[FinancialScheduledTransaction] CHECK CONSTRAINT [FK_dbo.FinancialScheduledTransaction_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[FinancialScheduledTransaction]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialScheduledTransaction_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[FinancialScheduledTransaction] CHECK CONSTRAINT [FK_dbo.FinancialScheduledTransaction_dbo.PersonAlias_ModifiedByPersonAliasId]

GO
```

## FinancialScheduledTransactionDetail
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[FinancialScheduledTransactionDetail](

[Id] [int] IDENTITY(1,1) NOT NULL,

[ScheduledTransactionId] [int] NOT NULL,

[AccountId] [int] NOT NULL,

[Amount] [decimal](18, 2) NOT NULL,

[Summary] [nvarchar](500) NULL,

[EntityTypeId] [int] NULL,

[EntityId] [int] NULL,

[Guid] [uniqueidentifier] NOT NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[ForeignKey] [nvarchar](100) NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL,

[FeeCoverageAmount] [decimal](18, 2) NULL

) ON [PRIMARY]

GO

ALTER TABLE [dbo].[FinancialScheduledTransactionDetail] ADD  CONSTRAINT [PK_dbo.FinancialScheduledTransactionDetail] PRIMARY KEY CLUSTERED 

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_AccountId] ON [dbo].[FinancialScheduledTransactionDetail]

(

[AccountId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[FinancialScheduledTransactionDetail]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_EntityTypeId_EntityId] ON [dbo].[FinancialScheduledTransactionDetail]

(

[EntityTypeId] ASC,

[EntityId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[FinancialScheduledTransactionDetail]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[FinancialScheduledTransactionDetail]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ScheduledTransactionId] ON [dbo].[FinancialScheduledTransactionDetail]

(

[ScheduledTransactionId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[FinancialScheduledTransactionDetail]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialScheduledTransactionDetail_dbo.EntityType_EntityTypeId] FOREIGN KEY([EntityTypeId])

REFERENCES [dbo].[EntityType] ([Id])

GO

ALTER TABLE [dbo].[FinancialScheduledTransactionDetail] CHECK CONSTRAINT [FK_dbo.FinancialScheduledTransactionDetail_dbo.EntityType_EntityTypeId]

GO

ALTER TABLE [dbo].[FinancialScheduledTransactionDetail]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialScheduledTransactionDetail_dbo.FinancialAccount_AccountId] FOREIGN KEY([AccountId])

REFERENCES [dbo].[FinancialAccount] ([Id])

GO

ALTER TABLE [dbo].[FinancialScheduledTransactionDetail] CHECK CONSTRAINT [FK_dbo.FinancialScheduledTransactionDetail_dbo.FinancialAccount_AccountId]

GO

ALTER TABLE [dbo].[FinancialScheduledTransactionDetail]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialScheduledTransactionDetail_dbo.FinancialScheduledTransaction_ScheduledTransactionId] FOREIGN KEY([ScheduledTransactionId])

REFERENCES [dbo].[FinancialScheduledTransaction] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[FinancialScheduledTransactionDetail] CHECK CONSTRAINT [FK_dbo.FinancialScheduledTransactionDetail_dbo.FinancialScheduledTransaction_ScheduledTransactionId]

GO

ALTER TABLE [dbo].[FinancialScheduledTransactionDetail]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialScheduledTransactionDetail_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[FinancialScheduledTransactionDetail] CHECK CONSTRAINT [FK_dbo.FinancialScheduledTransactionDetail_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[FinancialScheduledTransactionDetail]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialScheduledTransactionDetail_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[FinancialScheduledTransactionDetail] CHECK CONSTRAINT [FK_dbo.FinancialScheduledTransactionDetail_dbo.PersonAlias_ModifiedByPersonAliasId]

GO
```

## FinancialTransaction
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[FinancialTransaction](

[Id] [int] IDENTITY(1,1) NOT NULL,

[BatchId] [int] NULL,

[TransactionDateTime] [datetime] NULL,

[TransactionCode] [nvarchar](50) NULL,

[Summary] [nvarchar](max) NULL,

[TransactionTypeValueId] [int] NOT NULL,

[SourceTypeValueId] [int] NULL,

[CheckMicrEncrypted] [nvarchar](max) NULL,

[ScheduledTransactionId] [int] NULL,

[Guid] [uniqueidentifier] NOT NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[ForeignKey] [nvarchar](100) NULL,

[ProcessedByPersonAliasId] [int] NULL,

[ProcessedDateTime] [datetime] NULL,

[CheckMicrHash] [nvarchar](128) NULL,

[AuthorizedPersonAliasId] [int] NULL,

[FinancialGatewayId] [int] NULL,

[FinancialPaymentDetailId] [int] NULL,

[MICRStatus] [int] NULL,

[CheckMicrParts] [nvarchar](max) NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL,

[Status] [nvarchar](50) NULL,

[StatusMessage] [nvarchar](200) NULL,

[IsSettled] [bit] NULL,

[SettledGroupId] [nvarchar](100) NULL,

[SettledDate] [datetime] NULL,

[IsReconciled] [bit] NULL,

[ShowAsAnonymous] [bit] NOT NULL,

[FutureProcessingDateTime] [datetime] NULL,

[NonCashAssetTypeValueId] [int] NULL,

[SundayDate] [date] NULL,

[TransactionDateKey] [int] NULL,

[SettledDateKey] [int] NULL,

[ForeignCurrencyCodeValueId] [int] NULL

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[FinancialTransaction] ADD  CONSTRAINT [PK_dbo.FinancialTransaction] PRIMARY KEY CLUSTERED 

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [com_BEMAServices_AuthorizedPersonAliasId_TransactionDateTime] ON [dbo].[FinancialTransaction]

(

[AuthorizedPersonAliasId] ASC,

[TransactionDateTime] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_AuthorizedPersonAliasId] ON [dbo].[FinancialTransaction]

(

[AuthorizedPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_BatchId] ON [dbo].[FinancialTransaction]

(

[BatchId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

SET ANSI_PADDING ON

GO

CREATE NONCLUSTERED INDEX [IX_CheckMicrHash] ON [dbo].[FinancialTransaction]

(

[CheckMicrHash] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[FinancialTransaction]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_FinancialGatewayId] ON [dbo].[FinancialTransaction]

(

[FinancialGatewayId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_FinancialPaymentDetailId] ON [dbo].[FinancialTransaction]

(

[FinancialPaymentDetailId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

SET ANSI_PADDING ON

GO

CREATE NONCLUSTERED INDEX [IX_ForeignKey_FinancialGatewayId] ON [dbo].[FinancialTransaction]

(

[ForeignKey] ASC,

[FinancialGatewayId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_FutureProcessingDateTime] ON [dbo].[FinancialTransaction]

(

[FutureProcessingDateTime] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[FinancialTransaction]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[FinancialTransaction]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_NonCashAssetTypeValueId] ON [dbo].[FinancialTransaction]

(

[NonCashAssetTypeValueId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ProcessedByPersonAliasId] ON [dbo].[FinancialTransaction]

(

[ProcessedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ScheduledTransactionId] ON [dbo].[FinancialTransaction]

(

[ScheduledTransactionId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_SettledDateKey] ON [dbo].[FinancialTransaction]

(

[SettledDateKey] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_SourceTypeValueId] ON [dbo].[FinancialTransaction]

(

[SourceTypeValueId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_SundayDate] ON [dbo].[FinancialTransaction]

(

[SundayDate] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

SET ANSI_PADDING ON

GO

CREATE NONCLUSTERED INDEX [IX_TransactionCode] ON [dbo].[FinancialTransaction]

(

[TransactionCode] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_TransactionDateKey] ON [dbo].[FinancialTransaction]

(

[TransactionDateKey] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_TransactionDateTime_SourceType_AuthorizedPerson_PaymentDetails] ON [dbo].[FinancialTransaction]

(

[TransactionDateTime] ASC

)

INCLUDE([Id],[SourceTypeValueId],[AuthorizedPersonAliasId],[FinancialPaymentDetailId]) WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_TransactionDateTime_TransactionTypeValueId_Person] ON [dbo].[FinancialTransaction]

(

[TransactionTypeValueId] ASC,

[AuthorizedPersonAliasId] ASC,

[TransactionDateTime] ASC

)

INCLUDE([Id],[Summary],[FinancialPaymentDetailId]) WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_TransactionTypeValueId_TransactionDateTime] ON [dbo].[FinancialTransaction]

(

[TransactionTypeValueId] ASC,

[TransactionDateTime] ASC

)

INCLUDE([Id],[AuthorizedPersonAliasId]) WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[FinancialTransaction] ADD  DEFAULT ((0)) FOR [ShowAsAnonymous]

GO

ALTER TABLE [dbo].[FinancialTransaction] ADD  DEFAULT ('1753-01-01T00:00:00.000') FOR [SundayDate]

GO

ALTER TABLE [dbo].[FinancialTransaction]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialTransaction_dbo.DefinedValue_NonCashAssetTypeValueId] FOREIGN KEY([NonCashAssetTypeValueId])

REFERENCES [dbo].[DefinedValue] ([Id])

GO

ALTER TABLE [dbo].[FinancialTransaction] CHECK CONSTRAINT [FK_dbo.FinancialTransaction_dbo.DefinedValue_NonCashAssetTypeValueId]

GO

ALTER TABLE [dbo].[FinancialTransaction]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialTransaction_dbo.DefinedValue_SourceTypeValueId] FOREIGN KEY([SourceTypeValueId])

REFERENCES [dbo].[DefinedValue] ([Id])

GO

ALTER TABLE [dbo].[FinancialTransaction] CHECK CONSTRAINT [FK_dbo.FinancialTransaction_dbo.DefinedValue_SourceTypeValueId]

GO

ALTER TABLE [dbo].[FinancialTransaction]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialTransaction_dbo.DefinedValue_TransactionTypeValueId] FOREIGN KEY([TransactionTypeValueId])

REFERENCES [dbo].[DefinedValue] ([Id])

GO

ALTER TABLE [dbo].[FinancialTransaction] CHECK CONSTRAINT [FK_dbo.FinancialTransaction_dbo.DefinedValue_TransactionTypeValueId]

GO

ALTER TABLE [dbo].[FinancialTransaction]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialTransaction_dbo.FinancialBatch_BatchId] FOREIGN KEY([BatchId])

REFERENCES [dbo].[FinancialBatch] ([Id])

GO

ALTER TABLE [dbo].[FinancialTransaction] CHECK CONSTRAINT [FK_dbo.FinancialTransaction_dbo.FinancialBatch_BatchId]

GO

ALTER TABLE [dbo].[FinancialTransaction]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialTransaction_dbo.FinancialGateway_FinancialGatewayId] FOREIGN KEY([FinancialGatewayId])

REFERENCES [dbo].[FinancialGateway] ([Id])

GO

ALTER TABLE [dbo].[FinancialTransaction] CHECK CONSTRAINT [FK_dbo.FinancialTransaction_dbo.FinancialGateway_FinancialGatewayId]

GO

ALTER TABLE [dbo].[FinancialTransaction]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialTransaction_dbo.FinancialPaymentDetail_FinancialPaymentDetailId] FOREIGN KEY([FinancialPaymentDetailId])

REFERENCES [dbo].[FinancialPaymentDetail] ([Id])

GO

ALTER TABLE [dbo].[FinancialTransaction] CHECK CONSTRAINT [FK_dbo.FinancialTransaction_dbo.FinancialPaymentDetail_FinancialPaymentDetailId]

GO

ALTER TABLE [dbo].[FinancialTransaction]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialTransaction_dbo.FinancialScheduledTransaction_ScheduledTransactionId] FOREIGN KEY([ScheduledTransactionId])

REFERENCES [dbo].[FinancialScheduledTransaction] ([Id])

GO

ALTER TABLE [dbo].[FinancialTransaction] CHECK CONSTRAINT [FK_dbo.FinancialTransaction_dbo.FinancialScheduledTransaction_ScheduledTransactionId]

GO

ALTER TABLE [dbo].[FinancialTransaction]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialTransaction_dbo.PersonAlias_AuthorizedPersonAliasId] FOREIGN KEY([AuthorizedPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[FinancialTransaction] CHECK CONSTRAINT [FK_dbo.FinancialTransaction_dbo.PersonAlias_AuthorizedPersonAliasId]

GO

ALTER TABLE [dbo].[FinancialTransaction]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialTransaction_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[FinancialTransaction] CHECK CONSTRAINT [FK_dbo.FinancialTransaction_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[FinancialTransaction]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialTransaction_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[FinancialTransaction] CHECK CONSTRAINT [FK_dbo.FinancialTransaction_dbo.PersonAlias_ModifiedByPersonAliasId]

GO

ALTER TABLE [dbo].[FinancialTransaction]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialTransaction_dbo.PersonAlias_ProcessedByPersonAliasId] FOREIGN KEY([ProcessedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[FinancialTransaction] CHECK CONSTRAINT [FK_dbo.FinancialTransaction_dbo.PersonAlias_ProcessedByPersonAliasId]

GO
```

## FinancialTransactionDetail
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[FinancialTransactionDetail](

[Id] [int] IDENTITY(1,1) NOT NULL,

[TransactionId] [int] NOT NULL,

[AccountId] [int] NOT NULL,

[Amount] [decimal](18, 2) NOT NULL,

[Summary] [nvarchar](500) NULL,

[EntityTypeId] [int] NULL,

[EntityId] [int] NULL,

[Guid] [uniqueidentifier] NOT NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[ForeignKey] [nvarchar](100) NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL,

[FeeAmount] [decimal](18, 2) NULL,

[FeeCoverageAmount] [decimal](18, 2) NULL,

[ForeignCurrencyAmount] [decimal](18, 2) NULL

) ON [PRIMARY]

GO

ALTER TABLE [dbo].[FinancialTransactionDetail] ADD  CONSTRAINT [PK_dbo.FinancialTransactionDetail] PRIMARY KEY CLUSTERED 

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_AccountId] ON [dbo].[FinancialTransactionDetail]

(

[AccountId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_AccountId_TransactionId_Amount] ON [dbo].[FinancialTransactionDetail]

(

[AccountId] ASC

)

INCLUDE([TransactionId],[Amount]) WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[FinancialTransactionDetail]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_EntityTypeId_EntityId] ON [dbo].[FinancialTransactionDetail]

(

[EntityTypeId] ASC,

[EntityId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[FinancialTransactionDetail]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[FinancialTransactionDetail]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_TransactionId] ON [dbo].[FinancialTransactionDetail]

(

[TransactionId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[FinancialTransactionDetail] ADD  DEFAULT ((0)) FOR [FeeAmount]

GO

ALTER TABLE [dbo].[FinancialTransactionDetail]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialTransactionDetail_dbo.EntityType_EntityTypeId] FOREIGN KEY([EntityTypeId])

REFERENCES [dbo].[EntityType] ([Id])

GO

ALTER TABLE [dbo].[FinancialTransactionDetail] CHECK CONSTRAINT [FK_dbo.FinancialTransactionDetail_dbo.EntityType_EntityTypeId]

GO

ALTER TABLE [dbo].[FinancialTransactionDetail]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialTransactionDetail_dbo.FinancialAccount_AccountId] FOREIGN KEY([AccountId])

REFERENCES [dbo].[FinancialAccount] ([Id])

GO

ALTER TABLE [dbo].[FinancialTransactionDetail] CHECK CONSTRAINT [FK_dbo.FinancialTransactionDetail_dbo.FinancialAccount_AccountId]

GO

ALTER TABLE [dbo].[FinancialTransactionDetail]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialTransactionDetail_dbo.FinancialTransaction_TransactionId] FOREIGN KEY([TransactionId])

REFERENCES [dbo].[FinancialTransaction] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[FinancialTransactionDetail] CHECK CONSTRAINT [FK_dbo.FinancialTransactionDetail_dbo.FinancialTransaction_TransactionId]

GO

ALTER TABLE [dbo].[FinancialTransactionDetail]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialTransactionDetail_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[FinancialTransactionDetail] CHECK CONSTRAINT [FK_dbo.FinancialTransactionDetail_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[FinancialTransactionDetail]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialTransactionDetail_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[FinancialTransactionDetail] CHECK CONSTRAINT [FK_dbo.FinancialTransactionDetail_dbo.PersonAlias_ModifiedByPersonAliasId]

GO
```

## FinancialTransactionImage
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[FinancialTransactionImage](

[Id] [int] IDENTITY(1,1) NOT NULL,

[TransactionId] [int] NOT NULL,

[BinaryFileId] [int] NOT NULL,

[Guid] [uniqueidentifier] NOT NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[ForeignKey] [nvarchar](100) NULL,

[Order] [int] NOT NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL

) ON [PRIMARY]

GO

ALTER TABLE [dbo].[FinancialTransactionImage] ADD  CONSTRAINT [PK_dbo.FinancialTransactionImage] PRIMARY KEY CLUSTERED 

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_BinaryFileId] ON [dbo].[FinancialTransactionImage]

(

[BinaryFileId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[FinancialTransactionImage]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[FinancialTransactionImage]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[FinancialTransactionImage]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_TransactionId] ON [dbo].[FinancialTransactionImage]

(

[TransactionId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[FinancialTransactionImage] ADD  DEFAULT ((0)) FOR [Order]

GO

ALTER TABLE [dbo].[FinancialTransactionImage]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialTransactionImage_dbo.BinaryFile_BinaryFileId] FOREIGN KEY([BinaryFileId])

REFERENCES [dbo].[BinaryFile] ([Id])

GO

ALTER TABLE [dbo].[FinancialTransactionImage] CHECK CONSTRAINT [FK_dbo.FinancialTransactionImage_dbo.BinaryFile_BinaryFileId]

GO

ALTER TABLE [dbo].[FinancialTransactionImage]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialTransactionImage_dbo.FinancialTransaction_TransactionId] FOREIGN KEY([TransactionId])

REFERENCES [dbo].[FinancialTransaction] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[FinancialTransactionImage] CHECK CONSTRAINT [FK_dbo.FinancialTransactionImage_dbo.FinancialTransaction_TransactionId]

GO

ALTER TABLE [dbo].[FinancialTransactionImage]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialTransactionImage_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[FinancialTransactionImage] CHECK CONSTRAINT [FK_dbo.FinancialTransactionImage_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[FinancialTransactionImage]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialTransactionImage_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[FinancialTransactionImage] CHECK CONSTRAINT [FK_dbo.FinancialTransactionImage_dbo.PersonAlias_ModifiedByPersonAliasId]

GO
```

## FinancialTransactionRefund
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[FinancialTransactionRefund](

[Id] [int] NOT NULL,

[RefundReasonValueId] [int] NULL,

[RefundReasonSummary] [nvarchar](max) NULL,

[Guid] [uniqueidentifier] NOT NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[ForeignKey] [nvarchar](100) NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL,

[OriginalTransactionId] [int] NULL

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[FinancialTransactionRefund] ADD  CONSTRAINT [PK_dbo.FinancialTransactionRefund] PRIMARY KEY CLUSTERED 

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[FinancialTransactionRefund]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[FinancialTransactionRefund]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[FinancialTransactionRefund]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_OriginalTransactionId] ON [dbo].[FinancialTransactionRefund]

(

[OriginalTransactionId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_RefundReasonValueId] ON [dbo].[FinancialTransactionRefund]

(

[RefundReasonValueId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[FinancialTransactionRefund]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialTransactionRefund_dbo.DefinedValue_RefundReasonValueId] FOREIGN KEY([RefundReasonValueId])

REFERENCES [dbo].[DefinedValue] ([Id])

GO

ALTER TABLE [dbo].[FinancialTransactionRefund] CHECK CONSTRAINT [FK_dbo.FinancialTransactionRefund_dbo.DefinedValue_RefundReasonValueId]

GO

ALTER TABLE [dbo].[FinancialTransactionRefund]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialTransactionRefund_dbo.FinancialTransaction_Id] FOREIGN KEY([Id])

REFERENCES [dbo].[FinancialTransaction] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[FinancialTransactionRefund] CHECK CONSTRAINT [FK_dbo.FinancialTransactionRefund_dbo.FinancialTransaction_Id]

GO

ALTER TABLE [dbo].[FinancialTransactionRefund]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialTransactionRefund_dbo.FinancialTransaction_OriginalTransactionId] FOREIGN KEY([OriginalTransactionId])

REFERENCES [dbo].[FinancialTransaction] ([Id])

GO

ALTER TABLE [dbo].[FinancialTransactionRefund] CHECK CONSTRAINT [FK_dbo.FinancialTransactionRefund_dbo.FinancialTransaction_OriginalTransactionId]

GO

ALTER TABLE [dbo].[FinancialTransactionRefund]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialTransactionRefund_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[FinancialTransactionRefund] CHECK CONSTRAINT [FK_dbo.FinancialTransactionRefund_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[FinancialTransactionRefund]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialTransactionRefund_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[FinancialTransactionRefund] CHECK CONSTRAINT [FK_dbo.FinancialTransactionRefund_dbo.PersonAlias_ModifiedByPersonAliasId]

GO
```

## FinancialTransactionAlertType
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[FinancialTransactionAlertType](

[Id] [int] IDENTITY(1,1) NOT NULL,

[Name] [nvarchar](250) NULL,

[CampusId] [int] NULL,

[AlertType] [int] NOT NULL,

[ContinueIfMatched] [bit] NOT NULL,

[RepeatPreventionDuration] [int] NULL,

[FrequencySensitivityScale] [decimal](6, 1) NULL,

[AmountSensitivityScale] [decimal](6, 2) NULL,

[MinimumGiftAmount] [decimal](18, 2) NULL,

[MaximumGiftAmount] [decimal](18, 2) NULL,

[MinimumMedianGiftAmount] [decimal](18, 2) NULL,

[MaximumMedianGiftAmount] [decimal](18, 2) NULL,

[DataViewId] [int] NULL,

[WorkflowTypeId] [int] NULL,

[ConnectionOpportunityId] [int] NULL,

[SystemCommunicationId] [int] NULL,

[SendBusEvent] [bit] NOT NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[Guid] [uniqueidentifier] NOT NULL,

[ForeignId] [int] NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignKey] [nvarchar](100) NULL,

[Order] [int] NOT NULL,

[MaximumDaysSinceLastGift] [int] NULL,

[RunDays] [int] NULL,

[AlertSummaryNotificationGroupId] [int] NULL,

[FinancialAccountId] [int] NULL,

[IncludeChildFinancialAccounts] [bit] NOT NULL,

[AccountParticipantSystemCommunicationId] [int] NULL

) ON [PRIMARY]

GO

ALTER TABLE [dbo].[FinancialTransactionAlertType] ADD  CONSTRAINT [PK_dbo.FinancialTransactionAlertType] PRIMARY KEY CLUSTERED 

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_AccountParticipantSystemCommunicationId] ON [dbo].[FinancialTransactionAlertType]

(

[AccountParticipantSystemCommunicationId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_AlertSummaryNotificationGroupId] ON [dbo].[FinancialTransactionAlertType]

(

[AlertSummaryNotificationGroupId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CampusId] ON [dbo].[FinancialTransactionAlertType]

(

[CampusId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ConnectionOpportunityId] ON [dbo].[FinancialTransactionAlertType]

(

[ConnectionOpportunityId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[FinancialTransactionAlertType]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_DataViewId] ON [dbo].[FinancialTransactionAlertType]

(

[DataViewId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_FinancialAccountId] ON [dbo].[FinancialTransactionAlertType]

(

[FinancialAccountId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[FinancialTransactionAlertType]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[FinancialTransactionAlertType]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_Order] ON [dbo].[FinancialTransactionAlertType]

(

[Order] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_SystemCommunicationId] ON [dbo].[FinancialTransactionAlertType]

(

[SystemCommunicationId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_WorkflowTypeId] ON [dbo].[FinancialTransactionAlertType]

(

[WorkflowTypeId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[FinancialTransactionAlertType] ADD  DEFAULT ((0)) FOR [Order]

GO

ALTER TABLE [dbo].[FinancialTransactionAlertType] ADD  DEFAULT ((0)) FOR [IncludeChildFinancialAccounts]

GO

ALTER TABLE [dbo].[FinancialTransactionAlertType]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialTransactionAlertType_dbo.Campus_CampusId] FOREIGN KEY([CampusId])

REFERENCES [dbo].[Campus] ([Id])

GO

ALTER TABLE [dbo].[FinancialTransactionAlertType] CHECK CONSTRAINT [FK_dbo.FinancialTransactionAlertType_dbo.Campus_CampusId]

GO

ALTER TABLE [dbo].[FinancialTransactionAlertType]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialTransactionAlertType_dbo.ConnectionOpportunity_ConnectionOpportunityId] FOREIGN KEY([ConnectionOpportunityId])

REFERENCES [dbo].[ConnectionOpportunity] ([Id])

GO

ALTER TABLE [dbo].[FinancialTransactionAlertType] CHECK CONSTRAINT [FK_dbo.FinancialTransactionAlertType_dbo.ConnectionOpportunity_ConnectionOpportunityId]

GO

ALTER TABLE [dbo].[FinancialTransactionAlertType]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialTransactionAlertType_dbo.DataView_DataViewId] FOREIGN KEY([DataViewId])

REFERENCES [dbo].[DataView] ([Id])

GO

ALTER TABLE [dbo].[FinancialTransactionAlertType] CHECK CONSTRAINT [FK_dbo.FinancialTransactionAlertType_dbo.DataView_DataViewId]

GO

ALTER TABLE [dbo].[FinancialTransactionAlertType]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialTransactionAlertType_dbo.FinancialAccount_FinancialAccountId] FOREIGN KEY([FinancialAccountId])

REFERENCES [dbo].[FinancialAccount] ([Id])

GO

ALTER TABLE [dbo].[FinancialTransactionAlertType] CHECK CONSTRAINT [FK_dbo.FinancialTransactionAlertType_dbo.FinancialAccount_FinancialAccountId]

GO

ALTER TABLE [dbo].[FinancialTransactionAlertType]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialTransactionAlertType_dbo.Group_AlertSummaryNotificationGroupId] FOREIGN KEY([AlertSummaryNotificationGroupId])

REFERENCES [dbo].[Group] ([Id])

GO

ALTER TABLE [dbo].[FinancialTransactionAlertType] CHECK CONSTRAINT [FK_dbo.FinancialTransactionAlertType_dbo.Group_AlertSummaryNotificationGroupId]

GO

ALTER TABLE [dbo].[FinancialTransactionAlertType]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialTransactionAlertType_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[FinancialTransactionAlertType] CHECK CONSTRAINT [FK_dbo.FinancialTransactionAlertType_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[FinancialTransactionAlertType]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialTransactionAlertType_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[FinancialTransactionAlertType] CHECK CONSTRAINT [FK_dbo.FinancialTransactionAlertType_dbo.PersonAlias_ModifiedByPersonAliasId]

GO

ALTER TABLE [dbo].[FinancialTransactionAlertType]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialTransactionAlertType_dbo.SystemCommunication_AccountParticipantSystemCommunicationId] FOREIGN KEY([AccountParticipantSystemCommunicationId])

REFERENCES [dbo].[SystemCommunication] ([Id])

GO

ALTER TABLE [dbo].[FinancialTransactionAlertType] CHECK CONSTRAINT [FK_dbo.FinancialTransactionAlertType_dbo.SystemCommunication_AccountParticipantSystemCommunicationId]

GO

ALTER TABLE [dbo].[FinancialTransactionAlertType]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialTransactionAlertType_dbo.SystemCommunication_SystemCommunicationId] FOREIGN KEY([SystemCommunicationId])

REFERENCES [dbo].[SystemCommunication] ([Id])

GO

ALTER TABLE [dbo].[FinancialTransactionAlertType] CHECK CONSTRAINT [FK_dbo.FinancialTransactionAlertType_dbo.SystemCommunication_SystemCommunicationId]

GO

ALTER TABLE [dbo].[FinancialTransactionAlertType]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialTransactionAlertType_dbo.WorkflowType_WorkflowTypeId] FOREIGN KEY([WorkflowTypeId])

REFERENCES [dbo].[WorkflowType] ([Id])

GO

ALTER TABLE [dbo].[FinancialTransactionAlertType] CHECK CONSTRAINT [FK_dbo.FinancialTransactionAlertType_dbo.WorkflowType_WorkflowTypeId]

GO
```

## FinancialTransactionAlert
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[FinancialTransactionAlert](

[Id] [int] IDENTITY(1,1) NOT NULL,

[TransactionId] [int] NULL,

[PersonAliasId] [int] NOT NULL,

[GivingId] [nvarchar](50) NULL,

[AlertTypeId] [int] NOT NULL,

[Amount] [decimal](18, 2) NULL,

[AmountCurrentMedian] [decimal](18, 2) NULL,

[AmountCurrentIqr] [decimal](18, 2) NULL,

[AmountIqrMultiplier] [decimal](6, 1) NULL,

[FrequencyCurrentMean] [decimal](6, 1) NULL,

[FrequencyCurrentStandardDeviation] [decimal](6, 1) NULL,

[FrequencyDifferenceFromMean] [decimal](6, 1) NULL,

[FrequencyZScore] [decimal](6, 1) NULL,

[ReasonsKey] [nvarchar](2500) NULL,

[AlertDateTime] [datetime] NOT NULL,

[AlertDateKey] [int] NOT NULL,

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

ALTER TABLE [dbo].[FinancialTransactionAlert] ADD  CONSTRAINT [PK_dbo.FinancialTransactionAlert] PRIMARY KEY CLUSTERED 

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_AlertDateTime] ON [dbo].[FinancialTransactionAlert]

(

[AlertDateTime] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_AlertTypeId] ON [dbo].[FinancialTransactionAlert]

(

[AlertTypeId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[FinancialTransactionAlert]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[FinancialTransactionAlert]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[FinancialTransactionAlert]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_PersonAliasId] ON [dbo].[FinancialTransactionAlert]

(

[PersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_TransactionId] ON [dbo].[FinancialTransactionAlert]

(

[TransactionId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[FinancialTransactionAlert]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialTransactionAlert_dbo.FinancialTransaction_TransactionId] FOREIGN KEY([TransactionId])

REFERENCES [dbo].[FinancialTransaction] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[FinancialTransactionAlert] CHECK CONSTRAINT [FK_dbo.FinancialTransactionAlert_dbo.FinancialTransaction_TransactionId]

GO

ALTER TABLE [dbo].[FinancialTransactionAlert]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialTransactionAlert_dbo.FinancialTransactionAlertType_AlertTypeId] FOREIGN KEY([AlertTypeId])

REFERENCES [dbo].[FinancialTransactionAlertType] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[FinancialTransactionAlert] CHECK CONSTRAINT [FK_dbo.FinancialTransactionAlert_dbo.FinancialTransactionAlertType_AlertTypeId]

GO

ALTER TABLE [dbo].[FinancialTransactionAlert]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialTransactionAlert_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[FinancialTransactionAlert] CHECK CONSTRAINT [FK_dbo.FinancialTransactionAlert_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[FinancialTransactionAlert]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialTransactionAlert_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[FinancialTransactionAlert] CHECK CONSTRAINT [FK_dbo.FinancialTransactionAlert_dbo.PersonAlias_ModifiedByPersonAliasId]

GO

ALTER TABLE [dbo].[FinancialTransactionAlert]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FinancialTransactionAlert_dbo.PersonAlias_PersonAliasId] FOREIGN KEY([PersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[FinancialTransactionAlert] CHECK CONSTRAINT [FK_dbo.FinancialTransactionAlert_dbo.PersonAlias_PersonAliasId]

GO
```

## AnalyticsSourceFinancialTransaction
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[AnalyticsSourceFinancialTransaction](

[Id] [int] IDENTITY(1,1) NOT NULL,

[TransactionKey] [nvarchar](40) NULL,

[TransactionDateKey] [int] NOT NULL,

[AuthorizedPersonKey] [int] NULL,

[AuthorizedCurrentPersonKey] [int] NULL,

[DaysSinceLastTransactionOfType] [int] NULL,

[IsFirstTransactionOfType] [bit] NOT NULL,

[AuthorizedFamilyId] [int] NULL,

[IsScheduled] [bit] NOT NULL,

[TransactionFrequency] [nvarchar](250) NULL,

[GivingGroupId] [int] NULL,

[GivingId] [nvarchar](20) NULL,

[Count] [int] NOT NULL,

[TransactionDateTime] [datetime] NOT NULL,

[TransactionCode] [nvarchar](50) NULL,

[Summary] [nvarchar](max) NULL,

[TransactionTypeValueId] [int] NOT NULL,

[SourceTypeValueId] [int] NULL,

[AuthorizedPersonAliasId] [int] NULL,

[ProcessedByPersonAliasId] [int] NULL,

[ProcessedDateTime] [datetime] NULL,

[BatchId] [int] NULL,

[FinancialGatewayId] [int] NULL,

[EntityTypeId] [int] NULL,

[EntityId] [int] NULL,

[TransactionId] [int] NOT NULL,

[TransactionDetailId] [int] NOT NULL,

[AccountId] [int] NOT NULL,

[CurrencyTypeValueId] [int] NULL,

[CreditCardTypeValueId] [int] NULL,

[Amount] [decimal](18, 2) NOT NULL,

[ModifiedDateTime] [datetime] NULL,

[Guid] [uniqueidentifier] NOT NULL,

[ForeignId] [int] NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignKey] [nvarchar](100) NULL

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[AnalyticsSourceFinancialTransaction] ADD  CONSTRAINT [PK_dbo.AnalyticsSourceFinancialTransaction] PRIMARY KEY CLUSTERED 

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

SET ANSI_PADDING ON

GO

CREATE NONCLUSTERED INDEX [IX_GivingID_TransactionDateTime_TransactionTypeValueId] ON [dbo].[AnalyticsSourceFinancialTransaction]

(

[GivingId] ASC,

[TransactionTypeValueId] ASC,

[TransactionDateTime] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[AnalyticsSourceFinancialTransaction]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_TransactionDateKey] ON [dbo].[AnalyticsSourceFinancialTransaction]

(

[TransactionDateKey] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

SET ANSI_PADDING ON

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_TransactionKey] ON [dbo].[AnalyticsSourceFinancialTransaction]

(

[TransactionKey] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_TransactionTypeValueId_TransactionDateTime_AuthorizedPersonAliasId_AccountId] ON [dbo].[AnalyticsSourceFinancialTransaction]

(

[TransactionTypeValueId] ASC,

[TransactionDateTime] ASC,

[AuthorizedPersonAliasId] ASC,

[AccountId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO
```

## BenevolenceType
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[BenevolenceType](

[Id] [int] IDENTITY(1,1) NOT NULL,

[Name] [nvarchar](50) NOT NULL,

[Description] [nvarchar](max) NULL,

[IsActive] [bit] NOT NULL,

[RequestLavaTemplate] [nvarchar](max) NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[Guid] [uniqueidentifier] NOT NULL,

[ForeignId] [int] NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignKey] [nvarchar](100) NULL,

[ShowFinancialResults] [bit] NOT NULL,

[AdditionalSettingsJson] [nvarchar](max) NULL

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[BenevolenceType] ADD  CONSTRAINT [PK_dbo.BenevolenceType] PRIMARY KEY CLUSTERED 

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[BenevolenceType]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[BenevolenceType]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[BenevolenceType]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[BenevolenceType] ADD  DEFAULT ((1)) FOR [ShowFinancialResults]

GO

ALTER TABLE [dbo].[BenevolenceType]  WITH CHECK ADD  CONSTRAINT [FK_dbo.BenevolenceType_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[BenevolenceType] CHECK CONSTRAINT [FK_dbo.BenevolenceType_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[BenevolenceType]  WITH CHECK ADD  CONSTRAINT [FK_dbo.BenevolenceType_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[BenevolenceType] CHECK CONSTRAINT [FK_dbo.BenevolenceType_dbo.PersonAlias_ModifiedByPersonAliasId]

GO
```

## BenevolenceWorkflow
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[BenevolenceWorkflow](

[Id] [int] IDENTITY(1,1) NOT NULL,

[BenevolenceTypeId] [int] NULL,

[WorkflowTypeId] [int] NOT NULL,

[TriggerType] [int] NOT NULL,

[QualifierValue] [nvarchar](max) NULL,

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

ALTER TABLE [dbo].[BenevolenceWorkflow] ADD  CONSTRAINT [PK_dbo.BenevolenceWorkflow] PRIMARY KEY CLUSTERED 

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_BenevolenceTypeId] ON [dbo].[BenevolenceWorkflow]

(

[BenevolenceTypeId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[BenevolenceWorkflow]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[BenevolenceWorkflow]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[BenevolenceWorkflow]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_WorkflowTypeId] ON [dbo].[BenevolenceWorkflow]

(

[WorkflowTypeId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[BenevolenceWorkflow]  WITH CHECK ADD  CONSTRAINT [FK_dbo.BenevolenceWorkflow_dbo.BenevolenceType_BenevolenceTypeId] FOREIGN KEY([BenevolenceTypeId])

REFERENCES [dbo].[BenevolenceType] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[BenevolenceWorkflow] CHECK CONSTRAINT [FK_dbo.BenevolenceWorkflow_dbo.BenevolenceType_BenevolenceTypeId]

GO

ALTER TABLE [dbo].[BenevolenceWorkflow]  WITH CHECK ADD  CONSTRAINT [FK_dbo.BenevolenceWorkflow_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[BenevolenceWorkflow] CHECK CONSTRAINT [FK_dbo.BenevolenceWorkflow_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[BenevolenceWorkflow]  WITH CHECK ADD  CONSTRAINT [FK_dbo.BenevolenceWorkflow_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[BenevolenceWorkflow] CHECK CONSTRAINT [FK_dbo.BenevolenceWorkflow_dbo.PersonAlias_ModifiedByPersonAliasId]

GO

ALTER TABLE [dbo].[BenevolenceWorkflow]  WITH CHECK ADD  CONSTRAINT [FK_dbo.BenevolenceWorkflow_dbo.WorkflowType_WorkflowTypeId] FOREIGN KEY([WorkflowTypeId])

REFERENCES [dbo].[WorkflowType] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[BenevolenceWorkflow] CHECK CONSTRAINT [FK_dbo.BenevolenceWorkflow_dbo.WorkflowType_WorkflowTypeId]

GO
```

## BenevolenceRequest
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[BenevolenceRequest](

[Id] [int] IDENTITY(1,1) NOT NULL,

[FirstName] [nvarchar](50) NOT NULL,

[LastName] [nvarchar](50) NOT NULL,

[Email] [nvarchar](254) NULL,

[RequestedByPersonAliasId] [int] NULL,

[RequestText] [nvarchar](max) NOT NULL,

[RequestDateTime] [datetime] NOT NULL,

[HomePhoneNumber] [nvarchar](20) NULL,

[CellPhoneNumber] [nvarchar](20) NULL,

[WorkPhoneNumber] [nvarchar](20) NULL,

[CaseWorkerPersonAliasId] [int] NULL,

[GovernmentId] [nvarchar](100) NULL,

[RequestStatusValueId] [int] NOT NULL,

[ResultSummary] [nvarchar](max) NULL,

[ConnectionStatusValueId] [int] NULL,

[LocationId] [int] NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[Guid] [uniqueidentifier] NOT NULL,

[ForeignKey] [nvarchar](100) NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL,

[ProvidedNextSteps] [nvarchar](max) NULL,

[CampusId] [int] NULL,

[RequestDateKey] [int] NOT NULL,

[BenevolenceTypeId] [int] NOT NULL

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[BenevolenceRequest] ADD  CONSTRAINT [PK_dbo.BenevolenceRequest] PRIMARY KEY CLUSTERED 

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_BenevolenceTypeId] ON [dbo].[BenevolenceRequest]

(

[BenevolenceTypeId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CampusId] ON [dbo].[BenevolenceRequest]

(

[CampusId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CaseWorkerPersonAliasId] ON [dbo].[BenevolenceRequest]

(

[CaseWorkerPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ConnectionStatusValueId] ON [dbo].[BenevolenceRequest]

(

[ConnectionStatusValueId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[BenevolenceRequest]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[BenevolenceRequest]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_LocationId] ON [dbo].[BenevolenceRequest]

(

[LocationId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[BenevolenceRequest]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_RequestDateKey] ON [dbo].[BenevolenceRequest]

(

[RequestDateKey] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_RequestedByPersonAliasId] ON [dbo].[BenevolenceRequest]

(

[RequestedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_RequestStatusValueId] ON [dbo].[BenevolenceRequest]

(

[RequestStatusValueId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[BenevolenceRequest] ADD  DEFAULT ((0)) FOR [RequestDateKey]

GO

ALTER TABLE [dbo].[BenevolenceRequest] ADD  DEFAULT ((1)) FOR [BenevolenceTypeId]

GO

ALTER TABLE [dbo].[BenevolenceRequest]  WITH CHECK ADD  CONSTRAINT [FK_dbo.BenevolenceRequest_dbo.BenevolenceType_BenevolenceTypeId] FOREIGN KEY([BenevolenceTypeId])

REFERENCES [dbo].[BenevolenceType] ([Id])

GO

ALTER TABLE [dbo].[BenevolenceRequest] CHECK CONSTRAINT [FK_dbo.BenevolenceRequest_dbo.BenevolenceType_BenevolenceTypeId]

GO

ALTER TABLE [dbo].[BenevolenceRequest]  WITH CHECK ADD  CONSTRAINT [FK_dbo.BenevolenceRequest_dbo.Campus_CampusId] FOREIGN KEY([CampusId])

REFERENCES [dbo].[Campus] ([Id])

GO

ALTER TABLE [dbo].[BenevolenceRequest] CHECK CONSTRAINT [FK_dbo.BenevolenceRequest_dbo.Campus_CampusId]

GO

ALTER TABLE [dbo].[BenevolenceRequest]  WITH CHECK ADD  CONSTRAINT [FK_dbo.BenevolenceRequest_dbo.DefinedValue_ConnectionStatusValueId] FOREIGN KEY([ConnectionStatusValueId])

REFERENCES [dbo].[DefinedValue] ([Id])

GO

ALTER TABLE [dbo].[BenevolenceRequest] CHECK CONSTRAINT [FK_dbo.BenevolenceRequest_dbo.DefinedValue_ConnectionStatusValueId]

GO

ALTER TABLE [dbo].[BenevolenceRequest]  WITH CHECK ADD  CONSTRAINT [FK_dbo.BenevolenceRequest_dbo.DefinedValue_RequestStatusValueId] FOREIGN KEY([RequestStatusValueId])

REFERENCES [dbo].[DefinedValue] ([Id])

GO

ALTER TABLE [dbo].[BenevolenceRequest] CHECK CONSTRAINT [FK_dbo.BenevolenceRequest_dbo.DefinedValue_RequestStatusValueId]

GO

ALTER TABLE [dbo].[BenevolenceRequest]  WITH CHECK ADD  CONSTRAINT [FK_dbo.BenevolenceRequest_dbo.Location_LocationId] FOREIGN KEY([LocationId])

REFERENCES [dbo].[Location] ([Id])

GO

ALTER TABLE [dbo].[BenevolenceRequest] CHECK CONSTRAINT [FK_dbo.BenevolenceRequest_dbo.Location_LocationId]

GO

ALTER TABLE [dbo].[BenevolenceRequest]  WITH CHECK ADD  CONSTRAINT [FK_dbo.BenevolenceRequest_dbo.PersonAlias_CaseWorkerPersonAliasId] FOREIGN KEY([CaseWorkerPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[BenevolenceRequest] CHECK CONSTRAINT [FK_dbo.BenevolenceRequest_dbo.PersonAlias_CaseWorkerPersonAliasId]

GO

ALTER TABLE [dbo].[BenevolenceRequest]  WITH CHECK ADD  CONSTRAINT [FK_dbo.BenevolenceRequest_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[BenevolenceRequest] CHECK CONSTRAINT [FK_dbo.BenevolenceRequest_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[BenevolenceRequest]  WITH CHECK ADD  CONSTRAINT [FK_dbo.BenevolenceRequest_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[BenevolenceRequest] CHECK CONSTRAINT [FK_dbo.BenevolenceRequest_dbo.PersonAlias_ModifiedByPersonAliasId]

GO

ALTER TABLE [dbo].[BenevolenceRequest]  WITH CHECK ADD  CONSTRAINT [FK_dbo.BenevolenceRequest_dbo.PersonAlias_RequestedByPersonAliasId] FOREIGN KEY([RequestedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[BenevolenceRequest] CHECK CONSTRAINT [FK_dbo.BenevolenceRequest_dbo.PersonAlias_RequestedByPersonAliasId]

GO
```

## BenevolenceResult
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[BenevolenceResult](

[Id] [int] IDENTITY(1,1) NOT NULL,

[BenevolenceRequestId] [int] NOT NULL,

[ResultTypeValueId] [int] NOT NULL,

[Amount] [decimal](18, 2) NULL,

[ResultSummary] [nvarchar](max) NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[Guid] [uniqueidentifier] NOT NULL,

[ForeignKey] [nvarchar](100) NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[BenevolenceResult] ADD  CONSTRAINT [PK_dbo.BenevolenceResult] PRIMARY KEY CLUSTERED 

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_BenevolenceRequestId] ON [dbo].[BenevolenceResult]

(

[BenevolenceRequestId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[BenevolenceResult]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[BenevolenceResult]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[BenevolenceResult]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ResultTypeValueId] ON [dbo].[BenevolenceResult]

(

[ResultTypeValueId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[BenevolenceResult]  WITH CHECK ADD  CONSTRAINT [FK_dbo.BenevolenceResult_dbo.BenevolenceRequest_BenevolenceRequestId] FOREIGN KEY([BenevolenceRequestId])

REFERENCES [dbo].[BenevolenceRequest] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[BenevolenceResult] CHECK CONSTRAINT [FK_dbo.BenevolenceResult_dbo.BenevolenceRequest_BenevolenceRequestId]

GO

ALTER TABLE [dbo].[BenevolenceResult]  WITH CHECK ADD  CONSTRAINT [FK_dbo.BenevolenceResult_dbo.DefinedValue_ResultTypeValueId] FOREIGN KEY([ResultTypeValueId])

REFERENCES [dbo].[DefinedValue] ([Id])

GO

ALTER TABLE [dbo].[BenevolenceResult] CHECK CONSTRAINT [FK_dbo.BenevolenceResult_dbo.DefinedValue_ResultTypeValueId]

GO

ALTER TABLE [dbo].[BenevolenceResult]  WITH CHECK ADD  CONSTRAINT [FK_dbo.BenevolenceResult_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[BenevolenceResult] CHECK CONSTRAINT [FK_dbo.BenevolenceResult_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[BenevolenceResult]  WITH CHECK ADD  CONSTRAINT [FK_dbo.BenevolenceResult_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[BenevolenceResult] CHECK CONSTRAINT [FK_dbo.BenevolenceResult_dbo.PersonAlias_ModifiedByPersonAliasId]

GO
```

## BenevolenceRequestDocument
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[BenevolenceRequestDocument](

[Id] [int] IDENTITY(1,1) NOT NULL,

[BenevolenceRequestId] [int] NOT NULL,

[BinaryFileId] [int] NOT NULL,

[Order] [int] NULL,

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

ALTER TABLE [dbo].[BenevolenceRequestDocument] ADD  CONSTRAINT [PK_dbo.BenevolenceRequestDocument] PRIMARY KEY CLUSTERED 

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_BenevolenceRequestId] ON [dbo].[BenevolenceRequestDocument]

(

[BenevolenceRequestId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_BinaryFileId] ON [dbo].[BenevolenceRequestDocument]

(

[BinaryFileId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[BenevolenceRequestDocument]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[BenevolenceRequestDocument]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[BenevolenceRequestDocument]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[BenevolenceRequestDocument]  WITH CHECK ADD  CONSTRAINT [FK_dbo.BenevolenceRequestDocument_dbo.BenevolenceRequest_BenevolenceRequestId] FOREIGN KEY([BenevolenceRequestId])

REFERENCES [dbo].[BenevolenceRequest] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[BenevolenceRequestDocument] CHECK CONSTRAINT [FK_dbo.BenevolenceRequestDocument_dbo.BenevolenceRequest_BenevolenceRequestId]

GO

ALTER TABLE [dbo].[BenevolenceRequestDocument]  WITH CHECK ADD  CONSTRAINT [FK_dbo.BenevolenceRequestDocument_dbo.BinaryFile_BinaryFileId] FOREIGN KEY([BinaryFileId])

REFERENCES [dbo].[BinaryFile] ([Id])

GO

ALTER TABLE [dbo].[BenevolenceRequestDocument] CHECK CONSTRAINT [FK_dbo.BenevolenceRequestDocument_dbo.BinaryFile_BinaryFileId]

GO

ALTER TABLE [dbo].[BenevolenceRequestDocument]  WITH CHECK ADD  CONSTRAINT [FK_dbo.BenevolenceRequestDocument_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[BenevolenceRequestDocument] CHECK CONSTRAINT [FK_dbo.BenevolenceRequestDocument_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[BenevolenceRequestDocument]  WITH CHECK ADD  CONSTRAINT [FK_dbo.BenevolenceRequestDocument_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[BenevolenceRequestDocument] CHECK CONSTRAINT [FK_dbo.BenevolenceRequestDocument_dbo.PersonAlias_ModifiedByPersonAliasId]

GO
```
