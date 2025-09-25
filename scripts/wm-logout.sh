#!/bin/bash
# Smart logout script that works with both Niri and Hyprland
# Detects current compositor and uses appropriate exit command

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

# Function to get appropriate logout command
get_logout_command() {
    local compositor="$1"

    case "$compositor" in
        "hyprland")
            echo "hyprctl dispatch exit"
            ;;
        "niri")
            echo "niri msg action quit"
            ;;
        "sway")
            echo "swaymsg exit"
            ;;
        *)
            # Fallback to session manager
            echo "loginctl terminate-session \$XDG_SESSION_ID"
            ;;
    esac
}

# Main execution
main() {
    local compositor
    compositor=$(detect_compositor)

    local logout_cmd
    logout_cmd=$(get_logout_command "$compositor")

    case "${1:-logout}" in
        "logout")
            eval "$logout_cmd"
            ;;
        "get-command")
            echo "$logout_cmd"
            ;;
        "test")
            echo "Detected compositor: $compositor"
            echo "Logout command: $logout_cmd"
            ;;
        *)
            echo "Usage: $0 [logout|get-command|test]"
            echo "  logout      - Execute logout (default)"
            echo "  get-command - Show the logout command that would be used"
            echo "  test        - Show detected compositor and command"
            exit 1
            ;;
    esac
}

main "$@"