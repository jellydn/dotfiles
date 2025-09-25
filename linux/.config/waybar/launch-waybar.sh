#!/bin/bash

# Waybar launcher script that detects window manager and uses appropriate config

CONFIG_DIR="$HOME/.config/waybar"

# Function to detect window manager
detect_wm() {
    if pgrep -x "niri" > /dev/null; then
        echo "niri"
    elif pgrep -x "Hyprland" > /dev/null; then
        echo "hyprland"
    elif [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
        echo "hyprland"
    elif [ -n "$NIRI_SOCKET" ]; then
        echo "niri"
    else
        # Default fallback
        echo "hyprland"
    fi
}

WM=$(detect_wm)
CONFIG_FILE="$CONFIG_DIR/config-$WM.jsonc"

if [ -f "$CONFIG_FILE" ]; then
    echo "Launching waybar with $WM config: $CONFIG_FILE"
    waybar -c "$CONFIG_FILE" -s "$CONFIG_DIR/style.css"
else
    echo "Config file not found: $CONFIG_FILE"
    echo "Falling back to default config"
    waybar -c "$CONFIG_DIR/config.jsonc" -s "$CONFIG_DIR/style.css"
fi