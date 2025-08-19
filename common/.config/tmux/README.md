# Tmux Configuration

A clean, minimal tmux configuration based on [typecraft-dev dotfiles](https://github.com/typecraft-dev/dotfiles) with Kanagawa color scheme and essential plugins.

## Features

- **Clean & Minimal**: Simplified configuration without bloat
- **Kanagawa Theme**: Beautiful color scheme from [kanagawa.nvim](https://github.com/rebelot/kanagawa.nvim)
- **Vim Integration**: Seamless navigation between vim and tmux panes
- **Session Persistence**: Restore sessions with tmux-resurrect
- **Mouse Support**: Modern mouse interaction support

## Installation

The tmux configuration is integrated into the dotfiles:

```sh
# Using the dotfiles install script
./install.sh stow-app tmux

# Or manually symlink
ln -sf ~/.config/tmux/tmux.conf ~/.tmux.conf
```

## Usage

### Starting tmux

```sh
# Start new session
tmux

# Start named session
tmux new -s session_name

# Attach to existing session
tmux attach -t session_name

# List sessions
tmux ls
```

## Key Bindings

### Prefix Key
- **Prefix**: `Ctrl+s` (changed from default `Ctrl+b`)

### Session Management

| Keybinding | Action |
|------------|--------|
| `Prefix + d` | Detach from session |
| `Prefix + s` | List and switch sessions |
| `Prefix + $` | Rename current session |

### Window Management

| Keybinding | Action |
|------------|--------|
| `Prefix + c` | Create new window |
| `Prefix + ,` | Rename current window |
| `Prefix + &` | Kill current window |
| `Prefix + n` | Next window |
| `Prefix + p` | Previous window |
| `Prefix + 0-9` | Switch to window by number |

### Pane Management

| Keybinding | Action |
|------------|--------|
| `Prefix + %` | Split pane vertically |
| `Prefix + "` | Split pane horizontally |
| `Prefix + x` | Kill current pane |
| `Prefix + z` | Toggle pane zoom |
| `Prefix + q` | Show pane numbers |

### Vim-style Pane Navigation

| Keybinding | Action |
|------------|--------|
| `Prefix + h` | Select left pane |
| `Prefix + j` | Select pane below |
| `Prefix + k` | Select pane above |
| `Prefix + l` | Select right pane |

### Smart Vim-Tmux Navigation
*Works both in tmux and vim without prefix*

| Keybinding | Action |
|------------|--------|
| `Ctrl + h` | Navigate left (vim pane or tmux pane) |
| `Ctrl + j` | Navigate down (vim pane or tmux pane) |
| `Ctrl + k` | Navigate up (vim pane or tmux pane) |
| `Ctrl + l` | Navigate right (vim pane or tmux pane) |
| `Ctrl + \` | Navigate to last pane |

### Scrolling & Copy Mode

| Keybinding | Action |
|------------|--------|
| `PageUp` | Scroll up (enters copy mode) |
| `PageDown` | Scroll down |
| `Prefix + [` | Enter copy mode |
| `Space` | Start selection (in copy mode) |
| `Enter` | Copy selection (in copy mode) |
| `Prefix + ]` | Paste |
| `q` | Exit copy mode |

### Miscellaneous

| Keybinding | Action |
|------------|--------|
| `Prefix + r` | Reload configuration |
| `Prefix + e` | Edit configuration (opens in nvim) |
| `Prefix + t` | Show clock |
| `Prefix + ?` | List all key bindings |
| `Prefix + :` | Command prompt |

## Plugins

### Tmux Plugin Manager (TPM)
Manages tmux plugins automatically.

**Installation**: Plugins are automatically installed when you start tmux.

**Manual plugin management**:
- `Prefix + I` - Install plugins
- `Prefix + U` - Update plugins  
- `Prefix + Alt + u` - Uninstall plugins

### Vim-Tmux Navigator
Seamless navigation between vim and tmux panes.

**Features**:
- Navigate between vim splits and tmux panes with the same keys
- Works with vim, nvim, and other vim-like editors
- Supports lazygit and fzf integration

### Tmux Resurrect
Persist tmux sessions across system restarts.

**Usage**:
- `Prefix + Ctrl + s` - Save session
- `Prefix + Ctrl + r` - Restore session

**Features**:
- Automatically saves pane contents
- Restores vim and nvim sessions
- Saves and restores directory structure

## Color Scheme

The configuration uses the Kanagawa color palette:

- **Dark Gray**: `#16161D` - Background
- **Light Blue**: `#7fb4ca` - Active elements
- **Yellow**: `#e6c384` - Highlights
- **Light Gray**: `#727169` - Secondary text
- **Green**: `#98bb6c` - Success states
- **Red**: `#C34043` - Error states

## Configuration Structure

```
~/.config/tmux/
├── tmux.conf          # Main configuration file
├── tmux.conf.backup   # Backup of previous config
└── README.md          # This file
```

## Customization

To customize the configuration, edit `~/.config/tmux/tmux.conf`:

### Change Prefix Key
```tmux
# Change back to Ctrl+b if preferred
set -g prefix C-b
unbind C-s
bind C-b send-prefix
```

### Modify Colors
```tmux
# Example: Change active pane border color
kanagawa_custom_blue="#your_color_here"
set -g pane-active-border-style "fg=$kanagawa_custom_blue"
```

### Add Custom Key Bindings
```tmux
# Example: Quick window splits
bind | split-window -h -c '#{pane_current_path}'
bind - split-window -v -c '#{pane_current_path}'
```

## Troubleshooting

### Colors not displaying correctly
Ensure your terminal supports true color:
```sh
# Add to your shell profile
export TERM="xterm-256color"
```

### Vim navigation not working
Make sure vim-tmux-navigator is installed in your vim/nvim configuration.

### Plugins not loading
Manually install TPM:
```sh
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

Then restart tmux and press `Prefix + I` to install plugins.

## Author

👤 **Huynh Duc Dung**

- Website: https://productsway.com/
- Twitter: [@jellydn](https://twitter.com/jellydn)
- Github: [@jellydn](https://github.com/jellydn)

## Show your support

If this guide has been helpful, please give it a ⭐️.