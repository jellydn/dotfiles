#!/bin/bash
# Simple Hyprland health check for integration with status bars and monitoring
# Returns JSON format compatible with Waybar custom modules

set -euo pipefail

# Function to get Hyprland health status
get_hyprland_health() {
    local status="unknown"
    local class="unknown"
    local text="Hyprland Status Unknown"
    local tooltip=""
    local percentage=0

    # Check if Hyprland is running
    if ! pgrep -x "Hyprland" >/dev/null 2>&1; then
        status="critical"
        class="critical"
        text="Hyprland Not Running"
        tooltip="Hyprland compositor is not running\nClick to check status"
        percentage=0
    else
        # Hyprland is running, check health indicators
        local issues=0
        local total_checks=5
        local details=()

        # Check Wayland display
        if [[ -z "${WAYLAND_DISPLAY:-}" ]]; then
            issues=$((issues + 1))
            details+=("No Wayland display")
        else
            details+=("Wayland: $WAYLAND_DISPLAY")
        fi

        # Check Hyprland instance signature
        if [[ -z "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
            issues=$((issues + 1))
            details+=("No instance signature")
        else
            details+=("Instance: ${HYPRLAND_INSTANCE_SIGNATURE:0:8}...")
        fi

        # Check if we can communicate with Hyprland
        if ! hyprctl version >/dev/null 2>&1; then
            issues=$((issues + 1))
            details+=("Cannot communicate with Hyprland")
        else
            # Get basic info
            local window_count=0
            local workspace_count=0

            if command -v jq >/dev/null 2>&1; then
                window_count=$(hyprctl clients -j 2>/dev/null | jq '. | length' 2>/dev/null || echo "0")
                workspace_count=$(hyprctl workspaces -j 2>/dev/null | jq '. | length' 2>/dev/null || echo "0")
            else
                window_count=$(hyprctl clients 2>/dev/null | grep -c "Window" || echo "0")
                workspace_count=$(hyprctl workspaces 2>/dev/null | grep -c "workspace ID" || echo "0")
            fi

            details+=("Windows: $window_count, Workspaces: $workspace_count")
        fi

        # Check configuration errors
        local config_errors=$(hyprctl configerrors 2>/dev/null || echo "")
        if [[ -n "$config_errors" && "$config_errors" != "no errors" ]]; then
            issues=$((issues + 1))
            details+=("Config has errors")
        else
            details+=("Config valid")
        fi

        # Check memory usage (if over 800MB, flag as warning - Hyprland can use more than Niri)
        local hyprland_pid=$(pgrep -x Hyprland)
        local mem_kb=$(ps -o rss= -p "$hyprland_pid" 2>/dev/null || echo "0")
        local mem_mb=$((mem_kb / 1024))
        if [[ $mem_mb -gt 800 ]]; then
            issues=$((issues + 1))
            details+=("High memory: ${mem_mb}MB")
        else
            details+=("Memory: ${mem_mb}MB")
        fi

        # Determine status based on issues
        percentage=$(( (total_checks - issues) * 100 / total_checks ))

        if [[ $issues -eq 0 ]]; then
            status="good"
            class="good"
            text="Hyprland Healthy"
        elif [[ $issues -le 1 ]]; then
            status="warning"
            class="warning"
            text="Hyprland Issues"
        else
            status="critical"
            class="critical"
            text="Hyprland Problems"
        fi

        # Build tooltip
        tooltip="Hyprland Status: $status\\n$(printf '%s\\n' "${details[@]}")"
    fi

    # Output JSON for Waybar
    printf '{"text": "%s", "class": "%s", "percentage": %d, "tooltip": "%s"}\n' \
        "$text" "$class" "$percentage" "$tooltip"
}

# Function to output simple status (for shell prompt)
get_simple_status() {
    if pgrep -x "Hyprland" >/dev/null 2>&1; then
        if [[ -n "${WAYLAND_DISPLAY:-}" ]] && [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]] && hyprctl version >/dev/null 2>&1; then
            # Check for config errors
            local errors=$(hyprctl configerrors 2>/dev/null || echo "")
            if [[ -n "$errors" && "$errors" != "no errors" ]]; then
                echo "!"
            else
                echo "✓"
            fi
        else
            echo "!"
        fi
    else
        echo "✗"
    fi
}

# Function to output health percentage (for monitoring)
get_health_percentage() {
    if ! pgrep -x "Hyprland" >/dev/null 2>&1; then
        echo "0"
        return
    fi

    local issues=0
    local total_checks=5

    # Wayland display check
    [[ -z "${WAYLAND_DISPLAY:-}" ]] && issues=$((issues + 1))

    # Instance signature check
    [[ -z "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]] && issues=$((issues + 1))

    # Communication check
    ! hyprctl version >/dev/null 2>&1 && issues=$((issues + 1))

    # Config check
    local config_errors=$(hyprctl configerrors 2>/dev/null || echo "")
    [[ -n "$config_errors" && "$config_errors" != "no errors" ]] && issues=$((issues + 1))

    # Memory check (over 800MB)
    local hyprland_pid=$(pgrep -x Hyprland || echo "")
    if [[ -n "$hyprland_pid" ]]; then
        local mem_kb=$(ps -o rss= -p "$hyprland_pid" 2>/dev/null || echo "0")
        local mem_mb=$((mem_kb / 1024))
        [[ $mem_mb -gt 800 ]] && issues=$((issues + 1))
    else
        issues=$((issues + 1))
    fi

    echo $(( (total_checks - issues) * 100 / total_checks ))
}

# Main function
main() {
    case "${1:-json}" in
        "json")
            get_hyprland_health
            ;;
        "simple"|"status")
            get_simple_status
            ;;
        "percentage"|"percent")
            get_health_percentage
            ;;
        "help")
            echo "Hyprland Health Check"
            echo "Usage: $0 [format]"
            echo ""
            echo "Formats:"
            echo "  json       - JSON format for Waybar (default)"
            echo "  simple     - Simple status symbol (✓/!/✗)"
            echo "  percentage - Health percentage (0-100)"
            echo "  help       - Show this help"
            ;;
        *)
            echo "Unknown format: $1" >&2
            echo "Use '$0 help' for available formats" >&2
            exit 1
            ;;
    esac
}

main "$@"