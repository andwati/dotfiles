install_onedrive() {
  if has_cmd onedrive; then
    ok "onedrive already installed"
    return
  fi

  local version repo_base
  version=$(. /etc/os-release; echo "$VERSION_ID")
  repo_base="https://download.opensuse.org/repositories/home:/npreining:/debian-ubuntu-onedrive/xUbuntu_${version}"

  if ! curl -fsSL -o /dev/null "${repo_base}/Release"; then
    warn "onedrive's OBS repo has no build for Ubuntu ${version} yet, falling back to 24.04"
    version="24.04"
    repo_base="https://download.opensuse.org/repositories/home:/npreining:/debian-ubuntu-onedrive/xUbuntu_${version}"
  fi

  apt_add_repo onedrive /etc/apt/keyrings/onedrive.gpg \
    "${repo_base}/Release.key" \
    "deb ${repo_base}/ ./"
  apt_install onedrive
}
