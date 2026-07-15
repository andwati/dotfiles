# dotfiles

My configuration files, plus a modular installer for the tools I use on a
fresh Ubuntu box (targeting 26.04). Everything installs from each vendor's
official source — apt repos with their real signing keys, or their official
install scripts/tarballs. No PPAs of unclear provenance, no snaps unless the
vendor's own instructions use one (Ubuntu's own default snaps are actively
replaced — see `desnap.sh` below).

## Quick start

On a fresh Ubuntu install:

```sh
git clone <this-repo> ~/dotfiles
cd ~/dotfiles
./bootstrap.sh
```

That will:

1. Install `stow`, `zsh`, `curl`, `git`.
2. Symlink the dotfiles (`zsh/`, `git/`, `tmux/`, `vscode/`) into `$HOME` with
   GNU Stow.
3. Prompt once for your git name/email/signing key, saved to
   `~/.gitconfig.local` (gitignored — never committed, so this repo stays
   shareable).
4. Set zsh as your default shell.
5. Run `install/install.sh`, which shows a checklist (see below) of every
   tool to install.

Open a new shell afterwards (or `exec zsh`) to pick up PATH changes.

## Picking what to install

Run interactively with no arguments and `install/install.sh` shows a
`whiptail` checklist — space to toggle, enter to confirm. Everything's
checked by default; uncheck what you don't want. If `whiptail` isn't
available it's installed automatically; if that's not possible either it
falls back to a plain numbered prompt.

Non-interactive options:

```sh
./bootstrap.sh nvm node pnpm docker     # only these modules (+ base deps)
./install/install.sh --list             # list all module names
./install/install.sh --except discord,slack,spotify
./install/install.sh --all              # skip the checklist, install everything
./install/install.sh --dry-run          # show what would run without doing it
```

`--dry-run` works with any of the above (`--dry-run --all`,
`--dry-run nvm docker`, ...) and also works on `bootstrap.sh` and
`desnap.sh`.

## Resilience: a failed module doesn't kill the run

Every module runs in its own subshell with `errexit` on. If a command in a
module fails partway through, that module's own changes (packages
installed, repos added, directories created, group memberships granted —
whatever it called `rollback_push` for) are unwound in reverse order, the
failure is recorded, and the **next module still runs**. At the end you get
a summary of what succeeded and what failed, and the script exits nonzero
only if something actually failed. Every module is also idempotent — safe
to re-run individually or all together.

## What gets installed

| Category | Tools |
|---|---|
| System | apt mirror benchmarking, `~/.ssh`/`~/.gnupg` permission fixes, eza/ripgrep |
| JS/TS runtimes | nvm, node (via nvm, LTS), pnpm, deno, bun |
| Python | pyenv, pipx, pipenv, poetry, uv |
| Systems languages | go, rust (rustup), zig + zls |
| Dev tooling | VS Code (+ your extensions/settings, mirrored to Cursor), Cursor, GitHub CLI (`gh`), Docker Engine |
| Apps | Chrome, Firefox, Discord, Slack, Postman, JetBrains Toolbox, mpv, Spotify, Telegram, Signal, ProtonVPN, OneDrive (abraunegg) |
| Desktop | GNOME Tweaks, Extension Manager, AppIndicator support |
| Misc | Wakatime API key setup |

## Layout

```
bootstrap.sh          entrypoint: stows dotfiles, then runs install/install.sh
desnap.sh              standalone: purges snapd, replaces default snaps with apt/Flatpak
install/
  lib.sh              shared shell helpers (apt/repo/rollback/profile-line helpers)
  install.sh           module runner — TUI checklist, dry-run, rollback, summary
  modules/*.sh          one file per tool, each defines install_<name>()
zsh/ git/ tmux/ vscode/  stow packages — mirror their target layout under $HOME
```

To add a new tool: drop a new `install/modules/<name>.sh` defining
`install_<name>()`, and add `<name>` (+ a description) to `ALL_MODULES` /
`MODULE_DESC` in `install/install.sh`.

## desnap.sh

Purges snapd entirely and pins it out of apt so it can't come back on
upgrade. Before removing anything it works out, per installed snap, whether
there's a real replacement:

- Snaps we already have an official-source module for (Firefox) get that
  module.
- Known default-Ubuntu snaps with a plain apt equivalent (Thunderbird,
  snap-store → gnome-software) get that apt package.
- GNOME/core runtime snaps (content-only, no user-facing app) are skipped.
- Anything else gets Flatpak + Flathub set up and is listed at the end so
  you can `flatpak search`/`install` it yourself, rather than guessing an
  app id.

Destructive and asks for confirmation (`-y`/`--yes` to skip the prompt);
supports `--dry-run` to preview the plan first.

```sh
./desnap.sh --dry-run
./desnap.sh
```

## Notes

- `mirrors` benchmarks official Ubuntu mirrors (speed + a freshness check on
  `Last-Modified`) and rewrites apt's sources to the fastest one — handles
  both the legacy `sources.list` and the 24.04+/26.04 deb822
  `ubuntu.sources` format. Runs early so the rest of the install benefits.
  `security.ubuntu.com` is left alone on purpose.
- `firefox` removes the transitional apt stub / snap package first and pins
  Mozilla's official apt repo, since stock Ubuntu ships Firefox as a snap.
- `docker`, `onedrive` each check whether their upstream repo has packages
  for the running Ubuntu codename/version yet and fall back to the most
  recent known-supported one if it's too new (relevant right after a fresh
  26.04 install).
- `vscode` installs every extension listed in `vscode/extensions.txt`
  (exported with `code --list-extensions`) and mirrors `settings.json` to
  Cursor via symlink, so both stay in sync from one source of truth.
- `wakatime` prompts once for your API key and writes `~/.wakatime.cfg`
  (chmod 600); leave the prompt blank to skip.
- Tool PATH/init lines are appended idempotently to the end of `zsh/.zshrc`
  by `profile_add` in `install/lib.sh` — re-running a module never
  duplicates a line.
