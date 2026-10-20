#!/usr/bin/env bash
# Symlink this repo's commands, agents and skills into a Claude config dir.
#
#   ./install.sh                 # installs into $CLAUDE_CONFIG_DIR or ~/.claude
#   ./install.sh /path/to/dir    # installs somewhere else (e.g. a project's .claude)
#
# Works on macOS, Linux and Windows (Git Bash or WSL).
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${1:-${CLAUDE_CONFIG_DIR:-$HOME/.claude}}"

# Git Bash copies files on `ln -s` by default. Ask for real symlinks and fail
# loudly if Windows won't allow them.
case "$(uname -s)" in
  MINGW*|MSYS*|CYGWIN*) export MSYS=winsymlinks:nativestrict ;;
esac

linked=0
skipped=0

link() {
  local src="$1" dest="$2"

  if [ -L "$dest" ]; then
    rm "$dest"                       # our old link, or a stale one: replace it
  elif [ -e "$dest" ]; then
    echo "skip  $dest (already exists and is not a symlink)"
    skipped=$((skipped + 1))
    return
  fi

  if ! ln -s "$src" "$dest" 2>/dev/null; then
    echo "error: could not create symlink $dest" >&2
    echo "On Windows, turn on Developer Mode (Settings > System > For developers)" >&2
    echo "or run this from an Administrator terminal." >&2
    exit 1
  fi
  echo "link  $dest"
  linked=$((linked + 1))
}

echo "Installing soft-factory into $TARGET"

for kind in commands agents; do
  mkdir -p "$TARGET/$kind"
  for f in "$REPO/$kind"/*.md; do
    [ -e "$f" ] || continue
    link "$f" "$TARGET/$kind/$(basename "$f")"
  done
done

mkdir -p "$TARGET/skills"
for d in "$REPO/skills"/*/; do
  [ -d "$d" ] || continue
  d="${d%/}"
  link "$d" "$TARGET/skills/$(basename "$d")"
done

echo "Done: $linked linked, $skipped skipped."
