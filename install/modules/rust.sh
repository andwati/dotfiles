install_rust() {
  if has_cmd rustc; then ok "rust already installed"; return; fi
  track_new_dir "$HOME/.cargo"
  track_new_dir "$HOME/.rustup"
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
  profile_add '. "$HOME/.cargo/env"'
}
