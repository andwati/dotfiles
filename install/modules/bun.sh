install_bun() {
  if has_cmd bun; then ok "bun already installed"; return; fi
  track_new_dir "$HOME/.bun"
  NO_MODIFY_PATH=1 bash -c "$(curl -fsSL https://bun.sh/install)"
  profile_add 'export BUN_INSTALL="$HOME/.bun"'
  profile_add 'export PATH="$BUN_INSTALL/bin:$PATH"'
}
