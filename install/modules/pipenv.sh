install_pipenv() {
  if ! has_cmd pipx; then
    err "pipx not found; run the pipx module first"
    return 1
  fi
  if pipx list --short 2>/dev/null | grep -q '^pipenv '; then
    ok "pipenv already installed"
    return
  fi
  pipx install pipenv
  rollback_push "pipx uninstall pipenv"
}
