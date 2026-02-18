#!/bin/bash
set -e

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

link() {
  local src="$DOTFILES/$1"
  local dst="$HOME/$1"

  mkdir -p "$(dirname "$dst")"

  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    echo "  ok  $dst"
    return
  fi

  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    mv "$dst" "$dst.bak"
    echo "  bak $dst → $dst.bak"
  fi

  ln -sf "$src" "$dst"
  echo "  ln  $dst → $src"
}

echo "Installing dotfiles..."
link .claude/CLAUDE.md
link .claude/settings.json
link .claude/hooks
echo "Done."
