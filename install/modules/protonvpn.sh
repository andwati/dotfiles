install_protonvpn() {
  if dpkg -s proton-vpn-gnome-desktop >/dev/null 2>&1; then
    ok "protonvpn already installed"
    return
  fi

  local list_url deb_name deb
  list_url="https://repo.protonvpn.com/debian/dists/stable/main/binary-all/"
  deb_name=$(curl -fsSL "$list_url" | grep -oE 'protonvpn-stable-release_[0-9.]+_all\.deb' | sort -V | tail -n1)

  if [[ -z "$deb_name" ]]; then
    err "could not find the protonvpn-stable-release package on repo.protonvpn.com"
    return 1
  fi

  deb=$(mktemp --suffix=.deb)
  curl -fsSL "${list_url}${deb_name}" -o "$deb"
  apt_update_once
  sudo apt-get install -y "$deb"
  rm -f "$deb"
  rollback_push "sudo apt-get remove -y protonvpn-stable-release"

  apt_invalidate
  apt_install proton-vpn-gnome-desktop
}
