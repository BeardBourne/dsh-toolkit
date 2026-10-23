# session-autotitle

Renames a DSH session after the agent claims a task, using the task title from
the repository's task board.

With a constant opening prompt, DSH would otherwise generate the same title for
every session (titles come from the first human message, and the agent has no
rename tool).

## What it does

1. Listens on `tools/post-execute`.
2. Matches a bash command containing `tasks:claim <id>` and `--venture <venture>`.
3. Checks the session's **first user message** contains the configured marker
   (default `docs/session-prompt.md`) — so unrelated sessions are never touched.
4. Reads `apps/<venture>/docs/tasks/index.json` and finds the task title.
5. Calls `ctx.sessionTitle.rename(session, "<venture>/<ID> — <title>")`.

It renames at most once per session and swallows every error.

## Config

The profile's `cordis.patch.yml` is a **patch list**: a bare entry only overrides
an entry that already exists. This plugin is new, so it must be added inside an
`insert:` block (the installer does this):

```yaml
- insert:
    - id: session-autotitle
      name: "./plugins/session-autotitle/index.js"
      config:
        repoRoot: "/absolute/path/to/repo"      # required
        promptMarker: "docs/session-prompt.md"  # optional
```

A bare `- id: session-autotitle` in a patch list targets no existing entry, is
skipped by the profile loader, and leaves the plugin unloaded.

Keep unrelated inserts in their own `- insert:` block: the installer rewrites the
block that owns `session-autotitle` when it updates the repo path.

## Verify the install

1. `grep -A6 'insert:' "$HOME/.dsh/profiles/desktop/cordis.patch.yml"` shows the block.
2. Restart DSH after adding the block; a running profile does not pick up a new plugin entry.
3. In a task session, the first user message must contain `docs/session-prompt.md`,
   and the claim command must exit 0.
4. The session title becomes `<venture>/<ID> — <task title>`. The title is cosmetic;
   the task board remains the source of truth.

If the title does not change, check the block is an `insert:` (not a bare `- id:`),
that the claim succeeded, and that `repoRoot` points at the checkout containing
`apps/<venture>/docs/tasks/index.json`.

## Contract

See [../../docs/contract.md](../../docs/contract.md).
