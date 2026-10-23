# Example session prompt

```text
Read docs/session-prompt.md and execute it for venture <venture>.
```

Keep that sentence constant — it is the marker the plugin looks for. The task
selection happens inside `docs/session-prompt.md`, not in the opening message.

The opening message must contain `docs/session-prompt.md` (or whatever
`promptMarker` you configure), otherwise the session is left alone.
