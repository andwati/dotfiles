install_ghcli() {
  if has_cmd gh; then ok "gh already installed"; return; fi
  apt_add_repo github-cli /etc/apt/keyrings/githubcli-archive-keyring.gpg \
    https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    "deb [arch=$(deb_arch) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main"
  apt_install gh
}
