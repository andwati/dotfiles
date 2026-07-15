install_slack() {
  if has_cmd slack; then ok "slack already installed"; return; fi
  apt_add_repo slack /etc/apt/trusted.gpg.d/slack.gpg \
    https://packagecloud.io/slacktechnologies/slack/gpgkey \
    "deb https://packagecloud.io/slacktechnologies/slack/debian/ jessie main"
  apt_install slack-desktop
}
