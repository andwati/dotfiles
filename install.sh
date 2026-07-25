#!/usr/bin/env bash
# Bootstraps dotfiles on a new machine: installs oh-my-zsh + the custom
# theme/plugins .zshrc expects, then symlinks packages into $HOME via
# GNU Stow (each top-level dir is a package mirroring $HOME, e.g.
# zsh/.zshrc -> ~/.zshrc). Add a new package by adding a new top-level dir.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

command -v stow >/dev/null || {
  echo "GNU Stow is required: sudo pacman -S stow (or your distro's equivalent)" >&2
  exit 1
}

clone_if_missing() {
  local url="$1" dst="$2"
  [ -d "$dst" ] || git clone --depth=1 "$url" "$dst"
}

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing oh-my-zsh..."
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

clone_if_missing https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
clone_if_missing https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
clone_if_missing https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
clone_if_missing https://github.com/zsh-users/zsh-history-substring-search "$ZSH_CUSTOM/plugins/zsh-history-substring-search"
clone_if_missing https://github.com/zsh-users/zsh-completions "$ZSH_CUSTOM/plugins/zsh-completions"
clone_if_missing https://github.com/MichaelAquilina/zsh-you-should-use "$ZSH_CUSTOM/plugins/you-should-use"

# Stow refuses to link over a real (non-symlink) file, so move any
# conflicting pre-existing file aside first (e.g. the .zshrc oh-my-zsh's
# own installer just wrote above).
stow_package() {
  local pkg="$1" f rel target
  while IFS= read -r -d '' f; do
    rel="${f#"$DOTFILES_DIR/$pkg/"}"
    target="$HOME/$rel"
    if [ -L "$target" ]; then
      rm "$target"
    elif [ -e "$target" ]; then
      mkdir -p "$(dirname "$target")"
      mv "$target" "$target.bak.$(date +%s)"
      echo "Backed up existing $target"
    fi
  done < <(find "$DOTFILES_DIR/$pkg" -type f -print0)
  stow --dir="$DOTFILES_DIR" --target="$HOME" --restow "$pkg"
  echo "Stowed $pkg"
}

mkdir -p "$HOME/.gnupg" && chmod 700 "$HOME/.gnupg"

stow_package zsh
stow_package gnupg
gpgconf --kill gpg-agent 2>/dev/null || true

cat <<'EOF'

Done. This does NOT install (grab these separately if missing):
  - nvm, pyenv, bun, pnpm, deno, rustup, docker, fzf, zoxide
  - a Nerd Font (JetBrains Mono Nerd Font) — set it as your terminal's font

Start a new shell to pick everything up: exec zsh
EOF
