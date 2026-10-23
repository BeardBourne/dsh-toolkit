# Contract: task board and prompt marker

`session-autotitle` is deliberately dumb. It depends on three conventions, all
of which live in your repository, not in the plugin.

## 1. A prompt marker

The session's **first user message** must contain `promptMarker`
(default `docs/session-prompt.md`). This is how the plugin distinguishes a
task session from every other conversation.

Example opening message:

```text
Read docs/session-prompt.md and execute it for venture re-invest.
```

Any other session — debugging, research, chatting — is left untouched.

## 2. A claim command

The agent must run a bash command containing:

```text
tasks:claim <id> --venture <venture>
```

The plugin reads the id and venture from that command.

## 3. A task board

`<repoRoot>/apps/<venture>/docs/tasks/index.json`:

```json
{
  "tasks": [
    { "id": "A3", "title": "Engine tax, cash flow, IRR", "status": "todo" }
  ]
}
```

The session title becomes `<venture>/<ID> — <title>`, truncated to 72 chars.

## Why these seams

- They are stable, plain files and command strings — no DSH internals beyond
  the two hooks the plugin uses.
- They fail silently: a missing board or a mismatched marker simply means no
  rename, never a broken tool call.
