---
name: rock-sql-schema
description: CREATE TABLE schema references for the Rock RMS SQL Server database — Person/PersonAlias, Group/GroupMember, Attendance, Finance, Registration, Workflow, Connections, Attribute/AttributeValue, Campus, Location, DataViews, and more. Use when writing or debugging T-SQL against a Rock database, checking table or column names, choosing JOINs, or looking up foreign-key relationships. Read only the reference files for the tables the task touches.
---

# Rock RMS SQL Schema

`references/` contains the `CREATE TABLE` scripts for Rock's SQL Server tables, annotated with contextual notes. Tables are grouped by **JOIN affinity** — tables that are commonly queried together live in the same file, so the relevant schemas sit side-by-side when writing a query that spans related entities.

## How to use this skill

1. Find the table(s) the task touches in the File Index below.
2. Read **only** those reference files. Do not read the whole directory.
3. When joining to people, always join through `PersonAlias`, not directly to `Person` — duplicate-record merges repoint aliases, so `PersonAlias` is the merge-safe path. See `references/Person-and-PersonAlias.md`.
4. Format queries per the house SQL style (injected as session rules); the `format-tsql` skill in this plugin applies it mechanically.

## File Index

| File | Tables | Grouping Rationale |
|------|--------|--------------------|
| [Person-and-PersonAlias.md](references/Person-and-PersonAlias.md) | Person, PersonAlias, PersonDuplicate | Person identity resolution and duplicate detection |
| [GroupType-and-Roles-and-Associations.md](references/GroupType-and-Roles-and-Associations.md) | GroupType, GroupTypeAssociation, GroupTypeRole, GroupTypeLocationType | Group taxonomy, roles, and type-level configuration |
| [Group.md](references/Group.md) | Group, GroupDemographicType, GroupDemographicValue, GroupHistorical, GroupSync | Core group entity, demographics, history, and sync |
| [GroupMember.md](references/GroupMember.md) | GroupMember, GroupMemberAssignment, GroupMemberHistorical, GroupMemberScheduleTemplate, GroupMemberWorkflowTrigger | Group membership, assignments, history, and automation |
| [GroupRequirement.md](references/GroupRequirement.md) | GroupRequirementType, GroupRequirement, GroupMemberRequirement | Requirement definitions, group-level application, and per-member tracking |
| [GroupLocation-and-GroupSchedule.md](references/GroupLocation-and-GroupSchedule.md) | GroupScheduleExclusion, GroupLocation, GroupLocationHistorical, GroupLocationHistoricalSchedule, GroupLocationSchedule, GroupLocationScheduleConfig | Where and when groups meet — locations, schedules, and exclusions |
| [ConnectionType-and-Status.md](references/ConnectionType-and-Status.md) | ConnectionType, ConnectionStatus, ConnectionStatusAutomation, ConnectionWorkflow | Connection framework type-level configuration |
| [ConnectionOpportunity.md](references/ConnectionOpportunity.md) | ConnectionOpportunity, ConnectionOpportunityCampus, ConnectionOpportunityConnectorGroup, ConnectionOpportunityGroupConfig, ConnectionOpportunityGroup | Connection opportunities and placement configuration |
| [ConnectionRequest-and-Activity.md](references/ConnectionRequest-and-Activity.md) | ConnectionRequest, ConnectionRequestWorkflow, ConnectionActivityType, ConnectionRequestActivity | Connection request processing and activity tracking |
| [Attribute-and-Value.md](references/Attribute-and-Value.md) | Attribute, AttributeCategory, AttributeQualifier, AttributeValue, AttributeValueHistorical, AttributeReferencedEntity, AttributeValueReferencedEntity, AttributeMatrixTemplate, AttributeMatrix, AttributeMatrixItem | Attribute definitions, stored values, history, matrix data, and entity reference tracking |
| [database-structure-tables.md](references/database-structure-tables.md) | FieldType, EntityType, DefinedType, DefinedValue, EntitySet, EntitySetItem, Device, DeviceLocation, PersonalDevice, Schedule, ScheduleCategoryExclusion, ServiceJob, ServiceJobHistory, ServiceLog | Type system, entity metadata, devices, scheduling, and service infrastructure |
| [Block-and-BlockType.md](references/Block-and-BlockType.md) | BlockType, Block | Block type definitions and block instances |
| [Campus.md](references/Campus.md) | Campus, CampusSchedule, CampusTopic | Campus definitions, schedules, and topics |
| [Location.md](references/Location.md) | Location | Physical/virtual places in the campus/building hierarchy (with gotchas) |
| [Category.md](references/Category.md) | Category | Hierarchical categorization for multiple entity types |
| [DataView-and-Report.md](references/DataView-and-Report.md) | DataViewFilter, DataView, DataViewPersistedValue, Report, ReportField, Query | Data filtering, persisted results, report definitions, and saved queries |
| [Workflow.md](references/Workflow.md) | WorkflowFormBuilderTemplate, WorkflowType, WorkflowActivityType, WorkflowActionForm, WorkflowActionFormSection, WorkflowActionFormAttribute, WorkflowActionType, WorkflowTrigger, Workflow, WorkflowActivity, WorkflowAction, WorkflowLog | Workflow type definitions, action/activity blueprints, form configuration, runtime instances, and logging |
| [Attendance.md](references/Attendance.md) | CheckInLabel, AttendanceCode, AttendanceCheckInSession, AttendanceOccurrence, Attendance, AttendanceData, AnalyticsSourceAttendance | Check-in configuration, occurrence events, individual attendance records, label data, and analytics |
| [Finance.md](references/Finance.md) | FinancialGateway, FinancialAccount, FinancialStatementTemplate, FinancialBatch, FinancialPaymentDetail, FinancialPersonBankAccount, FinancialPersonSavedAccount, FinancialPledge, FinancialScheduledTransaction, FinancialScheduledTransactionDetail, FinancialTransaction, FinancialTransactionDetail, FinancialTransactionImage, FinancialTransactionRefund, FinancialTransactionAlertType, FinancialTransactionAlert, AnalyticsSourceFinancialTransaction, BenevolenceType, BenevolenceWorkflow, BenevolenceRequest, BenevolenceResult, BenevolenceRequestDocument | Financial accounts, transactions, pledges, scheduled giving, alerting, analytics, and benevolence |
| [CalendarEvent.md](references/CalendarEvent.md) | EventCalendar, EventItem, EventCalendarContentChannel, EventCalendarItem, EventItemAudience, EventItemOccurrence, EventItemOccurrenceChannelItem, EventItemOccurrenceGroupMap | Event calendars, event definitions, audience targeting, occurrences, content channel links, and registration/group mappings |
| [Registration.md](references/Registration.md) | RegistrationTemplate, RegistrationTemplateForm, RegistrationTemplateFormField, RegistrationTemplateFee, RegistrationTemplateFeeItem, RegistrationTemplateDiscount, RegistrationTemplatePlacement, RegistrationInstance, Registration, RegistrationSession, RegistrationRegistrant, RegistrationRegistrantFee | Registration templates, form/fee/discount/placement configuration, instances, submissions, sessions, registrants, and fee charges |

## Related skills

- `bema-room-management` — schema for the BEMA Room Management plugin tables (`_com_bemaservices_RoomManagement_*`), which reference several core tables above.
- `format-tsql` — applies the house T-SQL formatting style to a query.
