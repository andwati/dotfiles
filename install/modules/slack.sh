install_slack() {
  if flatpak list --app 2>/dev/null | grep -q com.slack.Slack; then
    ok "slack already installed"
    return
  fi

  ensure_flatpak
  sudo flatpak install -y flathub com.slack.Slack
  rollback_push "sudo flatpak uninstall -y com.slack.Slack"
}
