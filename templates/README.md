# templates/

The workspace files that the [`/rock-init`](../commands/rock-init.md) command scaffolds from. `{{…}}` placeholders are filled from the init interview (or from an installed church overlay's `workspace-defaults` skill); the HTML comments beside each placeholder hold the drafted variants.

These files double as the **manual** scaffold path: copy them into your workspace by hand and fill the placeholders yourself.

| Template | Becomes |
|---|---|
| `workspace-CLAUDE.md` | `CLAUDE.md` |
| `workspace-docs-README.md` | `docs/README.md` |
| `workspace-instance-facts.md` | `docs/instance-facts.md` |
| `workspace-gitignore` | `.gitignore` |
