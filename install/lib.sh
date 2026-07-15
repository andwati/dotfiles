#!/usr/bin/env bash
# Shared helpers sourced by install.sh, bootstrap.sh, desnap.sh, and every
# module in install/modules/.

C_RESET=$'\033[0m'; C_BLUE=$'\033[1;34m'; C_GREEN=$'\033[1;32m'; C_YELLOW=$'\033[1;33m'; C_RED=$'\033[1;31m'

log()  { printf '%s==>%s %s\n' "$C_BLUE" "$C_RESET" "$*"; }
ok()   { printf '%s  ok%s %s\n' "$C_GREEN" "$C_RESET" "$*"; }
warn() { printf '%s warn%s %s\n' "$C_YELLOW" "$C_RESET" "$*" >&2; }
err()  { printf '%s   !!%s %s\n' "$C_RED" "$C_RESET" "$*" >&2; }

has_cmd() { command -v "$1" >/dev/null 2>&1; }

deb_arch() { dpkg --print-architecture; }
ubuntu_codename() { . /etc/os-release; echo "$VERSION_CODENAME"; }

# Each module now runs in its own subshell (see run_module in install.sh),
# so a plain shell variable can't track "already updated" across modules —
# it'd reset every time. Use a marker file scoped to this whole run ($$ is
# stable across subshells) instead; apt_invalidate removes it when a repo
# changes so the next apt_install re-syncs.
_apt_marker() { echo "/tmp/.dotfiles-apt-updated.$$"; }

apt_update_once() {
  local marker
  marker=$(_apt_marker)
  if [[ ! -f "$marker" ]]; then
    sudo apt-get update -qq
    touch "$marker"
  fi
}

apt_invalidate() { rm -f "$(_apt_marker)"; }

# apt_install <pkg...> — installs packages and, for any package that wasn't
# already present, registers a rollback that removes it again. Packages the
# user already had are left alone on rollback.
apt_install() {
  apt_update_once
  local -a new_pkgs=()
  local p
  for p in "$@"; do
    dpkg -s "$p" >/dev/null 2>&1 || new_pkgs+=("$p")
  done
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "$@"
  if [[ ${#new_pkgs[@]} -gt 0 ]]; then
    rollback_push "sudo DEBIAN_FRONTEND=noninteractive apt-get remove -y ${new_pkgs[*]}"
  fi
}

# apt_add_repo <list-name> <keyring-path> <key-url> <repo-line>
# Registers a signed apt repo the way every vendor's official install docs do
# it (dearmor the key into /etc/apt/keyrings or similar, write a .list file),
# forces the next apt_install to refresh package lists, and registers a
# rollback that removes the repo + keyring again.
apt_add_repo() {
  local list_name="$1" keyring="$2" key_url="$3" repo_line="$4"
  sudo install -d -m 0755 "$(dirname "$keyring")"
  curl -fsSL "$key_url" | sudo gpg --dearmor --yes -o "$keyring"
  sudo chmod a+r "$keyring"
  echo "$repo_line" | sudo tee "/etc/apt/sources.list.d/${list_name}.list" >/dev/null
  rollback_push "sudo rm -f '/etc/apt/sources.list.d/${list_name}.list' '$keyring'"
  apt_invalidate
}

add_line_once() {
  local file="$1" line="$2"
  mkdir -p "$(dirname "$file")"
  touch "$file"
  grep -qxF "$line" "$file" || printf '%s\n' "$line" >> "$file"
}

# profile_add <line> — idempotently append a PATH/init line to ~/.zshrc so
# re-running a module never duplicates it. Not rollback-tracked: a stray
# export pointing at a directory that got rolled back is inert, not broken.
profile_add() { add_line_once "$HOME/.zshrc" "$1"; }

# --- transactional rollback -------------------------------------------------
#
# Each module gets a fresh rollback stack (see run_module in install.sh).
# Anything a module does that should be undone if a *later* command in the
# same module fails should call rollback_push with a shell command string.
# On success the stack is simply discarded; on failure it's run in reverse.

ROLLBACK_ACTIONS=()

rollback_reset() { ROLLBACK_ACTIONS=(); }
rollback_push()  { ROLLBACK_ACTIONS+=("$1"); }

rollback_run() {
  local i
  for (( i=${#ROLLBACK_ACTIONS[@]}-1; i>=0; i-- )); do
    warn "rollback: ${ROLLBACK_ACTIONS[$i]}"
    eval "${ROLLBACK_ACTIONS[$i]}" || true
  done
  ROLLBACK_ACTIONS=()
}

track_new_dir()      { rollback_push "rm -rf '$1'"; }
track_new_sudo_dir()  { rollback_push "sudo rm -rf '$1'"; }
