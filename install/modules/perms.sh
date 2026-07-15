install_perms() {
  if [[ -d "$HOME/.ssh" ]]; then
    chmod 700 "$HOME/.ssh"
    find "$HOME/.ssh" -maxdepth 1 -type f ! -name '*.pub' -exec chmod 600 {} +
    find "$HOME/.ssh" -maxdepth 1 -type f -name '*.pub' -exec chmod 644 {} +
    if [[ -f "$HOME/.ssh/config" ]]; then chmod 600 "$HOME/.ssh/config"; fi
    if [[ -f "$HOME/.ssh/authorized_keys" ]]; then chmod 600 "$HOME/.ssh/authorized_keys"; fi
    if [[ -f "$HOME/.ssh/known_hosts" ]]; then chmod 644 "$HOME/.ssh/known_hosts"; fi
    ok "fixed ~/.ssh permissions"
  else
    warn "~/.ssh not found, skipping"
  fi

  if [[ -d "$HOME/.gnupg" ]]; then
    chmod 700 "$HOME/.gnupg"
    find "$HOME/.gnupg" -type d -exec chmod 700 {} +
    find "$HOME/.gnupg" -type f -exec chmod 600 {} +
    ok "fixed ~/.gnupg permissions"
  else
    warn "~/.gnupg not found, skipping"
  fi
}
