#!/bin/bash
# Setup script for niri systemd services
# Run this after stowing linux dotfiles

set -e

echo "Setting up niri systemd services..."

# Reload systemd user daemon to pick up new services
systemctl --user daemon-reload

# Add services to niri session
echo "Adding waybar service to niri session..."
systemctl --user add-wants niri.service waybar.service

echo "Adding wallpaper service to niri session..."
systemctl --user add-wants niri.service wallpaper.service

echo "Adding swayidle service to niri session..."
systemctl --user add-wants niri.service swayidle.service

echo "Setup complete!"
echo "Services will start automatically when niri starts."
echo ""
echo "📊 Status and Health Checking:"
echo "  ~/.dotfiles/scripts/niri-status.sh         # Comprehensive status check"
echo "  ~/.dotfiles/scripts/niri-status.sh quick   # Quick status (scriptable)"
echo "  ~/.dotfiles/scripts/niri-status.sh full    # Detailed diagnostics"
echo ""
echo "🔧 Individual Service Management:"
echo "  systemctl --user status waybar.service"
echo "  systemctl --user status wallpaper.service"
echo "  systemctl --user status swayidle.service"
echo "  journalctl --user -u waybar.service -n 10"
echo "  journalctl --user -u wallpaper.service -n 10"
echo ""
echo "🔄 Service Control:"
echo "  systemctl --user restart waybar.service"
echo "  systemctl --user restart wallpaper.service"
echo "  systemctl --user restart swayidle.service"
echo ""
echo "🚨 Troubleshooting:"
echo "  ~/.dotfiles/scripts/fix-niri-vm-graphics.sh  # Fix VM/graphics issues"
echo "  niri validate -c ~/.config/niri/config.kdl   # Validate configuration"
echo ""
echo "💡 Pro tip: Add 'alias niri-status=\"~/.dotfiles/scripts/niri-status.sh\"' to your shell"