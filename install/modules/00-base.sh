install_00_base() {
  if ! grep -qi ubuntu /etc/os-release 2>/dev/null; then
    warn "this installer targets Ubuntu; continuing anyway"
  fi
  apt_install \
    curl wget git ca-certificates gnupg lsb-release jq \
    software-properties-common apt-transport-https \
    build-essential unzip xz-utils stow
}
