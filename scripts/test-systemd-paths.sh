#!/bin/bash
# Test script to verify systemd service paths work correctly
# Useful for debugging on VMs or different environments

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

echo "🧪 Testing systemd service paths..."
echo

# Test background image path detection
log_info "Testing background image path detection..."
FOUND_BG=false
for dir in "$HOME/.dotfiles" "$HOME/dotfiles" "$HOME/.config/dotfiles"; do
    if [[ -f "$dir/common/bg-images/Kanagawa.jpg" ]]; then
        log_success "Found background image: $dir/common/bg-images/Kanagawa.jpg"
        FOUND_BG=true
        break
    fi
done

if [[ "$FOUND_BG" == "false" ]]; then
    log_error "Background image not found in any common location"
    log_info "Checked: ~/.dotfiles, ~/dotfiles, ~/.config/dotfiles"
fi

# Test waybar config files
log_info "Testing waybar config files..."
WAYBAR_CONFIG="$HOME/.config/waybar/config.jsonc"
WAYBAR_STYLE="$HOME/.config/waybar/style.css"

if [[ -f "$WAYBAR_CONFIG" ]]; then
    log_success "Found waybar config: $WAYBAR_CONFIG"
else
    log_error "Waybar config not found: $WAYBAR_CONFIG"
fi

if [[ -f "$WAYBAR_STYLE" ]]; then
    log_success "Found waybar style: $WAYBAR_STYLE"
else
    log_error "Waybar style not found: $WAYBAR_STYLE"
fi

# Test required binaries
log_info "Testing required binaries..."
BINARIES=("swaybg" "waybar" "swayidle" "swaylock")
ALL_FOUND=true

for binary in "${BINARIES[@]}"; do
    if command -v "$binary" >/dev/null 2>&1; then
        log_success "$binary found: $(command -v "$binary")"
    else
        log_error "$binary not found"
        ALL_FOUND=false
    fi
done

# Test systemd service files
log_info "Testing systemd service files..."
SERVICE_FILES=(
    "$HOME/.config/systemd/user/waybar.service"
    "$HOME/.config/systemd/user/wallpaper.service"
    "$HOME/.config/systemd/user/swayidle.service"
)

for service_file in "${SERVICE_FILES[@]}"; do
    if [[ -f "$service_file" ]]; then
        log_success "Found service file: $(basename "$service_file")"
    else
        log_error "Service file not found: $service_file"
    fi
done

echo
if [[ "$FOUND_BG" == "true" && "$ALL_FOUND" == "true" ]]; then
    log_success "All paths and dependencies look good! Services should work."
    echo
    log_info "To test services manually:"
    echo "  systemctl --user daemon-reload"
    echo "  systemctl --user restart wallpaper.service waybar.service"
    echo "  systemctl --user status wallpaper.service waybar.service"
else
    log_warning "Some issues detected. Services may not work properly."
    echo
    log_info "Common fixes:"
    echo "  • Ensure dotfiles are stowed correctly"
    echo "  • Install missing dependencies: sudo dnf install swaybg waybar swayidle swaylock"
    echo "  • Check that background image exists in dotfiles"
fi