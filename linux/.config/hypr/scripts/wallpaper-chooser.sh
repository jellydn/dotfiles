#!/bin/bash
# Simple wallpaper chooser for Hyprland using swww

WALLPAPER_DIR="$HOME/bg-images"

# Colors for output
INFO="\033[34m[INFO]\033[0m"
OK="\033[32m[OK]\033[0m"
ERROR="\033[31m[ERROR]\033[0m"
NOTE="\033[33m[NOTE]\033[0m"

echo -e "${INFO} 🎨 Hyprland Wallpaper Chooser"
echo ""

# Check if swww is running
if ! pgrep -x "swww-daemon" > /dev/null; then
    echo -e "${ERROR} swww-daemon is not running"
    echo -e "${NOTE} Start it with: swww-daemon &"
    exit 1
fi

# Check if wallpaper directory exists
if [ ! -d "$WALLPAPER_DIR" ]; then
    echo -e "${ERROR} Wallpaper directory not found: $WALLPAPER_DIR"
    echo -e "${NOTE} Run the installer to create default wallpapers"
    exit 1
fi

# List available wallpapers
echo -e "${INFO} Available wallpapers:"
echo ""

wallpapers=()
i=1

# Find PNG files
for wallpaper in "$WALLPAPER_DIR"/*.png; do
    if [ -f "$wallpaper" ]; then
        basename_wallpaper=$(basename "$wallpaper")
        echo "  $i) $basename_wallpaper"
        wallpapers+=("$wallpaper")
        ((i++))
    fi
done

# Find JPG files
for wallpaper in "$WALLPAPER_DIR"/*.jpg "$WALLPAPER_DIR"/*.jpeg; do
    if [ -f "$wallpaper" ]; then
        basename_wallpaper=$(basename "$wallpaper")
        echo "  $i) $basename_wallpaper"
        wallpapers+=("$wallpaper")
        ((i++))
    fi
done

if [ ${#wallpapers[@]} -eq 0 ]; then
    echo -e "${ERROR} No wallpapers found in $WALLPAPER_DIR"
    notify-send "Wallpaper Chooser" "No wallpapers found in $WALLPAPER_DIR" -i dialog-error 2>/dev/null || true
    exit 1
fi

# Use rofi for GUI selection if available, otherwise fall back to terminal
if command -v rofi >/dev/null 2>&1 && [ -n "$WAYLAND_DISPLAY" ]; then
    # Build rofi options with cleaner formatting
    rofi_options=""
    declare -A wallpaper_map
    for j in "${!wallpapers[@]}"; do
        basename_wallpaper=$(basename "${wallpapers[j]}" .png)
        # Clean up the display name (replace - with spaces and capitalize)
        display_name=$(echo "$basename_wallpaper" | sed 's/-/ /g' | sed 's/\b\w/\U&/g')
        rofi_options="$rofi_options$display_name\n"
        wallpaper_map["$display_name"]="$j"
    done
    
    # Show rofi menu with improved styling
    selected=$(echo -e "$rofi_options" | rofi -dmenu -i -p "🎨 Choose wallpaper:" \
        -theme-str 'window {width: 700px; padding: 15px;} 
                   listview {lines: 12; columns: 1; spacing: 6px;} 
                   element {padding: 8px 12px; border-radius: 6px;} 
                   element-text {font: "Inter 11"; horizontal-align: 0.0;} 
                   prompt {font: "Inter Bold 12"; padding: 0px 6px 0px 0px;} 
                   textbox-prompt-colon {str: "";}')
    
    if [ -z "$selected" ]; then
        notify-send "Wallpaper Chooser" "No wallpaper selected" -i dialog-information 2>/dev/null || true
        exit 0
    fi
    
    # Get wallpaper index from map
    choice=$((${wallpaper_map["$selected"]} + 1))
else
    # Terminal fallback - open in a terminal window
    if command -v foot >/dev/null 2>&1; then
        # Re-run this script in a terminal
        exec foot -e "$0"
        exit 0
    else
        echo ""
        echo -e "${NOTE} Enter the number of the wallpaper you want to set:"
        read -p "Choice (1-$((i-1))): " choice
    fi
fi

# Validate input
if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -ge $i ]; then
    echo -e "${ERROR} Invalid choice: $choice"
    notify-send "Wallpaper Chooser" "Invalid choice: $choice" -i dialog-error 2>/dev/null || true
    exit 1
fi

# Set wallpaper
selected_wallpaper="${wallpapers[$((choice-1))]}"
echo -e "${INFO} Setting wallpaper: $(basename "$selected_wallpaper")"

if swww img "$selected_wallpaper"; then
    echo -e "${OK} ✅ Wallpaper set successfully!"
    
    # Update the symlink for next boot
    ln -sf "$selected_wallpaper" "$HOME/.config/swww/wall.png"
    echo -e "${NOTE} Wallpaper will be restored on next login"
    
    # Show success notification
    notify-send "Wallpaper Changed" "Set to: $(basename "$selected_wallpaper")" -i image-x-generic 2>/dev/null || true
else
    echo -e "${ERROR} Failed to set wallpaper"
    notify-send "Wallpaper Chooser" "Failed to set wallpaper" -i dialog-error 2>/dev/null || true
    exit 1
fi

echo ""
echo -e "${NOTE} 💡 Tips:"
echo "  • To add custom wallpapers, copy them to: $WALLPAPER_DIR"
echo "  • To set a wallpaper directly: swww img /path/to/wallpaper.png"
echo "  • To see current wallpaper info: swww query"