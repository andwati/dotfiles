install_deno() {
  if has_cmd deno; then ok "deno already installed"; return; fi
  track_new_dir "$HOME/.deno"
  curl -fsSL https://deno.land/install.sh | sh
  profile_add 'export DENO_INSTALL="$HOME/.deno"'
  profile_add 'export PATH="$DENO_INSTALL/bin:$PATH"'
}
