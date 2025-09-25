# Wayland Compositor Monitoring Suite

Comprehensive status monitoring and health checking for Wayland compositors, with specific support for **Hyprland** and **Niri** based on Arch Linux Wiki recommendations.

## 🎯 Quick Start

```bash
# Universal status check (auto-detects compositor)
~/.dotfiles/scripts/wm-status.sh

# Specific compositor checks
~/.dotfiles/scripts/hyprland-status.sh    # Hyprland-specific
~/.dotfiles/scripts/niri-status.sh        # Niri-specific

# Health checks for status bars
~/.dotfiles/scripts/wm-status.sh health   # Universal health (✓/!/✗)
```

## 📊 Available Scripts

### Universal Scripts
- **`wm-status.sh`** - Auto-detects compositor and runs appropriate checks
- Supports: Hyprland, Niri, Sway (basic), other Wayland compositors

### Hyprland-Specific Scripts
- **`hyprland-status.sh`** - Comprehensive Hyprland diagnostics
- **`hyprland-health-check.sh`** - Lightweight health monitoring
- **`setup-hyprland-monitoring.sh`** - One-time setup script

### Niri-Specific Scripts
- **`niri-status.sh`** - Comprehensive Niri diagnostics
- **`niri-health-check.sh`** - Lightweight health monitoring

## 🔧 Installation & Setup

### Automatic Setup
```bash
# For Hyprland users
~/.dotfiles/scripts/setup-hyprland-monitoring.sh

# Scripts are automatically executable after setup
```

### Manual Integration
```bash
# Make scripts executable
chmod +x ~/.dotfiles/scripts/{wm-status,hyprland-*,niri-*}.sh

# Add to shell (Fish example)
echo 'alias wm-status="~/.dotfiles/scripts/wm-status.sh"' >> ~/.config/fish/config.fish
```

## 📱 Shell Integration

### Fish Shell Aliases (Added Automatically)
```fish
# Universal
alias wm-status="~/.dotfiles/scripts/wm-status.sh"

# Hyprland-specific
alias hypr-status="~/.dotfiles/scripts/hyprland-status.sh"
alias hypr-health="~/.dotfiles/scripts/hyprland-health-check.sh"
alias hypr-reload="hyprctl reload"
alias hypr-monitors="hyprctl monitors"
alias hypr-workspaces="hyprctl workspaces"
alias hypr-windows="hyprctl clients"

# Niri-specific
alias niri-status="~/.dotfiles/scripts/niri-status.sh"
alias niri-health="~/.dotfiles/scripts/niri-health-check.sh"
```

### Shell Prompt Integration
```fish
# Add to Fish prompt (shows ✓/!/✗ based on compositor health)
function fish_right_prompt
    set_color normal
    echo -n (~/.dotfiles/scripts/wm-status.sh health)
end
```

## 📊 Waybar Integration

### Universal Module (Auto-detects Compositor)
```json
{
    "custom/compositor-status": {
        "exec": "~/.dotfiles/scripts/wm-status.sh health-json",
        "return-type": "json",
        "interval": 10,
        "on-click": "~/.dotfiles/scripts/wm-status.sh",
        "format": "󰖲 {}",
        "tooltip": true
    }
}
```

### Hyprland-Specific Modules
```json
{
    "custom/hyprland-status": {
        "exec": "~/.dotfiles/scripts/hyprland-health-check.sh json",
        "return-type": "json",
        "interval": 10,
        "format": "󰖲 {}",
        "on-click": "~/.dotfiles/scripts/hyprland-status.sh"
    },
    "custom/hyprland-workspaces": {
        "exec": "hyprctl workspaces -j | jq 'length'",
        "interval": 2,
        "format": "󱂬 {}"
    },
    "custom/hyprland-windows": {
        "exec": "hyprctl clients -j | jq 'length'",
        "interval": 2,
        "format": "󰖯 {}"
    }
}
```

### Niri-Specific Module
```json
{
    "custom/niri-status": {
        "exec": "~/.dotfiles/scripts/niri-health-check.sh json",
        "return-type": "json",
        "interval": 10,
        "format": "󱇚 {}",
        "on-click": "~/.dotfiles/scripts/niri-status.sh"
    }
}
```

### CSS Styling
```css
#custom-compositor-status,
#custom-hyprland-status,
#custom-niri-status {
    padding: 0 10px;
    margin: 0 5px;
    border-radius: 5px;
}

#custom-compositor-status.good,
#custom-hyprland-status.good,
#custom-niri-status.good {
    background-color: #a6da95;
    color: #1e2030;
}

#custom-compositor-status.warning,
#custom-hyprland-status.warning,
#custom-niri-status.warning {
    background-color: #eed49f;
    color: #1e2030;
}

#custom-compositor-status.critical,
#custom-hyprland-status.critical,
#custom-niri-status.critical {
    background-color: #ed8796;
    color: #1e2030;
    animation: blink 1s linear infinite;
}
```

## 🔍 Status Check Modes

### Universal Commands
```bash
~/.dotfiles/scripts/wm-status.sh status      # Standard check
~/.dotfiles/scripts/wm-status.sh quick       # Quick check
~/.dotfiles/scripts/wm-status.sh full        # Detailed check
~/.dotfiles/scripts/wm-status.sh health      # Health symbol
~/.dotfiles/scripts/wm-status.sh detect      # Show compositor name
```

### Compositor-Specific Commands
```bash
# Hyprland
hypr-status              # or ~/.dotfiles/scripts/hyprland-status.sh
hypr-status full         # Detailed diagnostics
hypr-status quick        # Quick scriptable check
hypr-status monitors     # Monitor information
hypr-status workspaces   # Workspace information
hypr-status windows      # Window information

# Niri
niri-status              # or ~/.dotfiles/scripts/niri-status.sh
niri-status full         # Detailed diagnostics
niri-status quick        # Quick scriptable check
```

## 🚨 Health Indicators

### Status Symbols
- **✓** - Healthy (all checks pass)
- **!** - Warning (minor issues or config errors)
- **✗** - Critical (compositor not running or major issues)
- **?** - Unknown compositor but Wayland active

### Health Metrics

#### Hyprland Health Checks (5 total)
1. **Process Running** - Hyprland compositor active
2. **Wayland Display** - WAYLAND_DISPLAY environment set
3. **Instance Signature** - HYPRLAND_INSTANCE_SIGNATURE present
4. **hyprctl Communication** - Can communicate with compositor
5. **Configuration Valid** - No config errors detected
6. **Memory Usage** - Within reasonable limits (<800MB)

#### Niri Health Checks (4 total)
1. **Process Running** - Niri compositor active
2. **Wayland Display** - WAYLAND_DISPLAY environment set
3. **niri msg Communication** - Can communicate with compositor
4. **Configuration Valid** - Config file syntax valid
5. **Memory Usage** - Within reasonable limits (<500MB)

## 📈 Monitoring & Automation

### Continuous Monitoring
```bash
# Watch status
watch -n 5 ~/.dotfiles/scripts/wm-status.sh quick

# Log health percentage
while true; do
    echo "$(date): $(~/.dotfiles/scripts/wm-status.sh health-percent)%"
    sleep 60
done
```

### Systemd Integration
```bash
# Optional health monitoring service (Hyprland)
systemctl --user enable hyprland-monitor.timer
systemctl --user start hyprland-monitor.timer
```

### Desktop Integration
- Desktop entries created for GUI status checking
- Search for "Hyprland Status" in your application launcher

## 🛠️ Troubleshooting

### Common Commands
```bash
# Check which compositor is detected
~/.dotfiles/scripts/wm-status.sh detect

# Full diagnostic output
~/.dotfiles/scripts/wm-status.sh full

# Compositor-specific troubleshooting
hypr-status config     # Check Hyprland config issues
niri-status config     # Check Niri config issues

# Direct compositor commands
hyprctl configerrors   # Hyprland config errors
niri validate -c ~/.config/niri/config.kdl  # Niri config validation
```

### Script Locations
```bash
ls -la ~/.dotfiles/scripts/{wm-status,hyprland-*,niri-*}.sh
```

## 📚 Documentation References

- **Hyprland**: [Arch Wiki - Hyprland](https://wiki.archlinux.org/title/Hyprland)
- **Niri**: [Arch Wiki - Niri](https://wiki.archlinux.org/title/Niri)
- **Waybar**: Module integration examples included
- **hyprctl**: Built-in help via `hyprctl --help`
- **niri msg**: Built-in help via `niri msg --help`

## 🔄 Updates & Maintenance

### Keeping Scripts Updated
```bash
# Scripts are part of your dotfiles repo
cd ~/.dotfiles && git pull

# Verify script functionality
~/.dotfiles/scripts/wm-status.sh info
```

### Adding New Compositors
To add support for additional compositors, modify `wm-status.sh`:
1. Add detection logic in `detect_compositor()`
2. Add status check logic in `run_status_check()`
3. Add health check logic in `run_health_check()`

This monitoring suite provides comprehensive health checking and status monitoring for modern Wayland compositors, with easy integration into status bars, shell prompts, and monitoring systems.