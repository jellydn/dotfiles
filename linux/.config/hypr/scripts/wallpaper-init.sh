#!/bin/bash
# SWWW Wallpaper Initialization Script for Hyprland
# Sets up wallpaper management and restores last wallpaper

# Configuration
WALLPAPER_DIR="$HOME/.config/swww/wallpapers"
FALLBACK_DIR="$HOME/.dotfiles/common/bg-images"
CONFIG_DIR="$HOME/.config/swww"
DEFAULT_WALLPAPER="Kanagawa.jpg"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[WALLPAPER]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Ensure directories exist
mkdir -p "$WALLPAPER_DIR" "$CONFIG_DIR"

# Wait for SWWW daemon to be ready
wait_for_swww() {
    local max_attempts=10
    local attempt=1

    while [[ $attempt -le $max_attempts ]]; do
        if pgrep -x "swww-daemon" > /dev/null && swww query &>/dev/null; then
            log_success "SWWW daemon is ready"
            return 0
        fi

        log_info "Waiting for SWWW daemon... (attempt $attempt/$max_attempts)"
        sleep 1
        ((attempt++))
    done

    log_error "SWWW daemon not ready after $max_attempts seconds"
    return 1
}

# Find a suitable wallpaper
find_wallpaper() {
    local wallpaper=""

    # Try to restore last wallpaper
    if [[ -f "$CONFIG_DIR/current" ]]; then
        source "$CONFIG_DIR/current"
        if [[ -f "$CURRENT_WALLPAPER" ]]; then
            echo "$CURRENT_WALLPAPER"
            return 0
        fi
    fi

    # Look for default wallpaper
    for dir in "$WALLPAPER_DIR" "$FALLBACK_DIR"; do
        if [[ -f "$dir/$DEFAULT_WALLPAPER" ]]; then
            echo "$dir/$DEFAULT_WALLPAPER"
            return 0
        fi
    done

    # Find any wallpaper
    for dir in "$WALLPAPER_DIR" "$FALLBACK_DIR"; do
        for ext in jpg jpeg png webp gif bmp; do
            wallpaper=$(find "$dir" -maxdepth 1 -iname "*.${ext}" -type f | head -n 1)
            if [[ -n "$wallpaper" ]]; then
                echo "$wallpaper"
                return 0
            fi
        done
    done

    return 1
}

# Copy default wallpapers if needed
setup_wallpapers() {
    if [[ ! -d "$WALLPAPER_DIR" ]] || [[ $(ls -A "$WALLPAPER_DIR" 2>/dev/null | wc -l) -eq 0 ]]; then
        log_info "Setting up wallpaper directory..."
        mkdir -p "$WALLPAPER_DIR"

        if [[ -d "$FALLBACK_DIR" ]]; then
            log_info "Copying default wallpapers from $FALLBACK_DIR"
            cp "$FALLBACK_DIR"/*.{jpg,jpeg,png,webp,gif,bmp} "$WALLPAPER_DIR/" 2>/dev/null || true

            local copied_count=$(ls -A "$WALLPAPER_DIR" 2>/dev/null | wc -l)
            if [[ $copied_count -gt 0 ]]; then
                log_success "Copied $copied_count wallpapers"
            fi
        fi
    fi
}

# Main initialization
main() {
    log_info "Initializing SWWW wallpaper system..."

    # Setup wallpaper directories
    setup_wallpapers

    # Wait for SWWW daemon
    if ! wait_for_swww; then
        log_error "Failed to initialize SWWW daemon"
        return 1
    fi

    # Find and set wallpaper
    local wallpaper
    wallpaper=$(find_wallpaper)

    if [[ -n "$wallpaper" ]]; then
        log_info "Setting wallpaper: $(basename "$wallpaper")"

        if swww img "$wallpaper" --transition-type fade --transition-duration 1; then
            log_success "Wallpaper initialized successfully"

            # Save current wallpaper info
            echo "CURRENT_WALLPAPER=\"$wallpaper\"" > "$CONFIG_DIR/current"
            echo "LAST_TRANSITION=\"fade\"" >> "$CONFIG_DIR/current"
            echo "LAST_DURATION=\"1\"" >> "$CONFIG_DIR/current"
            echo "LAST_SET=\"$(date)\"" >> "$CONFIG_DIR/current"
        else
            log_error "Failed to set wallpaper"
            return 1
        fi
    else
        log_warning "No wallpapers found - create some in $WALLPAPER_DIR"

        # Set a solid color as fallback
        swww img <(convert -size 1920x1080 xc:"#1e1e2e" png:-) 2>/dev/null || {
            log_info "Using solid color fallback"
            swww clear "#1e1e2e" 2>/dev/null || true
        }
    fi

    return 0
}

# Run main function
main "$@"