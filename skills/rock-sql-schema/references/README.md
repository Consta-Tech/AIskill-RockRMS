# Rock RMS SQL Table Schemas

These are the `CREATE TABLE` scripts related to SQL Tables in our SQL Server. These will be useful references for the actual schema definitions. (I took the liberty of ordering them in a way that made logical sense to me).

Tables are grouped by **JOIN affinity** — tables that are commonly queried together live in the same file. This makes it easy to reference the relevant schemas side-by-side when writing a query that spans related entities.

## File Index

| File | Tables | Grouping Rationale |
|------|--------|--------------------|
| [Person-and-PersonAlias.md](Person-and-PersonAlias.md) | Person, PersonAlias, PersonDuplicate | Person identity resolution and duplicate detection |
| [GroupType-and-Roles-and-Associations.md](GroupType-and-Roles-and-Associations.md) | GroupType, GroupTypeAssociation, GroupTypeRole, GroupTypeLocationType | Group taxonomy, roles, and type-level configuration |
| [Group.md](Group.md) | Group, GroupDemographicType, GroupDemographicValue, GroupHistorical, GroupSync | Core group entity, demographics, history, and sync |
| [GroupMember.md](GroupMember.md) | GroupMember, GroupMemberAssignment, GroupMemberHistorical, GroupMemberScheduleTemplate, GroupMemberWorkflowTrigger | Group membership, assignments, history, and automation |
| [GroupRequirement.md](GroupRequirement.md) | GroupRequirementType, GroupRequirement, GroupMemberRequirement | Requirement definitions, group-level application, and per-member tracking |
| [GroupLocation-and-GroupSchedule.md](GroupLocation-and-GroupSchedule.md) | GroupScheduleExclusion, GroupLocation, GroupLocationHistorical, GroupLocationHistoricalSchedule, GroupLocationSchedule, GroupLocationScheduleConfig | Where and when groups meet — locations, schedules, and exclusions |
| [ConnectionType-and-Status.md](ConnectionType-and-Status.md) | ConnectionType, ConnectionStatus, ConnectionStatusAutomation, ConnectionWorkflow | Connection framework type-level configuration |
| [ConnectionOpportunity.md](ConnectionOpportunity.md) | ConnectionOpportunity, ConnectionOpportunityCampus, ConnectionOpportunityConnectorGroup, ConnectionOpportunityGroupConfig, ConnectionOpportunityGroup | Connection opportunities and placement configuration |
| [ConnectionRequest-and-Activity.md](ConnectionRequest-and-Activity.md) | ConnectionRequest, ConnectionRequestWorkflow, ConnectionActivityType, ConnectionRequestActivity | Connection request processing and activity tracking |
| [Attribute-and-Value.md](Attribute-and-Value.md) | Attribute, AttributeCategory, AttributeQualifier, AttributeValue, AttributeValueHistorical, AttributeReferencedEntity, AttributeValueReferencedEntity, AttributeMatrixTemplate, AttributeMatrix, AttributeMatrixItem | Attribute definitions, stored values, history, matrix data, and entity reference tracking |
| [database-structure-tables.md](database-structure-tables.md) | FieldType, EntityType, DefinedType, DefinedValue, EntitySet, EntitySetItem, Device, DeviceLocation, PersonalDevice, Schedule, ScheduleCategoryExclusion, ServiceJob, ServiceJobHistory, ServiceLog | Type system, entity metadata, devices, scheduling, and service infrastructure |
| [Block-and-BlockType.md](Block-and-BlockType.md) | BlockType, Block | Block type definitions and block instances |
| [Campus.md](Campus.md) | Campus, CampusSchedule, CampusTopic | Campus definitions, schedules, and topics |
| [Location.md](Location.md) | Location | Physical/virtual places in the campus/building hierarchy (with gotchas) |
| [Category.md](Category.md) | Category | Hierarchical categorization for multiple entity types |
| [DataView-and-Report.md](DataView-and-Report.md) | DataViewFilter, DataView, DataViewPersistedValue, Report, ReportField, Query | Data filtering, persisted results, report definitions, and saved queries |
| [Workflow.md](Workflow.md) | WorkflowFormBuilderTemplate, WorkflowType, WorkflowActivityType, WorkflowActionForm, WorkflowActionFormSection, WorkflowActionFormAttribute, WorkflowActionType, WorkflowTrigger, Workflow, WorkflowActivity, WorkflowAction, WorkflowLog | Workflow type definitions, action/activity blueprints, form configuration, runtime instances, and logging |
| [Attendance.md](Attendance.md) | CheckInLabel, AttendanceCode, AttendanceCheckInSession, AttendanceOccurrence, Attendance, AttendanceData, AnalyticsSourceAttendance | Check-in configuration, occurrence events, individual attendance records, label data, and analytics |
| [Finance.md](Finance.md) | FinancialGateway, FinancialAccount, FinancialStatementTemplate, FinancialBatch, FinancialPaymentDetail, FinancialPersonBankAccount, FinancialPersonSavedAccount, FinancialPledge, FinancialScheduledTransaction, FinancialScheduledTransactionDetail, FinancialTransaction, FinancialTransactionDetail, FinancialTransactionImage, FinancialTransactionRefund, FinancialTransactionAlertType, FinancialTransactionAlert, AnalyticsSourceFinancialTransaction, BenevolenceType, BenevolenceWorkflow, BenevolenceRequest, BenevolenceResult, BenevolenceRequestDocument | Financial accounts, transactions, pledges, scheduled giving, alerting, analytics, and benevolence |
| [CalendarEvent.md](CalendarEvent.md) | EventCalendar, EventItem, EventCalendarContentChannel, EventCalendarItem, EventItemAudience, EventItemOccurrence, EventItemOccurrenceChannelItem, EventItemOccurrenceGroupMap | Event calendars, event definitions, audience targeting, occurrences, content channel links, and registration/group mappings |
| [Registration.md](Registration.md) | RegistrationTemplate, RegistrationTemplateForm, RegistrationTemplateFormField, RegistrationTemplateFee, RegistrationTemplateFeeItem, RegistrationTemplateDiscount, RegistrationTemplatePlacement, RegistrationInstance, Registration, RegistrationSession, RegistrationRegistrant, RegistrationRegistrantFee | Registration templates, form/fee/discount/placement configuration, instances, submissions, sessions, registrants, and fee charges |
