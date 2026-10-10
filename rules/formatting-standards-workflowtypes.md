---
trigger: always_on
---
# Formatting Standards — Workflow Types

> **Provenance tier:** `traced` — read from source or official documentation and cited (house convention, no Rock version). Catalogued in the plugin's knowledge manifest; `rockrms-knowledge-current` lists every entry.


Part of the formatting-standards house rules; `formatting-standards.md` holds what applies to every language.

## 3. Workflow Types
When configuring WorkflowTypes, i have some conventions i'd like to follow:
1. As a rule of thumb, most WorkflowTypes should have at least two Activities: one named "START" and one named "FINISH"
    - "START" is the Activity that sets any Attributes that are needed for the execution of this WorkflowType,
    - "FINISH" is the Activity that contains the 'Complete Workflow' Action.
    - Every other Activity can be named with normal capitalization, no need for all-caps.
1. Every Action should be named with a verb at the beginning. Example:
    - Activate Activity
    - Set Person Attributes
    - Complete Workflow
    - etc
1. When the name of an Action contains the name of an Activity, use square-brackets. Example:
    - Activate [FINISH]
    - Activate [Loop]
    - etc
1. When the name of an Action contains the Key (not Name) of a Workflow Attribute or Activity Attribute, use parentheses. Example:
    - Set (var_Person) from CurrentPerson
    - Send SMS to (var_Person) with (memo_Message)
    - Add Note to (obj_Person_Submitter)
    - etc
1. When naming a WorkflowType, it's (v1.0)
    - Modifying the WorkflowType doesn't necessarily increment the version label if it's a small change.
    - If it's a big change, it increments the version dot (from v1.0 to v1.1) and add a Note to the ChangeLog.
    - If it's a change so big that it cannot be done by modifying the WorkflowType, and rather we must create a new WorkflowType that replaces this one, then the new WorkflowType gets a new version number (v2.0) and the previous WorkflowType gets archived.
