install_telegram() {
  if [[ -x /opt/Telegram/Telegram ]]; then ok "telegram already installed"; return; fi

  local tarball
  tarball=$(mktemp --suffix=.tar.xz)
  curl -fsSL https://telegram.org/dl/desktop/linux -o "$tarball"
  track_new_sudo_dir /opt/Telegram
  sudo tar -xJf "$tarball" -C /opt
  rm -f "$tarball"
  sudo ln -sf /opt/Telegram/Telegram /usr/local/bin/telegram
  rollback_push "sudo rm -f /usr/local/bin/telegram /usr/share/applications/telegram.desktop"

  sudo tee /usr/share/applications/telegram.desktop >/dev/null <<'EOF'
[Desktop Entry]
Name=Telegram
Exec=/opt/Telegram/Telegram -- %u
Icon=/opt/Telegram/telegram.svg
Terminal=false
Type=Application
Categories=Network;InstantMessaging;
MimeType=x-scheme-handler/tg;
EOF
}
