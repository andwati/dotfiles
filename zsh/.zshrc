# If not running interactively, don't do anything
[[ $- != *i* ]] && return

HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000


autoload -Uz bashcompinit && bashcompinit
# Use completions
autoload -Uz compinit && compinit
autoload -Uz bashcompinit && bashcompinit


### SET VI MODE ###
# Uncomment this line to enable vi-like key bindings
bindkey -v
bindkey '^L' clear-screen

# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="agnoster"

zstyle ':omz:update' mode reminder  # just remind me to update when it's time


HIST_STAMPS="dd.mm.yyyy"

plugins=(git)

source $ZSH/oh-my-zsh.sh

export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# Compilation flags
export ARCHFLAGS="-arch $(uname -m)"

source /usr/share/nvm/init-nvm.sh
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - zsh)"


# Aliases
# ls alternatives:
alias ls='eza -al --icons --color=always --group-directories-first'
alias la='ls -a'
alias ll='ls -l | less -RF'

# track ever growing files
alias freespace="sudo du -h /* --exclude={'proc','run'}| sort -hr | less"

# grep
alias grep='grep --colour=auto'

# Aliases for navigation
alias ..='cd ..'
alias ...='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'
alias .5='cd ../../../../..'

# Automatically ls when changing directory
cd() {
  builtin cd "$@" && ls
}

# show all nearby wifi spots
alias scan="nmcli dev wifi"

### "nvim" as manpager
export MANPAGER="nvim +Man!"


### SETTING OTHER ENVIRONMENT VARIABLES
if [[ -z "$XDG_CONFIG_HOME" ]] ; then
    export XDG_CONFIG_HOME="$HOME/.config"
fi
if [[ -z "$XDG_DATA_HOME" ]] ; then
    export XDG_DATA_HOME="$HOME/.local/share"
fi
if [[ -z "$XDG_CACHE_HOME" ]] ; then
    export XDG_CACHE_HOME="$HOME/.cache"
fi

### CHANGE TITLE OF TERMINALS
case ${TERM} in
  xterm*|rxvt*|Eterm*|aterm|kterm|gnome*|alacritty|st|konsole|ghostty*)
    preexec() { print -Pn "\e]0;%n@%m:%~\a" }
    ;;
  screen*)
    preexec() { print -Pn "\e_%n@%m:%~\e\\" }
    ;;
esac

# Function extract for common file formats
ex() {
  if [[ -z "$1" ]]; then
    echo "Usage: ex <path/file_name>.<zip|rar|bz2|gz|tar|tbz2|tgz|Z|7z|xz|...>"
  else
    for n in "$@"; do
      if [[ -f "$n" ]]; then
        case "${n%,}" in
          *.tar.bz2|*.tbz2|*.tar.gz|*.tgz|*.tar.xz|*.txz|*.tar)
            tar xvf "$n" ;;
          *.gz) gunzip "$n" ;;
          *.xz) unxz "$n" ;;
          *.bz2) bunzip2 "$n" ;;
          *.zip) unzip "$n" ;;
          *.7z) 7z x "$n" ;;
          *.rar) unrar x "$n" ;;
          *)
            echo "ex: '$n' - unknown archive method" ;;
        esac
      else
        echo "'$n' - file does not exist"
      fi
    done
  fi
}