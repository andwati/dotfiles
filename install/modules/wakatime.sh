install_wakatime() {
  local cfg="$HOME/.wakatime.cfg"

  if grep -q '^api_key' "$cfg" 2>/dev/null; then
    ok "wakatime already configured in $cfg"
    return
  fi

  local key
  read -rsp "Wakatime API key (leave blank to skip): " key
  echo
  if [[ -z "$key" ]]; then
    warn "no key entered, skipping wakatime setup"
    return
  fi

  local fresh=0
  [[ -f "$cfg" ]] || fresh=1

  if [[ -f "$cfg" ]]; then
    grep -v '^api_key' "$cfg" > "${cfg}.tmp" 2>/dev/null || true
    mv "${cfg}.tmp" "$cfg"
    if grep -q '^\[settings\]' "$cfg"; then
      sed -i "/^\[settings\]/a api_key = ${key}" "$cfg"
    else
      { echo "[settings]"; echo "api_key = ${key}"; cat "$cfg"; } > "${cfg}.tmp"
      mv "${cfg}.tmp" "$cfg"
    fi
  else
    printf '[settings]\napi_key = %s\n' "$key" > "$cfg"
  fi

  chmod 600 "$cfg"
  if [[ $fresh -eq 1 ]]; then rollback_push "rm -f '$cfg'"; fi
  ok "wrote $cfg"
}
