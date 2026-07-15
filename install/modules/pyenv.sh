install_pyenv() {
  apt_install make build-essential libssl-dev zlib1g-dev libbz2-dev \
    libreadline-dev libsqlite3-dev wget curl llvm libncursesw5-dev \
    xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

  if [[ -d "$HOME/.pyenv" ]]; then
    ok "pyenv already installed"
  else
    track_new_dir "$HOME/.pyenv"
    curl -fsSL https://pyenv.run | bash
  fi

  profile_add 'export PYENV_ROOT="$HOME/.pyenv"'
  profile_add 'export PATH="$PYENV_ROOT/bin:$PATH"'
  profile_add 'eval "$(pyenv init - zsh)"'
}
