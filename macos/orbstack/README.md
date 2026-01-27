# OrbStack Ubuntu Setup

Automated setup script for configuring a fresh Ubuntu machine on OrbStack with essential development tools.

## Quick Start

Run the setup script with a single command:

```bash
curl -fsSL https://raw.githubusercontent.com/jellydn/dotfiles/refs/heads/master/macos/orbstack/setup.sh | bash
```

Or if you have cloned the repository:

```bash
./macos/orbstack/setup.sh
```

## Prerequisites

- [OrbStack](https://orbstack.dev) installed
- Ubuntu machine (Ubuntu 22.04+ recommended)
- Internet connection for downloading dependencies
- Sudo privileges (for installing system packages)

## What Gets Installed

| Tool                | Purpose                                  |
| ------------------- | ---------------------------------------- |
| **git**             | Version control                          |
| **curl**            | Command-line tool for transferring data  |
| **build-essential** | Build tools (gcc, make, etc.)            |
| **Homebrew**        | Package manager for Linux                |
| **mise**            | Version manager for development runtimes |
| **fish shell**      | Modern, user-friendly shell              |
| **pure prompt**     | Minimalist prompt for fish               |
| **Neovim**          | Modern text editor with tiny-nvim config |
| **Node.js**         | Required for Neovim plugins              |

## Key Features

- **Isolated Configuration**: Uses `/tmp/mise-local` for mise data directory to avoid conflicts with macOS environment
- **Automated Setup**: Installs and configures all tools in one go
- **Plugin Installation**: Automatically installs Neovim plugins via lazy.nvim
- **Shell Migration**: Sets fish as default shell with proper configuration
- **Non-interactive**: Runs without prompts for easy automation

## Post-Installation Steps

### Start Using Fish

```bash
fish
```

### Verify Installations

```bash
brew --version
mise --version
fish --version
nvim --version
```

### Open Neovim

```bash
nvim
```

The first time you open Neovim, it will automatically install all plugins defined in the tiny-nvim configuration.

## Troubleshooting

### Fish is Not Set as Default Shell

If the automatic shell change didn't work, run:

```bash
chsh -s /usr/bin/fish
```

Then restart your shell or reconnect to the OrbStack machine.

### Manually Add to PATH

If commands aren't found after installation, add this to your `~/.config/fish/config.fish`:

```fish
# Homebrew
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# mise (isolated data directory for OrbStack)
set -gx MISE_DATA_DIR "/tmp/mise-local"
~/.local/bin/mise activate fish | source
```

### Neovim Plugins Not Installing

Run this command in fish:

```bash
NVIM_APPNAME=nvim nvim --headless -c "Lazy install" -c "qa"
```

## Notes

- This script is specifically designed for OrbStack Ubuntu VMs
- The isolated mise configuration prevents conflicts with your macOS mise setup
- Pure prompt provides a clean, informative command-line experience
- tiny-nvim configuration is maintained by [@jellydn](https://github.com/jellydn)

## What's Next?

After setup, you can:

1. Install additional tools with `brew install <package>`
2. Manage Node.js versions with `mise use node@lts`
3. Customize your fish configuration in `~/.config/fish/config.fish`
4. Extend your Neovim configuration in `~/.config/nvim/`

## Support

For issues or questions:

- Check the [Troubleshooting](#troubleshooting) section
- Open an issue on the [dotfiles repository](https://github.com/jellydn/dotfiles/issues)
