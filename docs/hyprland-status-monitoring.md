# Hyprland Status Monitoring

Enhanced status checking for Hyprland compositor based on [Arch Linux Wiki recommendations](https://wiki.archlinux.org/title/Hyprland).

## 🔍 Status Check Scripts

### Comprehensive Status Check
```bash
# Full system diagnostics
~/.dotfiles/scripts/hyprland-status.sh
~/.dotfiles/scripts/hyprland-status.sh full

# Quick scriptable check
~/.dotfiles/scripts/hyprland-status.sh quick

# Specific checks
~/.dotfiles/scripts/hyprland-status.sh logs
~/.dotfiles/scripts/hyprland-status.sh config
~/.dotfiles/scripts/hyprland-status.sh monitors
~/.dotfiles/scripts/hyprland-status.sh workspaces
~/.dotfiles/scripts/hyprland-status.sh windows
```

### Health Monitoring
```bash
# For Waybar integration
~/.dotfiles/scripts/hyprland-health-check.sh json

# For shell prompts
~/.dotfiles/scripts/hyprland-health-check.sh simple

# For monitoring systems
~/.dotfiles/scripts/hyprland-health-check.sh percentage
```

## 📊 Waybar Integration

Add this module to your Waybar configuration:

```json
{
    "custom/hyprland-status": {
        "exec": "~/.dotfiles/scripts/hyprland-health-check.sh json",
        "return-type": "json",
        "interval": 10,
        "on-click": "~/.dotfiles/scripts/hyprland-status.sh",
        "format": "󰖲 {}",
        "tooltip": true
    }
}
```

### CSS Styling (waybar/style.css)
```css
#custom-hyprland-status {
    padding: 0 10px;
    margin: 0 5px;
    border-radius: 5px;
}

#custom-hyprland-status.good {
    background-color: #a6da95;
    color: #1e2030;
}

#custom-hyprland-status.warning {
    background-color: #eed49f;
    color: #1e2030;
}

#custom-hyprland-status.critical {
    background-color: #ed8796;
    color: #1e2030;
}
```

## 🛠️ Shell Integration

### Add to Fish Shell (~/.config/fish/config.fish)
```fish
# Hyprland status aliases
alias hypr-status="~/.dotfiles/scripts/hyprland-status.sh"
alias hypr-health="~/.dotfiles/scripts/hyprland-health-check.sh"

# Add Hyprland status to prompt (when running Hyprland)
function fish_right_prompt
    set_color normal
    if test "$XDG_CURRENT_DESKTOP" = "Hyprland"
        echo -n (~/.dotfiles/scripts/hyprland-health-check.sh simple)
    end
end
```

### Add to Bash/Zsh (~/.bashrc or ~/.zshrc)
```bash
# Hyprland status aliases
alias hypr-status="$HOME/.dotfiles/scripts/hyprland-status.sh"
alias hypr-health="$HOME/.dotfiles/scripts/hyprland-health-check.sh"

# Add to PS1 for Bash (when running Hyprland)
if [[ "$XDG_CURRENT_DESKTOP" == "Hyprland" ]]; then
    export PS1="$PS1\$(~/.dotfiles/scripts/hyprland-health-check.sh simple) "
fi
```

## 📋 Status Check Categories

### Process Status
- ✅ Hyprland compositor running
- ✅ Process ID and resource usage
- ✅ Wayland display environment
- ✅ Hyprland instance signature

### Communication
- ✅ hyprctl socket availability
- ✅ Command responses
- ✅ Version information
- ✅ System information

### Configuration
- ✅ Config file existence and readability
- ✅ Configuration error checking
- ✅ Real-time config validation

### Display Management
- ✅ Connected monitors status
- ✅ Monitor configurations
- ✅ Resolution and scaling
- ✅ Refresh rates

### Window Management
- ✅ Active workspaces count
- ✅ Open windows count
- ✅ Active window information
- ✅ Window properties

### Bindings & Features
- ✅ Key bindings status
- ✅ Animation configurations
- ✅ Plugin information
- ✅ Available layouts

### System Integration
- ✅ Related services (Waybar, hyprpaper, hypridle)
- ✅ Graphical session status
- ✅ GPU utilization (if NVIDIA)

## 🚨 Health Check Indicators

### Status Levels
- **Good (✓)**: All systems operational, no config errors
- **Warning (!)**: Minor issues or config errors detected
- **Critical (✗)**: Major problems or Hyprland not running

### Health Metrics
1. **Process Running**: Hyprland compositor active
2. **Wayland Display**: Environment properly set
3. **Instance Signature**: Hyprland instance identified
4. **hyprctl Communication**: Can query Hyprland status
5. **Configuration Valid**: No syntax or runtime errors
6. **Memory Usage**: Within reasonable limits (<800MB)

### Percentage Calculation
Health percentage = (Passed checks / Total checks) × 100

## 🔧 Hyprland-Specific Commands

Based on Arch Wiki and hyprctl capabilities:

```bash
# Check version and build info
hyprctl version

# Validate configuration (check for errors)
hyprctl configerrors

# Monitor status and configuration
hyprctl monitors
hyprctl monitors all  # includes inactive

# Workspace management
hyprctl workspaces
hyprctl activeworkspace

# Window information
hyprctl clients
hyprctl activewindow

# System information
hyprctl systeminfo

# Real-time logs
hyprctl rollinglog
hyprctl rollinglog --follow  # continuous

# Reload configuration
hyprctl reload

# Plugin management
hyprctl plugin list

# Bindings and options
hyprctl binds
hyprctl animations

# Dynamic configuration
hyprctl keyword <option> <value>
hyprctl getoption <option>
```

## 🎯 Performance Monitoring

### Resource Thresholds
- **Memory**: Warning if >800MB, critical if >1.5GB
- **CPU**: Monitored but dynamic based on workload
- **GPU**: NVIDIA utilization tracking if available
- **File Descriptors**: Tracked for leak detection

### Real-time Monitoring
```bash
# Watch Hyprland status
watch -n 5 ~/.dotfiles/scripts/hyprland-status.sh quick

# Monitor resource usage
watch -n 2 'ps aux | grep Hyprland | head -5'

# Live configuration errors
watch -n 10 hyprctl configerrors

# Monitor active window changes
hyprctl --batch "activewindow; activeworkspace" --timeout 1000
```

## 📈 Integration Examples

### Session Management
```bash
# Check if Hyprland is the current desktop
[[ "$XDG_CURRENT_DESKTOP" == "Hyprland" ]] && echo "Running Hyprland"

# Get current Hyprland session info
echo "Instance: $HYPRLAND_INSTANCE_SIGNATURE"
echo "Display: $WAYLAND_DISPLAY"
```

### Automated Health Monitoring
```bash
# Continuous health logging
while true; do
    echo "$(date): $(~/.dotfiles/scripts/hyprland-health-check.sh percentage)%"
    sleep 60
done

# Config error alerting
check_config_errors() {
    local errors=$(hyprctl configerrors 2>/dev/null)
    if [[ -n "$errors" && "$errors" != "no errors" ]]; then
        notify-send "Hyprland Config Error" "$errors"
    fi
}
```

### Waybar Custom Modules
```json
{
    "custom/hyprland-workspaces": {
        "exec": "hyprctl workspaces -j | jq 'length'",
        "interval": 5,
        "format": "{}",
        "tooltip-format": "{} active workspaces"
    },
    "custom/hyprland-windows": {
        "exec": "hyprctl clients -j | jq 'length'",
        "interval": 5,
        "format": "{}",
        "tooltip-format": "{} open windows"
    }
}
```

## 🚨 Troubleshooting Guide

### Common Issues
1. **Hyprland won't start**
   ```bash
   # Check from TTY
   echo $XDG_SESSION_TYPE
   Hyprland  # Start manually

   # Check config
   hyprctl configerrors
   ```

2. **Display issues**
   ```bash
   # Check monitors
   hyprctl monitors all

   # Reset monitor config
   hyprctl keyword monitor ",preferred,auto,1"
   ```

3. **Performance problems**
   ```bash
   # Check animations
   hyprctl animations

   # Disable animations temporarily
   hyprctl keyword animations:enabled false
   ```

4. **Plugin issues**
   ```bash
   # List loaded plugins
   hyprctl plugin list

   # Check plugin logs
   hyprctl rollinglog | grep -i plugin
   ```

### VM-Specific Issues
```bash
# For VMs, try these settings in hyprland.conf:
misc {
    vfr = false
    vrr = 0
}

render {
    explicit_sync = 0
    direct_scanout = false
}
```

This monitoring system provides comprehensive health checking following Arch Linux Wiki best practices for Hyprland compositor management.