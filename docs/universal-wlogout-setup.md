# Universal wlogout Setup

Cross-compositor logout menu that works with both **Hyprland** and **Niri**.

## 🎯 What's Included

### Smart Scripts
- **`wm-logout.sh`** - Detects compositor and runs appropriate logout command
- **`wm-wlogout.sh`** - Wrapper for wlogout that handles protocol differences

### Updated Configuration
- **`wlogout/layout`** - Now uses the universal logout script
- **Hyprland binding** - Super+Shift+E launches wlogout

## 🔧 How It Works

### Compositor Detection
The scripts automatically detect which compositor is running:

```bash
~/.dotfiles/scripts/wm-logout.sh test
# Output when in Hyprland:
# Detected compositor: hyprland
# Logout command: hyprctl dispatch exit

# Output when in Niri:
# Detected compositor: niri
# Logout command: niri msg action quit
```

### wlogout Layout Actions
The layout file now uses the smart logout script:

```json
{
    "label" : "logout",
    "action" : "~/.dotfiles/scripts/wm-logout.sh logout",
    "text" : "Logout",
    "keybind" : "e"
}
```

## 📋 Keybindings

### Hyprland (already configured)
```
Super + Shift + E  →  wlogout menu
Super + M          →  direct exit (no menu)
```

### Niri (add to your niri config)
```kdl
bind "Mod+Shift+E" { spawn "~/.dotfiles/scripts/wm-wlogout.sh"; }
bind "Mod+M" { quit; }
```

## 🚀 Usage

### Launch wlogout
```bash
# Via keybinding
Super + Shift + E

# Or run directly
~/.dotfiles/scripts/wm-wlogout.sh
```

### Direct logout (bypass menu)
```bash
# Smart logout that detects compositor
~/.dotfiles/scripts/wm-logout.sh logout

# Or via keybinding
Super + M
```

### Test the setup
```bash
# Check which compositor is detected
~/.dotfiles/scripts/wm-logout.sh test

# Test wlogout wrapper
~/.dotfiles/scripts/wm-wlogout.sh --help
```

## 📊 Menu Options

The wlogout menu provides these options:
- **Lock** - `swaylock` (works with both compositors)
- **Logout** - Smart logout command based on compositor
- **Suspend** - `systemctl suspend`
- **Hibernate** - `systemctl hibernate`
- **Reboot** - `systemctl reboot`
- **Shutdown** - `systemctl poweroff`

## 🔄 Adding to Niri

If you want the same keybinding in Niri, add this to your `~/.config/niri/config.kdl`:

```kdl
binds {
    // ... existing binds ...

    // System controls (matching Hyprland)
    Mod+Shift+E { spawn "~/.dotfiles/scripts/wm-wlogout.sh"; }
    Mod+M { quit; }
}
```

## 🛠️ Customization

### Change wlogout appearance
Edit `~/.config/wlogout/style.css` for colors and styling.

### Add custom actions
Edit `~/.config/wlogout/layout` and add new entries:

```json
{
    "label" : "custom",
    "action" : "your-command-here",
    "text" : "Custom Action",
    "keybind" : "c"
}
```

### Different keybinding
Change the keybinding in both compositor configs:

```bash
# Hyprland: Edit ~/.config/hypr/hyprland.conf
bind = $mainMod CTRL, L, exec, ~/.dotfiles/scripts/wm-wlogout.sh

# Niri: Edit ~/.config/niri/config.kdl
Mod+Ctrl+L { spawn "~/.dotfiles/scripts/wm-wlogout.sh"; }
```

## 🚨 Troubleshooting

### wlogout doesn't appear
```bash
# Test the wrapper directly
~/.dotfiles/scripts/wm-wlogout.sh

# Check if config files exist
ls -la ~/.config/wlogout/
```

### Wrong logout command
```bash
# Check detection
~/.dotfiles/scripts/wm-logout.sh test

# Manual test
~/.dotfiles/scripts/wm-logout.sh get-command
```

### Permission issues
```bash
# Ensure scripts are executable
chmod +x ~/.dotfiles/scripts/wm-*.sh
```

This setup provides a seamless logout experience that automatically adapts to whichever Wayland compositor you're currently running!