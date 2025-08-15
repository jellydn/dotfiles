#!/bin/bash
# Simple KooL Terminal Chooser
# Interactive terminal selection with rofi

# Terminal options with their commands and descriptions
declare -A terminals=(
    ["foot"]="foot"
    ["kitty"]="kitty"
    ["alacritty"]="alacritty"
    ["ghostty"]="ghostty"
    ["wezterm"]="wezterm"
    ["st"]="st"
    ["terminator"]="terminator"
    ["gnome-terminal"]="gnome-terminal"
)

declare -A descriptions=(
    ["foot"]="🦶 Foot - Fast, minimal Wayland terminal"
    ["kitty"]="🐱 Kitty - GPU-accelerated, feature-rich"
    ["alacritty"]="⚡ Alacritty - OpenGL terminal emulator"
    ["ghostty"]="👻 Ghostty - Fast, native terminal"
    ["wezterm"]="🔧 WezTerm - Rust-based, highly configurable"
    ["st"]="💎 st - Simple Terminal (suckless)"
    ["terminator"]="🤖 Terminator - Multiple panes/tabs"
    ["gnome-terminal"]="🌐 GNOME Terminal - Desktop integrated"
)

# Check which terminals are installed
available_terminals=()
for term in "${!terminals[@]}"; do
    if command -v "${terminals[$term]}" >/dev/null 2>&1; then
        available_terminals+=("$term")
    fi
done

if [ ${#available_terminals[@]} -eq 0 ]; then
    notify-send "Terminal Chooser" "No supported terminals found!" -u critical
    exit 1
fi

# Create rofi menu options
rofi_options=""
for term in "${available_terminals[@]}"; do
    rofi_options+="\n${descriptions[$term]}"
done

# Show rofi menu
chosen=$(echo -e "$rofi_options" | rofi -dmenu -i -p "Choose Terminal" \
    -theme ~/.config/rofi/simple-kool.rasi \
    -markup-rows \
    -format "s")

if [ -n "$chosen" ]; then
    # Extract terminal name from the chosen option
    for term in "${available_terminals[@]}"; do
        if [[ "$chosen" == *"$term"* ]]; then
            selected_terminal="$term"
            break
        fi
    done
    
    if [ -n "$selected_terminal" ]; then
        # Update the hyprland config
        config_file="$HOME/.config/hyprland/hyprland.conf"
        if [ -f "$config_file" ]; then
            # Create backup
            cp "$config_file" "$config_file.bak.$(date +%s)"
            
            # Update the terminal variable
            sed -i "s/^\$term = .*$/\$term = $selected_terminal/" "$config_file"
            
            # Send notification
            notify-send "Terminal Chooser" "Terminal changed to: ${descriptions[$selected_terminal]}" -t 3000
            
            # Launch the chosen terminal immediately
            exec "${terminals[$selected_terminal]}" &
        else
            notify-send "Terminal Chooser" "Hyprland config not found!" -u critical
        fi
    fi
fi