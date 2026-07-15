install_firefox() {
  if [[ -f /etc/apt/preferences.d/mozilla ]]; then
    ok "firefox (deb) already installed"
    return
  fi

  log "removing snap firefox / transitional apt stub in favor of Mozilla's official apt repo"
  sudo apt-get remove -y firefox 2>/dev/null || true
  sudo snap remove firefox 2>/dev/null || true

  apt_add_repo mozilla /etc/apt/keyrings/packages.mozilla.org.asc \
    https://packages.mozilla.org/apt/repo-signing-key.gpg \
    "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main"

  printf 'Package: *\nPin: origin packages.mozilla.org\nPin-Priority: 1000\n' \
    | sudo tee /etc/apt/preferences.d/mozilla >/dev/null
  rollback_push "sudo rm -f /etc/apt/preferences.d/mozilla"

  apt_install firefox
}
