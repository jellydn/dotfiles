#!/bin/bash
# Intelligent copy script for niri
# Detects if focused window is a terminal and uses appropriate keybinding

WIN_INFO=$(niri msg windows | jq '.[] | select(.is_focused == true)')
APP_ID=$(echo "$WIN_INFO" | jq -r '.app_id // empty')

# Check if it's a terminal (use Ctrl+Shift+C)
case "$APP_ID" in
  *foot*|*alacritty*|*kitty*|*wezterm*|*terminal*|*konsole*|*xterm*|*urxvt*|*termite*)
    wtype -M ctrl -M shift -k c
    ;;
  *)
    # Regular app (use Ctrl+C)
    wtype -M ctrl -k c
    ;;
esac
