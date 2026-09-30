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

# Deploy greetd config to /etc
echo "Deploying greetd configuration..."
sudo install -d -m 0755 /etc/greetd
sudo install -m 0644 "$DOTFILES_DIR/linux/etc/greetd/config.toml" /etc/greetd/config.toml

# Enable greetd service
echo "Enabling greetd service..."
sudo systemctl enable greetd.service

echo ""
echo "✅ Setup complete!"
echo ""
echo "📋 Next Steps:"
echo "  1. Reboot to start greetd on boot"
echo "  2. Login will use agreety greeter with niri-session"
echo ""
echo "🔧 Service Management:"
echo "  sudo systemctl status greetd.service   # Check status"
echo "  sudo systemctl restart greetd.service  # Restart greeter"
echo "  sudo journalctl -u greetd -n 50        # View logs"
echo ""
echo "⚙️  Configuration:"
echo "  /etc/greetd/config.toml                         # Active config"
echo "  ~/.dotfiles/linux/etc/greetd/config.toml        # Source config"
echo ""
echo "💡 To switch to a different greeter (e.g., tuigreet):"
echo "  Edit ~/.dotfiles/linux/etc/greetd/config.toml"
echo "  Change command to: tuigreet --cmd niri-session"
echo "  Run this script again to deploy"
