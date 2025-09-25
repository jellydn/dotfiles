#!/bin/bash
# Comprehensive Hyprland status checker
# Based on Arch Wiki recommendations: https://wiki.archlinux.org/title/Hyprland

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

# Function to check if Hyprland is running
check_hyprland_running() {
    if pgrep -x "Hyprland" >/dev/null 2>&1; then
        log_success "Hyprland compositor is running (PID: $(pgrep -x Hyprland))"
        return 0
    else
        log_error "Hyprland compositor is NOT running"
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

    if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
        log_success "Hyprland instance signature: $HYPRLAND_INSTANCE_SIGNATURE"
    else
        log_warning "HYPRLAND_INSTANCE_SIGNATURE not set"
    fi
}

# Function to show Hyprland version and build info
show_hyprland_info() {
    if check_hyprland_running; then
        echo
        log_info "Hyprland version information:"
        if hyprctl version 2>/dev/null; then
            echo
        else
            log_warning "Could not retrieve Hyprland version"
        fi

        echo
        log_info "System information:"
        if hyprctl systeminfo 2>/dev/null; then
            echo
        else
            log_warning "Could not retrieve system information"
        fi
    fi
}

# Function to show monitors status
show_monitors_status() {
    if check_hyprland_running; then
        echo
        log_info "Connected monitors:"
        if hyprctl monitors 2>/dev/null; then
            echo
        else
            log_warning "Could not retrieve monitor information"
        fi
    fi
}

# Function to show workspaces status
show_workspaces_status() {
    if check_hyprland_running; then
        echo
        log_info "Workspaces:"
        if hyprctl workspaces 2>/dev/null; then
            echo
        else
            log_warning "Could not retrieve workspaces information"
        fi

        echo
        log_info "Active workspace:"
        if hyprctl activeworkspace 2>/dev/null; then
            echo
        else
            log_warning "Could not retrieve active workspace"
        fi
    fi
}

# Function to show windows status
show_windows_status() {
    if check_hyprland_running; then
        echo
        log_info "Open windows:"
        local window_count
        if window_count=$(hyprctl clients -j 2>/dev/null | jq '. | length' 2>/dev/null) && [[ "$window_count" -gt 0 ]]; then
            hyprctl clients 2>/dev/null
            log_info "Total windows: $window_count"
        else
            # Fallback without jq
            if window_count=$(hyprctl clients 2>/dev/null | grep -c "Window" || echo "0") && [[ "$window_count" -gt 0 ]]; then
                hyprctl clients 2>/dev/null
                log_info "Total windows: $window_count"
            else
                log_info "No windows open"
            fi
        fi
        echo

        log_info "Active window:"
        if hyprctl activewindow 2>/dev/null; then
            echo
        else
            log_info "No active window"
        fi
    fi
}

# Function to check configuration status
check_config_status() {
    local config="$HOME/.config/hypr/hyprland.conf"
    if [[ -f "$config" ]]; then
        log_success "Configuration file exists: $config"

        # Check for config errors
        if check_hyprland_running; then
            local errors
            errors=$(hyprctl configerrors 2>/dev/null || echo "")
            if [[ -n "$errors" && "$errors" != "no errors" ]]; then
                log_error "Configuration has errors:"
                echo "$errors"
            else
                log_success "No configuration errors found"
            fi
        else
            log_warning "Cannot check config errors - Hyprland not running"
        fi

        # Check file permissions
        if [[ -r "$config" ]]; then
            log_success "Configuration file is readable"
        else
            log_error "Configuration file is not readable"
        fi
    else
        log_error "Configuration file not found: $config"
    fi
}

# Function to show bindings and options
show_bindings_options() {
    if check_hyprland_running; then
        echo
        log_info "Key bindings (first 10):"
        if hyprctl binds 2>/dev/null | head -10; then
            local total_binds=$(hyprctl binds 2>/dev/null | wc -l || echo "0")
            log_info "Total bindings: $total_binds"
            echo
        else
            log_warning "Could not retrieve key bindings"
        fi

        echo
        log_info "Animation status:"
        if hyprctl animations 2>/dev/null; then
            echo
        else
            log_warning "Could not retrieve animation status"
        fi
    fi
}

# Function to show systemd services status
show_systemd_services() {
    log_info "Hyprland-related systemd services:"

    # Hyprland itself doesn't typically run as a systemd service
    # But related services might
    local services=("waybar.service" "hyprpaper.service" "hypridle.service" "swayidle.service")
    for service in "${services[@]}"; do
        if systemctl --user list-unit-files | grep -q "^$service"; then
            check_systemd_status "$service"
        fi
    done

    # Check if running under a session manager
    if systemctl --user is-active graphical-session.target >/dev/null 2>&1; then
        log_success "graphical-session.target: active"
    else
        log_warning "graphical-session.target: inactive"
    fi
}

# Function to show resource usage
show_resource_usage() {
    if check_hyprland_running; then
        local hyprland_pid=$(pgrep -x Hyprland)
        log_info "Resource usage (PID: $hyprland_pid):"

        # Memory usage
        local mem_kb=$(ps -o rss= -p "$hyprland_pid" 2>/dev/null || echo "0")
        local mem_mb=$((mem_kb / 1024))
        echo "  Memory: ${mem_mb} MB"

        # CPU usage (brief sample)
        local cpu_percent=$(ps -o %cpu= -p "$hyprland_pid" 2>/dev/null | tr -d ' ' || echo "0.0")
        echo "  CPU: ${cpu_percent}%"

        # File descriptors
        if [[ -d "/proc/$hyprland_pid/fd" ]]; then
            local fd_count=$(ls /proc/"$hyprland_pid"/fd 2>/dev/null | wc -l)
            echo "  File descriptors: $fd_count"
        fi

        # Check for GPU usage if available
        if command -v nvidia-smi >/dev/null 2>&1; then
            echo "  GPU (NVIDIA):"
            nvidia-smi --query-gpu=utilization.gpu,memory.used,memory.total --format=csv,noheader,nounits 2>/dev/null | while IFS=, read -r gpu_util mem_used mem_total; do
                echo "    Utilization: ${gpu_util}%, Memory: ${mem_used}MB/${mem_total}MB"
            done
        fi
    fi
}

# Function to show recent logs
show_recent_logs() {
    log_info "Recent Hyprland logs:"

    # Try to get logs from hyprctl first
    if check_hyprland_running; then
        echo "Rolling log (last 20 lines):"
        if timeout 3 hyprctl rollinglog 2>/dev/null | tail -20; then
            echo
        else
            log_warning "Could not retrieve rolling log"
        fi
    fi

    # Also check journalctl if Hyprland is running as part of a session
    if journalctl --user -t Hyprland -n 10 --no-pager -q 2>/dev/null | grep -q .; then
        echo
        log_info "Journal logs (last 10 lines):"
        journalctl --user -t Hyprland -n 10 --no-pager -q 2>/dev/null
    fi
}

# Function to check plugins and extensions
show_plugins_info() {
    if check_hyprland_running; then
        echo
        log_info "Plugin information:"
        if hyprctl plugin list 2>/dev/null; then
            echo
        else
            log_info "No plugins loaded or plugin command unavailable"
        fi
    fi
}

# Function to show troubleshooting suggestions
show_troubleshooting() {
    if ! check_hyprland_running; then
        log_section "TROUBLESHOOTING SUGGESTIONS"
        echo "Hyprland is not running. Try these steps:"
        echo "1. Check if running in session: echo \$XDG_SESSION_TYPE"
        echo "2. Start from TTY: Hyprland"
        echo "3. Check logs: journalctl --user -t Hyprland"
        echo "4. Verify config: ~/.config/hypr/hyprland.conf"
        echo "5. Check Wayland support: echo \$WAYLAND_DISPLAY"
        echo "6. Verify GPU drivers are loaded"

        # Check if in VM
        if systemd-detect-virt -q 2>/dev/null; then
            local vm_type=$(systemd-detect-virt)
            echo "7. VM detected ($vm_type): Ensure 3D acceleration is enabled"
        fi

        # Check display manager
        if systemctl is-active display-manager >/dev/null 2>&1; then
            local dm=$(systemctl status display-manager 2>/dev/null | grep -o 'loaded.*service' | cut -d/ -f2 | cut -d. -f1 || echo "unknown")
            echo "8. Display manager active: $dm (may conflict with manual Hyprland start)"
        fi
    fi
}

# Main function
main() {
    local option="${1:-status}"

    case "$option" in
        "status"|"")
            echo "🔍 Hyprland Status Check"
            echo "========================"

            log_section "PROCESS STATUS"
            check_hyprland_running

            log_section "ENVIRONMENT"
            check_wayland_env

            log_section "SYSTEMD SERVICES"
            show_systemd_services

            log_section "CONFIGURATION"
            check_config_status

            show_troubleshooting
            ;;

        "full"|"detailed")
            echo "🔍 Detailed Hyprland Status"
            echo "==========================="

            log_section "PROCESS STATUS"
            check_hyprland_running

            log_section "ENVIRONMENT"
            check_wayland_env

            log_section "VERSION INFO"
            show_hyprland_info

            log_section "MONITORS"
            show_monitors_status

            log_section "WORKSPACES"
            show_workspaces_status

            log_section "WINDOWS"
            show_windows_status

            log_section "BINDINGS & OPTIONS"
            show_bindings_options

            log_section "PLUGINS"
            show_plugins_info

            log_section "SYSTEMD SERVICES"
            show_systemd_services

            log_section "CONFIGURATION"
            check_config_status

            log_section "RESOURCE USAGE"
            show_resource_usage

            log_section "RECENT LOGS"
            show_recent_logs

            show_troubleshooting
            ;;

        "quick")
            if check_hyprland_running; then
                echo "✓ Hyprland is running"
                if [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
                    echo "✓ Wayland: $WAYLAND_DISPLAY"
                fi
                if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
                    echo "✓ Instance: ${HYPRLAND_INSTANCE_SIGNATURE:0:8}..."
                fi

                # Get window and workspace count
                local window_count=0
                local workspace_count=0

                if command -v jq >/dev/null 2>&1; then
                    window_count=$(hyprctl clients -j 2>/dev/null | jq '. | length' 2>/dev/null || echo "0")
                    workspace_count=$(hyprctl workspaces -j 2>/dev/null | jq '. | length' 2>/dev/null || echo "0")
                else
                    window_count=$(hyprctl clients 2>/dev/null | grep -c "Window" || echo "0")
                    workspace_count=$(hyprctl workspaces 2>/dev/null | grep -c "workspace ID" || echo "0")
                fi

                echo "• Windows: $window_count"
                echo "• Workspaces: $workspace_count"

                # Check for config errors
                local errors=$(hyprctl configerrors 2>/dev/null || echo "")
                if [[ -n "$errors" && "$errors" != "no errors" ]]; then
                    echo "! Config has errors"
                    exit 1
                fi
                exit 0
            else
                echo "✗ Hyprland is not running"
                exit 1
            fi
            ;;

        "logs")
            show_recent_logs
            ;;

        "config")
            check_config_status
            ;;

        "monitors")
            show_monitors_status
            ;;

        "workspaces")
            show_workspaces_status
            ;;

        "windows")
            show_windows_status
            ;;

        "help")
            echo "Hyprland Status Checker"
            echo "Usage: $0 [option]"
            echo ""
            echo "Options:"
            echo "  status      - Standard status check (default)"
            echo "  full        - Detailed status with all information"
            echo "  quick       - Quick status check (suitable for scripts)"
            echo "  logs        - Show recent logs only"
            echo "  config      - Check configuration only"
            echo "  monitors    - Show monitor information"
            echo "  workspaces  - Show workspace information"
            echo "  windows     - Show window information"
            echo "  help        - Show this help"
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