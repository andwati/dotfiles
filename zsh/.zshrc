HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_DUPS SHARE_HISTORY EXTENDED_HISTORY INC_APPEND_HISTORY

autoload -Uz compinit && compinit

export EDITOR="vim"
export PATH="$HOME/.local/bin:$PATH"

[[ -f "$HOME/.zsh_aliases" ]] && source "$HOME/.zsh_aliases"

PROMPT='%F{blue}%~%f %(?.%F{green}.%F{red})❯%f '

# --- devenv installers (managed by install/lib.sh profile_add, appended below) ---
