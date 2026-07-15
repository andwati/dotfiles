install_gnome() {
  if ! has_cmd gnome-shell; then
    warn "gnome-shell not found; skipping (not running GNOME?)"
    return
  fi

  apt_install gnome-tweaks gnome-shell-extension-manager dconf-editor \
    gnome-shell-extension-appindicator

  if has_cmd gnome-extensions; then
    gnome-extensions enable appindicatorsupport@rgcjonas.gmail.com 2>/dev/null || true
  fi

  ok "log out/in for the AppIndicator extension to take full effect (tray icons for Discord/Slack/Signal etc.)"
}
