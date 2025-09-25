#!/bin/bash
# Setup script for Hyprland monitoring integration
# Configures status checking, health monitoring, and shell integration

set -euo pipefail

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }

echo "🔧 Setting up Hyprland Status Monitoring"
echo "========================================"

# Check if Hyprland is available
if ! command -v Hyprland >/dev/null 2>&1; then
    log_warning "Hyprland not found in PATH. Install it first."
    exit 1
fi

log_success "Hyprland found: $(command -v Hyprland)"

# Check if hyprctl is available
if ! command -v hyprctl >/dev/null 2>&1; then
    log_warning "hyprctl not found. Make sure Hyprland is properly installed."
    exit 1
fi

log_success "hyprctl found: $(command -v hyprctl)"

# Test scripts
log_info "Testing monitoring scripts..."

if ~/.dotfiles/scripts/hyprland-health-check.sh help >/dev/null 2>&1; then
    log_success "Health check script working"
else
    log_warning "Health check script may have issues"
fi

if ~/.dotfiles/scripts/hyprland-status.sh help >/dev/null 2>&1; then
    log_success "Status script working"
else
    log_warning "Status script may have issues"
fi

# Create shell aliases
log_info "Setting up shell aliases..."

FISH_CONFIG="$HOME/.config/fish/config.fish"
if [[ -f "$FISH_CONFIG" ]]; then
    if ! grep -q "hypr-status" "$FISH_CONFIG"; then
        cat >> "$FISH_CONFIG" << 'EOF'

# Hyprland status monitoring aliases
alias hypr-status="~/.dotfiles/scripts/hyprland-status.sh"
alias hypr-health="~/.dotfiles/scripts/hyprland-health-check.sh"

# Hyprland-specific aliases
alias hypr-reload="hyprctl reload"
alias hypr-version="hyprctl version"
alias hypr-monitors="hyprctl monitors"
alias hypr-workspaces="hyprctl workspaces"
alias hypr-windows="hyprctl clients"
alias hypr-logs="hyprctl rollinglog"

# Function to show Hyprland status in prompt (only when running Hyprland)
function hypr_prompt_status
    if test "$XDG_CURRENT_DESKTOP" = "Hyprland"
        ~/.dotfiles/scripts/hyprland-health-check.sh simple
    end
end
EOF
        log_success "Added Fish shell aliases and functions"
    else
        log_info "Fish shell aliases already exist"
    fi
else
    log_info "Fish config not found, skipping Fish setup"
fi

# Setup for bash/zsh
BASHRC="$HOME/.bashrc"
if [[ -f "$BASHRC" ]]; then
    if ! grep -q "hypr-status" "$BASHRC"; then
        cat >> "$BASHRC" << 'EOF'

# Hyprland status monitoring aliases
alias hypr-status="$HOME/.dotfiles/scripts/hyprland-status.sh"
alias hypr-health="$HOME/.dotfiles/scripts/hyprland-health-check.sh"

# Hyprland-specific aliases
alias hypr-reload="hyprctl reload"
alias hypr-version="hyprctl version"
alias hypr-monitors="hyprctl monitors"
alias hypr-workspaces="hyprctl workspaces"
alias hypr-windows="hyprctl clients"
alias hypr-logs="hyprctl rollinglog"
EOF
        log_success "Added Bash shell aliases"
    else
        log_info "Bash shell aliases already exist"
    fi
fi

# Create Waybar configuration snippet
WAYBAR_DIR="$HOME/.config/waybar"
if [[ -d "$WAYBAR_DIR" ]]; then
    log_info "Creating Waybar integration example..."

    cat > "$WAYBAR_DIR/hyprland-module-example.json" << 'EOF'
{
    "custom/hyprland-status": {
        "exec": "~/.dotfiles/scripts/hyprland-health-check.sh json",
        "return-type": "json",
        "interval": 10,
        "on-click": "~/.dotfiles/scripts/hyprland-status.sh",
        "format": "󰖲 {}",
        "tooltip": true,
        "signal": 8
    },
    "custom/hyprland-workspaces": {
        "exec": "hyprctl workspaces -j | jq 'length'",
        "interval": 2,
        "format": "󱂬 {}",
        "tooltip-format": "{} active workspaces",
        "on-click": "~/.dotfiles/scripts/hyprland-status.sh workspaces"
    },
    "custom/hyprland-windows": {
        "exec": "hyprctl clients -j | jq 'length'",
        "interval": 2,
        "format": "󰖯 {}",
        "tooltip-format": "{} open windows",
        "on-click": "~/.dotfiles/scripts/hyprland-status.sh windows"
    }
}
EOF

    cat > "$WAYBAR_DIR/hyprland-style-example.css" << 'EOF'
/* Hyprland status module styling */
#custom-hyprland-status {
    padding: 0 10px;
    margin: 0 5px;
    border-radius: 5px;
    font-weight: bold;
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
    animation: blink 1s linear infinite;
}

#custom-hyprland-workspaces,
#custom-hyprland-windows {
    padding: 0 8px;
    margin: 0 3px;
    border-radius: 3px;
    background-color: rgba(255, 255, 255, 0.1);
}

@keyframes blink {
    0%, 50% { opacity: 1; }
    51%, 100% { opacity: 0.5; }
}
EOF

    log_success "Created Waybar integration examples"
    log_info "Files created:"
    log_info "  - $WAYBAR_DIR/hyprland-module-example.json"
    log_info "  - $WAYBAR_DIR/hyprland-style-example.css"
else
    log_info "Waybar config directory not found, skipping Waybar setup"
fi

# Create systemd monitoring service (optional)
SYSTEMD_DIR="$HOME/.config/systemd/user"
if [[ -d "$SYSTEMD_DIR" ]]; then
    log_info "Creating optional systemd monitoring service..."

    cat > "$SYSTEMD_DIR/hyprland-monitor.service" << 'EOF'
[Unit]
Description=Hyprland Health Monitor
After=graphical-session.target

[Service]
Type=simple
ExecStart=/bin/bash -c 'while sleep 300; do ~/.dotfiles/scripts/hyprland-health-check.sh percentage | logger -t hyprland-monitor; done'
Restart=on-failure

[Install]
WantedBy=default.target
EOF

    cat > "$SYSTEMD_DIR/hyprland-monitor.timer" << 'EOF'
[Unit]
Description=Run Hyprland Health Monitor every 5 minutes
Requires=hyprland-monitor.service

[Timer]
OnCalendar=*:0/5
Persistent=true

[Install]
WantedBy=timers.target
EOF

    log_success "Created systemd monitoring service (disabled by default)"
    log_info "To enable: systemctl --user enable hyprland-monitor.timer"
else
    log_info "Systemd user directory not found, skipping service creation"
fi

# Create desktop entry for status checking
DESKTOP_DIR="$HOME/.local/share/applications"
mkdir -p "$DESKTOP_DIR"

cat > "$DESKTOP_DIR/hyprland-status.desktop" << 'EOF'
[Desktop Entry]
Name=Hyprland Status
Comment=Check Hyprland compositor status
Exec=kitty -e ~/.dotfiles/scripts/hyprland-status.sh full
Icon=preferences-system
Terminal=false
Type=Application
Categories=System;Monitor;
EOF

log_success "Created desktop entry for status checking"

echo ""
log_success "🎉 Hyprland monitoring setup complete!"
echo ""
echo "📊 Available commands:"
echo "  hypr-status           # Comprehensive status check"
echo "  hypr-health          # Health monitoring"
echo "  hypr-reload          # Reload configuration"
echo "  hypr-monitors        # Show monitors"
echo "  hypr-workspaces      # Show workspaces"
echo "  hypr-windows         # Show windows"
echo "  hypr-logs            # Show logs"
echo ""
echo "🔧 Test the setup:"
echo "  ~/.dotfiles/scripts/hyprland-status.sh"
echo "  ~/.dotfiles/scripts/hyprland-health-check.sh json"
echo ""
echo "📈 Integration options:"
echo "  • Waybar: Use examples in ~/.config/waybar/"
echo "  • Shell prompt: Restart your shell to load aliases"
echo "  • Desktop entry: Search for 'Hyprland Status' in your launcher"
echo ""
echo "⚠️  Remember to restart your shell or run: source ~/.config/fish/config.fish"