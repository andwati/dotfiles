install_poetry() {
  if has_cmd poetry; then ok "poetry already installed"; return; fi
  track_new_dir "$HOME/.local/share/pypoetry"
  rollback_push "rm -f '$HOME/.local/bin/poetry'"
  curl -sSL https://install.python-poetry.org | python3 -
  profile_add 'export PATH="$HOME/.local/bin:$PATH"'
}
