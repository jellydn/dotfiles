# dotfiles

A cross-platform dotfiles repository organized with GNU Stow for easy management across macOS and Linux systems.

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/your-username/dotfiles.git ~/.dotfiles
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
├── common/           # Cross-platform configurations
│   ├── .config/
│   │   ├── nvim/    # Neovim config
│   │   ├── fish/    # Fish shell
│   │   ├── helix/   # Helix editor
│   │   ├── ghostty/ # Ghostty terminal
│   │   ├── kitty/   # Kitty terminal
│   │   ├── lazygit/ # Lazygit TUI
│   │   ├── zellij/  # Zellij terminal multiplexer
│   │   └── ...
│   └── .gitconfig   # Git configuration
├── macos/           # macOS-specific configurations
│   ├── .config/
│   │   ├── karabiner/   # Keyboard customization
│   │   ├── sketchybar/  # Status bar
│   │   ├── rectangle/   # Window management
│   │   └── ...
│   ├── .zshrc          # Zsh configuration
│   ├── .yabairc        # Yabai window manager
│   └── ...
├── linux/           # Linux-specific configurations
│   ├── .config/
│   │   ├── hypr/       # Hyprland compositor
│   │   ├── waybar/     # Wayland status bar
│   │   ├── i3/         # i3 window manager
│   │   ├── foot/       # Foot terminal
│   │   └── ...
│   └── ...
├── scripts/         # Helper scripts
│   ├── install-tools.sh     # Install development tools with mise
│   └── update-submodules.sh # Update git submodules
├── install.sh       # Main installation script
├── .tool-versions   # Development tools managed by mise
├── .stow-local-ignore  # Files to ignore during stowing
└── .gitignore       # Git ignore patterns
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
- [FlashSpace](https://github.com/wojciech-kulik/FlashSpace) - FlashSpace is a blazingly fast virtual workspace manager for macOS.
- [Rectangle](https://github.com/rxhanson/Rectangle) - Move and resize windows on macOS with keyboard shortcuts and snap areas.
- [ghostty](https://github.com/ghostty-org/ghostty) - 👻 Ghostty is a fast, feature-rich, and cross-platform terminal emulator that uses platform-native UI and GPU acceleration.
- [raycast](https://www.raycast.com/) - is a blazingly fast, totally extendable
  launcher.
- [leader-key](https://github.com/mikker/LeaderKey.app) - Faster than your launcher
- [delta](https://github.com/dandavison/delta) - a syntax-highlighting pager for git, diff, and grep output
- [lazygit](https://github.com/jesseduffield/lazygit): simple terminal UI for git commands
- [Marta](https://marta.sh/) - file manager
- [f.lux](https://justgetflux.com/) - makes the color of your computer's display
  adapt to the time of day, warm at night and like sunlight during the day.
- [caffeine](https://intelliscapesolutions.com/apps/caffeine) - don't let your Mac fall asleep.
- [git-credential-manager](https://github.com/GitCredentialManager/git-credential-manager/) - Git Credential Manager
- [karabiner-elements](https://karabiner-elements.pqrs.org) - a powerful and stable keyboard customizer for macOS.
- [poetry](https://github.com/python-poetry/poetry) - Python packaging and dependency management made easy
- [astral-sh/rye](https://github.com/astral-sh/rye) - a Hassle-Free Python Experience
- [direnv](https://github.com/direnv/direnv) - unclutter your .profile.
- [gyazo](https://gyazo.com/) - share and search what you see. Instantly.
- [colima](https://github.com/abiosoft/colima) - Container runtimes on macOS (and Linux) with minimal setup
- [medis](https://github.com/luin/medis) - Medis is a beautiful, easy-to-use Mac database management application for Redis
- [keycastr](https://github.com/keycastr/keycastr) - KeyCastr, an open-source keystroke visualizer
- [EVKey](https://evkeyvn.com/) - Vietnamese Keyboard
- [Navicat Premium Lite](https://www.navicat.com/en/download/navicat-premium-lite)
- [BetterDisplay](https://github.com/waydabber/BetterDisplay?tab=readme-ov-file) - Unlock your displays on your Mac! Smooth scaling, HiDPI unlock, XDR/HDR extra brightness upscale, DDC, brightness and dimming, virtual screens, PIP and lots more!
- [SketchyBar](https://felixkratz.github.io/SketchyBar/) - A highly customizable macOS status bar replacement
- [OBS](https://obsproject.com/) - Open Broadcaster Software
- [Yeti X](https://support.logi.com/hc/en-us/articles/13171603624471-Download-Yeti-X)
- [Hurl](https://hurl.dev/) - Run and Test HTTP Requests
- [restish](https://github.com/danielgtaylor/restish) - Restish is a CLI for interacting with REST-ish HTTP APIs with some nice features built-in

## Deprecated tools
- [fnm](https://github.com/Schniz/fnm) - 🚀 fast and simple Node.js version manager, built in Rust
- [sourcetreeapp](https://www.sourcetreeapp.com/) - simplicity and power in a beautiful Git GUI
- [starship](https://starship.rs/) - the minimal, blazing-fast, and infinitely customizable prompt for any shell!
- [ohmyz](https://ohmyz.sh/) - a delightful, open source, community-driven
  framework for managing your Zsh configuration
- [powerlevel10k](https://github.com/romkatv/powerlevel10k#oh-my-zsh) A
  Zsh theme
- [.tmux](https://github.com/gpakosz/.tmux) - oh my tmux! My self-contained, pretty & versatile tmux configuration made with ❤️
- [AeroSpace](https://github.com/nikitabobko/AeroSpace) - AeroSpace is an i3-like tiling window manager for macOS.
- [Fig](https://fig.sh/) - adds IDE-style autocomplete to your existing terminal
- [iterm2](https://iterm2.com/) - a replacement for Terminal
- [WezTerm](https://wezfurlong.org/wezterm/) - Wez's Terminal Emulator
- [kitty](https://github.com/kovidgoyal/kitty) - Cross-platform, fast, feature-rich, GPU based terminal
- [warp](https://app.warp.dev/referral/2ENQM7) - the terminal for the 21st century
  emulator
- [OrbStack](https://orbstack.dev/) - Fast, light, simple Docker & Linux on macOS
- [pock](https://pock.app/) - widgets manager for MacBook Touch Bar
- [httpie](https://github.com/httpie/httpie) - HTTPie for Terminal — modern, user-friendly command-line HTTP client for the API era. JSON support, colors, sessions, downloads, plugins & more
- [spectacleapp](https://www.spectacleapp.com/) - move and resize windows with ease
- [AltTab](https://alt-tab-macos.netlify.app/) - Windows alt-tab on macOS
- [alacritty](https://alacritty.org/) - A cross-platform, OpenGL terminal
- [koekeishiya/yabai](https://github.com/koekeishiya/yabai): A tiling window manager for macOS based on binary space partitioning
- [koekeishiya/skhd](https://github.com/koekeishiya/skhd): Simple hotkey daemon for macOS
- [krisp AI](https://ref.krisp.ai/u/u458fbd216) - Noise cancellation App
- [ianyh/Amethyst](https://github.com/ianyh/Amethyst) - Automatic tiling window manager for macOS à la xmonad.

### Neovim Configuration

```sh
git clone https://github.com/jellydn/tiny-nvim ~/.config/nvim
```

## 🔧 Development Tools Management

### Automated Tool Installation

The repository includes automated tool installation using [mise](https://mise.jdx.dev/):

```bash
# Install all development tools defined in .tool-versions
./install.sh tools

# Or use the helper script directly
./scripts/install-tools.sh
```

### Managed Tools (.tool-versions)

Development tools automatically installed by mise:
- **Languages**: Node.js, Python, Go, Rust, Deno, Bun
- **CLI Tools**: ripgrep, fd, bat, fzf, jq, delta, lazygit, gh

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

### Shell Setup (Optional)

If using Fish shell:
```bash
# Install Fish
brew install fish # macOS
sudo apt install fish # Linux

# Set as default shell
chsh -s $(which fish)
```

If using Zsh with Oh My Zsh:
```bash
# Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# Install plugins
cd ~/.oh-my-zsh/custom/plugins/
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git
git clone https://github.com/zsh-users/zsh-autosuggestions.git
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
- Multiplexer configs (`.config/zellij`, `.config/tmux`)

## 📋 Configuration Notes

### Window Management
- **macOS**: Uses Yabai + SKHD for tiling window management
- **Linux**: Supports Hyprland, i3, and other window managers

### Terminal Setup
- **Cross-platform**: Ghostty terminal with Kanagawa theme
- **Alternatives**: Kitty terminal also configured
- **Shell**: Fish shell with custom theme and functions

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

### Oh My Tmux

- Refer to [./tmux/README.md](/tmux/README.md) for more details.

### Helix

- Refer to [./helix/README.md](/helix/README.md) for how to setup like my Neovim.
