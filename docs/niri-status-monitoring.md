# Niri Status Monitoring

Enhanced status checking for Niri compositor based on [Arch Linux Wiki recommendations](https://wiki.archlinux.org/title/Niri).

## 🔍 Status Check Scripts

### Comprehensive Status Check
```bash
# Full system diagnostics
~/.dotfiles/scripts/niri-status.sh
~/.dotfiles/scripts/niri-status.sh full

# Quick scriptable check
~/.dotfiles/scripts/niri-status.sh quick

# Specific checks
~/.dotfiles/scripts/niri-status.sh logs
~/.dotfiles/scripts/niri-status.sh config
```

### Health Monitoring
```bash
# For Waybar integration
~/.dotfiles/scripts/niri-health-check.sh json

# For shell prompts
~/.dotfiles/scripts/niri-health-check.sh simple

# For monitoring systems
~/.dotfiles/scripts/niri-health-check.sh percentage
```

## 📊 Waybar Integration

Add this module to your Waybar configuration:

```json
{
    "custom/niri-status": {
        "exec": "~/.dotfiles/scripts/niri-health-check.sh json",
        "return-type": "json",
        "interval": 10,
        "on-click": "~/.dotfiles/scripts/niri-status.sh",
        "format": "󱇚 {}",
        "tooltip": true
    }
}
```

### CSS Styling (waybar/style.css)
```css
#custom-niri-status {
    padding: 0 10px;
    margin: 0 5px;
    border-radius: 5px;
}

#custom-niri-status.good {
    background-color: #a6da95;
    color: #1e2030;
}

#custom-niri-status.warning {
    background-color: #eed49f;
    color: #1e2030;
}

#custom-niri-status.critical {
    background-color: #ed8796;
    color: #1e2030;
}
```

## 🛠️ Shell Integration

### Add to Fish Shell (~/.config/fish/config.fish)
```fish
# Niri status alias
alias niri-status="~/.dotfiles/scripts/niri-status.sh"
alias niri-health="~/.dotfiles/scripts/niri-health-check.sh"

# Add Niri status to prompt
function fish_right_prompt
    set_color normal
    echo -n (~/.dotfiles/scripts/niri-health-check.sh simple)
end
```

### Add to Bash/Zsh (~/.bashrc or ~/.zshrc)
```bash
# Niri status aliases
alias niri-status="$HOME/.dotfiles/scripts/niri-status.sh"
alias niri-health="$HOME/.dotfiles/scripts/niri-health-check.sh"

# Add to PS1 for Bash
export PS1="$PS1\$(~/.dotfiles/scripts/niri-health-check.sh simple) "
```

## 📋 Status Check Categories

### Process Status
- ✅ Niri compositor running
- ✅ Process ID and resource usage
- ✅ Wayland display environment

### Communication
- ✅ IPC socket availability
- ✅ Message command responses
- ✅ Version information

### Configuration
- ✅ Config file existence and validity
- ✅ DRM device override status (VM compatibility)
- ✅ Syntax validation

### Display Management
- ✅ Connected outputs
- ✅ Focused output status
- ✅ Resolution and scaling
- ✅ Graphics driver status

### Window Management
- ✅ Active workspaces count
- ✅ Open windows count
- ✅ Focused window information
- ✅ Layout state

### System Integration
- ✅ Systemd service status
- ✅ Related services (Waybar, wallpaper, swayidle)
- ✅ Service dependencies
- ✅ Recent logs analysis

## 🚨 Health Check Indicators

### Status Levels
- **Good (✓)**: All systems operational
- **Warning (!)**: Minor issues detected
- **Critical (✗)**: Major problems or Niri not running

### Health Metrics
1. **Process Running**: Niri compositor active
2. **Wayland Display**: Environment properly set
3. **IPC Communication**: Can query Niri status
4. **Configuration Valid**: No syntax errors
5. **Memory Usage**: Within reasonable limits (<500MB)

### Percentage Calculation
Health percentage = (Passed checks / Total checks) × 100

## 🔧 Troubleshooting Commands

Based on Arch Wiki recommendations:

```bash
# Validate configuration
niri validate -c ~/.config/niri/config.kdl

# Check logs
journalctl --user -u niri.service

# Test direct startup
niri

# Fix VM graphics issues
~/.dotfiles/scripts/fix-niri-vm-graphics.sh

# Check EGL support
eglinfo | grep -i wayland

# Verify graphics driver
glxinfo | grep -E "(vendor|renderer)"
```

## 🎯 Performance Monitoring

### Resource Thresholds
- **Memory**: Warning if >500MB, critical if >1GB
- **CPU**: Monitored but no fixed thresholds (depends on workload)
- **File Descriptors**: Tracked for leak detection

### Automated Checks
The health check runs every 10 seconds in Waybar and provides:
- Real-time status indication
- Detailed tooltips with metrics
- Click-through to full diagnostics

## 📈 Integration Examples

### Continuous Monitoring
```bash
# Watch status in terminal
watch -n 5 ~/.dotfiles/scripts/niri-status.sh quick

# Log health percentage
while true; do
    echo "$(date): $(~/.dotfiles/scripts/niri-health-check.sh percentage)%"
    sleep 60
done
```

### Service Health Checks
```bash
# Systemd service monitoring
systemctl --user status niri.service waybar.service wallpaper.service

# Combined status
~/.dotfiles/scripts/niri-status.sh | grep -E "(✓|✗|!)"
```

This monitoring system provides comprehensive health checking aligned with Arch Linux Wiki best practices for Niri compositor management.