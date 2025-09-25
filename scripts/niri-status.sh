#!/bin/bash
# Comprehensive Niri status checker
# Based on Arch Wiki recommendations: https://wiki.archlinux.org/title/Niri

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[✓]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[!]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1"; }
log_section() { echo -e "\n${CYAN}=== $1 ===${NC}"; }

# Function to check if niri is running
check_niri_running() {
    if pgrep -x "niri" >/dev/null 2>&1; then
        log_success "Niri compositor is running (PID: $(pgrep -x niri))"
        return 0
    else
        log_error "Niri compositor is NOT running"
        return 1
    fi
}

# Function to check systemd service status
check_systemd_status() {
    local service="$1"
    if systemctl --user is-active "$service" >/dev/null 2>&1; then
        local status=$(systemctl --user is-active "$service")
        log_success "$service: $status"
        return 0
    else
        local status=$(systemctl --user is-active "$service" || echo "inactive")
        log_warning "$service: $status"
        return 1
    fi
}

# Function to check Wayland environment
check_wayland_env() {
    if [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
        log_success "Wayland display server: $WAYLAND_DISPLAY"
    else
        log_error "WAYLAND_DISPLAY not set"
    fi

    if [[ -n "${XDG_SESSION_TYPE:-}" ]]; then
        log_info "Session type: $XDG_SESSION_TYPE"
    else
        log_warning "XDG_SESSION_TYPE not set"
    fi
}

# Function to show niri version and build info
show_niri_info() {
    if check_niri_running; then
        echo
        log_info "Niri version information:"
        if niri msg version 2>/dev/null; then
            echo
        else
            log_warning "Could not retrieve niri version"
        fi
    fi
}

# Function to show outputs status
show_outputs_status() {
    if check_niri_running; then
        echo
        log_info "Connected outputs:"
        if niri msg outputs 2>/dev/null; then
            echo
        else
            log_warning "Could not retrieve outputs information"
        fi

        echo
        log_info "Focused output:"
        if niri msg focused-output 2>/dev/null; then
            echo
        else
            log_warning "Could not retrieve focused output"
        fi
    fi
}

# Function to show workspaces status
show_workspaces_status() {
    if check_niri_running; then
        echo
        log_info "Workspaces:"
        if niri msg workspaces 2>/dev/null; then
            echo
        else
            log_warning "Could not retrieve workspaces information"
        fi
    fi
}

# Function to show windows status
show_windows_status() {
    if check_niri_running; then
        echo
        log_info "Open windows:"
        local window_count
        if window_count=$(niri msg windows 2>/dev/null | wc -l) && [[ "$window_count" -gt 0 ]]; then
            niri msg windows 2>/dev/null
            log_info "Total windows: $window_count"
        else
            log_info "No windows open"
        fi
        echo

        log_info "Focused window:"
        if niri msg focused-window 2>/dev/null; then
            echo
        else
            log_info "No focused window"
        fi
    fi
}

# Function to check graphics and EGL status
check_graphics_status() {
    log_info "Graphics driver information:"
    if command -v glxinfo >/dev/null 2>&1; then
        local renderer=$(glxinfo 2>/dev/null | grep "OpenGL renderer" | cut -d: -f2- | sed 's/^ *//' || echo "Unknown")
        local vendor=$(glxinfo 2>/dev/null | grep "OpenGL vendor" | cut -d: -f2- | sed 's/^ *//' || echo "Unknown")
        echo "  Renderer: $renderer"
        echo "  Vendor: $vendor"

        if echo "$renderer" | grep -qi "llvmpipe\|software\|mesa"; then
            log_warning "Using software rendering - consider enabling hardware acceleration"
        else
            log_success "Hardware acceleration enabled"
        fi
    else
        log_warning "glxinfo not found (install mesa-utils for detailed graphics info)"
    fi

    # Check EGL support
    if command -v eglinfo >/dev/null 2>&1; then
        if eglinfo 2>/dev/null | grep -q "EGL_WL_bind_wayland_display"; then
            log_success "EGL Wayland display binding supported"
        else
            log_warning "EGL Wayland display binding NOT supported - may need manual DRM device override"
        fi
    else
        log_info "eglinfo not found (install mesa-utils for EGL diagnostics)"
    fi
}

# Function to check configuration status
check_config_status() {
    local config="$HOME/.config/niri/config.kdl"
    if [[ -f "$config" ]]; then
        log_success "Configuration file exists: $config"

        # Check for DRM override
        if grep -q "^debug" "$config"; then
            if grep -A 5 "^debug" "$config" | grep -q "render-drm-device"; then
                log_info "Manual DRM device override enabled (for VM/compatibility)"
            else
                log_info "Debug configuration present"
            fi
        elif grep -q "^/-debug" "$config"; then
            log_info "DRM device override available but commented out"
        fi

        # Check for recent config validation
        if niri validate -c "$config" >/dev/null 2>&1; then
            log_success "Configuration file is valid"
        else
            log_error "Configuration file has validation errors"
            echo "Run: niri validate -c $config"
        fi
    else
        log_error "Configuration file not found: $config"
    fi
}

# Function to show systemd services status
show_systemd_services() {
    log_info "Niri-related systemd services:"

    # Core niri service
    check_systemd_status "niri.service"

    # Related services that might be configured
    local services=("waybar.service" "wallpaper.service" "swayidle.service" "swaylock.service")
    for service in "${services[@]}"; do
        if systemctl --user list-unit-files | grep -q "^$service"; then
            check_systemd_status "$service"
        fi
    done
}

# Function to show resource usage
show_resource_usage() {
    if check_niri_running; then
        local niri_pid=$(pgrep -x niri)
        log_info "Resource usage (PID: $niri_pid):"

        # Memory usage
        local mem_kb=$(ps -o rss= -p "$niri_pid" 2>/dev/null || echo "0")
        local mem_mb=$((mem_kb / 1024))
        echo "  Memory: ${mem_mb} MB"

        # CPU usage (brief sample)
        local cpu_percent=$(ps -o %cpu= -p "$niri_pid" 2>/dev/null | tr -d ' ' || echo "0.0")
        echo "  CPU: ${cpu_percent}%"

        # File descriptors
        if [[ -d "/proc/$niri_pid/fd" ]]; then
            local fd_count=$(ls /proc/"$niri_pid"/fd 2>/dev/null | wc -l)
            echo "  File descriptors: $fd_count"
        fi
    fi
}

# Function to show recent logs
show_recent_logs() {
    log_info "Recent niri logs (last 10 lines):"
    if systemctl --user is-active niri.service >/dev/null 2>&1; then
        journalctl --user -u niri.service -n 10 --no-pager -q 2>/dev/null || log_warning "Could not retrieve systemd logs"
    else
        log_warning "Niri systemd service not active - no systemd logs available"
    fi
}

# Function to show troubleshooting suggestions
show_troubleshooting() {
    if ! check_niri_running; then
        log_section "TROUBLESHOOTING SUGGESTIONS"
        echo "Niri is not running. Try these steps:"
        echo "1. Check systemd service: systemctl --user status niri.service"
        echo "2. Check configuration: niri validate -c ~/.config/niri/config.kdl"
        echo "3. Start manually for debugging: niri"
        echo "4. Check logs: journalctl --user -u niri.service"
        echo "5. Verify Wayland support: echo \$WAYLAND_DISPLAY"
        echo "6. For VMs: Run ~/.dotfiles/scripts/fix-niri-vm-graphics.sh"

        # Check if in VM
        if systemd-detect-virt -q 2>/dev/null; then
            local vm_type=$(systemd-detect-virt)
            echo "7. VM detected ($vm_type): Consider enabling DRM device override"
        fi
    fi
}

# Main function
main() {
    local option="${1:-status}"

    case "$option" in
        "status"|"")
            echo "🔍 Niri Status Check"
            echo "===================="

            log_section "PROCESS STATUS"
            check_niri_running

            log_section "ENVIRONMENT"
            check_wayland_env

            log_section "SYSTEMD SERVICES"
            show_systemd_services

            log_section "CONFIGURATION"
            check_config_status

            log_section "GRAPHICS"
            check_graphics_status

            show_troubleshooting
            ;;

        "full"|"detailed")
            echo "🔍 Detailed Niri Status"
            echo "======================="

            log_section "PROCESS STATUS"
            check_niri_running

            log_section "ENVIRONMENT"
            check_wayland_env

            log_section "VERSION INFO"
            show_niri_info

            log_section "OUTPUTS"
            show_outputs_status

            log_section "WORKSPACES"
            show_workspaces_status

            log_section "WINDOWS"
            show_windows_status

            log_section "SYSTEMD SERVICES"
            show_systemd_services

            log_section "CONFIGURATION"
            check_config_status

            log_section "GRAPHICS"
            check_graphics_status

            log_section "RESOURCE USAGE"
            show_resource_usage

            log_section "RECENT LOGS"
            show_recent_logs

            show_troubleshooting
            ;;

        "quick")
            if check_niri_running; then
                echo "✓ Niri is running"
                if [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
                    echo "✓ Wayland: $WAYLAND_DISPLAY"
                fi
                local window_count=$(niri msg windows 2>/dev/null | wc -l || echo "0")
                echo "• Windows: $window_count"
                local workspace_count=$(niri msg workspaces 2>/dev/null | wc -l || echo "0")
                echo "• Workspaces: $workspace_count"
                exit 0
            else
                echo "✗ Niri is not running"
                exit 1
            fi
            ;;

        "logs")
            show_recent_logs
            ;;

        "config")
            check_config_status
            ;;

        "help")
            echo "Niri Status Checker"
            echo "Usage: $0 [option]"
            echo ""
            echo "Options:"
            echo "  status    - Standard status check (default)"
            echo "  full      - Detailed status with all information"
            echo "  quick     - Quick status check (suitable for scripts)"
            echo "  logs      - Show recent logs only"
            echo "  config    - Check configuration only"
            echo "  help      - Show this help"
            ;;

        *)
            log_error "Unknown option: $option"
            echo "Use '$0 help' for available options"
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"