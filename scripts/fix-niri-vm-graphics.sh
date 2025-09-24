#!/bin/bash
# Fix niri graphics issues in VMs and systems with limited EGL support
# Addresses: EGL_WL_bind_wayland_display extension errors

set -euo pipefail

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Helper function for yes/no questions
ask_yes_no() {
    local question="$1"
    local response

    while true; do
        read -p "$question [y/N]: " response
        response=${response:-n}

        case "$response" in
            [Yy]|[Yy][Ee][Ss])
                return 0
                ;;
            [Nn]|[Nn][Oo])
                return 1
                ;;
            *)
                echo "Please answer yes or no."
                ;;
        esac
    done
}

echo "🔧 Niri VM Graphics Fix"
echo "======================"

# Check if we're in a VM
log_info "Checking virtualization environment..."
if systemd-detect-virt -q; then
    VM_TYPE=$(systemd-detect-virt)
    log_warning "Running in virtual machine: $VM_TYPE"
    IN_VM=true
else
    log_info "Running on physical hardware"
    IN_VM=false
fi

# Check EGL extensions
log_info "Checking EGL extensions..."
if command -v eglinfo >/dev/null 2>&1; then
    if eglinfo 2>/dev/null | grep -q "EGL_WL_bind_wayland_display"; then
        log_success "EGL_WL_bind_wayland_display extension is supported"
        EGL_SUPPORTED=true
    else
        log_error "EGL_WL_bind_wayland_display extension NOT supported"
        EGL_SUPPORTED=false
    fi
else
    log_warning "eglinfo not found - installing mesa-utils might help"
    EGL_SUPPORTED=false
fi

# Check graphics driver
log_info "Checking graphics driver..."
if command -v glxinfo >/dev/null 2>&1; then
    RENDERER=$(glxinfo 2>/dev/null | grep "OpenGL renderer" || echo "Unknown")
    VENDOR=$(glxinfo 2>/dev/null | grep "OpenGL vendor" || echo "Unknown")
    log_info "Graphics: $RENDERER"
    log_info "Vendor: $VENDOR"

    if echo "$RENDERER" | grep -qi "llvmpipe\|software\|mesa"; then
        log_warning "Using software rendering"
        SW_RENDERING=true
    else
        log_info "Using hardware acceleration"
        SW_RENDERING=false
    fi
else
    log_warning "glxinfo not found - installing mesa-utils recommended"
    SW_RENDERING=true
fi

# Check niri config
NIRI_CONFIG="$HOME/.config/niri/config.kdl"
if [[ -f "$NIRI_CONFIG" ]]; then
    log_info "Checking niri configuration..."
    if grep -q "^/-debug" "$NIRI_CONFIG"; then
        log_info "DRM debug configuration found (commented out)"
        SW_CONFIG_AVAILABLE=true
        SW_CONFIG_ENABLED=false
    elif grep -q "^debug" "$NIRI_CONFIG"; then
        log_info "Debug configuration found"
        SW_CONFIG_AVAILABLE=true
        if grep -A 5 "^debug" "$NIRI_CONFIG" | grep -q "render-drm-device"; then
            log_success "DRM device override is enabled"
            SW_CONFIG_ENABLED=true
        else
            log_info "Debug config present but no DRM override"
            SW_CONFIG_ENABLED=false
        fi
    else
        log_warning "No debug configuration found in niri config"
        SW_CONFIG_AVAILABLE=false
        SW_CONFIG_ENABLED=false
    fi
else
    log_error "Niri config not found: $NIRI_CONFIG"
    exit 1
fi

echo
log_info "=== RECOMMENDATIONS ==="

# Determine if we need software rendering
if [[ "$IN_VM" == "true" || "$EGL_SUPPORTED" == "false" || "$SW_RENDERING" == "true" ]]; then
    NEED_SW_RENDERING=true
else
    NEED_SW_RENDERING=false
fi

if [[ "$NEED_SW_RENDERING" == "true" ]]; then
    if [[ "$SW_CONFIG_ENABLED" == "false" ]]; then
        log_warning "Manual DRM device override recommended for your environment"
        echo
        log_info "To enable DRM device override in niri:"
        echo "1. Edit ~/.config/niri/config.kdl"
        echo "2. Uncomment the debug block (remove /- prefix):"
        echo "   debug {"
        echo "       render-drm-device \"/dev/dri/renderD128\""
        echo "   }"
        echo "3. Restart niri"
        echo

        if ask_yes_no "Enable manual DRM device override now?"; then
            log_info "Enabling DRM device override..."
            if sed -i 's/^/-debug/debug/' "$NIRI_CONFIG"; then
                log_success "DRM device override enabled in niri config"
                log_info "Please restart niri for changes to take effect"
            else
                log_error "Failed to modify niri config automatically"
                log_info "Please edit $NIRI_CONFIG manually"
            fi
        fi
    else
        log_success "Software rendering already enabled - should work in VM"
    fi
else
    log_success "Hardware acceleration should work on your system"
    if [[ "$SW_CONFIG_ENABLED" == "true" ]]; then
        log_info "You can disable software rendering for better performance"
        echo "Edit ~/.config/niri/config.kdl and comment out render block (add /- prefix)"
    fi
fi

# Additional VM-specific recommendations
if [[ "$IN_VM" == "true" ]]; then
    echo
    log_info "=== VM-SPECIFIC RECOMMENDATIONS ==="
    case "$VM_TYPE" in
        "qemu"|"kvm")
            log_info "QEMU/KVM detected:"
            echo "  • Enable 3D acceleration: -device virtio-gpu-pci,virgl=on"
            echo "  • Use QXL or VirtIO GPU driver"
            echo "  • Install mesa-dri-drivers package"
            ;;
        "vmware")
            log_info "VMware detected:"
            echo "  • Enable 3D acceleration in VM settings"
            echo "  • Install mesa-dri-drivers and mesa-vulkan-drivers"
            echo "  • Consider installing open-vm-tools"
            ;;
        "virtualbox")
            log_info "VirtualBox detected:"
            echo "  • Enable 3D acceleration in VM settings"
            echo "  • Install Guest Additions"
            echo "  • Software rendering is often more reliable"
            ;;
        *)
            log_info "Generic VM recommendations:"
            echo "  • Enable 3D acceleration if available"
            echo "  • Install mesa-dri-drivers"
            echo "  • Use software rendering if hardware acceleration fails"
            ;;
    esac
fi

echo
log_info "=== TROUBLESHOOTING ==="
echo "If niri still fails to start:"
echo "1. Check logs: journalctl --user -u niri.service"
echo "2. Try running niri directly: niri"
echo "3. Verify Wayland support: echo \$WAYLAND_DISPLAY"
echo "4. Install missing packages: sudo dnf install mesa-dri-drivers mesa-vulkan-drivers"