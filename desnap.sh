#!/usr/bin/env bash
set -euo pipefail

export DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=install/lib.sh
source "$DOTFILES_DIR/install/lib.sh"

DRY_RUN=0
ASSUME_YES=0
for a in "$@"; do
  case "$a" in
    --dry-run) DRY_RUN=1 ;;
    -y|--yes) ASSUME_YES=1 ;;
  esac
done

if ! has_cmd snap; then
  ok "snapd not installed, nothing to do"
  exit 0
fi

mapfile -t snaps < <(snap list 2>/dev/null | awk 'NR>1 {print $1}')

if [[ ${#snaps[@]} -eq 0 ]]; then
  log "no snaps installed"
else
  log "snaps currently installed: ${snaps[*]}"
fi

# snapd's own bundled core/bare snaps can't be removed while anything else
# depends on them, so they're removed last, in their own pass, below.
core_snaps=(snapd core core18 core20 core22 core24 bare)

# Known default-Ubuntu snaps mapped to their real, official-source
# replacement: an existing dotfiles module (reused so it stays one source of
# truth), a plain apt package, or "skip" for snap-only infra with no
# user-facing equivalent. Anything not listed here that isn't a GNOME/core
# runtime snap falls back to Flatpak/Flathub instead of a guessed package.
declare -A SNAP_REPLACEMENTS=(
  [firefox]="module:firefox"
  [thunderbird]="apt:thunderbird"
  [snap-store]="apt:gnome-software"
  [snapd-desktop-integration]="skip"
  [gtk-common-themes]="skip"
)

_replacement_for() {
  local snap="$1"
  if [[ -n "${SNAP_REPLACEMENTS[$snap]:-}" ]]; then
    echo "${SNAP_REPLACEMENTS[$snap]}"
    return
  fi
  case "$snap" in
    gnome-*|core*|bare) echo "skip" ;;
    *) echo "unmapped" ;;
  esac
}

declare -a to_remove=() modules_to_run=() apt_pkgs=() unmapped=()
for s in "${snaps[@]}"; do
  case " ${core_snaps[*]} " in *" $s "*) continue ;; esac
  to_remove+=("$s")

  action=$(_replacement_for "$s")
  case "$action" in
    module:*) modules_to_run+=("${action#module:}") ;;
    apt:*) apt_pkgs+=("${action#apt:}") ;;
    skip) : ;;
    unmapped) unmapped+=("$s") ;;
  esac
done

if [[ "$DRY_RUN" == "1" ]]; then
  log "[dry-run] would remove: ${to_remove[*]:-<none>} (plus core/base snaps)"
  log "[dry-run] would purge snapd and pin /etc/apt/preferences.d/nosnap.pref"
  if [[ ${#modules_to_run[@]} -gt 0 ]]; then
    log "[dry-run] would reinstall via existing modules: ${modules_to_run[*]}"
  fi
  if [[ ${#apt_pkgs[@]} -gt 0 ]]; then
    log "[dry-run] would reinstall via apt: ${apt_pkgs[*]}"
  fi
  if [[ ${#unmapped[@]} -gt 0 ]]; then
    log "[dry-run] no apt equivalent for: ${unmapped[*]} — would set up Flatpak/Flathub instead"
  fi
  exit 0
fi

if [[ "$ASSUME_YES" != "1" ]]; then
  warn "this removes ALL snap packages, purges snapd, and blocks it from ever being reinstalled by apt."
  read -rp "continue? [y/N] " reply
  [[ "$reply" =~ ^[Yy]$ ]] || { log "aborted"; exit 1; }
fi

for s in "${to_remove[@]}"; do
  log "removing snap: $s"
  sudo snap remove --purge "$s" || warn "failed to remove $s, continuing"
done
for s in "${core_snaps[@]}"; do
  if snap list "$s" >/dev/null 2>&1; then
    log "removing snap: $s"
    sudo snap remove --purge "$s" || true
  fi
done

log "purging snapd"
sudo apt-get purge -y snapd
sudo rm -rf /var/cache/snapd/ "$HOME/snap"

log "pinning snapd out of apt so it can't come back on upgrade"
sudo tee /etc/apt/preferences.d/nosnap.pref >/dev/null <<'EOF'
Package: snapd
Pin: release a=*
Pin-Priority: -10
EOF

for m in "${modules_to_run[@]}"; do
  log "installing $m from its official source (snap replacement)"
  # shellcheck disable=SC1090
  source "$DOTFILES_DIR/install/modules/$m.sh"
  "install_${m//-/_}"
done

if [[ ${#apt_pkgs[@]} -gt 0 ]]; then
  log "installing apt replacements: ${apt_pkgs[*]}"
  apt_install "${apt_pkgs[@]}"
fi

if [[ ${#unmapped[@]} -gt 0 ]]; then
  warn "no apt equivalent known for: ${unmapped[*]} — setting up Flatpak/Flathub so you can still get them"
  apt_install flatpak
  if has_cmd gnome-shell; then
    apt_install gnome-software-plugin-flatpak
  fi
  sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  warn "search/install with: flatpak search <name>   &&   flatpak install flathub <app-id>"
  for s in "${unmapped[@]}"; do
    warn "  - $s"
  done
fi

ok "desnapped — snapd is purged and pinned out, replacements installed from apt/official sources"
