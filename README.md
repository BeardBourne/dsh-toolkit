# dsh-toolkit

Small tools and profile plugins for **DeepSeek Harness (DSH)** — the self-made
pieces that make long-running, multi-session agent work bearable.

Each tool is independent, documented, and installs into a DSH profile rather
than the app bundle, so it survives app updates (until the internal API changes).

## Tools

| Tool | What it does |
|---|---|
| [session-autotitle](plugins/session-autotitle/README.md) | Renames a session to `<venture>/<ID> — <task title>` after the agent claims a task, so every session is identifiable without typing a title |

## Install

```zsh
git clone https://github.com/BeardBourne/dsh-toolkit.git
cd dsh-toolkit
./scripts/install-session-autotitle.sh /absolute/path/to/your/repo
```

Restart DSH after the first install; later changes reload with the profile.

## Design notes

- Plugins live in `$HOME/.dsh/profiles/<profile>/plugins/` and are referenced by
  a relative path from `cordis.patch.yml`.
- They hook documented-in-practice seams (`tools/post-execute`,
  `ctx.sessionTitle.rename`) and must never throw into the tool path.
- Everything is opt-in through config: a repo path, a prompt marker, a title
  format.

## License

MIT
