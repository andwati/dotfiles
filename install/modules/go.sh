install_go() {
  local latest
  latest=$(curl -fsSL 'https://go.dev/VERSION?m=text' | head -n1)

  if has_cmd go && go version | grep -q "$latest"; then
    ok "go already at $latest"
    return
  fi

  local arch
  case "$(uname -m)" in
    x86_64) arch=amd64 ;;
    aarch64) arch=arm64 ;;
    *) err "unsupported arch $(uname -m)"; return 1 ;;
  esac

  local tarball="/tmp/${latest}.linux-${arch}.tar.gz"
  curl -fsSL "https://go.dev/dl/${latest}.linux-${arch}.tar.gz" -o "$tarball"

  local backup=""
  if [[ -d /usr/local/go ]]; then
    backup="/usr/local/go.bak.$$"
    sudo mv /usr/local/go "$backup"
    rollback_push "sudo rm -rf /usr/local/go; sudo mv '$backup' /usr/local/go"
  else
    rollback_push "sudo rm -rf /usr/local/go"
  fi

  sudo tar -C /usr/local -xzf "$tarball"
  rm -f "$tarball"
  if [[ -n "$backup" ]]; then sudo rm -rf "$backup"; fi

  profile_add 'export PATH="/usr/local/go/bin:$HOME/go/bin:$PATH"'
}
