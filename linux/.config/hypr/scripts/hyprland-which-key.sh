#!/bin/bash
# /* ---- 💫 Fast Hotkey Overlay (Niri-style) 💫 ---- */
# Optimized for instant response and minimal animations

# Kill existing rofi instances for instant response
if pidof rofi > /dev/null; then
    pkill -f rofi
    exit 0
fi

# Performance optimization
export ROFI_CACHE=0

# Create temp file with keybinding categories
temp_file=$(mktemp)

# Main categories menu with enhanced styling
cat << EOF > "$temp_file"
<span color='#f38ba8'> </span> <span weight='bold' color='#cdd6f4'>Applications</span>
<span color='#89b4fa'> </span> <span weight='bold' color='#cdd6f4'>Window Management</span>
<span color='#fab387'>󰖲 </span> <span weight='bold' color='#cdd6f4'>Workspaces</span>
<span color='#94e2d5'>󰕴 </span> <span weight='bold' color='#cdd6f4'>Layout & Tiling</span>
<span color='#f9e2af'>󰒓 </span> <span weight='bold' color='#cdd6f4'>System Controls</span>
<span color='#cba6f7'>󰎆 </span> <span weight='bold' color='#cdd6f4'>Media & Volume</span>
<span color='#f2cdcd'>󰄀 </span> <span weight='bold' color='#cdd6f4'>Screenshots</span>
<span color='#a6e3a1'>󰊠 </span> <span weight='bold' color='#cdd6f4'>Special Features</span>
EOF

# Function to show category details
show_category() {
    local category="$1"
    local temp_detail=$(mktemp)
    
    case "$category" in
        *"Applications"*)
            cat << EOF > "$temp_detail"
<span color='#89dceb'>󰆍</span>  <span weight='bold' color='#f38ba8'>Super</span> + <span color='#fab387' weight='bold'>Return</span>    Open Terminal
<span color='#89dceb'>󰈹</span>  <span weight='bold' color='#f38ba8'>Super</span> + <span color='#fab387' weight='bold'>B</span>           Open Browser
<span color='#89dceb'>󰉋</span>  <span weight='bold' color='#f38ba8'>Super</span> + <span color='#fab387' weight='bold'>E</span>           File Manager
<span color='#89dceb'>󱓞</span>  <span weight='bold' color='#f38ba8'>Super</span> + <span color='#fab387' weight='bold'>D</span>           App Launcher
<span color='#89dceb'>󰌌</span>  <span weight='bold' color='#f38ba8'>Super</span> + <span color='#fab387' weight='bold'>Shift</span> + <span color='#fab387' weight='bold'>?</span>   Show Hotkeys
EOF
            ;;
        *"Window Management"*)
            cat << EOF > "$temp_detail"
<span color='#f38ba8'>󰅖</span>  <span weight='bold' color='#f38ba8'>Super</span> + <span color='#fab387' weight='bold'>Shift</span> + <span color='#fab387' weight='bold'>Q</span>      Close Window
<span color='#a6e3a1'>󰖲</span>  <span weight='bold' color='#f38ba8'>Super</span> + <span color='#fab387' weight='bold'>Shift</span> + <span color='#fab387' weight='bold'>Space</span>  Toggle Floating
<span color='#89dceb'>󰊓</span>  <span weight='bold' color='#f38ba8'>Super</span> + <span color='#fab387' weight='bold'>F</span>               Fullscreen
<span color='#cba6f7'>󰊖</span>  <span weight='bold' color='#f38ba8'>Super</span> + <span color='#fab387' weight='bold'>Shift</span> + <span color='#fab387' weight='bold'>F</span>      Maximize Column
<span color='#94e2d5'>󰕴</span>  <span weight='bold' color='#f38ba8'>Super</span> + <span color='#fab387' weight='bold'>H/J/K/L</span>       Focus Direction
<span color='#f9e2af'>󰁞</span>  <span weight='bold' color='#f38ba8'>Super</span> + <span color='#fab387' weight='bold'>Ctrl</span> + <span color='#fab387' weight='bold'>H/J/K/L</span>  Move Window
<span color='#74c7ec'>󰏈</span>  <span weight='bold' color='#f38ba8'>Super</span> + <span color='#fab387' weight='bold'>-</span> / <span color='#fab387' weight='bold'>=</span>         Resize Width
EOF
            ;;
        *"Workspaces"*)
            cat << EOF > "$temp_detail"
<span color='#fab387'>󰎤</span>  <span weight='bold' color='#f38ba8'>Super</span> + <span color='#fab387' weight='bold'>1-9</span>             Switch Workspace
<span color='#a6e3a1'>󰊠</span>  <span weight='bold' color='#f38ba8'>Super</span> + <span color='#fab387' weight='bold'>Shift</span> + <span color='#fab387' weight='bold'>1-9</span>     Move to Workspace
<span color='#89dceb'>󰒮</span>  <span weight='bold' color='#f38ba8'>Super</span> + <span color='#fab387' weight='bold'>U</span> / <span color='#fab387' weight='bold'>I</span>         Prev/Next Workspace
<span color='#cba6f7'>󰒭</span>  <span weight='bold' color='#f38ba8'>Super</span> + <span color='#fab387' weight='bold'>Page↑</span> / <span color='#fab387' weight='bold'>↓</span>    Navigate Workspaces
<span color='#f9e2af'>󰁞</span>  <span weight='bold' color='#f38ba8'>Super</span> + <span color='#fab387' weight='bold'>Ctrl</span> + <span color='#fab387' weight='bold'>U/I</span>     Move Window Adjacent
<span color='#94e2d5'>󰅂</span>  <span weight='bold' color='#f38ba8'>Super</span> + <span color='#fab387' weight='bold'>[</span> / <span color='#fab387' weight='bold'>]</span>         Quick Navigation
EOF
            ;;
        *"Layout & Tiling"*)
            cat << EOF > "$temp_detail"
<span color='#74c7ec'>󰏈</span>  <span weight='bold' color='#f38ba8'>Super</span> + <span color='#fab387' weight='bold'>R</span>               Column Width Presets
<span color='#89dceb'>󰢻</span>  <span weight='bold' color='#f38ba8'>Super</span> + <span color='#fab387' weight='bold'>Shift</span> + <span color='#fab387' weight='bold'>R</span>      Window Height Presets
<span color='#f9e2af'>󰁞</span>  <span weight='bold' color='#f38ba8'>Super</span> + <span color='#fab387' weight='bold'>-</span> / <span color='#fab387' weight='bold'>=</span>         Adjust Width ±10%
<span color='#a6e3a1'>󰢸</span>  <span weight='bold' color='#f38ba8'>Super</span> + <span color='#fab387' weight='bold'>Shift</span> + <span color='#fab387' weight='bold'>-/=</span>    Adjust Height ±10%
<span color='#cba6f7'>󰹑</span>  <span weight='bold' color='#f38ba8'>Super</span> + <span color='#fab387' weight='bold'>C</span>               Center Column
<span color='#94e2d5'>󰕴</span>  <span weight='bold' color='#f38ba8'>Super</span> + <span color='#fab387' weight='bold'>W</span>               Toggle Tabbed
<span color='#f2cdcd'>󰁔</span>  <span weight='bold' color='#f38ba8'>Super</span> + <span color='#fab387' weight='bold'>Shift</span> + <span color='#fab387' weight='bold'>Enter</span>  Swap with Master
EOF
            ;;
        *"System Controls"*)
            cat << EOF > "$temp_detail"
<span color='#f38ba8'>󰌾</span>  <span weight='bold' color='#f38ba8'>Super</span> + <span color='#fab387' weight='bold'>Shift</span> + <span color='#fab387' weight='bold'>Del</span>    Lock Screen
<span color='#89dceb'>󰗼</span>  <span weight='bold' color='#f38ba8'>Super</span> + <span color='#fab387' weight='bold'>Shift</span> + <span color='#fab387' weight='bold'>E</span>      Exit/Logout
<span color='#a6e3a1'>󰜉</span>  <span weight='bold' color='#f38ba8'>Super</span> + <span color='#fab387' weight='bold'>Shift</span> + <span color='#fab387' weight='bold'>R</span>      Reload Hyprland
<span color='#cba6f7'>󰕮</span>  <span weight='bold' color='#f38ba8'>Super</span> + <span color='#fab387' weight='bold'>Shift</span> + <span color='#fab387' weight='bold'>B</span>      Restart Waybar
<span color='#f9e2af'>󰂚</span>  <span weight='bold' color='#f38ba8'>Super</span> + <span color='#fab387' weight='bold'>N</span>               Notifications
<span color='#74c7ec'>󰈆</span>  <span weight='bold' color='#f38ba8'>Super</span> + <span color='#fab387' weight='bold'>M</span>               Exit Hyprland
<span color='#94e2d5'>󰽥</span>  <span weight='bold' color='#f38ba8'>Super</span> + <span color='#fab387' weight='bold'>Shift</span> + <span color='#fab387' weight='bold'>P</span>      Power Off Monitors
EOF
            ;;
        "🎵 Media & Volume")
            cat << EOF > "$temp_detail"
🔊 Volume Up/Down → Adjust Volume
🔇 Volume Mute → Toggle Audio Mute
🎤 Mic Mute → Toggle Microphone
⏯️ Media Play/Pause → Media Control
⏭️ Media Next/Previous → Skip Tracks
🔆 Brightness Up/Down → Screen Brightness
🎵 Click Volume in Waybar → Open pavucontrol
📊 Scroll Volume in Waybar → Quick Adjust
EOF
            ;;
        "📸 Screenshots")
            cat << EOF > "$temp_detail"
📷 Print Screen → Full Screen Screenshot
📱 Super + Shift + S → Area Selection
📋 Auto Copy → Screenshots to Clipboard
📁 Save Location → ~/Pictures/Screenshots
🖼️ grim → Screenshot Backend
✂️ slurp → Area Selection Tool
🎯 Click & Drag → Select Custom Area
EOF
            ;;
        "✨ Special Features")
            cat << EOF > "$temp_detail"
🖥️ VM Auto-scaling → Detects VMware/VBox
🎨 Catppuccin Mocha → Color Scheme
🚫 No Animations → Performance Mode
📱 Fish Shell → User-friendly Terminal
⚡ Foot Terminal → Fast & Lightweight
🎯 Workspace Names → Auto Organization
💫 KooL Styling → Beautiful Interface
🔧 Which-Key → This Help System
EOF
            ;;
    esac
    
    # Show category details with fast performance styling
    rofi -dmenu \
        -i \
        -p "  $category" \
        -markup-rows \
        -no-custom \
        -no-lazy-grab \
        -show-icons \
        -theme-str 'window {width: 800px; height: 650px; padding: 10px;}
                   listview {lines: 15; columns: 1; spacing: 3px; dynamic: false;}
                   element {padding: 6px 8px; border-radius: 3px; font: "Inter 10";}
                   element-text {horizontal-align: 0.0; font: "Inter 10";}
                   prompt {font: "Inter Bold 11"; padding: 0px 4px 0px 0px;}
                   textbox-prompt-colon {str: "";}
                   inputbar {padding: 8px 10px; margin: 0px 0px 5px 0px; border-radius: 4px;}
                   * {transition: none;}' < "$temp_detail"
    
    rm -f "$temp_detail"
}

# Show main menu with fast performance styling
selected=$(rofi -dmenu \
    -i \
    -p "󰌌 Important Hotkeys" \
    -markup-rows \
    -no-custom \
    -no-lazy-grab \
    -show-icons \
    -theme-str 'window {width: 450px; height: 400px; padding: 10px;}
               listview {lines: 8; columns: 1; spacing: 4px; dynamic: false;}
               element {padding: 8px 10px; border-radius: 4px; font: "Inter 10";}
               element-text {horizontal-align: 0.0; font: "Inter 10";}
               prompt {font: "Inter Bold 11"; padding: 0px 6px 0px 0px;}
               textbox-prompt-colon {str: "";}
               inputbar {padding: 8px 10px; margin: 0px 0px 6px 0px; border-radius: 4px;}
               * {transition: none;}' < "$temp_file")

# Clean up temp file
rm -f "$temp_file"

# Show selected category or exit
if [[ -n "$selected" ]]; then
    # Debug: log the selection
    echo "Selected: $selected" >> /tmp/which-key-debug.log
    show_category "$selected"
else
    echo "No selection made" >> /tmp/which-key-debug.log
fi

exit 0