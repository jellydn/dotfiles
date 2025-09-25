#!/bin/bash
# Universal Wayland compositor status checker
# Automatically detects Hyprland, Niri, or other compositors and uses appropriate tools

set -euo pipefail

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[✓]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[!]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1"; }

# Function to detect current compositor
detect_compositor() {
    # Check environment variables first
    if [[ "${XDG_CURRENT_DESKTOP:-}" == "Hyprland" ]]; then
        echo "hyprland"
        return
    fi

    # Check running processes
    if pgrep -x "Hyprland" >/dev/null 2>&1; then
        echo "hyprland"
        return
    elif pgrep -x "niri" >/dev/null 2>&1; then
        echo "niri"
        return
    elif pgrep -x "sway" >/dev/null 2>&1; then
        echo "sway"
        return
    elif pgrep -x "river" >/dev/null 2>&1; then
        echo "river"
        return
    elif pgrep -x "wayfire" >/dev/null 2>&1; then
        echo "wayfire"
        return
    fi

    # Check if we're in a Wayland session at all
    if [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
        echo "unknown-wayland"
    else
        echo "none"
    fi
}

# Function to run appropriate status script
run_status_check() {
    local compositor="$1"
    local mode="${2:-status}"

    case "$compositor" in
        "hyprland")
            if [[ -x ~/.dotfiles/scripts/hyprland-status.sh ]]; then
                ~/.dotfiles/scripts/hyprland-status.sh "$mode"
            else
                log_error "Hyprland status script not found"
                return 1
            fi
            ;;
        "niri")
            if [[ -x ~/.dotfiles/scripts/niri-status.sh ]]; then
                ~/.dotfiles/scripts/niri-status.sh "$mode"
            else
                log_error "Niri status script not found"
                return 1
            fi
            ;;
        "sway")
            log_info "Sway detected - using basic checks"
            if pgrep -x "sway" >/dev/null 2>&1; then
                log_success "Sway is running (PID: $(pgrep -x sway))"
                if [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
                    log_success "Wayland display: $WAYLAND_DISPLAY"
                fi
                if command -v swaymsg >/dev/null 2>&1; then
                    log_info "Sway version: $(swaymsg -t get_version | head -1)"
                fi
            else
                log_error "Sway is not running"
                return 1
            fi
            ;;
        "unknown-wayland")
            log_warning "Unknown Wayland compositor running"
            log_info "Wayland display: ${WAYLAND_DISPLAY:-none}"
            log_info "Session type: ${XDG_SESSION_TYPE:-unknown}"
            log_info "Current desktop: ${XDG_CURRENT_DESKTOP:-unknown}"
            ;;
        "none")
            log_error "No Wayland compositor detected"
            log_info "Current session type: ${XDG_SESSION_TYPE:-unknown}"
            if [[ -n "${DISPLAY:-}" ]]; then
                log_info "X11 display detected: $DISPLAY"
                log_warning "You may be running X11 instead of Wayland"
            fi
            return 1
            ;;
        *)
            log_warning "Compositor '$compositor' not specifically supported"
            log_info "Basic Wayland checks:"
            log_info "Wayland display: ${WAYLAND_DISPLAY:-none}"
            log_info "Session type: ${XDG_SESSION_TYPE:-unknown}"
            ;;
    esac
}

# Function to run health check
run_health_check() {
    local compositor="$1"
    local format="${2:-simple}"

    case "$compositor" in
        "hyprland")
            if [[ -x ~/.dotfiles/scripts/hyprland-health-check.sh ]]; then
                ~/.dotfiles/scripts/hyprland-health-check.sh "$format"
            else
                echo "✗"
            fi
            ;;
        "niri")
            if [[ -x ~/.dotfiles/scripts/niri-health-check.sh ]]; then
                ~/.dotfiles/scripts/niri-health-check.sh "$format"
            else
                echo "✗"
            fi
            ;;
        "sway")
            if pgrep -x "sway" >/dev/null 2>&1 && [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
                echo "✓"
            else
                echo "✗"
            fi
            ;;
        *)
            if [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
                echo "?"
            else
                echo "✗"
            fi
            ;;
    esac
}

# Function to show compositor info
show_compositor_info() {
    local compositor="$1"

    echo "🖥️  Compositor Detection Results"
    echo "==============================="
    log_info "Detected compositor: $compositor"
    log_info "Wayland display: ${WAYLAND_DISPLAY:-not set}"
    log_info "Session type: ${XDG_SESSION_TYPE:-not set}"
    log_info "Current desktop: ${XDG_CURRENT_DESKTOP:-not set}"

    if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
        log_info "Hyprland instance: ${HYPRLAND_INSTANCE_SIGNATURE:0:8}..."
    fi

    echo
    log_info "Available status scripts:"
    [[ -x ~/.dotfiles/scripts/hyprland-status.sh ]] && echo "  ✓ Hyprland status script"
    [[ -x ~/.dotfiles/scripts/niri-status.sh ]] && echo "  ✓ Niri status script"
    [[ -x ~/.dotfiles/scripts/hyprland-health-check.sh ]] && echo "  ✓ Hyprland health check"
    [[ -x ~/.dotfiles/scripts/niri-health-check.sh ]] && echo "  ✓ Niri health check"
}

# Main function
main() {
    local action="${1:-status}"
    local compositor

    compositor=$(detect_compositor)

    case "$action" in
        "status"|"")
            show_compositor_info "$compositor"
            echo
            run_status_check "$compositor" "status"
            ;;
        "quick")
            run_status_check "$compositor" "quick"
            ;;
        "full"|"detailed")
            show_compositor_info "$compositor"
            echo
            run_status_check "$compositor" "full"
            ;;
        "health")
            run_health_check "$compositor" "simple"
            ;;
        "health-json")
            run_health_check "$compositor" "json"
            ;;
        "health-percent")
            run_health_check "$compositor" "percentage"
            ;;
        "detect")
            echo "$compositor"
            ;;
        "info")
            show_compositor_info "$compositor"
            ;;
        "help")
            echo "Universal Wayland Compositor Status Checker"
            echo "Usage: $0 [action]"
            echo ""
            echo "Actions:"
            echo "  status        - Show compositor info and run status check (default)"
            echo "  quick         - Quick status check"
            echo "  full          - Detailed status check"
            echo "  health        - Simple health status (✓/!/✗)"
            echo "  health-json   - Health status in JSON format"
            echo "  health-percent- Health status as percentage"
            echo "  detect        - Just show detected compositor name"
            echo "  info          - Show compositor detection info only"
            echo "  help          - Show this help"
            echo ""
            echo "Supported compositors: Hyprland, Niri, Sway (basic), others (basic)"
            ;;
        *)
            log_error "Unknown action: $action"
            echo "Use '$0 help' for available actions"
            exit 1
            ;;
    esac
}

main "$@"