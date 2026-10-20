#!/usr/bin/env bash
# Symlink this repo's commands, agents and skills into a Claude config dir.
#
#   ./install.sh                 # installs into $CLAUDE_CONFIG_DIR or ~/.claude
#   ./install.sh /path/to/dir    # installs somewhere else (e.g. a project's .claude)
#
# Works on macOS, Linux and Windows (Git Bash or WSL).
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/claude"
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

# Make sure $1 is a folder. A broken symlink there (e.g. an old link to a
# folder that has since moved) is removed first.
ensure_dir() {
  if [ -L "$1" ] && [ ! -e "$1" ]; then
    echo "fix   $1 (removed broken symlink)"
    rm "$1"
  fi
  mkdir -p "$1"
}

echo "Installing soft-factory into $TARGET"

for kind in commands agents; do
  ensure_dir "$TARGET/$kind"
  for f in "$SRC/$kind"/*.md; do
    [ -e "$f" ] || continue
    link "$f" "$TARGET/$kind/$(basename "$f")"
  done
done

ensure_dir "$TARGET/skills"
for d in "$SRC/skills"/*/; do
  [ -d "$d" ] || continue
  d="${d%/}"
  link "$d" "$TARGET/skills/$(basename "$d")"
done

echo "Done: $linked linked, $skipped skipped."
