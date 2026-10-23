#!/usr/bin/env bash
# Install the session-autotitle plugin into the current DSH profile.
# Usage: ./scripts/install-session-autotitle.sh /absolute/path/to/your/repo
set -euo pipefail

repo_root="${1:?usage: install-session-autotitle.sh <absolute path to repo>}"
[ -d "$repo_root" ] || { echo "not a directory: $repo_root" >&2; exit 1; }
repo_root="$(cd "$repo_root" && pwd)"

profile="${DSH_PROFILE_DIR:-$HOME/.dsh/profiles/desktop}"
[ -f "$profile/cordis.patch.yml" ] || { echo "no profile at $profile" >&2; exit 1; }

here="$(cd "$(dirname "$0")" && pwd)"
dest="$profile/plugins/session-autotitle"
mkdir -p "$dest"
cp "$here/../plugins/session-autotitle/index.js" "$here/../plugins/session-autotitle/package.json" "$dest/"

cp "$profile/cordis.patch.yml" "$profile/cordis.patch.yml.bak-session-autotitle"

python3 - "$profile/cordis.patch.yml" "$repo_root" <<'PY'
import json
import sys

path, repo_root = sys.argv[1], sys.argv[2]
with open(path, encoding="utf-8") as handle:
    text = handle.read()

# A patch list replaces fields on an entry that already exists. A new plugin
# therefore needs an `insert:` block; a bare `- id:` entry targets nothing and
# is skipped by the profile loader. The first installer wrote the bare form,
# so this one also removes that old entry.
insert_block = (
    "- insert:\n"
    "    - id: session-autotitle\n"
    '      name: "./plugins/session-autotitle/index.js"\n'
    "      config:\n"
    f"        repoRoot: {json.dumps(repo_root)}\n"
    '        promptMarker: "docs/session-prompt.md"\n'
)


def without_owned_entry(source):
    lines = source.splitlines(keepends=True)
    kept = []
    removed = 0
    index = 0
    while index < len(lines):
        line = lines[index]
        if line.startswith("- id: session-autotitle"):
            removed += 1
            index += 1
            while index < len(lines) and not lines[index].startswith("- "):
                index += 1
            continue
        if line.startswith("- insert:"):
            block_end = index + 1
            while block_end < len(lines) and not lines[block_end].startswith("- "):
                block_end += 1
            block = lines[index:block_end]
            if any(
                candidate.lstrip().startswith("- id: session-autotitle")
                for candidate in block[1:]
            ):
                # The installer owns this block; unrelated inserts belong in
                # their own block so this rewrite cannot take them with it.
                removed += 1
                index = block_end
                continue
        kept.append(line)
        index += 1
    return "".join(kept), removed


text, removed = without_owned_entry(text)
if not text.endswith("\n"):
    text += "\n"
if not text.endswith("\n\n"):
    text += "\n"
text += insert_block

with open(path, "w", encoding="utf-8") as handle:
    handle.write(text)

print(f"profile patch updated ({removed} old session-autotitle entry block(s) removed)")
PY

echo "installed into $profile"
echo "restart DSH once; the next task session should rename itself after the claim"
