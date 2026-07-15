install_cursor() {
  if [[ -x /opt/cursor/cursor.AppImage ]]; then
    ok "cursor already installed"
    return
  fi

  apt_install libfuse2

  local appimage
  appimage=$(mktemp --suffix=.AppImage)
  curl -fsSL https://downloader.cursor.sh/linux/appImage/x64 -o "$appimage"
  chmod +x "$appimage"

  track_new_sudo_dir /opt/cursor
  sudo mkdir -p /opt/cursor
  sudo mv "$appimage" /opt/cursor/cursor.AppImage
  sudo ln -sf /opt/cursor/cursor.AppImage /usr/local/bin/cursor
  rollback_push "sudo rm -f /usr/local/bin/cursor"

  sudo tee /usr/share/applications/cursor.desktop >/dev/null <<'EOF'
[Desktop Entry]
Name=Cursor
Exec=/opt/cursor/cursor.AppImage --no-sandbox %U
Icon=cursor
Terminal=false
Type=Application
Categories=Development;
EOF
  rollback_push "sudo rm -f /usr/share/applications/cursor.desktop"

  # Reuses vscode.sh's mirror step to symlink settings + install the same
  # extensions into the newly-installed Cursor.
  # shellcheck disable=SC1090
  source "${DOTFILES_DIR:?}/install/modules/vscode.sh"
  _vscode_mirror_cursor
}
