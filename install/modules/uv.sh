install_uv() {
  if has_cmd uv; then ok "uv already installed"; return; fi
  rollback_push "rm -f '$HOME/.local/bin/uv' '$HOME/.local/bin/uvx'"
  curl -LsSf https://astral.sh/uv/install.sh | sh
  profile_add 'export PATH="$HOME/.local/bin:$PATH"'
}
