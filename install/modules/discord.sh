install_discord() {
  if has_cmd discord; then ok "discord already installed"; return; fi
  local deb
  deb=$(mktemp --suffix=.deb)
  curl -fsSL 'https://discord.com/api/download?platform=linux&format=deb' -o "$deb"
  apt_update_once
  sudo apt-get install -y "$deb"
  rm -f "$deb"
  rollback_push "sudo apt-get remove -y discord"
}
