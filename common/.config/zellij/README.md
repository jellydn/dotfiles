# Zellij Configuration

A modern terminal workspace configuration for Zellij with Kanagawa color scheme, vim-style navigation, and **tmux-compatible `Ctrl a` prefix**.

## Features

- **Tmux-Compatible Keybindings**: Exclusively uses `Ctrl a` as prefix - seamless switching between tmux and zellij
- **No Conflicts**: No individual mode triggers (`Ctrl p`, `Ctrl t`, etc.) that conflict with neovim or other tools
- **Kanagawa Theme**: Beautiful color scheme matching neovim kanagawa theme
- **Modal Editing**: Vim-inspired modal system accessed through prefix key
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

## Key Bindings Philosophy

**This configuration uses ONLY `Ctrl a` as the prefix** - identical to tmux. All individual mode triggers are explicitly disabled to avoid conflicts:

- ❌ `Ctrl p` - Unbound (won't conflict with neovim)
- ❌ `Ctrl t` - Unbound (won't conflict with file browser toggle)
- ❌ `Ctrl g` - Unbound (won't conflict with Claude AI)
- ❌ `Ctrl n`, `Ctrl s`, `Ctrl o`, `Ctrl h`, `Ctrl b` - All unbound

These keys will pass through to your applications (neovim, terminal, Claude AI, etc.) without being intercepted by Zellij.

### Prefix System

Press `Ctrl a` to enter prefix mode, then press a key to:
- Enter a specific mode (pane, tab, resize, etc.)
- Execute a direct action (split, new tab, etc.)
- Exit any mode with `Enter` or `Esc`

| Mode | Keybinding | Purpose |
|------|------------|---------|
| Locked | `Ctrl a` → `g` | Lock mode (disable all keybindings) |
| Pane | `Ctrl a` → `p` | Pane management |
| Tab | `Ctrl a` → `t` | Tab management |
| Resize | `Ctrl a` → `r` | Resize panes |
| Move | `Ctrl a` → `m` | Move panes |
| Scroll | `Ctrl a` → `s` | Scroll mode |
| Session | `Ctrl a` → `o` | Session management |

### Direct Actions (Tmux-Compatible)

These work directly from the prefix without entering a mode:

| Keybinding | Action |
|------------|--------|
| `Ctrl a` `"` | Split pane horizontally (down) |
| `Ctrl a` `%` | Split pane vertically (right) |
| `Ctrl a` `c` | New tab |
| `Ctrl a` `,` | Rename tab |
| `Ctrl a` `n` | Next tab |
| `Ctrl a` `h/j/k/l` | Move focus vim-style |
| `Ctrl a` `1-9` | Go to tab number |
| `Ctrl a` `z` | Toggle fullscreen |
| `Ctrl a` `x` | Close pane |
| `Ctrl a` `d` | Detach session |
| `Ctrl a` `g` | Lock mode (disable all keybindings) |
| `Ctrl a` `Space` | Next swap layout |
| `Ctrl a` `[` | Enter scroll/copy mode |
| `Ctrl a` `Ctrl a` | Send literal `Ctrl a` |

### Global Keybindings (No Prefix Needed)

These work from any mode for quick access:

| Keybinding | Action |
|------------|--------|
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

### Pane Mode (`Ctrl a` → `p`)

Enter with `Ctrl a` then `p`. Exit with `Enter` or `Esc`.

| Keybinding | Action |
|------------|--------|
| `h` / `Left` | Move focus left |
| `j` / `Down` | Move focus down |
| `k` / `Up` | Move focus up |
| `l` / `Right` | Move focus right |
| `o` | Switch focus to next pane |
| `n` | New pane (default direction) |
| `d` | New pane below |
| `v` | New pane to the right (vertical split) |
| `x` | Close focused pane |
| `f` | Toggle fullscreen |
| `z` | Toggle pane frames |
| `w` | Toggle floating panes |
| `e` | Toggle embed or floating |
| `c` | Rename pane |

### Tab Mode (`Ctrl a` → `t`)

Enter with `Ctrl a` then `t`. Exit with `Enter` or `Esc`.

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

### Resize Mode (`Ctrl a` → `r`)

Enter with `Ctrl a` then `r`. Exit with `Enter` or `Esc`.

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

### Move Mode (`Ctrl a` → `m`)

Enter with `Ctrl a` then `m`. Exit with `Enter` or `Esc`.

| Keybinding | Action |
|------------|--------|
| `n` / `Tab` | Move pane forward |
| `p` | Move pane backwards |
| `h` / `Left` | Move pane left |
| `j` / `Down` | Move pane down |
| `k` / `Up` | Move pane up |
| `l` / `Right` | Move pane right |

### Scroll Mode (`Ctrl a` → `s` or `Ctrl a` → `[`)

Enter with `Ctrl a` then `s` or `[`. Exit with `Enter`, `Esc`, or `Ctrl c`.

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

### Search Mode (From Scroll Mode: press `s`)

Enter search mode from scroll mode. Exit with `Enter`, `Esc`, or `Ctrl c`.

| Keybinding | Action |
|------------|--------|
| `n` | Search down |
| `p` | Search up |
| `c` | Toggle case sensitivity |
| `w` | Toggle wrap |
| `o` | Toggle whole word |
| `Ctrl c` | Exit search |

### Session Mode (`Ctrl a` → `o`)

Enter with `Ctrl a` then `o`. Exit with `Enter` or `Esc`.

| Keybinding | Action |
|------------|--------|
| `d` | Detach from session |
| `w` | Open session manager (floating window) |
| `s` | Switch to scroll mode |

## Plugins

### Built-in Plugins

- **Tab Bar**: Top tab bar with tab information
- **Status Bar**: Bottom status bar with mode indicators
- **Compact Bar**: Minimal combined tab and status bar
- **Strider**: File picker for quick file navigation
- **Session Manager**: Interactive session management (`Ctrl a` → `o` → `w`)

### Session Manager

Access with `Ctrl a` → `o` → `w` to:
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
1. Modify conflicting keys in `config.kdl`
2. Change the prefix key from `Ctrl a` to another combination
3. Check your terminal emulator's keybinding settings

### URLs and Link Clicking

**Important:** URL detection and clicking is handled by your **terminal emulator** (Ghostty), not Zellij.

#### Configuration

Your Ghostty config has URL detection enabled:
```ghostty
link-url = true
```

#### How to Click URLs

**With Zellij mouse mode enabled (`mouse_mode true`):**

Since Zellij captures mouse events, you need to use a modifier key:

| Terminal | Action | Result |
|----------|--------|--------|
| **Ghostty** (macOS) | `Cmd+Click` | Opens URL in browser |
| **Ghostty** (macOS) | `Option+Click` | Bypasses Zellij, triggers terminal |
| **Kitty** (macOS) | `Cmd+Click` | Opens URL |
| **iTerm2** (macOS) | `Cmd+Click` | Opens URL |

**Testing URL detection:**
```sh
# Print a test URL
echo "Test: https://github.com"
# Now try Cmd+Click on the URL
```

**If Cmd+Click doesn't work:**
1. Reload Ghostty config: `Cmd+Shift+,`
2. Ensure `link-url = true` in `~/.config/ghostty/config`
3. Try `Option+Click` to bypass Zellij mouse capture
4. Check that your browser is set as default for opening links

**Alternative method (keyboard-only):**
```sh
# Enter scroll mode to select and copy URLs
Ctrl a [      # Enter scroll mode
# Use mouse to select URL (will auto-copy)
# Then paste in browser address bar
```

## Quick Reference

### Common Workflows (Tmux-Compatible)

```sh
# Lock mode (disable all Zellij keybindings)
Ctrl a g      # Enter locked mode
Ctrl a g      # Exit locked mode (same key)

# Split panes (direct actions, like tmux)
Ctrl a "      # Split horizontally (down)
Ctrl a %      # Split vertically (right)

# Or use pane mode for more options
Ctrl a → p → d    # Split horizontally (down)
Ctrl a → p → v    # Split vertically (right)

# Navigate panes (direct)
Ctrl a h/j/k/l    # Move focus vim-style (like tmux)

# Manage tabs (direct)
Ctrl a c          # New tab
Ctrl a 1-9        # Go to tab number
Ctrl a n          # Next tab

# Session management
Ctrl a d          # Detach session (direct)
Ctrl a → o → w    # Open session manager
Ctrl a → o → d    # Detach (from session mode)

# Resize panes
Ctrl a → r → h/j/k/l    # Resize in direction

# Scroll and search (like tmux copy mode)
Ctrl a [              # Enter scroll mode (tmux-style)
Ctrl a → s            # Enter scroll mode (zellij-style)
s (in scroll)         # Search
Ctrl c                # Exit scroll/search
```

### Key Differences from Tmux

| Feature | Tmux | Zellij |
|---------|------|--------|
| Prefix | `Ctrl b` (default) | `Ctrl a` |
| Copy mode | `Ctrl b [` | `Ctrl a [` or `Ctrl a → s` |
| Session manager | External (tmuxinator) | Built-in (`Ctrl a → o → w`) |
| Pane frames | Always on | Off by default |
| Floating panes | Not available | `Ctrl a → p → w` |

### Migration Tips

If you're used to tmux with `Ctrl a`:
- ✅ Most keybindings are identical
- ✅ `Ctrl a "` and `Ctrl a %` work the same
- ✅ `Ctrl a c`, `Ctrl a n`, `Ctrl a 1-9` work the same
- ✅ `Ctrl a [` enters copy mode (scroll mode)
- 🆕 Use `Ctrl a → o → w` for the session manager
- 🆕 `Alt` shortcuts for quick navigation without prefix

## Author

👤 **Huynh Duc Dung**

- Website: https://productsway.com/
- Twitter: [@jellydn](https://twitter.com/jellydn)
- Github: [@jellydn](https://github.com/jellydn)

## Show your support

If this guide has been helpful, please give it a ⭐️.
