#!/usr/bin/env bash
set -euo pipefail

export DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=install/lib.sh
source "$DOTFILES_DIR/install/lib.sh"

DRY_RUN=0
for a in "$@"; do
  if [[ "$a" == "--dry-run" ]]; then DRY_RUN=1; fi
done
export DRY_RUN

STOW_PACKAGES=(zsh git tmux vscode)

if [[ "$DRY_RUN" == "1" ]]; then
  log "[dry-run] would install base packages: stow zsh curl git"
  log "[dry-run] would stow: ${STOW_PACKAGES[*]} -> \$HOME"
else
  log "installing base packages"
  apt_install stow zsh curl git

  log "stowing dotfiles from $DOTFILES_DIR"
  stow -v -t "$HOME" -d "$DOTFILES_DIR" "${STOW_PACKAGES[@]}"
fi

if [[ "$DRY_RUN" == "1" ]]; then
  log "[dry-run] would prompt for git identity + signing key -> ~/.gitconfig.local"
elif [[ ! -f "$HOME/.gitconfig.local" ]]; then
  read -rp "git user.name: " git_name
  read -rp "git user.email [andwatiian@gmail.com]: " git_email
  git_email="${git_email:-andwatiian@gmail.com}"
  read -rp "git signing key (GPG key id) [1F20FED0AA05B0DA]: " git_signkey
  git_signkey="${git_signkey:-1F20FED0AA05B0DA}"
  {
    echo "[user]"
    echo "    name = $git_name"
    echo "    email = $git_email"
    if [[ -n "$git_signkey" ]]; then echo "    signingkey = $git_signkey"; fi
  } > "$HOME/.gitconfig.local"
  ok "wrote $HOME/.gitconfig.local"
fi

if [[ "$DRY_RUN" == "1" ]]; then
  if [[ "$SHELL" != *zsh* ]]; then log "[dry-run] would set default shell to zsh"; fi
elif [[ "$SHELL" != *zsh* ]]; then
  log "setting zsh as default shell"
  chsh -s "$(command -v zsh)" "$USER"
fi

log "running tool installer"
"$DOTFILES_DIR/install/install.sh" "$@"

ok "all done — open a new shell (or 'exec zsh') to pick up PATH changes"
