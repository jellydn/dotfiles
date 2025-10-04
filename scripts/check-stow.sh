#!/usr/bin/env bash

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Detect OS
detect_os() {
    case "$(uname -s)" in
        Darwin*)
            echo "macos"
            ;;
        Linux*)
            echo "linux"
            ;;
        *)
            log_error "Unsupported operating system: $(uname -s)"
            exit 1
            ;;
    esac
}

# Check if a path is a symlink pointing to dotfiles
is_stow_symlink() {
    local path="$1"
    local dotfiles_dir="$2"
    
    if [[ -L "$path" ]]; then
        local target=$(readlink "$path")
        # Convert relative path to absolute path for comparison
        local absolute_target
        if [[ "$target" = /* ]]; then
            # Already absolute
            absolute_target="$target"
        else
            # Relative path - resolve it
            absolute_target="$(cd "$(dirname "$path")" && cd "$(dirname "$target")" && pwd)/$(basename "$target")"
        fi
        
        # Check if the absolute target is within the dotfiles directory
        if [[ "$absolute_target" == "$dotfiles_dir"* ]]; then
            return 0  # Is a stow symlink
        fi
    fi
    return 1  # Not a stow symlink
}

# Check if a directory is fully managed by stow (all files are stow symlinks)
is_fully_stow_managed_dir() {
    local dir_path="$1"
    local dotfiles_dir="$2"
    
    if [[ ! -d "$dir_path" ]]; then
        return 1
    fi
    
    # Check if all files in the directory are stow symlinks
    local stow_files=0
    local total_files=0
    
    for file in "$dir_path"/*; do
        if [[ -e "$file" ]]; then
            ((total_files++))
            if is_stow_symlink "$file" "$dotfiles_dir"; then
                ((stow_files++))
            fi
        fi
    done
    
    # All files must be stow symlinks for directory to be considered fully managed
    if [[ $total_files -gt 0 && $stow_files -eq $total_files ]]; then
        return 0
    fi
    
    return 1
}

# Check if a directory is partially managed by stow (some files are stow symlinks)
is_partially_stow_managed_dir() {
    local dir_path="$1"
    local dotfiles_dir="$2"
    
    if [[ ! -d "$dir_path" ]]; then
        return 1
    fi
    
    # Check if some (but not all) files in the directory are stow symlinks
    local stow_files=0
    local total_files=0
    
    for file in "$dir_path"/*; do
        if [[ -e "$file" ]]; then
            ((total_files++))
            if is_stow_symlink "$file" "$dotfiles_dir"; then
                ((stow_files++))
            fi
        fi
    done
    
    # Some but not all files are stow symlinks
    if [[ $total_files -gt 0 && $stow_files -gt 0 && $stow_files -lt $total_files ]]; then
        return 0
    fi
    
    return 1
}

# Get available apps from dotfiles structure
get_available_apps() {
    local os="$1"
    local dotfiles_dir="$2"
    local apps=()

    # Check common apps
    if [[ -d "$dotfiles_dir/common/.config" ]]; then
        for app_dir in "$dotfiles_dir/common/.config"/*/; do
            if [[ -d "$app_dir" ]]; then
                local app_name=$(basename "$app_dir")
                apps+=("$app_name")
            fi
        done
    fi

    # Check OS-specific apps
    if [[ -d "$dotfiles_dir/$os/.config" ]]; then
        for app_dir in "$dotfiles_dir/$os/.config"/*/; do
            if [[ -d "$app_dir" ]]; then
                local app_name=$(basename "$app_dir")
                apps+=("$app_name")
            fi
        done
    fi

    # Check for root-level configs in OS directories
    if [[ "$os" == "macos" ]]; then
        [[ -f "$dotfiles_dir/macos/.yabairc" ]] && apps+=("yabai")
        [[ -f "$dotfiles_dir/macos/.skhdrc" ]] && apps+=("skhd")
        [[ -f "$dotfiles_dir/macos/.aerospace.toml" ]] && apps+=("aerospace")
        [[ -f "$dotfiles_dir/macos/.alacritty.toml" ]] && apps+=("alacritty")
        [[ -f "$dotfiles_dir/macos/.wezterm.lua" ]] && apps+=("wezterm")
    elif [[ "$os" == "linux" ]]; then
        [[ -f "$dotfiles_dir/linux/.alacritty.toml" ]] && apps+=("alacritty")
        [[ -d "$dotfiles_dir/linux/.config/niri" ]] && apps+=("niri")
        [[ -d "$dotfiles_dir/linux/.config/hypr" ]] && apps+=("hypr")
        [[ -f "$dotfiles_dir/linux/etc/greetd/config.toml" ]] && apps+=("greetd")
    fi

    # Remove duplicates and sort
    printf '%s\n' "${apps[@]}" | sort -u
}

# Get display name for app
get_app_display_name() {
    local app="$1"
    case "$app" in
        nvim) echo "Neovim" ;;
        hypr) echo "Hyprland" ;;
        i3status) echo "i3status" ;;
        lazygit) echo "LazyGit" ;;
        vscode) echo "VSCode" ;;
        input-remapper-2) echo "Input Remapper" ;;
        swww) echo "SWWW" ;;
        evremap.toml) echo "Evremap" ;;
        yabairc) echo "Yabai" ;;
        skhdrc) echo "SKHD" ;;
        aerospace.toml) echo "AeroSpace" ;;
        alacritty.toml) echo "Alacritty" ;;
        wezterm.lua) echo "WezTerm" ;;
        *) echo "${app^}" ;;  # Capitalize first letter
    esac
}

# Get config path for app
get_config_path() {
    local app="$1"
    local os="$2"

    # Special cases for root-level configs
    case "$app" in
        yabai) echo "$HOME/.yabairc" ;;
        skhd) echo "$HOME/.skhdrc" ;;
        aerospace) echo "$HOME/.aerospace.toml" ;;
        greetd) echo "/etc/greetd/config.toml" ;;
        *)
            # Check if it's a special file
            if [[ "$app" == *.* ]]; then
                echo "$HOME/.$app"
            else
                # Standard .config location
                echo "$HOME/.config/$app"
            fi
            ;;
    esac
}

# Check stow status for a specific configuration
check_config_status() {
    local config_name="$1"
    local config_path="$2"
    local dotfiles_dir="$3"

    if [[ ! -e "$config_path" ]]; then
        echo -e "  ${YELLOW}✗${NC} $config_name: Not found"
        return
    fi

    if is_stow_symlink "$config_path" "$dotfiles_dir"; then
        local target=$(readlink "$config_path")
        echo -e "  ${GREEN}✓${NC} $config_name: Symlinked → $target"
    elif [[ -L "$config_path" ]]; then
        local target=$(readlink "$config_path")
        echo -e "  ${YELLOW}!${NC} $config_name: Symlinked but not to dotfiles → $target"
    elif [[ -d "$config_path" ]] && is_fully_stow_managed_dir "$config_path" "$dotfiles_dir"; then
        echo -e "  ${GREEN}✓${NC} $config_name: Directory with stow-managed files"
    elif [[ -d "$config_path" ]] && is_partially_stow_managed_dir "$config_path" "$dotfiles_dir"; then
        echo -e "  ${YELLOW}!${NC} $config_name: Mixed directory (some stow files, some real files)"
    elif [[ -d "$config_path" ]]; then
        echo -e "  ${RED}✗${NC} $config_name: Real directory (not symlinked)"
    elif [[ -f "$config_path" ]]; then
        echo -e "  ${RED}✗${NC} $config_name: Real file (not symlinked)"
    else
        echo -e "  ${YELLOW}?${NC} $config_name: Unknown type"
    fi
}

# Main check function
check_stow_status() {
    local os="$1"
    local dotfiles_dir="$(cd "$(dirname "$0")/.." && pwd)"
    
    log_info "Checking stow configuration status..."
    log_info "Dotfiles directory: $dotfiles_dir"
    log_info "Detected OS: $os"
    echo ""
    
    # Dynamically check all available apps
    local apps=($(get_available_apps "$os" "$dotfiles_dir"))

    if [[ ${#apps[@]} -eq 0 ]]; then
        log_warning "No apps found in dotfiles directory"
        return
    fi

    echo -e "${BLUE}Detected Configurations:${NC}"
    for app in "${apps[@]}"; do
        local display_name=$(get_app_display_name "$app")
        local config_path=$(get_config_path "$app" "$os")
        check_config_status "$display_name" "$config_path" "$dotfiles_dir"
    done
    echo ""
    
    log_info "Check complete! Look for red ✗ marks above to identify issues."
    echo ""
    log_info "Recommendations:"
    log_info "  - Red ✗ (Real): Run './install.sh backup' then './install.sh unstow-app <app>' and './install.sh stow-app <app>'"
    log_info "  - Yellow ! (Wrong symlink): Check if pointing to correct location"
    log_info "  - Yellow ✗ (Not found): Config may not be installed or needed"
}

# Show usage
show_usage() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -h, --help    Show this help message"
    echo "  -v, --verbose Show detailed symlink information"
    echo ""
    echo "This script checks if your dotfiles are properly managed by stow."
    echo "It verifies that configuration files are symlinked to the dotfiles repository"
    echo "rather than being real files or directories."
}

# Parse command line arguments
main() {
    local verbose=false
    
    for arg in "$@"; do
        case "$arg" in
            -h|--help)
                show_usage
                exit 0
                ;;
            -v|--verbose)
                verbose=true
                ;;
            *)
                log_error "Unknown option: $arg"
                show_usage
                exit 1
                ;;
        esac
    done
    
    local os
    os=$(detect_os)
    
    check_stow_status "$os"
}

# Run main function with all arguments
main "$@"