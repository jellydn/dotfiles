#!/bin/bash
# Intelligent copy script for niri
# Detects if focused window is a terminal and uses appropriate keybinding

set -euo pipefail

APP_ID=$(niri msg --json windows | jq -er \
  'first(.[] | select(.is_focused == true)) | .app_id // error("focused window has no app_id")')

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
