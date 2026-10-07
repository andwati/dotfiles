# dotfiles

My configuration files that keep me from flipping a table after logging in.

## Setup

```
sudo pacman -S stow   # or your distro's equivalent
git clone https://github.com/andwati/dotfiles ~/dev/dotfiles
~/dev/dotfiles/install.sh
```

Each top-level directory is a [GNU Stow](https://www.gnu.org/software/stow/)
package mirroring `$HOME` (e.g. `zsh/.zshrc` -> `~/.zshrc`). `install.sh`
clones oh-my-zsh plus the theme/plugins `.zshrc` expects (powerlevel10k,
zsh-autosuggestions, zsh-syntax-highlighting, zsh-history-substring-search,
zsh-completions, you-should-use), then stows the `zsh`, `gnupg`, `git`,
`ghostty`, `kde`, `nvim`, and `vscode` packages to link everything in, backing
up any conflicting real files it finds first (e.g. oh-my-zsh's own
freshly-installed `.zshrc`).

To add a new package: create a top-level dir shaped like `$HOME` (e.g.
`git/.gitconfig`), then add a `stow_package <name>` call in `install.sh`.

`gpg-agent.conf` caches your GPG passphrase for 8 hours (24h hard cap)
instead of the 10-minute default, so signed commits don't re-prompt
constantly, and uses `pinentry-qt` for a native dialog instead of a
terminal prompt.

Not installed by the script — grab these separately if a fresh machine needs
them: `nvm`, `pyenv`, `bun`, `pnpm`, `deno`, `rustup`, `docker`, `fzf`,
`zoxide`, and a Nerd Font (JetBrains Mono Nerd Font) set as your terminal font.

## Everforest theme

The desktop is themed with [Everforest](https://github.com/sainnhe/everforest)
(dark, medium; background `#2b3339`):

- `kde` — `Everforest` color scheme, wallpaper, and the lock screen wallpaper
  (`kscreenlockerrc`). Select the scheme in System Settings > Colors.
- `ghostty` — `everforest-dark` theme with background opacity and blur (needs
  KWin's Blur effect on Plasma).
- `nvim` — LazyVim with `neanias/everforest-nvim` (transparent background) and
  LSP for zig, python, typescript, rust, go, c and c++.
- `vscode` — user `settings.json` (Everforest Dark via the
  `reesew.everforest-theme` extension).
- `chrome/everforest` — not stowed. Open `chrome://extensions`, enable
  Developer mode, and Load unpacked on that folder.

The Plasma Login Manager screen is root-owned and can't be stowed: pick the
wallpaper and sync colors in System Settings > Login Screen after changing the
scheme. Firefox uses the Everforest Dark Medium theme from addons.mozilla.org.
