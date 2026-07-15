install_pnpm() {
  if has_cmd pnpm; then ok "pnpm already installed"; return; fi
  track_new_dir "$HOME/.local/share/pnpm"
  curl -fsSL https://get.pnpm.io/install.sh | sh -
  profile_add 'export PNPM_HOME="$HOME/.local/share/pnpm"'
  profile_add 'case ":$PATH:" in *":$PNPM_HOME:"*) ;; *) export PATH="$PNPM_HOME:$PATH" ;; esac'
}
