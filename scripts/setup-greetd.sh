#!/bin/bash
# Setup script for greetd with niri
# Automatically called by install.sh after stowing linux dotfiles

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

echo "Setting up greetd for niri..."

if ! systemctl list-unit-files greetd.service --no-legend 2>/dev/null | grep -q '^greetd\.service'; then
    echo "Error: greetd.service is not installed." >&2
    echo "On Fedora, run: sudo dnf install greetd tuigreet" >&2
    exit 1
fi

display_manager_link=/etc/systemd/system/display-manager.service
if [[ -L "$display_manager_link" ]]; then
    current_display_manager=$(basename "$(readlink -f "$display_manager_link")")
    if [[ "$current_display_manager" != "greetd.service" ]]; then
        echo "Error: $current_display_manager currently owns display-manager.service." >&2
        echo "Disable it first if you want greetd to replace the current display manager." >&2
        exit 1
    fi
fi

# Fedora packages use the greetd account; upstream packages use greeter.
greeter_user=greeter
if [[ -f /etc/fedora-release ]]; then
    greeter_user=greetd
fi
temporary_config=$(mktemp)
trap 'rm -f "$temporary_config"' EXIT
sed "s/^user = \"greeter\"/user = \"$greeter_user\"/" \
    "$DOTFILES_DIR/linux/etc/greetd/config.toml" > "$temporary_config"

# Deploy greetd config to /etc, preserving a different existing configuration.
echo "Deploying greetd configuration..."
sudo install -d -m 0755 /etc/greetd
if sudo test -f /etc/greetd/config.toml && ! sudo cmp -s "$temporary_config" /etc/greetd/config.toml; then
    backup_path="/etc/greetd/config.toml.backup_$(date +%Y%m%d_%H%M%S)"
    echo "Backing up existing configuration to $backup_path"
    sudo cp -a /etc/greetd/config.toml "$backup_path"
fi
sudo install -m 0644 "$temporary_config" /etc/greetd/config.toml

# Enable greetd service
echo "Enabling greetd service..."
sudo systemctl enable --force greetd.service
if ! systemctl is-enabled --quiet greetd.service; then
    echo "Error: greetd.service is still disabled after enablement." >&2
    echo "Check: sudo systemctl status greetd.service" >&2
    exit 1
fi

echo ""
echo "✅ Setup complete!"
echo ""
echo "📋 Next Steps:"
echo "  1. Reboot to start greetd on boot"
echo "  2. Login will use tuigreet with niri-session"
echo ""
echo "🔧 Service Management:"
echo "  sudo systemctl status greetd.service   # Check status"
echo "  sudo systemctl restart greetd.service  # Restart greeter"
echo "  sudo journalctl -u greetd -n 50        # View logs"
echo ""
echo "⚙️  Configuration:"
echo "  /etc/greetd/config.toml                         # Active config"
echo "  $DOTFILES_DIR/linux/etc/greetd/config.toml        # Source config"
echo ""
echo "💡 To change the greeter command:"
echo "  Edit $DOTFILES_DIR/linux/etc/greetd/config.toml"
echo "  Run this script again to deploy"
