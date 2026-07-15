install_signal() {
  if has_cmd signal-desktop; then ok "signal already installed"; return; fi
  apt_add_repo signal-xenial /usr/share/keyrings/signal-desktop-keyring.gpg \
    https://updates.signal.org/desktop/apt/keys.asc \
    "deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main"
  apt_install signal-desktop
}
