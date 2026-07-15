install_vscode() {
  if has_cmd code; then
    ok "vscode already installed"
  else
    apt_add_repo vscode /etc/apt/keyrings/packages.microsoft.gpg \
      https://packages.microsoft.com/keys/microsoft.asc \
      "deb [arch=$(deb_arch) signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main"
    apt_install code
  fi

  _vscode_install_extensions code
  _vscode_mirror_cursor
}

# Installs every extension id listed in vscode/extensions.txt (exported from
# this machine with `code --list-extensions`) into whichever editor binary
# is passed — reused for both `code` and `cursor` since Cursor is a VS Code
# fork that reads the same extension id format.
_vscode_install_extensions() {
  local bin="$1"
  local list="${DOTFILES_DIR:?}/vscode/extensions.txt"
  has_cmd "$bin" || return 0
  [[ -f "$list" ]] || return 0

  local installed
  installed=$("$bin" --list-extensions 2>/dev/null || true)

  local ext
  while IFS= read -r ext; do
    if [[ -z "$ext" || "$ext" == \#* ]]; then continue; fi
    if grep -qxF "$ext" <<< "$installed"; then continue; fi
    log "$bin: installing extension $ext"
    "$bin" --install-extension "$ext" --force >/dev/null 2>&1 || warn "$bin: failed to install $ext"
  done < "$list"
  return 0
}

# Cursor reads ~/.config/Cursor/User/settings.json the same way VS Code
# reads ~/.config/Code/User/settings.json. Symlinking it to the (stowed)
# Code settings keeps both in sync from one source of truth in this repo.
_vscode_mirror_cursor() {
  local src="$HOME/.config/Code/User/settings.json"
  local dest_dir="$HOME/.config/Cursor/User"
  [[ -f "$src" ]] || return 0

  mkdir -p "$dest_dir"
  if [[ ! -e "$dest_dir/settings.json" ]]; then
    ln -sf "$src" "$dest_dir/settings.json"
    ok "mirrored VS Code settings to Cursor"
  fi

  if has_cmd cursor; then _vscode_install_extensions cursor; fi
  return 0
}
