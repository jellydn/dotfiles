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
        if [[ "$target" == *"$dotfiles_dir"* ]]; then
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
    
    # Common configurations
    echo -e "${BLUE}Common Configurations:${NC}"
    check_config_status "Git config" "$HOME/.gitconfig" "$dotfiles_dir"
    check_config_status "Neovim" "$HOME/.config/nvim" "$dotfiles_dir"
    check_config_status "Fish shell" "$HOME/.config/fish" "$dotfiles_dir"
    check_config_status "Kitty terminal" "$HOME/.config/kitty" "$dotfiles_dir"
    check_config_status "Ghostty terminal" "$HOME/.config/ghostty" "$dotfiles_dir"
    check_config_status "Helix editor" "$HOME/.config/helix" "$dotfiles_dir"
    check_config_status "LazyGit" "$HOME/.config/lazygit" "$dotfiles_dir"
    check_config_status "Zellij" "$HOME/.config/zellij" "$dotfiles_dir"
    check_config_status "Tmux" "$HOME/.config/tmux" "$dotfiles_dir"
    check_config_status "VSCode" "$HOME/.config/vscode" "$dotfiles_dir"
    check_config_status "Zed editor" "$HOME/.config/zed" "$dotfiles_dir"
    check_config_status "Cursor editor" "$HOME/.config/cursor" "$dotfiles_dir"
    check_config_status "Claude" "$HOME/.config/claude" "$dotfiles_dir"
    echo ""
    
    # OS-specific configurations
    case "$os" in
        linux)
            echo -e "${BLUE}Linux-specific Configurations:${NC}"
            check_config_status "Foot terminal" "$HOME/.config/foot" "$dotfiles_dir"
            check_config_status "Hyprland" "$HOME/.config/hypr" "$dotfiles_dir"
            check_config_status "i3 window manager" "$HOME/.config/i3" "$dotfiles_dir"
            check_config_status "i3status" "$HOME/.config/i3status" "$dotfiles_dir"
            check_config_status "Waybar" "$HOME/.config/waybar" "$dotfiles_dir"
            check_config_status "Polybar" "$HOME/.config/polybar" "$dotfiles_dir"
            check_config_status "Rofi launcher" "$HOME/.config/rofi" "$dotfiles_dir"
            check_config_status "Borders" "$HOME/.config/borders" "$dotfiles_dir"
            check_config_status "Kanata" "$HOME/.config/kanata" "$dotfiles_dir"
            check_config_status "KMonad" "$HOME/.config/kmonad" "$dotfiles_dir"
            check_config_status "Input Remapper" "$HOME/.config/input-remapper-2" "$dotfiles_dir"
            check_config_status "SWWW" "$HOME/.config/swww" "$dotfiles_dir"
            check_config_status "Systemd user" "$HOME/.config/systemd" "$dotfiles_dir"
            check_config_status "Evremap" "$HOME/.config/evremap.toml" "$dotfiles_dir"
            ;;
        macos)
            echo -e "${BLUE}macOS-specific Configurations:${NC}"
            check_config_status "Yabai" "$HOME/.yabairc" "$dotfiles_dir"
            check_config_status "SKHD" "$HOME/.skhdrc" "$dotfiles_dir"
            check_config_status "AeroSpace" "$HOME/.aerospace.toml" "$dotfiles_dir"
            check_config_status "Alacritty" "$HOME/.alacritty.toml" "$dotfiles_dir"
            check_config_status "WezTerm" "$HOME/.wezterm.lua" "$dotfiles_dir"
            ;;
    esac
    echo ""
    
    log_info "Check complete! Look for red ✗ marks above to identify issues."
    echo ""
    log_info "Recommendations:"
    log_info "  - Red ✗ (Real): Backup manually and run './install.sh restow'"
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