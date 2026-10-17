# Selective Setup on Omarchy (Linux, Hyprland)

A tested walkthrough for applying these dotfiles to a Linux machine that already
has a working desktop — specifically **Omarchy** (Arch Linux, Hyprland). The
goal is to adopt the tool/editor configs from this repo _without_ clobbering an
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
- Optionally install `jellydn/my-ai-tools` with Pi, Codex, Amp, OpenCode, and
  Grok as the default assistant set.
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

## Optional: Work apps (Slack and Microsoft Teams)

Neither is in Arch's official repos, and both need `sudo` — run them in a
terminal where you can type your password.

**Slack** — Omarchy's own repo carries the official Slack desktop app:

```bash
omarchy pkg add slack-desktop
```

**Microsoft Teams** — Microsoft ships no native Linux package, so pick one:

```bash
# A) Community Electron client (a real desktop window, tray icon, notifications)
omarchy pkg aur add teams-for-linux-bin

# B) Omarchy's supported web app (Teams plus Outlook, Word, Excel,
#    PowerPoint, and OneDrive, all as Chromium web apps)
omarchy install service microsoft
```

Option A wraps the Teams web client in Electron; it uses PipeWire for screen
sharing, which Omarchy already provides. Option B needs no AUR build and is
maintained by Omarchy, but every Microsoft app arrives at once and runs in
Chromium.

To remove them later:

```bash
omarchy pkg drop slack-desktop teams-for-linux-bin
omarchy remove service microsoft   # only if you chose option B
```

For a single Slack web app instead of the desktop client:

```bash
omarchy webapp install Slack https://app.slack.com/client slack
```

**Proton Pass** — the desktop app is **x86_64 only**, so choose by architecture:

```bash
# x86_64: native desktop app
omarchy pkg aur add proton-pass-bin

# aarch64 (or anywhere, no build): web app + Chromium extension
omarchy webapp install "Proton Pass" https://pass.proton.me/ \
  "https://www.google.com/s2/favicons?domain=pass.proton.me&sz=256"
mkdir -p ~/.config/chromium/"External Extensions"
printf '{ "external_update_url": "https://clients2.google.com/service/update2/crx" }\n' \
  > ~/.config/chromium/"External Extensions/ghmbeldphafepmbegfdlkpapadhbakde.json"
```

The extension JSON is the same mechanism Omarchy uses for the 1Password
extension, but written to the user-level path, so it needs no `sudo`. Restart
Chromium to load it.

## Optional: AI coding assistants (my-ai-tools)

[`jellydn/my-ai-tools`](https://github.com/jellydn/my-ai-tools) installs one
shared set of agent guidelines, skills, commands, hooks, and MCP servers across
AI coding assistants (Claude Code, OpenCode, Amp, Codex, Cursor, Pi, Grok CLI,
and more).

In non-interactive mode (`--yes`) it installs only the tools named in the
`TOOL_ALLOWLIST_YES` array near the top of `cli.sh` — that array is the default
active tool set. To make **Pi, Codex, Amp, OpenCode, and Grok** the default, use
a checkout (the one-line installer clones into a temp directory you cannot
edit) and rewrite the array before running it:

```bash
git clone https://github.com/jellydn/my-ai-tools.git ~/.my-ai-tools
cd ~/.my-ai-tools

# default active tool set: Pi, Codex, Amp, OpenCode, Grok
sed -i 's/^TOOL_ALLOWLIST_YES=.*/TOOL_ALLOWLIST_YES=(pi codex amp opencode grok)/' cli.sh
grep '^TOOL_ALLOWLIST_YES=' cli.sh   # show the new default

./cli.sh --dry-run --yes   # preview: only those five run, the rest are skipped
./cli.sh --backup --yes    # apply, keeping a restorable backup
```

With the array set this way the dry run logs `Auto-accepting OpenCode 2`,
`Auto-accepting OpenAI Codex CLI`, `Auto-accepting Amp`, `Auto-accepting Pi`,
and `Auto-accepting xAI Grok CLI`, and prints `Skipping … (not in -y allowlist)`
for every other tool.

Two things to know before you run it:

- It **replaces** existing assistant configuration for every supported tool, not
  just the allowlisted ones. Shared skills, plugins, hooks, and MCP servers are
  installed everywhere, and files such as `~/.config/opencode/opencode.json` and
  `~/.codex/config.toml` are overwritten. Pass `--backup` so the previous files
  stay restorable.
- The OpenCode config it installs is the author's own: it sets
  `"model": "omnirouter/free"` and providers that expect local services
  (`http://localhost:20128/v1`, `http://127.0.0.1:32124/v1`). On a machine
  without those services the default model will not resolve, and the previous
  `$schema`, `theme`, and `autoupdate` keys are dropped. After installing,
  review `~/.config/opencode/opencode.json` and re-apply your own model and
  provider (or restore the backup) before starting a new OpenCode session.

Notes:

- `--yes` also installs the shared prerequisites (Bun, RTK, global tools) and
  auto-accepts prompts. Node.js or Bun is required — Omarchy provides Node via
  mise.
- `--backup` writes to `~/ai-tools-backup-<timestamp>` (the five most recent are
  kept), and `./cli.sh --rollback` restores the last one.
- Allowlist keys map to installers: `pi` → Pi, `codex` → OpenAI Codex CLI,
  `amp` → Amp, `opencode` → OpenCode 2 (plus `open-cursor`), `grok` → xAI Grok
  CLI.
- Drop `--yes` to run interactively and be prompted per tool; that path installs
  every detected tool rather than just the allowlist.

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

# Work apps (optional; see the work-apps section)
pacman -Q slack-desktop teams-for-linux-bin

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
