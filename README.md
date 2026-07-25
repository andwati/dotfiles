# dotfiles

My configuration files that keep me from flipping a table after logging in.

## Setup

```
git clone https://github.com/andwati/dotfiles ~/dev/dotfiles
~/dev/dotfiles/install.sh
```

Symlinks `zsh/.zshrc`, `zsh/.zshenv`, `zsh/.zprofile`, and `zsh/.p10k.zsh` into
`$HOME`, and clones oh-my-zsh plus the theme/plugins `.zshrc` expects
(powerlevel10k, zsh-autosuggestions, zsh-syntax-highlighting,
zsh-history-substring-search, zsh-completions, you-should-use).

Not installed by the script — grab these separately if a fresh machine needs
them: `nvm`, `pyenv`, `bun`, `pnpm`, `deno`, `rustup`, `docker`, `fzf`,
`zoxide`, and a Nerd Font (JetBrains Mono Nerd Font) set as your terminal font.
