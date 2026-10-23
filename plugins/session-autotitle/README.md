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

```yaml
- id: session-autotitle
  name: "./plugins/session-autotitle/index.js"
  config:
    repoRoot: "/absolute/path/to/repo"      # required
    promptMarker: "docs/session-prompt.md"  # optional
```

## Contract

See [../../docs/contract.md](../../docs/contract.md).
