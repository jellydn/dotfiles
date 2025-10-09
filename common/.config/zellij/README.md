# Zellij Configuration

A modern terminal workspace configuration for Zellij with Kanagawa color scheme, vim-style navigation, and tmux compatibility mode.

## Features

- **Kanagawa Theme**: Beautiful color scheme matching neovim kanagawa theme
- **Modal Editing**: Vim-inspired modal system for different operations
- **Tmux Compatibility**: Familiar tmux keybindings for easy migration
- **Session Manager**: Built-in session management with floating window
- **Simplified UI**: Clean interface with hidden session names and no pane frames
- **Fish Integration**: Uses Fish shell as default

## Installation

The Zellij configuration is integrated into the dotfiles:

```sh
# Using the dotfiles install script
./install.sh stow-app zellij

# Or manually symlink
ln -sf ~/.config/zellij ~/.config/zellij
```

## Usage

### Starting Zellij

```sh
# Start new session
zellij

# Start named session
zellij -s session_name

# Attach to existing session
zellij attach session_name

# List sessions
zellij list-sessions

# Delete a session
zellij delete-session session_name
```

## Key Bindings

### Mode System

Zellij uses a modal system similar to vim. Press the mode key to enter a mode, perform actions, then `Enter` or `Esc` to return to normal mode.

| Mode | Keybinding | Purpose |
|------|------------|---------|
| Locked | `Ctrl g` | Lock mode (disable all keybindings) |
| Pane | `Ctrl p` | Pane management |
| Tab | `Ctrl t` | Tab management |
| Resize | `Ctrl n` | Resize panes |
| Move | `Ctrl h` | Move panes |
| Scroll | `Ctrl s` | Scroll mode |
| Session | `Ctrl o` | Session management |
| Tmux | `Ctrl b` | Tmux compatibility mode |

### Global Keybindings (Any Mode)

| Keybinding | Action |
|------------|--------|
| `Ctrl g` | Toggle locked mode |
| `Ctrl q` | Quit Zellij |
| `Alt n` | Create new pane |
| `Alt h` / `Alt Left` | Move focus or tab left |
| `Alt l` / `Alt Right` | Move focus or tab right |
| `Alt j` / `Alt Down` | Move focus down |
| `Alt k` / `Alt Up` | Move focus up |
| `Alt i` | Move current tab left |
| `Alt o` | Move current tab right |
| `Alt =` / `Alt +` | Increase pane size |
| `Alt -` | Decrease pane size |
| `Alt [` | Previous swap layout |
| `Alt ]` | Next swap layout |
| `Alt x` | Clear screen |

### Pane Mode (`Ctrl p`)

| Keybinding | Action |
|------------|--------|
| `h` / `Left` | Move focus left |
| `j` / `Down` | Move focus down |
| `k` / `Up` | Move focus up |
| `l` / `Right` | Move focus right |
| `p` | Switch focus to next pane |
| `n` | New pane (default direction) |
| `d` | New pane below |
| `r` | New pane to the right |
| `x` | Close focused pane |
| `f` | Toggle fullscreen |
| `z` | Toggle pane frames |
| `w` | Toggle floating panes |
| `e` | Toggle embed or floating |
| `c` | Rename pane |

### Tab Mode (`Ctrl t`)

| Keybinding | Action |
|------------|--------|
| `h` / `Left` / `k` / `Up` | Previous tab |
| `l` / `Right` / `j` / `Down` | Next tab |
| `n` | New tab |
| `x` | Close current tab |
| `r` | Rename tab |
| `s` | Toggle sync tab (sync input across panes) |
| `b` | Break pane into new tab |
| `[` | Break pane left |
| `]` | Break pane right |
| `1-9` | Go to tab by number |
| `Tab` | Toggle between tabs |

### Resize Mode (`Ctrl n`)

| Keybinding | Action |
|------------|--------|
| `h` / `Left` | Increase left |
| `j` / `Down` | Increase down |
| `k` / `Up` | Increase up |
| `l` / `Right` | Increase right |
| `H` | Decrease left |
| `J` | Decrease down |
| `K` | Decrease up |
| `L` | Decrease right |
| `=` / `+` | Increase size |
| `-` | Decrease size |

### Move Mode (`Ctrl h`)

| Keybinding | Action |
|------------|--------|
| `n` / `Tab` | Move pane forward |
| `p` | Move pane backwards |
| `h` / `Left` | Move pane left |
| `j` / `Down` | Move pane down |
| `k` / `Up` | Move pane up |
| `l` / `Right` | Move pane right |

### Scroll Mode (`Ctrl s`)

| Keybinding | Action |
|------------|--------|
| `j` / `Down` | Scroll down |
| `k` / `Up` | Scroll up |
| `Ctrl f` / `PageDown` / `l` / `Right` | Page down |
| `Ctrl b` / `PageUp` / `h` / `Left` | Page up |
| `d` | Half page down |
| `u` | Half page up |
| `e` | Edit scrollback in editor |
| `s` | Enter search mode |
| `Ctrl c` | Scroll to bottom and exit |

### Search Mode (From Scroll Mode: `s`)

| Keybinding | Action |
|------------|--------|
| `n` | Search down |
| `p` | Search up |
| `c` | Toggle case sensitivity |
| `w` | Toggle wrap |
| `o` | Toggle whole word |
| `Ctrl c` | Exit search |

### Session Mode (`Ctrl o`)

| Keybinding | Action |
|------------|--------|
| `d` | Detach from session |
| `w` | Open session manager (floating window) |
| `Ctrl s` | Switch to scroll mode |

### Tmux Compatibility Mode (`Ctrl b`)

For users migrating from tmux, this mode provides familiar keybindings:

| Keybinding | Action |
|------------|--------|
| `[` | Enter scroll mode |
| `"` | Split pane horizontally (down) |
| `%` | Split pane vertically (right) |
| `z` | Toggle fullscreen |
| `c` | New tab |
| `,` | Rename tab |
| `p` | Previous tab |
| `n` | Next tab |
| `h` / `Left` | Focus left |
| `j` / `Down` | Focus down |
| `k` / `Up` | Focus up |
| `l` / `Right` | Focus right |
| `o` | Focus next pane |
| `d` | Detach session |
| `Space` | Next layout |
| `x` | Close pane |
| `Ctrl b` | Send literal Ctrl-b |

## Plugins

### Built-in Plugins

- **Tab Bar**: Top tab bar with tab information
- **Status Bar**: Bottom status bar with mode indicators
- **Compact Bar**: Minimal combined tab and status bar
- **Strider**: File picker for quick file navigation
- **Session Manager**: Interactive session management (`Ctrl o` + `w`)

### Session Manager

Access with `Ctrl o` + `w` to:
- Create new sessions
- Switch between sessions
- Rename sessions
- Delete sessions

## Configuration

### Theme

The configuration uses the Kanagawa color palette:

- **Background**: `#1F1F28` (sumiInk1)
- **Foreground**: `#DCD7BA` (fujiWhite)
- **Red**: `#E82424` (samuraiRed)
- **Green**: `#98BB6C` (springGreen)
- **Blue**: `#7E9CD8` (crystalBlue)
- **Yellow**: `#DCA561` (autumnYellow)
- **Magenta**: `#D27E99` (sakuraPink)
- **Orange**: `#FFA066` (surimiOrange)
- **Cyan**: `#7AA89F` (waveAqua2)

Alternative theme: Catppuccin Macchiato (defined but not active)

### UI Settings

```kdl
simplified_ui true           // Simplified UI without fancy fonts
pane_frames false           // No frames around panes
default_shell "fish"        // Use Fish shell by default
default_layout "compact"    // Use compact layout on startup
copy_command "pbcopy"       // macOS clipboard integration
```

### Hidden Features

- Session name hidden in pane frames for cleaner look
- Session serialization enabled for persistence
- Mouse mode enabled for modern terminal interaction
- Scroll buffer size: 10,000 lines (default)

## Configuration Structure

```
~/.config/zellij/
├── config.kdl        # Main configuration file
└── README.md         # This file
```

## Customization

To customize the configuration, edit `~/.config/zellij/config.kdl`:

### Change Theme

```kdl
// Switch to Catppuccin Macchiato
theme "catppuccino-macchiato"

// Or define your own theme in the themes section
```

### Change Default Shell

```kdl
// Use zsh instead of fish
default_shell "zsh"
```

### Modify Keybindings

```kdl
keybinds {
    normal {
        // Add custom keybinding
        bind "Ctrl y" { /* your action */ }
    }
}
```

### Enable Session Serialization

```kdl
// Uncomment to disable session persistence
// session_serialization false

// Serialize pane viewports
// serialize_pane_viewport true
// scrollback_lines_to_serialize 10000
```

## Troubleshooting

### Colors not displaying correctly

Ensure your terminal supports true color:
```sh
# Check if terminal supports true color
echo $COLORTERM  # Should output "truecolor" or "24bit"
```

### Copy/paste not working

- **macOS**: Should work with `pbcopy` by default
- **Linux X11**: Change `copy_command` to `"xclip -selection clipboard"`
- **Linux Wayland**: Change `copy_command` to `"wl-copy"`

### Session not persisting

Check that session serialization is enabled:
```kdl
// Should NOT be commented out or set to false
// session_serialization false
```

### Keybindings conflict with terminal

If you experience keybinding conflicts, you can:
1. Use tmux compatibility mode (`Ctrl b`)
2. Modify conflicting keys in `config.kdl`
3. Check your terminal emulator's keybinding settings

## Migration from Tmux

If you're coming from tmux:

1. Use `Ctrl b` (tmux mode) for familiar keybindings
2. Gradually adopt Zellij modes for more features
3. Key differences:
   - Sessions are more isolated (no nested sessions)
   - Modal system provides better organization
   - Built-in session manager replaces tmux-resurrect
   - Layouts are handled differently (auto-layout)

## Author

👤 **Huynh Duc Dung**

- Website: https://productsway.com/
- Twitter: [@jellydn](https://twitter.com/jellydn)
- Github: [@jellydn](https://github.com/jellydn)

## Show your support

If this guide has been helpful, please give it a ⭐️.
