install_pipx() {
  apt_install pipx
  profile_add 'export PATH="$HOME/.local/bin:$PATH"'
}
