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
echo "To check status:"
echo "  systemctl --user status waybar.service"
echo "  systemctl --user status wallpaper.service"
echo "  systemctl --user status swayidle.service"
echo ""
echo "To restart individual services:"
echo "  systemctl --user restart waybar.service"
echo "  systemctl --user restart wallpaper.service"
echo "  systemctl --user restart swayidle.service"