install_zig() {
  local index latest
  index=$(curl -fsSL https://ziglang.org/download/index.json)
  latest=$(jq -r 'keys[]' <<< "$index" | grep -v '^master$' | sort -V | tail -n1)

  if has_cmd zig && zig version 2>/dev/null | grep -qx "$latest"; then
    ok "zig already at $latest"
  else
    local url tarball extract_dir
    url=$(jq -r --arg v "$latest" '.[$v]["x86_64-linux"].tarball' <<< "$index")
    tarball=$(mktemp --suffix=.tar.xz)
    curl -fsSL "$url" -o "$tarball"

    extract_dir=$(mktemp -d)
    tar -xJf "$tarball" -C "$extract_dir" --strip-components=1
    rm -f "$tarball"

    sudo rm -rf /opt/zig
    track_new_sudo_dir /opt/zig
    sudo mv "$extract_dir" /opt/zig
    sudo ln -sf /opt/zig/zig /usr/local/bin/zig
    rollback_push "sudo rm -f /usr/local/bin/zig"
  fi

  _zig_install_zls
}

# zls (the Zig language server) is versioned against a specific zig build;
# zigtools' own select-version API returns the right zls release for
# whatever zig version is currently installed.
_zig_install_zls() {
  if ! has_cmd zig; then return 0; fi

  local zig_version resp url
  zig_version=$(zig version)
  resp=$(curl -fsSL "https://releases.zigtools.org/v1/zls/select-version?zig_version=${zig_version}&compatibility=only-runtime")
  url=$(jq -r '.["x86_64-linux"].tarball // empty' <<< "$resp" 2>/dev/null)

  if [[ -z "$url" ]]; then
    warn "no matching zls build for zig $zig_version, skipping"
    return 0
  fi

  if [[ -x /opt/zls/zls ]]; then
    local current
    current=$(/opt/zls/zls --version 2>/dev/null || echo "")
    if [[ "$current" == *"$zig_version"* ]]; then
      ok "zls already matches zig $zig_version"
      return 0
    fi
  fi

  local tarball extract_dir
  tarball=$(mktemp --suffix=.tar.xz)
  curl -fsSL "$url" -o "$tarball"
  extract_dir=$(mktemp -d)
  tar -xJf "$tarball" -C "$extract_dir"
  rm -f "$tarball"

  sudo rm -rf /opt/zls
  track_new_sudo_dir /opt/zls
  sudo mv "$extract_dir" /opt/zls
  sudo ln -sf /opt/zls/zls /usr/local/bin/zls
  rollback_push "sudo rm -f /usr/local/bin/zls"
}
