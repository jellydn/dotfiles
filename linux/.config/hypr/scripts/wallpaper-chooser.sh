#!/bin/bash
# Modern SWWW Wallpaper Chooser for Hyprland
# Based on latest SWWW standards and best practices

# Configuration
WALLPAPER_DIR="$HOME/.config/swww/wallpapers"
FALLBACK_DIR="$HOME/.dotfiles/common/bg-images"
CONFIG_DIR="$HOME/.config/swww"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Ensure directories exist
mkdir -p "$WALLPAPER_DIR" "$CONFIG_DIR"

# Create wallpaper directory structure if it doesn't exist
if [[ ! -d "$WALLPAPER_DIR" ]]; then
    log_info "Creating wallpaper directory structure..."
    mkdir -p "$WALLPAPER_DIR"

    # Copy some default wallpapers from common directory if available
    if [[ -d "$FALLBACK_DIR" ]]; then
        log_info "Copying default wallpapers..."
        cp "$FALLBACK_DIR"/*.{jpg,jpeg,png,webp} "$WALLPAPER_DIR/" 2>/dev/null || true
    fi
fi

# Check if SWWW daemon is running
if ! pgrep -x "swww-daemon" > /dev/null; then
    log_warning "SWWW daemon not running, starting it..."
    swww-daemon &
    sleep 2
fi

# Function to get available wallpapers
get_wallpapers() {
    local wallpapers=()

    # Look for common image formats
    for ext in jpg jpeg png webp gif bmp tiff; do
        while IFS= read -r -d '' file; do
            wallpapers+=("$file")
        done < <(find "$WALLPAPER_DIR" -maxdepth 1 -iname "*.${ext}" -type f -print0 2>/dev/null)
    done

    # Also check fallback directory
    if [[ -d "$FALLBACK_DIR" ]]; then
        for ext in jpg jpeg png webp gif bmp tiff; do
            while IFS= read -r -d '' file; do
                wallpapers+=("$file")
            done < <(find "$FALLBACK_DIR" -maxdepth 1 -iname "*.${ext}" -type f -print0 2>/dev/null)
        done
    fi

    printf '%s\n' "${wallpapers[@]}"
}

# Function to set wallpaper with SWWW
set_wallpaper() {
    local wallpaper_path="$1"
    local transition="${2:-wipe}"
    local duration="${3:-2}"

    if [[ ! -f "$wallpaper_path" ]]; then
        log_error "Wallpaper file not found: $wallpaper_path"
        return 1
    fi

    log_info "Setting wallpaper: $(basename "$wallpaper_path")"
    log_info "Transition: $transition, Duration: ${duration}s"

    # Set wallpaper with SWWW
    if swww img "$wallpaper_path" \
        --transition-type "$transition" \
        --transition-duration "$duration" \
        --transition-fps 60; then

        log_success "Wallpaper set successfully!"

        # Save current wallpaper info
        echo "CURRENT_WALLPAPER=\"$wallpaper_path\"" > "$CONFIG_DIR/current"
        echo "LAST_TRANSITION=\"$transition\"" >> "$CONFIG_DIR/current"
        echo "LAST_DURATION=\"$duration\"" >> "$CONFIG_DIR/current"
        echo "LAST_SET=\"$(date)\"" >> "$CONFIG_DIR/current"

        return 0
    else
        log_error "Failed to set wallpaper!"
        return 1
    fi
}

# Function to show wallpaper menu with rofi
show_wallpaper_menu() {
    local wallpapers=($(get_wallpapers))

    if [[ ${#wallpapers[@]} -eq 0 ]]; then
        log_error "No wallpapers found!"
        notify-send "Wallpaper Chooser" "No wallpapers found in $WALLPAPER_DIR" -i dialog-error
        return 1
    fi

    log_info "Found ${#wallpapers[@]} wallpapers"

    # Create menu items (show only filename for cleaner display)
    local menu_items=()
    local wallpaper_map=()

    for wallpaper in "${wallpapers[@]}"; do
        local basename_file=$(basename "$wallpaper")
        local display_name="${basename_file%.*}"  # Remove extension for cleaner display
        menu_items+=("$display_name")
        wallpaper_map+=("$wallpaper")
    done

    # Show rofi menu
    local choice
    choice=$(printf '%s\n' "${menu_items[@]}" | rofi -dmenu \
        -p "Choose Wallpaper" \
        -i \
        -theme-str 'window { width: 600px; } listview { lines: 10; }' \
        -format i)

    if [[ -n "$choice" && "$choice" =~ ^[0-9]+$ && "$choice" -lt "${#wallpaper_map[@]}" ]]; then
        local selected_wallpaper="${wallpaper_map[$choice]}"

        # Ask for transition type
        local transition
        transition=$(echo -e "wipe\nwave\ngrow\nfade\nslide\nsimple" | rofi -dmenu \
            -p "Transition Type" \
            -i \
            -theme-str 'window { width: 400px; } listview { lines: 6; }')

        if [[ -z "$transition" ]]; then
            transition="wipe"  # Default transition
        fi

        set_wallpaper "$selected_wallpaper" "$transition" "2"
    else
        log_info "No wallpaper selected"
    fi
}

# Function to cycle through wallpapers
cycle_wallpaper() {
    local wallpapers=($(get_wallpapers))

    if [[ ${#wallpapers[@]} -eq 0 ]]; then
        log_error "No wallpapers found!"
        return 1
    fi

    # Get current wallpaper
    local current_wallpaper=""
    if [[ -f "$CONFIG_DIR/current" ]]; then
        source "$CONFIG_DIR/current"
        current_wallpaper="$CURRENT_WALLPAPER"
    fi

    # Find next wallpaper
    local next_wallpaper="${wallpapers[0]}"  # Default to first

    if [[ -n "$current_wallpaper" ]]; then
        for i in "${!wallpapers[@]}"; do
            if [[ "${wallpapers[$i]}" == "$current_wallpaper" ]]; then
                # Get next wallpaper (wrap around if at end)
                local next_index=$(( (i + 1) % ${#wallpapers[@]} ))
                next_wallpaper="${wallpapers[$next_index]}"
                break
            fi
        done
    fi

    set_wallpaper "$next_wallpaper" "fade" "1"
}

# Function to show random wallpaper
random_wallpaper() {
    local wallpapers=($(get_wallpapers))

    if [[ ${#wallpapers[@]} -eq 0 ]]; then
        log_error "No wallpapers found!"
        return 1
    fi

    local random_index=$((RANDOM % ${#wallpapers[@]}))
    local random_wallpaper="${wallpapers[$random_index]}"

    local transitions=("wipe" "wave" "grow" "fade" "slide")
    local random_transition="${transitions[$((RANDOM % ${#transitions[@]}))]}"

    set_wallpaper "$random_wallpaper" "$random_transition" "2"
}

# Main script logic
case "${1:-menu}" in
    "menu"|"choose")
        show_wallpaper_menu
        ;;
    "cycle"|"next")
        cycle_wallpaper
        ;;
    "random"|"rand")
        random_wallpaper
        ;;
    "set")
        if [[ -z "$2" ]]; then
            log_error "Usage: $0 set <wallpaper_path> [transition] [duration]"
            exit 1
        fi
        set_wallpaper "$2" "${3:-wipe}" "${4:-2}"
        ;;
    "help"|"-h"|"--help")
        echo "SWWW Wallpaper Chooser"
        echo "Usage: $0 [command]"
        echo ""
        echo "Commands:"
        echo "  menu, choose    Show wallpaper selection menu (default)"
        echo "  cycle, next     Cycle to next wallpaper"
        echo "  random, rand    Set random wallpaper with random transition"
        echo "  set <path>      Set specific wallpaper"
        echo "  help            Show this help"
        echo ""
        echo "Wallpaper directory: $WALLPAPER_DIR"
        echo "Config directory: $CONFIG_DIR"
        ;;
    *)
        log_error "Unknown command: $1"
        log_info "Use '$0 help' for usage information"
        exit 1
        ;;
esac