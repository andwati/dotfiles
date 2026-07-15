install_postman() {
  if [[ -x /opt/Postman/Postman ]]; then ok "postman already installed"; return; fi

  local tarball
  tarball=$(mktemp --suffix=.tar.gz)
  curl -fsSL https://dl.pstmn.io/download/latest/linux_64 -o "$tarball"
  track_new_sudo_dir /opt/Postman
  sudo tar -xzf "$tarball" -C /opt
  rm -f "$tarball"
  sudo ln -sf /opt/Postman/Postman /usr/local/bin/postman
  rollback_push "sudo rm -f /usr/local/bin/postman /usr/share/applications/postman.desktop"

  sudo tee /usr/share/applications/postman.desktop >/dev/null <<'EOF'
[Desktop Entry]
Name=Postman
Exec=/opt/Postman/Postman %U
Icon=/opt/Postman/app/resources/app/assets/icon.png
Terminal=false
Type=Application
Categories=Development;
EOF
}
