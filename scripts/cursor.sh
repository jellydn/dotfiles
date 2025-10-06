#!/bin/bash
# Cursor AppImage launcher with Wayland/GPU optimizations

# Set Wayland-specific flags for Electron
export ELECTRON_OZONE_PLATFORM_HINT=wayland
export NIXOS_OZONE_WL=1

# GPU acceleration flags (disable if running in VM with issues)
export LIBGL_ALWAYS_SOFTWARE=0

# Suppress GTK warnings
export G_MESSAGES_DEBUG=""

# Find Cursor.AppImage
CURSOR_PATH=""
if [ -f "$HOME/Cursor.AppImage" ]; then
    CURSOR_PATH="$HOME/Cursor.AppImage"
elif [ -f "$HOME/Downloads/Cursor.AppImage" ]; then
    CURSOR_PATH="$HOME/Downloads/Cursor.AppImage"
elif [ -f "$HOME/.local/share/AppImage/Cursor.AppImage" ]; then
    CURSOR_PATH="$HOME/.local/share/AppImage/Cursor.AppImage"
elif [ -f "$HOME/.local/share/Cursor.AppImage" ]; then
    CURSOR_PATH="$HOME/.local/share/Cursor.AppImage"
fi

if [ -z "$CURSOR_PATH" ]; then
    echo "Error: Cursor.AppImage not found"
    echo "Searched locations:"
    echo "  - $HOME/Cursor.AppImage"
    echo "  - $HOME/Downloads/Cursor.AppImage"
    echo "  - $HOME/.local/share/Cursor.AppImage"
    echo "  - $HOME/.local/share/Cursor.AppImage"
    exit 1
fi

# Launch with GPU acceleration, fallback to software rendering if it fails
"$CURSOR_PATH" "$@" 2>&1 | grep -v "gtk_widget_get_scale_factor" | grep -v "command_buffer_proxy_impl"