install_nvm() {
  export NVM_DIR="$HOME/.nvm"

  if [[ -s "$NVM_DIR/nvm.sh" ]]; then
    ok "nvm already installed"
  else
    local version installer
    version=$(curl -fsSL https://api.github.com/repos/nvm-sh/nvm/releases/latest | jq -r .tag_name)
    installer=$(mktemp)
    curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/${version}/install.sh" -o "$installer"
    track_new_dir "$NVM_DIR"
    # PROFILE=/dev/null: we manage PATH/init lines ourselves via profile_add below.
    PROFILE=/dev/null bash "$installer"
    rm -f "$installer"
  fi

  profile_add 'export NVM_DIR="$HOME/.nvm"'
  profile_add '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"'
  profile_add '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"'
}
