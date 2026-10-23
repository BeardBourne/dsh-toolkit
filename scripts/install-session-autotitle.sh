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
import sys
path, repo_root = sys.argv[1], sys.argv[2]
text = open(path).read()
if "session-autotitle" in text:
    print("entry already present; plugin files updated")
else:
    if not text.endswith("\n"):
        text += "\n"
    text += (
        "- id: session-autotitle\n"
        '  name: "./plugins/session-autotitle/index.js"\n'
        "  config:\n"
        f'    repoRoot: "{repo_root}"\n'
        '    promptMarker: "docs/session-prompt.md"\n'
    )
    open(path, "w").write(text)
    print("entry added")
PY

echo "installed into $profile"
echo "restart DSH once if the title does not change after the next claim"
