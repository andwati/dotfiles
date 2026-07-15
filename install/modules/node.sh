install_node() {
  export NVM_DIR="$HOME/.nvm"
  if [[ ! -s "$NVM_DIR/nvm.sh" ]]; then
    err "nvm not found; run the nvm module first"
    return 1
  fi
  # shellcheck disable=SC1091
  \. "$NVM_DIR/nvm.sh"

  nvm install --lts
  nvm alias default 'lts/*'
}
