#!/bin/bash
# Simple Niri health check for integration with status bars and monitoring
# Returns JSON format compatible with Waybar custom modules

set -euo pipefail

# Function to get Niri health status
get_niri_health() {
    local status="unknown"
    local class="unknown"
    local text="Niri Status Unknown"
    local tooltip=""
    local percentage=0

    # Check if Niri is running
    if ! pgrep -x "niri" >/dev/null 2>&1; then
        status="critical"
        class="critical"
        text="Niri Not Running"
        tooltip="Niri compositor is not running\nClick to check status"
        percentage=0
    else
        # Niri is running, check health indicators
        local issues=0
        local total_checks=4
        local details=()

        # Check Wayland display
        if [[ -z "${WAYLAND_DISPLAY:-}" ]]; then
            issues=$((issues + 1))
            details+=("No Wayland display")
        else
            details+=("Wayland: $WAYLAND_DISPLAY")
        fi

        # Check if we can communicate with Niri
        if ! niri msg version >/dev/null 2>&1; then
            issues=$((issues + 1))
            details+=("Cannot communicate with Niri")
        else
            # Get basic info
            local window_count=$(niri msg windows 2>/dev/null | wc -l || echo "0")
            local workspace_count=$(niri msg workspaces 2>/dev/null | wc -l || echo "0")
            details+=("Windows: $window_count, Workspaces: $workspace_count")
        fi

        # Check configuration validity
        if [[ -f "$HOME/.config/niri/config.kdl" ]]; then
            if ! niri validate -c "$HOME/.config/niri/config.kdl" >/dev/null 2>&1; then
                issues=$((issues + 1))
                details+=("Config has errors")
            else
                details+=("Config valid")
            fi
        else
            issues=$((issues + 1))
            details+=("Config file missing")
        fi

        # Check memory usage (if over 500MB, flag as warning)
        local niri_pid=$(pgrep -x niri)
        local mem_kb=$(ps -o rss= -p "$niri_pid" 2>/dev/null || echo "0")
        local mem_mb=$((mem_kb / 1024))
        if [[ $mem_mb -gt 500 ]]; then
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
            text="Niri Healthy"
        elif [[ $issues -le 1 ]]; then
            status="warning"
            class="warning"
            text="Niri Issues"
        else
            status="critical"
            class="critical"
            text="Niri Problems"
        fi

        # Build tooltip
        tooltip="Niri Status: $status\\n$(printf '%s\\n' "${details[@]}")"
    fi

    # Output JSON for Waybar
    printf '{"text": "%s", "class": "%s", "percentage": %d, "tooltip": "%s"}\n' \
        "$text" "$class" "$percentage" "$tooltip"
}

# Function to output simple status (for shell prompt)
get_simple_status() {
    if pgrep -x "niri" >/dev/null 2>&1; then
        if [[ -n "${WAYLAND_DISPLAY:-}" ]] && niri msg version >/dev/null 2>&1; then
            echo "✓"
        else
            echo "!"
        fi
    else
        echo "✗"
    fi
}

# Function to output health percentage (for monitoring)
get_health_percentage() {
    if ! pgrep -x "niri" >/dev/null 2>&1; then
        echo "0"
        return
    fi

    local issues=0
    local total_checks=4

    # Wayland display check
    [[ -z "${WAYLAND_DISPLAY:-}" ]] && issues=$((issues + 1))

    # Communication check
    ! niri msg version >/dev/null 2>&1 && issues=$((issues + 1))

    # Config check
    if [[ -f "$HOME/.config/niri/config.kdl" ]]; then
        ! niri validate -c "$HOME/.config/niri/config.kdl" >/dev/null 2>&1 && issues=$((issues + 1))
    else
        issues=$((issues + 1))
    fi

    # Memory check (over 500MB)
    local niri_pid=$(pgrep -x niri || echo "")
    if [[ -n "$niri_pid" ]]; then
        local mem_kb=$(ps -o rss= -p "$niri_pid" 2>/dev/null || echo "0")
        local mem_mb=$((mem_kb / 1024))
        [[ $mem_mb -gt 500 ]] && issues=$((issues + 1))
    else
        issues=$((issues + 1))
    fi

    echo $(( (total_checks - issues) * 100 / total_checks ))
}

# Main function
main() {
    case "${1:-json}" in
        "json")
            get_niri_health
            ;;
        "simple"|"status")
            get_simple_status
            ;;
        "percentage"|"percent")
            get_health_percentage
            ;;
        "help")
            echo "Niri Health Check"
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