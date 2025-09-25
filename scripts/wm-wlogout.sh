#!/bin/bash
# Smart wlogout wrapper that works with both Niri and Hyprland
# Handles protocol differences and layout generation

set -euo pipefail

# Function to detect current compositor
detect_compositor() {
    if [[ "${XDG_CURRENT_DESKTOP:-}" == "Hyprland" ]] || pgrep -x "Hyprland" >/dev/null 2>&1; then
        echo "hyprland"
    elif pgrep -x "niri" >/dev/null 2>&1; then
        echo "niri"
    elif pgrep -x "sway" >/dev/null 2>&1; then
        echo "sway"
    else
        echo "unknown"
    fi
}

# Function to run wlogout with appropriate settings
run_wlogout() {
    local compositor="$1"
    shift
    local args=("$@")

    # Default wlogout arguments
    local wlogout_args=(
        --layout "$HOME/.config/wlogout/layout"
        --css "$HOME/.config/wlogout/style.css"
        --buttons-per-row 3
        --margin 20
    )

    case "$compositor" in
        "hyprland")
            # Use layer-shell protocol for Hyprland
            wlogout_args+=(--protocol layer-shell)
            ;;
        "niri")
            # Use layer-shell protocol for Niri (default)
            wlogout_args+=(--protocol layer-shell)
            ;;
        "sway")
            # Use layer-shell protocol for Sway
            wlogout_args+=(--protocol layer-shell)
            ;;
        *)
            # Try layer-shell as default
            wlogout_args+=(--protocol layer-shell)
            ;;
    esac

    # Add any additional arguments passed to script
    wlogout_args+=("${args[@]}")

    # Execute wlogout
    exec wlogout "${wlogout_args[@]}"
}

# Main execution
main() {
    local compositor
    compositor=$(detect_compositor)

    # Check if wlogout config exists
    if [[ ! -f "$HOME/.config/wlogout/layout" ]]; then
        echo "Error: wlogout layout not found at $HOME/.config/wlogout/layout" >&2
        exit 1
    fi

    if [[ ! -f "$HOME/.config/wlogout/style.css" ]]; then
        echo "Error: wlogout CSS not found at $HOME/.config/wlogout/style.css" >&2
        exit 1
    fi

    # Run wlogout with detected compositor settings
    run_wlogout "$compositor" "$@"
}

# Handle help
if [[ "${1:-}" == "--help" ]] || [[ "${1:-}" == "-h" ]]; then
    echo "Smart wlogout wrapper for multiple Wayland compositors"
    echo "Usage: $0 [wlogout-options...]"
    echo ""
    echo "This script automatically detects your compositor (Hyprland/Niri/Sway)"
    echo "and runs wlogout with appropriate protocol and settings."
    echo ""
    echo "Detected compositor: $(detect_compositor)"
    echo ""
    echo "For wlogout options, see: wlogout --help"
    exit 0
fi

main "$@"