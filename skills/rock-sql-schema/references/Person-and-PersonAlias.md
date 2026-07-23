# Person and PersonAlias

Person records, alias lookups, and duplicate detection.

> For a full index of all Rock RMS SQL table schemas and additional context, see `README.md`.

---

## Person
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[Person](

[Id] [int] IDENTITY(1,1) NOT NULL,

[IsSystem] [bit] NOT NULL,

[RecordTypeValueId] [int] NULL,

[RecordStatusValueId] [int] NULL,

[RecordStatusReasonValueId] [int] NULL,

[ConnectionStatusValueId] [int] NULL,

[IsDeceased] [bit] NOT NULL,

[TitleValueId] [int] NULL,

[FirstName] [nvarchar](50) NULL,

[NickName] [nvarchar](50) NULL,

[MiddleName] [nvarchar](50) NULL,

[LastName] [nvarchar](50) NULL,

[SuffixValueId] [int] NULL,

[PhotoId] [int] NULL,

[BirthDay] [int] NULL,

[BirthMonth] [int] NULL,

[BirthYear] [int] NULL,

[Gender] [int] NOT NULL,

[MaritalStatusValueId] [int] NULL,

[AnniversaryDate] [date] NULL,

[GivingGroupId] [int] NULL,

[Email] [nvarchar](75) NULL,

[IsEmailActive] [bit] NOT NULL,

[EmailNote] [nvarchar](250) NULL,

[SystemNote] [nvarchar](1000) NULL,

[ViewedCount] [int] NULL,

[Guid] [uniqueidentifier] NOT NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[EmailPreference] [int] NOT NULL,

[InactiveReasonNote] [nvarchar](1000) NULL,

[ForeignKey] [nvarchar](100) NULL,

[ReviewReasonValueId] [int] NULL,

[ReviewReasonNote] [nvarchar](1000) NULL,

[GraduationYear] [int] NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL,

[RecordStatusLastModifiedDateTime] [datetime] NULL,

[CommunicationPreference] [int] NOT NULL,

[TopSignalColor] [nvarchar](100) NULL,

[TopSignalIconCssClass] [nvarchar](100) NULL,

[TopSignalId] [int] NULL,

[AgeClassification] [int] NOT NULL,

[PrimaryFamilyId] [int] NULL,

[DaysUntilAnniversary] AS (case when datepart(month,[AnniversaryDate])=(2) AND datepart(day,[AnniversaryDate])=(29) AND datepart(month,sysdatetime())<(3) AND isdate(CONVERT([varchar](4),datepart(year,sysdatetime()))+'-02-29')=(0) then datediff(day,sysdatetime(),CONVERT([date],CONVERT([varchar](4),datepart(year,sysdatetime()))+'-02-28')) when datepart(month,[AnniversaryDate])=(2) AND datepart(day,[AnniversaryDate])=(29) AND isdate(CONVERT([varchar](4),datepart(year,dateadd(year,(1),sysdatetime())))+'-02-29')=(0) then datediff(day,sysdatetime(),CONVERT([date],CONVERT([varchar](4),datepart(year,dateadd(year,(1),sysdatetime())))+'-02-28')) else case when datepart(month,[AnniversaryDate])=(2) AND datepart(day,[AnniversaryDate])<(30) OR isdate((((CONVERT([varchar](4),datepart(year,sysdatetime()))+'-')+right('00'+CONVERT([varchar](2),datepart(month,[AnniversaryDate])),(2)))+'-')+right('00'+CONVERT([varchar](2),datepart(day,[AnniversaryDate])),(2)))=(1) then case when (datepart(month,sysdatetime())*(100)+datepart(day,sysdatetime()))>(datepart(month,[AnniversaryDate])*(100)+datepart(day,[AnniversaryDate])) then datediff(day,sysdatetime(),CONVERT([date],(((CONVERT([varchar](4),datepart(year,dateadd(year,(1),sysdatetime())))+'-')+right('00'+CONVERT([varchar](2),datepart(month,[AnniversaryDate])),(2)))+'-')+right('00'+CONVERT([varchar](2),datepart(day,[AnniversaryDate])),(2)))) else datediff(day,sysdatetime(),CONVERT([date],(((CONVERT([varchar](4),datepart(year,sysdatetime()))+'-')+right('00'+CONVERT([varchar](2),datepart(month,[AnniversaryDate])),(2)))+'-')+right('00'+CONVERT([varchar](2),datepart(day,[AnniversaryDate])),(2)))) end end end),

[IsLockedAsChild] [bit] NOT NULL,

[DeceasedDate] [datetime] NULL,

[GivingLeaderId] [int] NOT NULL,

[BirthDate] [date] NULL,

[ContributionFinancialAccountId] [int] NULL,

[PrimaryCampusId] [int] NULL,

[GivingId] [nvarchar](50) NULL,

[PreferredLanguageValueId] [int] NULL,

[AccountProtectionProfile] [int] NOT NULL,

[DaysUntilBirthday] AS (case when [BirthMonth]=(2) AND [BirthDay]=(29) AND datepart(month,sysdatetime())<(3) then datediff(day,sysdatetime(),dateadd(day,(-1),CONVERT([varchar](4),datepart(year,sysdatetime()))+'-03-01')) when [BirthMonth]=(2) AND [BirthDay]=(29) AND isdate(CONVERT([varchar](4),datepart(year,dateadd(year,(1),sysdatetime())))+'-02-29')=(0) then datediff(day,sysdatetime(),CONVERT([date],CONVERT([varchar](4),datepart(year,dateadd(year,(1),sysdatetime())))+'-02-28')) else case when [BirthMonth]=(2) AND [BirthDay]<(30) OR isdate((((CONVERT([varchar](4),datepart(year,sysdatetime()))+'-')+right('00'+CONVERT([varchar](2),[BirthMonth]),(2)))+'-')+right('00'+CONVERT([varchar](2),[BirthDay]),(2)))=(1) then case when (datepart(month,sysdatetime())*(100)+datepart(day,sysdatetime()))>([BirthMonth]*(100)+[BirthDay]) then datediff(day,sysdatetime(),CONVERT([date],(((CONVERT([varchar](4),datepart(year,dateadd(year,(1),sysdatetime())))+'-')+right('00'+CONVERT([varchar](2),[birthmonth]),(2)))+'-')+right('00'+CONVERT([varchar](2),[birthday]),(2)))) else datediff(day,sysdatetime(),CONVERT([date],(((CONVERT([varchar](4),datepart(year,sysdatetime()))+'-')+right('00'+CONVERT([varchar](2),[birthmonth]),(2)))+'-')+right('00'+CONVERT([varchar](2),[birthday]),(2)))) end end end),

[ReminderCount] [int] NULL,

[RaceValueId] [int] NULL,

[EthnicityValueId] [int] NULL,

[BirthDateKey] [int] NULL,

[AgeBracket] [int] NOT NULL,

[Age] [int] NULL,

[FirstNamePronunciationOverride] [nvarchar](200) NULL,

[NickNamePronunciationOverride] [nvarchar](200) NULL,

[LastNamePronunciationOverride] [nvarchar](200) NULL,

[PronunciationNote] [nvarchar](1000) NULL,

[PrimaryAliasId] [int] NULL,

[PrimaryAliasGuid] [uniqueidentifier] NULL,

[IsChatProfilePublic] [bit] NULL,

[IsChatOpenDirectMessageAllowed] [bit] NULL

) ON [PRIMARY]

GO

ALTER TABLE [dbo].[Person] ADD CONSTRAINT [PK_dbo.Person] PRIMARY KEY CLUSTERED

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_BirthDate] ON [dbo].[Person]

(

[BirthDate] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ContributionFinancialAccountId] ON [dbo].[Person]

(

[ContributionFinancialAccountId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[Person]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

SET ANSI_PADDING ON

GO

CREATE NONCLUSTERED INDEX [IX_Email] ON [dbo].[Person]

(

[Email] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_EthnicityValueId] ON [dbo].[Person]

(

[EthnicityValueId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_GivingGroupId] ON [dbo].[Person]

(

[GivingGroupId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

SET ANSI_PADDING ON

GO

CREATE NONCLUSTERED INDEX [IX_GivingId] ON [dbo].[Person]

(

[GivingId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_GivingLeaderId] ON [dbo].[Person]

(

[GivingLeaderId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[Person]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

SET ANSI_PADDING ON

GO

CREATE NONCLUSTERED INDEX [IX_IsDeceased_FirstName_LastName] ON [dbo].[Person]

(

[IsDeceased] ASC,

[FirstName] ASC,

[LastName] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

SET ANSI_PADDING ON

GO

CREATE NONCLUSTERED INDEX [IX_IsDeceased_LastName_FirstName] ON [dbo].[Person]

(

[IsDeceased] ASC,

[LastName] ASC,

[FirstName] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_MaritalStatusValueId] ON [dbo].[Person]

(

[MaritalStatusValueId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[Person]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_PersonStatusValueId] ON [dbo].[Person]

(

[ConnectionStatusValueId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_PhotoId] ON [dbo].[Person]

(

[PhotoId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_PreferredLanguageValueId] ON [dbo].[Person]

(

[PreferredLanguageValueId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_PrimaryCampusId] ON [dbo].[Person]

(

[PrimaryCampusId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_PrimaryFamilyId] ON [dbo].[Person]

(

[PrimaryFamilyId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_RaceValueId] ON [dbo].[Person]

(

[RaceValueId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_RecordStatusReasonValueId] ON [dbo].[Person]

(

[RecordStatusReasonValueId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_RecordStatusValueId] ON [dbo].[Person]

(

[RecordStatusValueId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

SET ANSI_PADDING ON

GO

CREATE NONCLUSTERED INDEX [IX_RecordTypeValueId_LastName] ON [dbo].[Person]

(

[RecordTypeValueId] ASC,

[LastName] ASC

)

INCLUDE([Guid]) WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ReviewReasonValueId] ON [dbo].[Person]

(

[ReviewReasonValueId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_SuffixValueId] ON [dbo].[Person]

(

[SuffixValueId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_TitleValueId] ON [dbo].[Person]

(

[TitleValueId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[Person] ADD DEFAULT ((0)) FOR [EmailPreference]

GO

ALTER TABLE [dbo].[Person] ADD DEFAULT ((0)) FOR [CommunicationPreference]

GO

ALTER TABLE [dbo].[Person] ADD DEFAULT ((0)) FOR [AgeClassification]

GO

ALTER TABLE [dbo].[Person] ADD DEFAULT ((0)) FOR [IsLockedAsChild]

GO

ALTER TABLE [dbo].[Person] ADD DEFAULT ((0)) FOR [GivingLeaderId]

GO

ALTER TABLE [dbo].[Person] ADD DEFAULT ((0)) FOR [AccountProtectionProfile]

GO

ALTER TABLE [dbo].[Person] ADD DEFAULT ((0)) FOR [AgeBracket]

GO

ALTER TABLE [dbo].[Person] WITH CHECK ADD CONSTRAINT [FK_dbo.Person_dbo.BinaryFile_PhotoId] FOREIGN KEY([PhotoId])

REFERENCES [dbo].[BinaryFile] ([Id])

GO

ALTER TABLE [dbo].[Person] CHECK CONSTRAINT [FK_dbo.Person_dbo.BinaryFile_PhotoId]

GO

ALTER TABLE [dbo].[Person] WITH CHECK ADD CONSTRAINT [FK_dbo.Person_dbo.Campus_PrimaryCampusId] FOREIGN KEY([PrimaryCampusId])

REFERENCES [dbo].[Campus] ([Id])

GO

ALTER TABLE [dbo].[Person] CHECK CONSTRAINT [FK_dbo.Person_dbo.Campus_PrimaryCampusId]

GO

ALTER TABLE [dbo].[Person] WITH CHECK ADD CONSTRAINT [FK_dbo.Person_dbo.DefinedValue_EthnicityValueId] FOREIGN KEY([EthnicityValueId])

REFERENCES [dbo].[DefinedValue] ([Id])

GO

ALTER TABLE [dbo].[Person] CHECK CONSTRAINT [FK_dbo.Person_dbo.DefinedValue_EthnicityValueId]

GO

ALTER TABLE [dbo].[Person] WITH CHECK ADD CONSTRAINT [FK_dbo.Person_dbo.DefinedValue_MaritalStatusValueId] FOREIGN KEY([MaritalStatusValueId])

REFERENCES [dbo].[DefinedValue] ([Id])

GO

ALTER TABLE [dbo].[Person] CHECK CONSTRAINT [FK_dbo.Person_dbo.DefinedValue_MaritalStatusValueId]

GO

ALTER TABLE [dbo].[Person] WITH CHECK ADD CONSTRAINT [FK_dbo.Person_dbo.DefinedValue_PersonStatusValueId] FOREIGN KEY([ConnectionStatusValueId])

REFERENCES [dbo].[DefinedValue] ([Id])

GO

ALTER TABLE [dbo].[Person] CHECK CONSTRAINT [FK_dbo.Person_dbo.DefinedValue_PersonStatusValueId]

GO

ALTER TABLE [dbo].[Person] WITH CHECK ADD CONSTRAINT [FK_dbo.Person_dbo.DefinedValue_PreferredLanguageValueId] FOREIGN KEY([PreferredLanguageValueId])

REFERENCES [dbo].[DefinedValue] ([Id])

GO

ALTER TABLE [dbo].[Person] CHECK CONSTRAINT [FK_dbo.Person_dbo.DefinedValue_PreferredLanguageValueId]

GO

ALTER TABLE [dbo].[Person] WITH CHECK ADD CONSTRAINT [FK_dbo.Person_dbo.DefinedValue_RaceValueId] FOREIGN KEY([RaceValueId])

REFERENCES [dbo].[DefinedValue] ([Id])

GO

ALTER TABLE [dbo].[Person] CHECK CONSTRAINT [FK_dbo.Person_dbo.DefinedValue_RaceValueId]

GO

ALTER TABLE [dbo].[Person] WITH CHECK ADD CONSTRAINT [FK_dbo.Person_dbo.DefinedValue_RecordStatusReasonValueId] FOREIGN KEY([RecordStatusReasonValueId])

REFERENCES [dbo].[DefinedValue] ([Id])

GO

ALTER TABLE [dbo].[Person] CHECK CONSTRAINT [FK_dbo.Person_dbo.DefinedValue_RecordStatusReasonValueId]

GO

ALTER TABLE [dbo].[Person] WITH CHECK ADD CONSTRAINT [FK_dbo.Person_dbo.DefinedValue_RecordStatusValueId] FOREIGN KEY([RecordStatusValueId])

REFERENCES [dbo].[DefinedValue] ([Id])

GO

ALTER TABLE [dbo].[Person] CHECK CONSTRAINT [FK_dbo.Person_dbo.DefinedValue_RecordStatusValueId]

GO

ALTER TABLE [dbo].[Person] WITH CHECK ADD CONSTRAINT [FK_dbo.Person_dbo.DefinedValue_RecordTypeValueId] FOREIGN KEY([RecordTypeValueId])

REFERENCES [dbo].[DefinedValue] ([Id])

GO

ALTER TABLE [dbo].[Person] CHECK CONSTRAINT [FK_dbo.Person_dbo.DefinedValue_RecordTypeValueId]

GO

ALTER TABLE [dbo].[Person] WITH CHECK ADD CONSTRAINT [FK_dbo.Person_dbo.DefinedValue_ReviewReasonValueId] FOREIGN KEY([ReviewReasonValueId])

REFERENCES [dbo].[DefinedValue] ([Id])

GO

ALTER TABLE [dbo].[Person] CHECK CONSTRAINT [FK_dbo.Person_dbo.DefinedValue_ReviewReasonValueId]

GO

ALTER TABLE [dbo].[Person] WITH CHECK ADD CONSTRAINT [FK_dbo.Person_dbo.DefinedValue_SuffixValueId] FOREIGN KEY([SuffixValueId])

REFERENCES [dbo].[DefinedValue] ([Id])

GO

ALTER TABLE [dbo].[Person] CHECK CONSTRAINT [FK_dbo.Person_dbo.DefinedValue_SuffixValueId]

GO

ALTER TABLE [dbo].[Person] WITH CHECK ADD CONSTRAINT [FK_dbo.Person_dbo.DefinedValue_TitleValueId] FOREIGN KEY([TitleValueId])

REFERENCES [dbo].[DefinedValue] ([Id])

GO

ALTER TABLE [dbo].[Person] CHECK CONSTRAINT [FK_dbo.Person_dbo.DefinedValue_TitleValueId]

GO

ALTER TABLE [dbo].[Person] WITH CHECK ADD CONSTRAINT [FK_dbo.Person_dbo.FinancialAccount_ContributionFinancialAccountId] FOREIGN KEY([ContributionFinancialAccountId])

REFERENCES [dbo].[FinancialAccount] ([Id])

GO

ALTER TABLE [dbo].[Person] CHECK CONSTRAINT [FK_dbo.Person_dbo.FinancialAccount_ContributionFinancialAccountId]

GO

ALTER TABLE [dbo].[Person] WITH CHECK ADD CONSTRAINT [FK_dbo.Person_dbo.Group_GivingGroupId] FOREIGN KEY([GivingGroupId])

REFERENCES [dbo].[Group] ([Id])

GO

ALTER TABLE [dbo].[Person] CHECK CONSTRAINT [FK_dbo.Person_dbo.Group_GivingGroupId]

GO

ALTER TABLE [dbo].[Person] WITH CHECK ADD CONSTRAINT [FK_dbo.Person_dbo.Group_PrimaryFamilyId] FOREIGN KEY([PrimaryFamilyId])

REFERENCES [dbo].[Group] ([Id])

GO

ALTER TABLE [dbo].[Person] CHECK CONSTRAINT [FK_dbo.Person_dbo.Group_PrimaryFamilyId]

GO

ALTER TABLE [dbo].[Person] WITH CHECK ADD CONSTRAINT [FK_dbo.Person_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[Person] CHECK CONSTRAINT [FK_dbo.Person_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[Person] WITH CHECK ADD CONSTRAINT [FK_dbo.Person_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[Person] CHECK CONSTRAINT [FK_dbo.Person_dbo.PersonAlias_ModifiedByPersonAliasId]

GO
```


## PersonAlias
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[PersonAlias](

[Id] [int] IDENTITY(1,1) NOT NULL,

[Name] [nvarchar](200) NULL,

[PersonId] [int] NOT NULL,

[AliasPersonId] [int] NULL,

[AliasPersonGuid] [uniqueidentifier] NULL,

[Guid] [uniqueidentifier] NOT NULL,

[ForeignKey] [nvarchar](100) NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL,

[AliasedDateTime] [datetime] NULL,

[LastVisitDateTime] [datetime] NULL,

[InternalMessage] [nvarchar](250) NULL

) ON [PRIMARY]

GO

ALTER TABLE [dbo].[PersonAlias] ADD CONSTRAINT [PK_dbo.PersonAlias] PRIMARY KEY CLUSTERED

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_AliasPersonId] ON [dbo].[PersonAlias]

(

[AliasPersonId] ASC

)

WHERE ([AliasPersonId] IS NOT NULL)

WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[PersonAlias]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Id] ON [dbo].[PersonAlias]

(

[Id] ASC

)

INCLUDE([PersonId]) WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

SET ANSI_PADDING ON

GO

CREATE NONCLUSTERED INDEX [IX_Name] ON [dbo].[PersonAlias]

(

[Name] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_PersonId] ON [dbo].[PersonAlias]

(

[PersonId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[PersonAlias] WITH CHECK ADD CONSTRAINT [FK_dbo.PersonAlias_dbo.Person_PersonId] FOREIGN KEY([PersonId])

REFERENCES [dbo].[Person] ([Id])

GO

ALTER TABLE [dbo].[PersonAlias] CHECK CONSTRAINT [FK_dbo.PersonAlias_dbo.Person_PersonId]

GO
```


## PersonDuplicate
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[PersonDuplicate](

[Id] [int] IDENTITY(1,1) NOT NULL,

[PersonAliasId] [int] NOT NULL,

[DuplicatePersonAliasId] [int] NOT NULL,

[IsConfirmedAsNotDuplicate] [bit] NOT NULL,

[Score] [int] NULL,

[ScoreDetail] [nvarchar](max) NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[Guid] [uniqueidentifier] NOT NULL,

[ForeignKey] [nvarchar](100) NULL,

[Capacity] [int] NULL,

[IgnoreUntilScoreChanges] [bit] NOT NULL,

[TotalCapacity] [int] NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL,

[ConfidenceScore] [float] NULL

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[PersonDuplicate] ADD CONSTRAINT [PK_dbo.PersonDuplicate] PRIMARY KEY CLUSTERED

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ConfidenceScore] ON [dbo].[PersonDuplicate]

(

[ConfidenceScore] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[PersonDuplicate]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_DuplicatePersonAliasId] ON [dbo].[PersonDuplicate]

(

[DuplicatePersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[PersonDuplicate]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[PersonDuplicate]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_PersonAliasId_DuplicatePersonAliasId] ON [dbo].[PersonDuplicate]

(

[PersonAliasId] ASC,

[DuplicatePersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[PersonDuplicate] ADD DEFAULT ((0)) FOR [IgnoreUntilScoreChanges]

GO

ALTER TABLE [dbo].[PersonDuplicate] WITH CHECK ADD CONSTRAINT [FK_dbo.PersonDuplicate_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[PersonDuplicate] CHECK CONSTRAINT [FK_dbo.PersonDuplicate_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[PersonDuplicate] WITH CHECK ADD CONSTRAINT [FK_dbo.PersonDuplicate_dbo.PersonAlias_DuplicatePersonAliasId] FOREIGN KEY([DuplicatePersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[PersonDuplicate] CHECK CONSTRAINT [FK_dbo.PersonDuplicate_dbo.PersonAlias_DuplicatePersonAliasId]

GO

ALTER TABLE [dbo].[PersonDuplicate] WITH CHECK ADD CONSTRAINT [FK_dbo.PersonDuplicate_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[PersonDuplicate] CHECK CONSTRAINT [FK_dbo.PersonDuplicate_dbo.PersonAlias_ModifiedByPersonAliasId]

GO

ALTER TABLE [dbo].[PersonDuplicate] WITH CHECK ADD CONSTRAINT [FK_dbo.PersonDuplicate_dbo.PersonAlias_PersonAliasId] FOREIGN KEY([PersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[PersonDuplicate] CHECK CONSTRAINT [FK_dbo.PersonDuplicate_dbo.PersonAlias_PersonAliasId]

GO
```