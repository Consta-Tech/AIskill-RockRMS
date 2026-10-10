# Reminder Notification WorkflowType

> **Provenance tier:** `traced` — read from source or official documentation and cited (Rock v18.2.4). Catalogued in the plugin's knowledge manifest; `rockrms-knowledge-current` lists every entry.



| Field | Vanilla value |
|---|---|
| `WorkflowType.Name` | `Reminder Notification` |
| `Description` | "Used for sending a reminder email to the event contact regarding their upcoming resource reservation." |
| `WorkTerm` | `Reservation Reminders` |
| `ProcessingIntervalSeconds` | `28800` (8h) |
| `IsPersisted` | `True` |
| `IconCssClass` | `fa fa-list-ol` |
| Receives `Entity` = | `Reservation` |

## Purpose

Send a "your reservation is coming up" email to the event contact for a single Reservation.

## Triggered by

**Not** triggered via [`ReservationWorkflowTrigger`](../sql-tables/Reservation-Workflow.md#reservationworkflowtrigger). The vanilla intent is to be fired by an external Rock Job on a schedule, passing each upcoming Reservation in via `Entity`. (BEMA leaves the schedule + selection criteria up to each org's Job config.)

## Workflow Attributes

| Key | Purpose |
|---|---|
| `Reservation` | The Reservation being reminded about (passed in via Entity). |
| `ReservationId` | Holds the integer Id (used for downstream lookups, optional). |
| `EmailTo` | The recipient email address — set from `Reservation.EventContactEmail`. |

## Activity flow

### Activity 0: "Start"

Single linear activity, four actions:

1. **`Set Reservation From Entity`** — pulls the Reservation from `Entity`.
2. **`Set Email To`** — Lava: `{% assign Reservation = Workflow | Attribute:'Reservation','Object' %}{{ Reservation.EventContactEmail }}`.
3. **`Send Email`** — `Run-If: EmailTo IsNotBlank`. Subject: `Reminder: You have a reservation scheduled for...`. Body builds an HTML table with reservation name, location list, schedule, and notes.
4. **`Complete Workflow`**.

## Design intent

- **The email recipient is resolved from `Reservation.EventContactEmail`, not from the `EventContactPersonAlias` person record.** That column is an override field on the Reservation — staff can type any address, even if the EventContact person has a different email on their Person record. This lets event contacts route reminders to a separate "events" inbox without touching their Person record.
- **The workflow has no logic about *when* to fire.** That lives outside (in a Rock Job). The workflow itself just "send the email if there's an address."
- **It's deliberately tiny** so it can be invoked many times in quick succession — once per upcoming reservation, on whatever cadence the Job runs.

## See also

- [README § Trigger architecture](README.md#trigger-architecture) — why this workflow has no `ReservationWorkflowTrigger` row.
