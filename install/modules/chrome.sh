install_chrome() {
  if has_cmd google-chrome-stable; then
    ok "chrome already installed"
    return
  fi

  local deb
  deb=$(mktemp --suffix=.deb)
  curl -fsSL https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -o "$deb"
  apt_update_once
  sudo apt-get install -y "$deb"
  rm -f "$deb"
  rollback_push "sudo apt-get remove -y google-chrome-stable"
}
