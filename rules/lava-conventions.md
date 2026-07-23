# Lava Coding Conventions

## `{% modifyentity %}` Commands

When writing `{% modifyentity %}` commands (E.g.: `modifygroup`, `modifygroupmember`, `modifyperson`, etc.), follow the three defensive rules below. Full documentation, tested behaviors, and examples are in the `language-lava` skill: `references/Lava-Language.md` > "Modify Entity Command", plus per-entity notes in `references/Lava-ModifyEntity/`.

1. **Separate blocks for separate fields.** Never put properties for mutually exclusive actions in the same `{% modifyentity %}` block. Each action gets its own block, guarded by an external `{% if %}`.

2. **One declaration per property.** Within a single block, each `[[ property ]]` should appear exactly once. Use `{% if %}` to control the *value* between the tags, not whether the declaration exists.

3. **Named return variables.** Always use `return:'modify_DescriptiveName'` on every `{% modifyentity %}` block. Never rely on the default `ModifyResult`. Check the named result directly (e.g., `modify_IsActive.Success == true`).
