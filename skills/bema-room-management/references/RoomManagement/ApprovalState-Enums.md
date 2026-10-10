# Approval-State Enums

> **Provenance tier:** `traced` — read from source or official documentation and cited (Rock v18.2.4). Catalogued in the plugin's knowledge manifest; `rockrms-knowledge-current` lists every entry.



The Room Management plugin defines **three** distinct `ApprovalState` enums — one for the parent `Reservation` and two for the child junction tables (`ReservationLocation`, `ReservationResource`). The integer values are **not** the same across these enums, despite the values for `Approved` and `Denied` happening to coincide.

Source of truth: BEMADEV's public source on GitHub.
- [`Model/Reservation/Reservation.cs`](https://github.com/BEMADEV/Room-Management/blob/main/com.bemaservices.RoomManagement/Model/Reservation/Reservation.cs) — `ReservationApprovalState`
- [`Model/ReservationLocation/ReservationLocation.cs`](https://github.com/BEMADEV/Room-Management/blob/main/com.bemaservices.RoomManagement/Model/ReservationLocation/ReservationLocation.cs) — `ReservationLocationApprovalState`
- [`Model/ReservationResource/ReservationResource.cs`](https://github.com/BEMADEV/Room-Management/blob/main/com.bemaservices.RoomManagement/Model/ReservationResource/ReservationResource.cs) — `ReservationResourceApprovalState`

Each enum is `public enum X { Member = N, ... }` with **explicit integer assignments** in C#. None inherit the default-zero-indexed C# behavior.

## The three enums

### `ReservationApprovalState` — parent (8 values, 0-indexed)

| Int | Member | Notes |
|---:|---|---|
| `0` | `Draft` | Default state for new reservations created through our flow. |
| `1` | `PendingInitialApproval` | Submitted; awaiting first stage of approval. |
| `2` | `Approved` | Final approval has landed. |
| `3` | `Denied` | Rejected. |
| `4` | `ChangesNeeded` | Approver returned the request for revisions. Re-submit allowed. |
| `5` | `PendingFinalApproval` | Initial approval done; awaiting final. |
| `6` | `PendingSpecialApproval` | A resource or location flagged for special approval. |
| `7` | `Cancelled` | Cancelled (distinct from Denied). |

SQL column default is `1` (per `Reservation-and-Type.md:66`), but our `commit-section-when` explicitly writes `0` (Draft) on insert, so the default never surfaces in our flow.

### `ReservationLocationApprovalState` — child junction (3 values, **1-indexed**)

| Int | Member | Notes |
|---:|---|---|
| `1` | `Unapproved` | **Default for new rows.** Per-location approval has not happened yet. |
| `2` | `Approved` | This specific Location has been approved on the parent reservation. |
| `3` | `Denied` | This specific Location has been denied. |

SQL column default is `1` = `Unapproved`. There is no `0` value.

### `ReservationResourceApprovalState` — child junction (3 values, **1-indexed**)

| Int | Member | Notes |
|---:|---|---|
| `1` | `Unapproved` | **Default for new rows.** |
| `2` | `Approved` | |
| `3` | `Denied` | |

SQL column default is `1` = `Unapproved`. There is no `0` value. Identical shape to the Location enum above.

## Watch out: the false-overlap trap

`Approved = 2` and `Denied = 3` are the same integer in all three enums. That coincidence makes it tempting to assume the enums are unified — they are **not**. If you treat the child enums as if they were the parent's:

- You'll write `WHEN 0 → "Unapproved"` for a child column. Children never produce `0`; that case is dead.
- You'll write `WHEN 4 → "Changes Needed"` (or `5/6/7`) for a child column. Children never produce those; the rendered fallback ("Unknown") will surface only if the data is corrupted, but the case will mislead future readers into thinking the child can hit those states.
- Conversely, you'll write `WHEN 1 → "Approved"` for a child column **off-by-one** vs. the parent. The child's `1` is `Unapproved`, not `Approved`.

A widespread version of this bug lived in our endpoints before we corroborated the enums against BEMA's source. See the historical note in `_code/LavaApplications/RoomManagement/Endpoints/README.md` (convention 22) for the fix that closed the loop.

## SQL idioms that depend on the enum values

These idioms appear throughout `LavaApplications/RoomManagement/Endpoints/*.lava`:

| Idiom | Reading |
|---|---|
| `rl.[ApprovalState] <> 2` (where `rl` is `ReservationLocation`) | "Locked-in approval has not landed" — i.e., excludes child rows that are already approved on a competing reservation, so unapproved + denied rows still occupy the slot. Same for `rr.[ApprovalState] <> 2`. |
| `rl.[ApprovalState] <> 3` (where `rl` is `ReservationLocation`) | "Not denied" — used to filter out child rows the user already declined. **Don't write `NOT IN (3, 7)` here**: `7` is a parent value (`Cancelled`) that does not exist on children. |
| `res.[ApprovalState] IN (1, 2, 4, 5, 6)` (where `res` is `Reservation`) | "Active states that block availability" — every parent state except `Draft (0)`, `Denied (3)`, and `Cancelled (7)`. |
| `r.[ApprovalState] = 0` (where `r` is `Reservation`) | "Is Draft" — the only reservations our Create page is allowed to mutate; non-Draft redirects to `/page/6077`. |
| `r.[ApprovalState] != 0 and r.[ApprovalState] != 4` (where `r` is `Reservation`) | "Not in a state that allows a fresh `Submit`." Submit is only allowed from `Draft (0)` or `ChangesNeeded (4)`. |

When in doubt about whether a comparison targets a parent or a child, look at the table alias: `r`, `res`, `parent` are parent `Reservation`; `rl`, `rr`, `rlc`, `rr2`, `c.ApprovalState` (where the row came from `[_com_bemaservices_RoomManagement_ReservationLocation]` or `_ReservationResource`) are children.

## Default-rendering pattern for child junction rows

Render-side, the canonical case statement for a child row's badge looks like this — three cases, no `0`, no `4-7`:

```lava
{%- case c.ApprovalState -%}
    {%- when 1 -%}<span class="label label-default">Unapproved</span>
    {%- when 2 -%}<span class="label label-success">Approved</span>
    {%- when 3 -%}<span class="label label-danger">Denied</span>
    {%- else -%}<span class="label label-default">Unknown</span>
{%- endcase -%}
```

If you need a "Pending" label for the child, you do **not** have one — the child enum has no `Pending*` member. The parent's `PendingInitialApproval (1)` does not propagate down.
