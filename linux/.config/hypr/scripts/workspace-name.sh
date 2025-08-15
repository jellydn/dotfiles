#!/bin/bash
# Workspace Name Indicator for Waybar
# Shows current workspace with name and context

# Get current workspace ID
current_workspace=$(hyprctl activeworkspace -j 2>/dev/null | jq -r '.id' 2>/dev/null || echo "1")
current_workspace=${current_workspace:-1}

# Define workspace names with icons and purposes
declare -A workspace_names=(
    [1]="󰞷 Terminal"
    [2]="󰈹 Browser" 
    [3]="󰉋 Files"
    [4]="󰨞 Code"
    [5]="󰎄 Media"
    [6]="󰑴 Chat"
    [7]="󰎆 Design"
    [8]="󰎉 Games"
    [9]="󰎌 System"
    [10]="󱂬 Extra"
)

declare -A workspace_descriptions=(
    [1]="Terminals and CLI tools"
    [2]="Web browsers and internet"
    [3]="File managers and documents"
    [4]="Code editors and IDEs"
    [5]="Music, video and media apps"
    [6]="Communication and messaging"
    [7]="Graphics and design tools"
    [8]="Games and entertainment"
    [9]="System monitoring and settings"
    [10]="Additional applications"
)

# Get workspace name or default
if [[ -n "${workspace_names[$current_workspace]}" ]]; then
    workspace_name="${workspace_names[$current_workspace]}"
    workspace_desc="${workspace_descriptions[$current_workspace]}"
else
    workspace_name="󰧞 Space $current_workspace"
    workspace_desc="Workspace $current_workspace"
fi

# Get number of windows in current workspace
window_count=$(hyprctl workspaces -j 2>/dev/null | jq -r ".[] | select(.id==$current_workspace) | .windows" 2>/dev/null || echo "0")
window_count=${window_count:-0}

# Create window indicator
if [[ $window_count -gt 0 ]]; then
    window_indicator="($window_count)"
else
    window_indicator=""
fi

# Output JSON for waybar
cat << EOF
{
    "text": "$workspace_name $window_indicator",
    "tooltip": "<span color='#cba6f7'><b>Current Workspace: $current_workspace</b></span>\n<span color='#89b4fa'>$workspace_desc</span>\n<span color='#a6e3a1'>Windows: $window_count</span>\n\n<span color='#fab387'>Navigation:</span>\n• Click workspaces to switch\n• Scroll on workspaces to navigate\n• Super + 1-9 for quick access",
    "class": "workspace-$current_workspace",
    "alt": "workspace-$current_workspace"
}
EOF