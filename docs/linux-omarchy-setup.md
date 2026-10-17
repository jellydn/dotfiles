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

# Optional: systray icon. Slack's optdep is libappindicator-gtk3, provided by
# extra/libappindicator; Omarchy's bar already ships omarchy.tray.
omarchy pkg add libappindicator
```

**Microsoft Teams** — Microsoft ships no native Linux package. Omarchy's web
app is the recommended route and now uses Microsoft's `cloud.microsoft` domain:

```bash
# Teams only (Chromium web app; works on any architecture)
omarchy webapp install "Microsoft Teams" https://teams.cloud.microsoft/ \
  https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/microsoft-teams.png

# Or the full Microsoft bundle: Teams plus Outlook, Word, Excel,
# PowerPoint, and OneDrive as web apps
omarchy install service microsoft
```

For a native window with a **tray icon** instead — the Chromium web app has no
tray — use the community Electron client (`omarchy pkg aur add
teams-for-linux-bin`); it wraps the same web client and uses PipeWire for screen
sharing, which Omarchy already provides.

To remove them later:

```bash
omarchy pkg drop slack-desktop teams-for-linux-bin
omarchy remove service microsoft   # only for the Microsoft bundle
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

## Optional: Editors (Zed, VS Code, and Cursor)

Omarchy installs and themes Zed and VS Code itself:

| Command | Installs | Available here (aarch64) |
| --- | --- | --- |
| `omarchy install editor zed` | `zed` plus `omazed` (live Omarchy theme for Zed) | `zed` 1.24.2-1 from Omarchy's repo |
| `omarchy install editor vscode` | AUR `visual-studio-code-bin`, keyring secrets via libsecret, `update.mode: none` | AUR ships `x86_64`, `aarch64`, and `armv7h` |
| *(no installer)* | Cursor: `scripts/cursor.sh` launches the AppImage, while `installer/install-cursor.sh` expects an x86_64 RPM | Cursor publishes an `aarch64` AppImage |

VS Code does **not** read XDG paths on every OS, so the repo keeps one copy under
`common/.config/Code/User/` and links it to the path each OS reads:

| OS | Path VS Code reads | How this repo wires it |
| --- | --- | --- |
| Linux / Omarchy | `~/.config/Code/User/` | the `[dotfiles]` entries in `common/.config/mise/config.toml`, or the `ln -s` calls below |
| macOS | `~/Library/Application Support/Code/User/` | the entries in `common/.config/mise/config.macos.toml` |
| Windows 11 | `%APPDATA%\Code\User\` | `windows/setup.ps1` copies the files, because symlinks need Developer Mode |

Wire it by hand on Omarchy. Link only these three entries, never the whole
`~/.config/Code` directory: VS Code writes `User/globalStorage/`, `CachedData`,
and logs there, and that runtime state must stay out of the repo.

```bash
mkdir -p ~/.config/Code/User
ln -sfn ~/.dotfiles/common/.config/Code/User/settings.json    ~/.config/Code/User/settings.json
ln -sfn ~/.dotfiles/common/.config/Code/User/keybindings.json ~/.config/Code/User/keybindings.json
ln -sfn ~/.dotfiles/common/.config/Code/User/snippets         ~/.config/Code/User/snippets
```

Order matters. `omarchy install editor vscode` writes a fresh
`~/.config/Code/User/settings.json` holding `{"update.mode": "none"}`. Run it
**before** creating the links: a shell redirect into an existing symlink follows
that symlink and would overwrite the repo copy.

Omarchy also rewrites `workbench.colorTheme` on every theme switch, with
`sed -i --follow-symlinks`, so it edits the repo copy. Stop it with:

```bash
omarchy toggle skip-vscode-theme-changes
```

`update.mode: none` suits this AUR package but is wrong on macOS and Windows,
where the vendor build should keep updating itself. Add it to the repo settings
only if Linux is your only VS Code.

For Zed, `omazed` regenerates the theme by moving a new file over
`~/.config/zed/settings.json`, which replaces a symlink with a real file. Use the
repo's merge script instead, and symlink only the files that nothing rewrites:

```bash
omarchy install editor zed
./scripts/merge-zed-settings.sh --install           # settings.json, as a real file
ln -sfn ~/.dotfiles/common/.config/zed/keymap.json ~/.config/zed/keymap.json
ln -sfn ~/.dotfiles/common/.config/zed/tasks.json  ~/.config/zed/tasks.json
```

Keep `~/.config/zed` a real directory: `omazed` also generates
`~/.config/zed/themes/omazed.json`, which must never land in the repo.

### Zed in a virtual machine needs a Vulkan driver

Omarchy installs Vulkan drivers only for Intel, AMD, Apple, and Qualcomm GPUs
(`/usr/share/omarchy/install/hardware/vulkan.sh`), with NVIDIA handled by
`nvidia.sh`. In a QEMU/virtio guest no vendor matches, so the only installable
client driver left is `nvidia-utils`' and there is no usable device. Zed renders
through wgpu, so it fails with:

```text
error opening [/path/to/project]: No GPU adapter found that can configure the display surface
```

`~/.local/share/zed/logs/Zed.log` shows why: Vulkan enumeration fails and the
only other candidate, the virgl OpenGL adapter, is rejected by wgpu.

```text
ERROR [wgpu_hal::vulkan::instance] enumerate_adapters: Initialization of an object has failed
INFO  [gpui_wgpu::wgpu_context]   - virgl (Apple M2 Pro) (backend=Gl, type=IntegratedGpu)
INFO  [gpui_wgpu::wgpu_context] Adapter virgl (Apple M2 Pro) (Gl) failed: Failed to create
      wgpu device: Limit 'max_compute_workgroups_per_dimension' value 65535 is better than
      allowed 0, trying next...
ERROR [zed::zed::open_listener] failed to open workspace [...]: No GPU adapter found ...
```

Install Mesa's CPU rasterizer and restart Zed. Close any Zed windows opened
before the driver existed — that instance keeps failing and only prints
`zed is already running`:

```bash
omarchy pkg add vulkan-swrast vulkan-tools
vulkaninfo --summary | sed -n '/^Devices:/,$p'   # expect: llvmpipe (LLVM ..., 128 bits)
zed .
```

Zed then logs `Selected GPU adapter: "llvmpipe (LLVM ..., 128 bits)" (Vulkan)`
with `is_software_emulated: true`: it works, but the UI is CPU-rendered, so
expect soft scrolling. Accelerated Vulkan would need the host to pass through
Venus (`virtio-gpu` with `venus=on`); `vulkan-virtio` reports no device on this VM.

Electron apps are unaffected — they render through OpenGL/virgl, which is what
Slack, Teams, and VS Code use here — so this is a Vulkan-only problem.

Do not run `./install.sh stow-app Code`. That links the whole `~/.config/Code`
directory instead of the three entries, and drags editor runtime state into the
repo. `stow-app Cursor` and full-repo stows have the same whole-directory
behaviour, which is why the per-OS mappings above are preferred.

Verify:

```bash
readlink -f ~/.config/Code/User/settings.json   # must resolve inside ~/.dotfiles
grep -n '"workbench.colorTheme"' ~/.config/Code/User/settings.json
readlink -f ~/.config/zed/keymap.json
```

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
