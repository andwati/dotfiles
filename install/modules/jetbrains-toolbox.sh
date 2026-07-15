install_jetbrains_toolbox() {
  if [[ -x /opt/jetbrains-toolbox/jetbrains-toolbox ]]; then
    ok "jetbrains toolbox already installed"
    return
  fi

  local url tarball extract_dir
  url=$(curl -fsSL 'https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release' \
    | jq -r '.TBA[0].downloads.linux.link')

  tarball=$(mktemp --suffix=.tar.gz)
  curl -fsSL "$url" -o "$tarball"
  extract_dir=$(mktemp -d)
  tar -xzf "$tarball" -C "$extract_dir" --strip-components=1
  rm -f "$tarball"

  sudo rm -rf /opt/jetbrains-toolbox
  track_new_sudo_dir /opt/jetbrains-toolbox
  sudo mv "$extract_dir" /opt/jetbrains-toolbox
  sudo ln -sf /opt/jetbrains-toolbox/jetbrains-toolbox /usr/local/bin/jetbrains-toolbox
  rollback_push "sudo rm -f /usr/local/bin/jetbrains-toolbox"

  ok "run 'jetbrains-toolbox' once to finish setup; it installs its own desktop entry"
}
