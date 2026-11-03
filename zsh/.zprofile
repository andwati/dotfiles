export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"

# pipx and Antigravity CLI install here
export PATH="/home/ian/.local/bin:$PATH"
