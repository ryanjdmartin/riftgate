#!/bin/bash
# The cloud session's start (27 October): Godot 4.8-beta2 into ~/bin (the project runs it for its
# MSAA fix until 4.8 ships, 30 October) and the project's first import, so the tests, the runners
# and the screenshots run as the README writes them from the first command. Runs only in a Claude
# Code cloud session (the desk machine has its own Godot); idempotent, so a resumed session costs
# nothing; the container's state is cached once it has run. The import rewrites four Prairie Dog
# textures and the maker's review tiles (the status's cloud note): they are restored when they
# were clean before it.
set -euo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

VERSION="4.8-beta2"
BIN="$HOME/bin/godot"
ASSET="Godot_v${VERSION}_linux.x86_64"

mkdir -p "$HOME/bin"
if ! "$BIN" --version 2>/dev/null | grep -q "^4\.8\.beta2\."; then
  tmp="$(mktemp -d)"
  curl -sSL --retry 3 --max-time 900 -o "$tmp/godot.zip" \
    "https://github.com/godotengine/godot-builds/releases/download/${VERSION}/${ASSET}.zip"
  unzip -o -q "$tmp/godot.zip" -d "$tmp"
  mv -f "$tmp/$ASSET" "$BIN"
  chmod +x "$BIN"
  rm -rf "$tmp"
  echo "godot $("$BIN" --version) installed at $BIN"
fi

# `godot` on the path for the session, as every command in CLAUDE.md and the README writes it.
if [ -n "${CLAUDE_ENV_FILE:-}" ]; then
  echo 'export PATH="$HOME/bin:$PATH"' >> "$CLAUDE_ENV_FILE"
fi

# The first import of a fresh checkout (CLAUDE.md: the first run, and after adding PNGs or a
# class_name), under the watchdog every headless run wears, since a script that errors before
# quit() hangs forever. A checkout that already carries .godot is left as it is.
PROJECT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"
cd "$PROJECT"
if [ ! -d .godot ]; then
  touched="art/models/prairie_dog_* tools/lowforge/tiles/"
  # shellcheck disable=SC2086
  dirty="$(git status --porcelain -- $touched 2>/dev/null || true)"
  perl -e 'alarm 600; exec @ARGV' "$BIN" --headless --path . --import > /dev/null 2>&1 || true
  if [ -z "$dirty" ]; then
    # shellcheck disable=SC2086
    git checkout -- $touched 2>/dev/null || true
  fi
  echo "project imported ($(ls .godot 2>/dev/null | wc -l) entries in .godot)"
fi
