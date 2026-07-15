install_spotify() {
  if has_cmd spotify; then ok "spotify already installed"; return; fi
  apt_add_repo spotify /etc/apt/trusted.gpg.d/spotify.gpg \
    https://download.spotify.com/debian/pubkey_6224F9941A8AA6D1.gpg \
    "deb http://repository.spotify.com stable non-free"
  apt_install spotify-client
}
