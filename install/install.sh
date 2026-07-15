#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULES_DIR="$SCRIPT_DIR/modules"
export DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$SCRIPT_DIR/.." && pwd)}"
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"
trap 'rm -f "$(_apt_marker)"' EXIT

ALL_MODULES=(
  00-base mirrors perms cli-tools
  nvm node pnpm deno bun
  pyenv pipx pipenv poetry uv
  vscode cursor ghcli docker go rust zig
  chrome discord slack firefox postman jetbrains-toolbox mpv spotify telegram signal protonvpn onedrive
  gnome wakatime
)

declare -A MODULE_DESC=(
  [00-base]="core apt packages (curl, git, build-essential, jq, stow, ...)"
  [mirrors]="benchmark + switch apt to the fastest fresh Ubuntu mirror"
  [perms]="fix ~/.ssh and ~/.gnupg permissions"
  [cli-tools]="eza, ripgrep + shell aliases"
  [nvm]="Node Version Manager"
  [node]="Node.js LTS (via nvm)"
  [pnpm]="pnpm package manager"
  [deno]="Deno runtime"
  [bun]="Bun runtime"
  [pyenv]="Python version manager"
  [pipx]="pipx (isolated python CLI installs)"
  [pipenv]="pipenv (via pipx)"
  [poetry]="Poetry python packaging"
  [uv]="uv python package/venv manager"
  [vscode]="VS Code + your extensions/settings (mirrors to Cursor too)"
  [cursor]="Cursor editor (official AppImage)"
  [ghcli]="GitHub CLI (gh)"
  [docker]="Docker Engine + compose plugin"
  [go]="Go toolchain"
  [rust]="Rust (rustup)"
  [zig]="Zig + zls (language server)"
  [chrome]="Google Chrome"
  [discord]="Discord"
  [slack]="Slack (Flathub)"
  [firefox]="Firefox (Mozilla apt repo, not snap)"
  [postman]="Postman"
  [jetbrains-toolbox]="JetBrains Toolbox"
  [mpv]="mpv media player"
  [spotify]="Spotify"
  [telegram]="Telegram Desktop"
  [signal]="Signal Desktop"
  [protonvpn]="ProtonVPN (official GNOME app)"
  [onedrive]="OneDrive client (abraunegg, official OBS repo)"
  [gnome]="GNOME Tweaks, Extension Manager, AppIndicator support"
  [wakatime]="Wakatime API key setup"
)

SUMMARY_OK=()
SUMMARY_FAILED=()

usage() {
  cat <<EOF
Usage: $(basename "$0") [module ...]
       $(basename "$0") --list
       $(basename "$0") --except mod1,mod2
       $(basename "$0") --dry-run [module ...]
       $(basename "$0") --all | --no-tui

With no arguments on an interactive terminal, shows a checklist (whiptail)
to pick which modules to install. Pass --all/--no-tui to skip the checklist
and install everything, or name modules explicitly.

A module failing does not abort the run: its own changes are rolled back,
the failure is recorded, and the next module runs. Exit status is nonzero
if anything failed. Every module is idempotent — safe to re-run.

Modules:
$(printf '  %-20s %s\n' $(for m in "${ALL_MODULES[@]}"; do printf '%s\n%s\n' "$m" "${MODULE_DESC[$m]:-}"; done))
EOF
}

list_modules() { printf '%s\n' "${ALL_MODULES[@]}"; }

ensure_whiptail() {
  if has_cmd whiptail; then return 0; fi
  log "installing whiptail for the selection menu"
  apt_update_once
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y whiptail
}

tui_select_modules() {
  if ! ensure_whiptail || ! has_cmd whiptail; then
    warn "whiptail unavailable, falling back to a plain prompt"
    plain_select_modules
    return
  fi

  local -a items=()
  local m
  for m in "${ALL_MODULES[@]}"; do
    items+=("$m" "${MODULE_DESC[$m]:-}" "ON")
  done

  local choices
  choices=$(whiptail --title "dotfiles installer" --checklist \
    "Space to toggle, Enter to confirm, Esc to cancel" 24 78 16 \
    "${items[@]}" 3>&1 1>&2 2>&3) || { warn "selection cancelled"; return 1; }

  eval "local -a selected=($choices)"
  printf '%s\n' "${selected[@]}"
}

plain_select_modules() {
  echo "Select modules (space-separated numbers, or 'all'):" >&2
  local i=1 m
  for m in "${ALL_MODULES[@]}"; do
    printf '  %2d) %-20s %s\n' "$i" "$m" "${MODULE_DESC[$m]:-}" >&2
    i=$((i + 1))
  done
  read -rp "> " reply
  if [[ "$reply" == "all" || -z "$reply" ]]; then
    printf '%s\n' "${ALL_MODULES[@]}"
    return
  fi
  local -a out=()
  local n
  for n in $reply; do
    [[ "$n" =~ ^[0-9]+$ ]] || continue
    out+=("${ALL_MODULES[$((n - 1))]}")
  done
  printf '%s\n' "${out[@]}"
}

run_module() {
  local slug="$1"
  local file="$MODULES_DIR/${slug}.sh"
  local fn="install_${slug//-/_}"

  if [[ ! -f "$file" ]]; then
    err "unknown module: $slug"
    SUMMARY_FAILED+=("$slug")
    return
  fi

  if [[ "${DRY_RUN:-0}" == "1" ]]; then
    log "[dry-run] would install: $slug — ${MODULE_DESC[$slug]:-}"
    SUMMARY_OK+=("$slug (dry-run)")
    return
  fi

  log "installing $slug"

  # Run in a subshell so a failing command genuinely aborts the module
  # (errexit) instead of limping on to the next line. Note: `if ( ... );
  # then` or `( ... ) || ...` would silently defeat -e here — bash suspends
  # errexit for the *whole* tested command, including inside a nested
  # subshell, even if that subshell re-sets -e itself. The subshell must run
  # as a genuinely unconditional statement, under a `set +e` bracket so its
  # own nonzero exit doesn't also kill the outer script, with $? captured
  # right after and -e restored immediately.
  set +e
  (
    set -Eeuo pipefail
    trap 'rollback_run' ERR
    # shellcheck disable=SC1090
    source "$file"
    rollback_reset
    "$fn"
  )
  local status=$?
  set -e

  if [[ $status -eq 0 ]]; then
    ok "$slug done"
    SUMMARY_OK+=("$slug")
  else
    err "$slug failed — its changes were rolled back"
    SUMMARY_FAILED+=("$slug")
  fi
}

print_summary() {
  echo
  log "summary"
  if [[ ${#SUMMARY_OK[@]} -gt 0 ]]; then printf '  ok:     %s\n' "${SUMMARY_OK[*]}"; fi
  if [[ ${#SUMMARY_FAILED[@]} -gt 0 ]]; then printf '  failed: %s\n' "${SUMMARY_FAILED[*]}"; fi
  return 0
}

main() {
  local -a explicit=() except=()
  local dry_run=0 force_all=0

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help) usage; exit 0 ;;
      --list) list_modules; exit 0 ;;
      --dry-run) dry_run=1; shift ;;
      --all|--no-tui) force_all=1; shift ;;
      --except)
        IFS=',' read -ra except <<< "${2:-}"
        shift 2
        ;;
      -*)
        err "unknown flag: $1"; usage; exit 1 ;;
      *) explicit+=("$1"); shift ;;
    esac
  done

  export DRY_RUN=$dry_run

  local -a targets=()
  local m s skipped
  if [[ ${#except[@]} -gt 0 ]]; then
    for m in "${ALL_MODULES[@]}"; do
      skipped=0
      for s in "${except[@]}"; do
        if [[ "$m" == "$s" ]]; then skipped=1; fi
      done
      [[ $skipped -eq 1 ]] || targets+=("$m")
    done
  elif [[ ${#explicit[@]} -gt 0 ]]; then
    targets=("${explicit[@]}")
  elif [[ $force_all -eq 0 && -t 0 && -t 1 ]]; then
    local tui_out
    if ! tui_out=$(tui_select_modules); then
      err "no modules selected"
      exit 1
    fi
    mapfile -t targets <<< "$tui_out"
  else
    targets=("${ALL_MODULES[@]}")
  fi

  if [[ ${#targets[@]} -eq 0 ]]; then
    warn "nothing selected"
    exit 0
  fi

  local -a ordered=(00-base)
  for m in "${targets[@]}"; do
    [[ "$m" == "00-base" ]] || ordered+=("$m")
  done

  for m in "${ordered[@]}"; do
    run_module "$m"
  done

  print_summary
  [[ ${#SUMMARY_FAILED[@]} -eq 0 ]]
}

main "$@"
