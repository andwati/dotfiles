#-------------------------------------------------------------------------------
# Aliases / Functions
#-------------------------------------------------------------------------------

# Vim
alias vim='nvim'

# Eza
alias ls='eza'
alias lst='eza -T'
alias lsg='eza -T --git-ignore'

# Git
alias ga='git add'
alias gb='git branch'
alias gca='git commit --amend'
alias gcan='git commit --amend --no-edit'
alias gcm='git commit -m'
alias gcv='git commit -v'
alias gs='git status'
alias gd='git diff'
alias gds='git diff --staged'
alias gl='git log'
alias glo='git log --oneline'
alias gp='git push'

# Project
alias cdp="cd $PERSONAL_PROJECTS_DIR"
alias cdf="cd $FOREIGN_PROJECTS_DIR"
alias cdd="cd $PERSONAL_PROJECTS_DIR/discard/"

# Zig
alias zigup='asdf uninstall zig master && asdf install zig master'
alias zbt='zig build test'
alias zbd='rm -rf zig-cache && zig build docs'
alias zbbd='rm -rf zig-cache && zig build bench'
alias zbbr='rm -rf zig-cache && zig build bench -Drelease=true'

# Youtube
alias ytm="yt-dlp -f ba[ext=m4a]"
