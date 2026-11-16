if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

typeset -U path PATH fpath
fpath=("$HOME/.zsh/completions" $fpath)

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
  git sudo extract docker docker-compose fzf
  zsh-completions you-should-use
  autoswitch_virtualenv
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-history-substring-search
)

source $ZSH/oh-my-zsh.sh
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

export GPG_TTY=$(tty)

export EDITOR=nano
export VISUAL=nano

command -v zoxide >/dev/null && eval "$(zoxide init zsh)"

_eza='eza --color=auto --icons=auto --hyperlink=auto --group-directories-first'
alias ls="$_eza"
alias l="$_eza -lah --git --color-scale=all"
alias ll="$_eza -lh --git --color-scale=all"
alias la="$_eza -lAh --git --color-scale=all"
alias lt="$_eza --tree --level=2"
unset _eza

pyenv() {
  unfunction pyenv
  eval "$(command pyenv init - zsh)"
  pyenv "$@"
}

export PNPM_HOME="$HOME/.local/share/pnpm"
export PATH="$PNPM_HOME/bin:$PATH"

export JAVA_HOME=/usr/lib/jvm/default
export ANDROID_HOME="$HOME/Android/Sdk"
export PATH="$JAVA_HOME/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"

export PATH="$HOME/.resend/bin:$HOME/depot_tools:$PATH"

FNM_PATH="$HOME/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$FNM_PATH:$PATH"
  eval "$(fnm env --shell zsh)"
fi

# Resend CLI
export PATH="$HOME/.resend/bin:$PATH"
