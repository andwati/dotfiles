install_docker() {
  if has_cmd docker; then ok "docker already installed"; return; fi
  apt_install ca-certificates curl

  local codename
  codename=$(ubuntu_codename)
  if ! curl -fsSL -o /dev/null "https://download.docker.com/linux/ubuntu/dists/${codename}/Release"; then
    warn "Docker has no repo for '${codename}' yet, falling back to 'noble' (24.04)"
    codename=noble
  fi

  apt_add_repo docker /etc/apt/keyrings/docker.asc \
    https://download.docker.com/linux/ubuntu/gpg \
    "deb [arch=$(deb_arch) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu ${codename} stable"
  apt_install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  sudo usermod -aG docker "$USER"
  rollback_push "sudo gpasswd -d '$USER' docker"
  warn "log out/in (or run 'newgrp docker') for docker group membership to take effect"
}
