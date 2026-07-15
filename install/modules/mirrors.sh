install_mirrors() {
  local codename
  codename=$(ubuntu_codename)

  local candidates
  candidates=$(curl -fsSL --max-time 5 https://mirrors.ubuntu.com/mirrors.txt) || {
    err "could not fetch the official Ubuntu mirror list"
    return 1
  }

  log "benchmarking mirrors for speed + freshness (this takes a few seconds)"

  local best_url="" best_time="" url resp t last_modified age_hours checked=0
  while IFS= read -r url; do
    if [[ -z "$url" || "$url" == \#* ]]; then continue; fi
    if [[ $checked -ge 12 ]]; then break; fi
    checked=$((checked + 1))

    resp=$(curl -o /dev/null -sD - --max-time 3 -w '\n%{time_total}' "${url}dists/${codename}/Release" 2>/dev/null) || continue
    if [[ -z "$resp" ]]; then continue; fi

    t=$(tail -n1 <<< "$resp")
    if [[ -z "$t" ]]; then continue; fi

    last_modified=$(grep -i '^Last-Modified:' <<< "$resp" | head -n1 | cut -d' ' -f2- | tr -d '\r')
    if [[ -n "$last_modified" ]]; then
      age_hours=$(( ($(date +%s) - $(date -d "$last_modified" +%s 2>/dev/null || echo 0)) / 3600 ))
      if [[ $age_hours -gt 72 ]]; then continue; fi
    fi

    if [[ -z "$best_time" ]] || awk -v a="$t" -v b="$best_time" 'BEGIN{exit !(a<b)}'; then
      best_time="$t"
      best_url="$url"
    fi
  done <<< "$candidates"

  if [[ -z "$best_url" ]]; then
    warn "no mirror passed the speed/freshness check, leaving apt sources untouched"
    return 0
  fi

  ok "fastest fresh mirror: $best_url (${best_time}s)"
  _mirrors_apply "$best_url"
}

# Rewrites whichever apt sources format is in use to point at the chosen
# mirror. Ubuntu 24.04+ (and 26.04) default to the deb822
# /etc/apt/sources.list.d/ubuntu.sources file; older installs still use the
# one-line-per-entry /etc/apt/sources.list. security.ubuntu.com is left
# alone on purpose — security updates stay on Canonical's own CDN.
_mirrors_apply() {
  local mirror="${1%/}"
  local deb822="/etc/apt/sources.list.d/ubuntu.sources"
  local legacy="/etc/apt/sources.list"
  local target="" backup=""

  if [[ -f "$deb822" ]]; then
    target="$deb822"
  elif [[ -f "$legacy" ]] && grep -q archive.ubuntu.com "$legacy"; then
    target="$legacy"
  else
    warn "no recognized apt sources file found, skipping"
    return 0
  fi

  backup="${target}.bak.$$"
  sudo cp "$target" "$backup"
  rollback_push "sudo mv '$backup' '$target'; apt_invalidate"
  sudo sed -i -E "s#https?://[a-zA-Z0-9.-]*archive\.ubuntu\.com/ubuntu#${mirror}#g" "$target"

  apt_invalidate
  if ! apt_update_once; then
    err "apt update failed against $mirror"
    return 1
  fi

  sudo rm -f "$backup"
  ok "apt now points at $mirror"
}
