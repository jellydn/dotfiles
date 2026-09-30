#!/usr/bin/env bash

set -euo pipefail

if command -v wlogout >/dev/null 2>&1; then
    exec wlogout
fi

choice=$(printf '%s\n' Lock Logout Suspend Reboot Shutdown | fuzzel --dmenu --prompt 'Power: ')
case "$choice" in
    Lock) swaylock ;;
    Logout) niri msg action quit --skip-confirmation ;;
    Suspend) systemctl suspend ;;
    Reboot) systemctl reboot ;;
    Shutdown) systemctl poweroff ;;
    *) exit 0 ;;
esac
