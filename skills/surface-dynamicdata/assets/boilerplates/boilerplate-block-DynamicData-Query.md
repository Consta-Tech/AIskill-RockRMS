# Boilerplate Template — Dynamic Data Query

Applies to `-Query.lava.sql` files under `_code/Block-DynamicData/PageId_*/`.

## Structure rules

The boilerplate is a **SQL** block comment (`/* … */`) at the top of the file — not a Lava comment. A Lava comment is stripped before the query reaches SQL Server, and this header should survive into the text you paste into your SQL client when debugging the query outside of Rock. See the house rules (about-documentation) > "Choosing the comment syntax in a `.lava.sql` file".

Every field below is on its own line, indented 4 spaces from the comment boundary. Field labels use Title Case followed by a colon.

### Required fields (in this order)

1. **Path** — the file's path relative to the repo root. Always present, always first.
2. **PageParameters consumed** — a bulleted list of the parameters this query reads, one per bullet, formatted as `{key} ({FieldType}): {what it filters}`. Name the Rock field type, because the field type determines the shape of the value — a Date Range field yields `start,end` and is split, whereas a Sliding Date Range field yields a slider expression and must go through `DateRangeFromSlidingFormat`. If the query reads no parameters, a single bullet that says `- none`.
3. **Hardcoded Ids** — a bulleted list of every literal Id, GroupTypeId, DefinedValueId, AttributeId, or date window baked into the query, formatted as `{value}: {what it means}`. If there are none, a single bullet that says `- none`.
4. **Description** — *optional*. One paragraph, present tense, describing what the Grid returns. Maximum ~5 lines. Omit it when the directory README already answers "what question does this page answer" and the query adds nothing to that.

There is deliberately **no "Enabled Lava Commands" field.** Older Dynamic Data blocks had no such setting, and the query's Lava layer should not need one — it reads PageParameters and shapes them into SQL literals. If yours genuinely needs a command, note it inline at the point of use.

### Heuristics

- The Hardcoded Ids field is the one that earns its keep. A `GroupTypeId = 221` is unreadable a year later, and a baked-in `'2026-01-01'` date window is a live bug waiting for January. Listing them here does not excuse commenting them at the point of use — see the house rules (formatting-standards) > "A hardcoded Id either gets hoisted, or gets a comment."
- If a parameter is read but only used inside a Lava `{% if %}` that gates a filter, say so in its bullet — it changes whether an empty parameter means "no filter" or "no rows".
- The boilerplate should aim to be 121 characters wide.
  - In other words, the comment block opens with `/*` followed by asterisks to column 121, and closes with asterisks followed by `*/` at the same width.
  - Technically it can be as wide as 147 characters. Be flexible between 121 and 147 where it benefits the prose, but never exceed 147.
- Target length: **≤ 20 lines** between the opening and closing comment boundaries.
- Do not restate the query's algorithm here. The stage comments inside the query carry that, and they are maintained next to the code they describe.

## Example

```sql
/************************************************************************************************************************

    Path:
    _code/Block-DynamicData/PageId_6180/BlockId_15034-Query.lava.sql

    PageParameters consumed:
    - c1 (Campus): filters to Attendees whose PrimaryCampus is this Campus; no filter when empty
    - c2 (Campus): filters to Attendance records recorded at this Campus; no filter when empty
    - daterange (Date Range): bounds the Attendance window; each side is optional and filters independently

    Hardcoded Ids:
    - GroupTypeId 221: the GroupType that VBS Participant Groups are built from
    - 2026-01-01 / 2027-01-01: the VBS season being reported on

    Description:
    Returns one row per VBS Attendee with their membership Campus, the Campus where they attended VBS, and the number
    of distinct days they attended.

************************************************************************************************************************/
```
