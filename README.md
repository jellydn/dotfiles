# dotfiles

A cross-platform dotfiles repository organized with GNU Stow for easy management across macOS and Linux systems.

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/jellydn/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Complete setup (dotfiles + tools + submodules)
./install.sh all

# Or install components separately
./install.sh install       # Install dotfiles only
./install.sh tools         # Install development tools with mise
./install.sh fish          # Install Fish shell and Fisher plugin manager
./install.sh submodules    # Update git submodules
./install.sh backup        # Backup existing dotfiles only
./install.sh uninstall     # Remove dotfiles
./install.sh restow        # Reinstall dotfiles

# Install with options
./install.sh install --with-tools    # Install dotfiles + tools
./install.sh install --update-subs   # Install dotfiles + update submodules
./install.sh install --no-backup     # Install without backing up existing files
./install.sh install --interactive   # Interactive mode with guided prompts
./install.sh install --simulate      # Dry run - see what would be done

# Safe installation workflow (recommended)
./install.sh install --simulate      # Preview changes first
./install.sh install --interactive   # Then install interactively
```

## 📁 Repository Structure

```
dotfiles/
├── common/              # Cross-platform configurations
│   ├── .config/
│   │   ├── claude/     # Claude IDE
│   │   ├── fish/       # Fish shell
│   │   ├── ghostty/    # Ghostty terminal
│   │   ├── helix/      # Helix editor
│   │   ├── k9s/        # Kubernetes CLI
│   │   ├── kitty/      # Kitty terminal
│   │   ├── lazygit/    # Lazygit TUI
│   │   ├── mise/       # Dev tools (replaces .tool-versions)
│   │   ├── nvim/       # Neovim config (submodule)
│   │   ├── herdr/      # Herdr agent multiplexer
│   │   ├── tmux/       # Tmux multiplexer
│   │   ├── vscode/     # VS Code settings
│   │   ├── zed/        # Zed editor
│   │   ├── zellij/     # Zellij multiplexer
│   │   └── Cursor/     # Cursor editor
│   ├── .gitconfig      # Git configuration
│   └── .ideavimrc      # IntelliJ IDEA Vim config
├── macos/              # macOS-specific configurations
│   ├── .aerospace.toml # AeroSpace window manager
│   ├── .alacritty.toml # Alacritty terminal
│   ├── .skhdrc         # SKHD hotkey daemon
│   ├── .wezterm.lua    # WezTerm terminal
│   ├── .yabairc        # Yabai window manager
│   ├── .zshrc          # Zsh configuration
│   ├── .config/
│   │   ├── fish/       # Fish local overrides
│   │   ├── flashspace/ # FlashSpace workspace manager
│   │   ├── karabiner/  # Keyboard customization
│   │   ├── leader-key/ # Leader Key app
│   │   ├── qmk/        # QMK keyboard firmware
│   │   ├── rectangle/  # Window management
│   │   ├── sketchybar/ # Status bar
│   │   ├── tmux/       # Tmux local overrides
│   │   └── zed/        # Zed local overrides
│   └── yabai.sh        # Yabai helper script
├── linux/              # Linux-specific configurations
│   ├── .alacritty.toml # Alacritty terminal
│   ├── .config/
│   │   ├── borders/    # Border decorations
│   │   ├── foot/       # Foot terminal
│   │   ├── fuzzel/     # App launcher
│   │   ├── hypr/       # Hyprland compositor
│   │   ├── i3/         # i3 window manager
│   │   ├── i3status/   # i3 status bar
│   │   ├── input-remapper-2/ # Key remapping
│   │   ├── kanata/     # Keyboard firmware
│   │   ├── kmonad/     # Keyboard remapping
│   │   ├── niri/       # Niri compositor
│   │   ├── polybar/    # Polybar status bar
│   │   ├── rofi/       # App launcher
│   │   ├── swww/       # Wallpaper daemon
│   │   ├── systemd/    # Systemd services
│   │   ├── waybar/     # Wayland status bar
│   │   └── wlogout/    # Wlogout session manager
│   └── evremap.toml    # EVKey remapping
├── scripts/            # Helper scripts
│   ├── install-tools.sh          # Install dev tools with mise
│   ├── install-uv-tools.sh       # Install Python uv tools
│   ├── install-global-npm.sh     # Install global npm packages
│   ├── update-submodules.sh      # Update git submodules
│   ├── merge-zed-settings.sh     # Merge Zed local settings
│   ├── setup-fish-plugins.sh     # Install fish plugins
│   ├── setup-mcp-servers.sh      # Setup MCP servers
│   ├── cleanup-mise.sh           # Clean mise tool cache
│   ├── cursor.sh                 # Cursor helper
│   ├── check-stow.sh             # Validate stow setup
│   └── (platform-specific: hyprland, niri, waybar helpers)
├── install.sh           # Main installation script
├── common/.config/mise/config.toml  # Dev tools managed by mise
├── .stow-local-ignore   # Files to ignore during stowing
└── .gitignore           # Git ignore patterns
```

## 🛠️ Manual Installation

If you prefer manual installation or want to install specific packages:

```bash
# Install GNU Stow first
# macOS: brew install stow
# Linux: sudo apt install stow  # or equivalent for your distro

# Stow common configs (works on both OS)
stow common

# Stow OS-specific configs
stow macos   # On macOS
stow linux   # On Linux

# Unstow (remove symlinks)
stow -D common macos  # or linux
```

> 📖 **New to GNU Stow?** Read our comprehensive [Stow Documentation](docs/STOW.md) to understand how it works, why we use it, and how to test and verify your setup.

## Machine-local overrides (secrets & paths)

Some configs stay in the repo as **examples**; copy to gitignored paths on your machine:

| Tool | Example in repo | On your machine |
|------|-----------------|-----------------|
| mise | `common/.config/mise/config.local.example.toml` | `~/.config/mise/config.local.toml` |
| Zed (private AI/terminal) | `common/.config/zed/settings.local.json.example` (+ optional `macos/...`) | `~/.config/zed/settings.local.json` then run `./scripts/merge-zed-settings.sh --install` |
| tmux (palette, etc.) | `macos/.config/tmux/local.conf.example` | `~/.config/tmux/local.conf` |
| fish (extra PATH) | `macos/.config/fish/conf.d/99-local.example.fish` | `~/.config/fish/conf.d/99-local.fish` |

**Security:** never commit API keys. If an OpenRouter (or other) key was ever committed, rotate it and use `config.local.toml` only.

**Neovim:** `common/.config/nvim` is a submodule — commit changes inside that repo, then update the submodule pointer here.

## 📦 Adding New Configurations

When adding new dotfiles, organize them by platform:

### Cross-platform tools (common/)
```bash
# Add to common/.config/ for tools that work on both macOS and Linux
mkdir -p common/.config/new-tool
cp ~/.config/new-tool/* common/.config/new-tool/
```

### Platform-specific tools
```bash
# macOS-specific (macos/)
mkdir -p macos/.config/macos-app
cp ~/.config/macos-app/* macos/.config/macos-app/

# Linux-specific (linux/)
mkdir -p linux/.config/linux-tool
cp ~/.config/linux-tool/* linux/.config/linux-tool/
```

### Testing configurations
```bash
# Test stowing new config
stow --simulate common  # Dry run to see what would be linked
stow common            # Actually create symlinks

# Remove if something goes wrong
stow -D common
```

## Tools
- [mise-en-place](https://github.com/jdx/mise) - The front-end to your dev env.
- [Zed](https://zed.dev/) - High-performance, multiplayer code editor with AI features
- [Cursor](https://cursor.com/) - AI-first code editor
- [Neovim](https://neovim.io/) - Hyperextensible Vim-based text editor (configured as submodule)
- [Helix](https://helix-editor.com/) - Post-modern modal text editor
- [Ghostty](https://github.com/ghostty-org/ghostty) - 👻 Fast, feature-rich, cross-platform terminal emulator
- [tmux](https://github.com/tmux/tmux) - Terminal multiplexer
- [zellij](https://zellij.dev/) - Terminal multiplexer workspace
- [herdr](https://herdr.dev/) - Terminal workspace manager for AI coding agents
- [lazygit](https://github.com/jesseduffield/lazygit) - Simple terminal UI for git
- [hunk](https://github.com/jaredallard/hunk) - Blazing-fast git pager in Go
- [FlashSpace](https://github.com/wojciech-kulik/FlashSpace) - Blazingly fast virtual workspace manager for macOS
- [Rectangle](https://github.com/rxhanson/Rectangle) - Window management for macOS
- [SketchyBar](https://felixkratz.github.io/SketchyBar/) - Highly customizable macOS status bar
- [karabiner-elements](https://karabiner-elements.pqrs.org) - Powerful keyboard customizer for macOS
- [leader-key](https://github.com/mikker/LeaderKey.app) - Faster than your launcher
- [qmk](https://qmk.fm/) - Quantum Mechanical Keyboard firmware
- [k9s](https://k9scli.io/) - Kubernetes CLI dashboard
- [direnv](https://github.com/direnv/direnv) - Directory-specific environment variables
- [Hurl](https://hurl.dev/) - Run and Test HTTP Requests
- [jq](https://jqlang.github.io/jq/) - Command-line JSON processor
- [difftastic](https://github.com/Wilfred/difftastic) - Structural diff tool
- [just](https://github.com/casey/just) - Command runner
- [fzf](https://github.com/junegunn/fzf) - Fuzzy finder
- [bat](https://github.com/sharkdp/bat) - Cat with syntax highlighting
- [fd](https://github.com/sharkdp/fd) - Fast find alternative
- [ripgrep (rg)](https://github.com/BurntSushi/ripgrep) - Line-oriented search tool
- [raycast](https://www.raycast.com/) - Blazingly fast, totally extendable launcher
- [Marta](https://marta.sh/) - File manager
- [BetterDisplay](https://github.com/waydabber/BetterDisplay) - Unlock your displays on Mac
- [OBS](https://obsproject.com/) - Open Broadcaster Software
- [Yeti X](https://support.logi.com/hc/en-us/articles/13171603624471-Download-Yeti-X) - Blue Yeti X microphone config
- [keycastr](https://github.com/keycastr/keycastr) - Open-source keystroke visualizer
- [caffeine](https://intelliscapesolutions.com/apps/caffeine) - Prevent Mac sleep
- [f.lux](https://justgetflux.com/) - Blue light adjustment
- [git-credential-manager](https://github.com/GitCredentialManager/git-credential-manager/) - Git Credential Manager
- [EVKey](https://evkeyvn.com/) - Vietnamese Keyboard
- [Navicat Premium Lite](https://www.navicat.com/en/download/navicat-premium-lite)

## Deprecated tools
Tools no longer the primary choice (configs preserved in repo for occasional use):
- [fnm](https://github.com/Schniz/fnm) - Node.js version manager (replaced by mise)
- [sourcetreeapp](https://www.sourcetreeapp.com/) - Git GUI
- [starship](https://starship.rs/) - Prompt (replaced by Pure)
- [ohmyz](https://ohmyz.sh/) - Zsh framework (replaced by Pure)
- [powerlevel10k](https://github.com/romkatv/powerlevel10k#oh-my-zsh) - Zsh theme
- [.tmux](https://github.com/gpakosz/.tmux) - Tmux config
- [poetry](https://github.com/python-poetry/poetry) - Python packaging
- [astral-sh/rye](https://github.com/astral-sh/rye) - Python experience
- [Fig](https://fig.sh/) - Terminal autocomplete
- [iterm2](https://iterm2.com/) - Terminal emulator
- [warp](https://app.warp.dev/referral/2ENQM7) - Terminal emulator
- [OrbStack](https://orbstack.dev/) - Docker & Linux on macOS
- [pock](https://pock.app/) - Touch Bar widgets
- [httpie](https://github.com/httpie/httpie) - HTTP client
- [spectacleapp](https://www.spectacleapp.com/) - Window management
- [AltTab](https://alt-tab-macos.netlify.app/) - Windows alt-tab on macOS
- [krisp AI](https://ref.krisp.ai/u/u458fbd216) - Noise cancellation
- [ianyh/Amethyst](https://github.com/ianyh/Amethyst) - Tiling window manager
- [colima](https://github.com/abiosoft/colima) - Container runtimes
- [medis](https://github.com/luin/medis) - Redis GUI

**Configs preserved (may still be used occasionally):**
- [AeroSpace](https://github.com/nikitabobko/AeroSpace) - macOS window manager (config at `macos/.aerospace.toml`)
- [Yabai](https://github.com/koekeishiya/yabai) + [SKHD](https://github.com/koekeishiya/skhd) - macOS tiling WM (configs at `macos/.yabairc`, `macos/.skhdrc`)
- [Kitty](https://github.com/kovidgoyal/kitty) - GPU terminal (config at `common/.config/kitty/`)
- [WezTerm](https://wezfurlong.org/wezterm/) - GPU terminal (config at `macos/.wezterm.lua`)
- [Alacritty](https://alacritty.org/) - OpenGL terminal (configs at `macos/.alacritty.toml`, `linux/.alacritty.toml`)



## 🔧 Development Tools Management

### Automated Tool Installation

The repository includes automated tool installation using [mise](https://mise.jdx.dev/):

```bash
# Install all development tools defined in mise/config.toml
./install.sh tools

# Or use the helper script directly
./scripts/install-tools.sh
```

### Managed Tools (mise config.toml)

Development tools automatically installed by [mise](https://mise.jdx.dev/):
- **Languages**: Node.js, Python, Go, Rust, Deno, Bun, Ruby, Lua
- **CLI Tools**: ripgrep (rg), fd, bat, fzf, jq, delta, lazygit, gh, zoxide, neovim, just, hurl
- **Tooling**: ruff, black, shellcheck, shfmt, yamllint, dprint, biome, prettier
- **Formatting**: stylua, difftastic, dprint
- **Utility**: ffmpeg, usage, yq/jq, uv, ctop, aube, prek, dotnet

### Git Submodules Management

Update editor configurations (Neovim, Zed, VSCode):

```bash
# Update all submodules
./install.sh submodules

# Or use the helper script directly
./scripts/update-submodules.sh

# Update specific submodule
./scripts/update-submodules.sh update-specific nvim

# List all submodules
./scripts/update-submodules.sh list
```

### Manual Prerequisites

Some tools need manual installation:

```bash
# Install GNU Stow (required)
# macOS: brew install stow
# Linux: sudo apt install stow

# Install mise (automatically handled by install-tools.sh)
curl https://mise.run | sh
```

### Shell Setup

Fish is the primary shell. Zsh is available as an alternative.

```bash
# Install Fish (if not already installed)
brew install fish # macOS
sudo apt install fish # Linux

# Set Fish as the default shell
echo "/opt/homebrew/bin/fish" | sudo tee -a /etc/shells
chsh -s /opt/homebrew/bin/fish

# Install Fisher (plugin manager)
fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"
```

If using Zsh instead:
```bash
# Install Pure prompt
brew install pure

# Initialize the prompt system and choose pure:
# autoload -U promptinit; promptinit
# prompt pure
```

## 📝 Install Script Usage

### Commands
```bash
Usage: ./install.sh [install|uninstall|restow|tools|submodules|all|backup|fish]

Commands:
  install      - Install dotfiles only (default)
  uninstall    - Remove dotfiles symlinks
  restow       - Remove and reinstall dotfiles
  tools        - Install development tools with mise
  fish         - Install Fish shell and Fisher plugin manager
  submodules   - Update git submodules
  all          - Install dotfiles, tools, and update submodules
  backup       - Backup existing dotfiles only

Options:
  --with-tools     - Install tools along with dotfiles
  --update-subs    - Update submodules along with dotfiles
  --no-backup      - Skip backing up existing dotfiles
  --interactive    - Interactive mode with prompts for choices
  --simulate       - Dry run - show what would be done without doing it
```

### Examples
```bash
# Basic installation
./install.sh                            # Install dotfiles only
./install.sh all                         # Complete setup

# Installation with options
./install.sh install --with-tools        # Dotfiles + development tools
./install.sh install --update-subs       # Dotfiles + git submodules
./install.sh install --no-backup         # Skip existing file backup
./install.sh install --simulate          # Preview changes (dry run)

# Interactive installation
./install.sh install --interactive       # Guided installation with prompts

# Component-specific installation  
./install.sh tools                       # Only install development tools
./install.sh fish                        # Only install Fish shell
./install.sh submodules                  # Only update git submodules
./install.sh backup                      # Only backup existing dotfiles

# Maintenance commands
./install.sh uninstall                   # Remove all dotfile symlinks
./install.sh restow                      # Reinstall (remove then install)
```

## 🤖 Interactive Installation

For first-time users or those who want guided installation:

```bash
./install.sh install --interactive
```

**Interactive features:**
- **Conflict detection**: Shows existing dotfiles that would be overwritten
- **Backup choices**: Ask whether to backup existing files before installation  
- **Package selection**: Choose which configuration groups to install
- **Component options**: Prompt for development tools and git submodules
- **Safety confirmations**: Multiple confirmation prompts for destructive actions

**Interactive prompts include:**
- `Do you want to backup these files before installation? [Y/n]`
- `Install common (cross-platform) configurations? [Y/n]`
- `Install macos-specific configurations? [Y/n]` (or linux-specific)
- `Install development tools with mise? [y/N]`
- `Update git submodules (editor configs)? [y/N]`

## 🛡️ Backup Protection

The install script automatically backs up your existing dotfiles before installation:

- **Automatic backup**: Creates timestamped backup directory (e.g., `~/dotfiles-backup-20241201-143022`)
- **Smart detection**: Only backs up real files, not existing stow symlinks
- **Hidden files**: Backed up files start with `.` (use `ls -la backup-dir` to see them)
- **Easy restoration**: Instructions provided to restore from backup
- **Optional**: Use `--no-backup` flag to skip backup process

### Backup Coverage
The backup process protects these configurations:
- Shell configs (`.zshrc`, `.bashrc`, `.config/fish`)
- Editor configs (`.config/nvim`, `.config/helix`, `.vimrc`)
- Terminal configs (`.config/ghostty`, `.config/kitty`, `.alacritty.toml`, `.config/foot`)
- Window manager configs (`.yabairc`, `.config/i3`, `.config/hypr`, `.config/waybar`, `.config/rofi`)
- Development configs (`.gitconfig`, `.tmux.conf`, `.config/mise`)
- Multiplexer configs (`.config/herdr`, `.config/zellij`, `.config/tmux`)

## 📋 Configuration Notes

### Window Management
- **macOS**: Uses FlashSpace for workspace management; Yabai + SKHD still available for tiling
- **Linux**: Supports Hyprland, i3, Niri, and other window managers

### Terminal Setup
- **Cross-platform**: Ghostty terminal with Kanagawa theme
- **Alternatives**: Kitty, WezTerm, Alacritty terminals also configured
- **Shell**: Fish shell (default) with Pure prompt; Zsh available as alternative

### Editor Configuration
- **Neovim**: Minimal, fast configuration with essential features
- **Helix**: Alternative editor setup

### Karabiner Complex Modification

Change `caps_lock` to `left_control` if pressed with other keys, change `caps_lock` to `escape` if pressed alone. More on https://ke-complex-modifications.pqrs.org/

```json
{
  "description": "Change caps_lock to left_control if pressed with other keys, change caps_lock to escape if pressed alone.",
  "manipulators": [
    {
      "from": {
        "key_code": "caps_lock",
        "modifiers": { "optional": ["any"] }
      },
      "to": [
        {
          "hold_down_milliseconds": 400,
          "key_code": "left_control"
        }
      ],
      "to_if_alone": [
        {
          "key_code": "escape",
          "lazy": true
        }
      ],
      "type": "basic"
    }
  ]
}
```

### Tip

- Hide desktop icon

```sh
defaults write com.apple.finder CreateDesktop false
killall Finder
```

- Hide Dock

```sh
defaults write com.apple.dock autohide -bool true && killall Dock
defaults write com.apple.dock autohide-delay -float 1000 && killall Dock
defaults write com.apple.dock no-bouncing -bool TRUE && killall Dock
```

- Restore Dock

```sh
defaults write com.apple.dock autohide -bool false && killall Dock
defaults delete com.apple.dock autohide-delay && killall Dock
defaults write com.apple.dock no-bouncing -bool FALSE && killall Dock
```

### Leader Key

- Map Right-CMD to Hyper key on Raycast
- Map Right-shift to Right Cmd-Space
- Map leader key with Hyper + Space

[![Raycast + Leaderkey](https://i.gyazo.com/27f7df849ca4625e7864efb08f896e72.gif)](https://gyazo.com/27f7df849ca4625e7864efb08f896e72)

### OBS setting for Blue Yeti Microphone

- Noise Suppression

[![Image from Gyazo](https://i.gyazo.com/d56efbfb5526573702527574f6fa00c7.png)](https://gyazo.com/d56efbfb5526573702527574f6fa00c7)

- Noise Gate

[![Image from Gyazo](https://i.gyazo.com/5c21fd448eea64903b62e1faf7b2309b.png)](https://gyazo.com/5c21fd448eea64903b62e1faf7b2309b)

- Compressor

[![Image from Gyazo](https://i.gyazo.com/f96c1d8d35126cc5f259629f61eea64e.png)](https://gyazo.com/f96c1d8d35126cc5f259629f61eea64e)

### Tmux

After installing the dotfiles, you need to install tmux plugins:

1. Install TPM (Tmux Plugin Manager):
   ```bash
   git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
   ```

2. Reload tmux configuration:
   ```bash
   tmux source-file ~/.config/tmux/tmux.conf
   ```

3. Install plugins by pressing `Ctrl+a` (prefix) + `I` inside tmux

**Key Bindings:**
- **Prefix key**: `Ctrl+a` (GNU Screen style)
- **Window navigation**: 
  - `Prefix + Tab` - Next window
  - `Prefix + Shift+Tab` - Previous window
- **Pane navigation**: `Prefix + h/j/k/l` (Vim-style)
- **Smart pane switching**: `Ctrl+h/j/k/l` (works with Vim splits)
- **Split panes**:
  - `Prefix + -` - Horizontal split
  - `Prefix + _` - Vertical split
- **Reload config**: `Prefix + r`
- **Edit config**: `Prefix + e`

**URL Opening:**
- **Cmd+click** (macOS) - Click URLs while holding Cmd to open in browser (no plugins needed)
- `Prefix + u` - Extract URLs with fzf and open selected URL
- `Prefix + Ctrl+u` - Copy first URL to clipboard
- Built-in terminal URL handling via terminal overrides

### Helix

- Refer to [./helix/README.md](/helix/README.md) for how to setup like my Neovim.
