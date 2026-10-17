# Selective Setup on Omarchy (Linux, Hyprland)

A tested walkthrough for applying these dotfiles to a Linux machine that already
has a working desktop — specifically **Omarchy** (Arch Linux, Hyprland). The
goal is to adopt the tool/editor configs from this repo *without* clobbering an
existing window-manager setup.

## What

- Install GNU Stow, required by the `./install.sh stow-app` command.
- Stow only the **application configs** that do not conflict with an existing
  desktop: `k9s`, `helix`, `zellij`, `fish`, `lazygit`, `tmux`.
- Link `.gitconfig` manually (it has no per-app stow entry).
- Install the git tooling referenced by `.gitconfig` (`hunk`, `delta`, `gh`,
  `git-lfs`) plus the stowed apps' binaries via **mise**.
- Install `fish` from the system package manager — it is not in the mise
  registry.
- Skip every window-manager-related config (`hypr`, `waybar`, `wlogout`,
  `rofi`, `swww`, `foot`, `ghostty`, `kitty`, `alacritty`, `herdr`, `mise`,
  `systemd`, `i3`, `niri`).

Existing configs that would be replaced are **backed up**, not deleted.

## Why

The full-`install.sh` path (`stow common linux`) and the Linux umbrella
(`./install.sh all`) overwrite whatever `~/.config/hypr`, `~/.config/waybar`,
and friends already contain. On a desktop that is already configured and in
active use (Omarchy ships its own Hyprland/waybar/foot theme), that replacement
is usually unwanted and can break the running session. `./install.sh stow-app
<app>` exists precisely for per-app adoption and was used instead.

Two non-obvious findings shaped the process:

1. `fish` cannot be installed through the mise registry (`mise install fish`
   fails: `fish not found in mise tool registry`). The repo's
   `./install.sh fish` already handles this by installing via `pacman`.
2. The `common/.config/nvim` submodule has been pinned to commits that were
   later force-pushed out of tiny-nvim's history (`upload-pack: not our ref`),
   which breaks `git submodule update --init`. At the time of writing the pin
   was `9d6c577…`; `master` has since been bumped to a reachable commit, so a
   plain `git submodule update --init` now works and step 7 keeps the re-add
   only as a recovery path.

## How

### 1. Clone and branch

```bash
git clone https://github.com/jellydn/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

### 2. GNU Stow

```bash
# Arch / Omarchy
sudo pacman -S --noconfirm stow
# or: sudo apt install stow   # Debian/Ubuntu
```

`./install.sh stow-app` creates the per-app symlinks itself (it does not shell
out to GNU Stow), but it aborts when no `stow` binary is in `PATH`, so install
GNU Stow first — then continue.

### 3. Stow the safe apps

Stows are idempotent per app; if a real directory already exists at the target
it is first backed up to `<path>_backup_<timestamp>`.

```bash
cd ~/.dotfiles
for app in k9s helix zellij fish lazygit tmux; do
  ./install.sh stow-app "$app"
done
```

`./install.sh stow-app` only runs a dependency check; it proceeds with a
warning if the binary is missing, so config symlinks are safe to create before
the binaries are installed.

Backed-up originals from the test run (non-destructive):

```text
~/.config/lazygit -> lazygit_backup_20260915_103228
~/.config/tmux    -> tmux_backup_20260915_103228
```

### 4. `.gitconfig`

```bash
ln -sf ~/.dotfiles/common/.gitconfig ~/.gitconfig
```

`.gitconfig` references `hunk`, `delta`, `gh`, and `git-lfs`. Install them
alongside the app binaries in one mise step:

```bash
export PATH="$HOME/.local/bin:$PATH"
mise install hunk delta gh git-lfs
mise use -g hunk delta gh git-lfs
```

### 5. The app binaries

```bash
mise install helix zellij lazygit k9s
mise use -g helix zellij lazygit k9s
```

Note: helix's binary is `hx`. If the shim is missing after `mise use`, run
`mise reshim`.

### 6. fish

```bash
sudo pacman -S --noconfirm fish
```

The stowed config is picked up automatically at `~/.config/fish`.

### 7. nvim submodule

```bash
cd ~/.dotfiles
git submodule update --init common/.config/nvim
./install.sh stow-app nvim
```

If the pinned commit is unreachable (`upload-pack: not our ref <sha>` — seen
while tiny-nvim was force-pushed), re-add the submodule at the current `main`
instead, then stow it:

```bash
cd ~/.dotfiles
git submodule sync common/.config/nvim
git submodule add -f https://github.com/jellydn/tiny-nvim.git common/.config/nvim
./install.sh stow-app nvim
```

### 8. What was deliberately skipped

```text
linux/.config/{hypr,waybar,wlogout,rofi,swww,foot,...systemd}
common/.config/{ghostty,kitty,alacritty,herdr,mise}
```

These are desktop/window-manager bindings that Omarchy already configures.
Stow them only if you want the repo versions to own those bindings:
`./install.sh stow-app hypr` (or `waybar`, `foot`, etc.).

## Verification

```bash
# Configs are symlinks into the repo
ls -la ~/.config/{k9s,helix,zellij,fish,lazygit,tmux} | grep '\->'

# Tools resolve
export PATH="$HOME/.local/bin:$PATH"
hunk --version && delta --version && gh --version | head -1 && git-lfs version
hx --version   # helix
zellij --version && lazygit --version && k9s version | head -1
fish --version

# git uses the configured identity/pager
git config --global user.name
```

## Troubleshooting

- **`mise install fish` fails** — expected; fish is not in the mise registry.
  Use the system package manager (`sudo pacman -S fish`).
- **Submodule fetch fails with `upload-pack: not our ref <sha>`** — the pinned
  commit was force-pushed away. Use the re-add fallback in step 7.
- **Your terminal does not see new binaries** — mise shims are in
  `~/.local/share/mise/shims`; restart the shell or re-source it (e.g. `exec
  bash`).