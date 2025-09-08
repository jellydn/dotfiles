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

# Enhanced OS and architecture detection
detect_platform() {
    local os arch
    
    case "$(uname -s)" in
        Darwin*)
            os="macos"
            ;;
        Linux*)
            os="linux"
            ;;
        CYGWIN*|MINGW*|MSYS*)
            os="windows"
            log_warning "Windows support is experimental"
            ;;
        *)
            log_error "Unsupported operating system: $(uname -s)"
            log_info "Supported: macOS, Linux, Windows (experimental)"
            exit 1
            ;;
    esac
    
    case "$(uname -m)" in
        x86_64|amd64)
            arch="x64"
            ;;
        arm64|aarch64)
            arch="arm64"
            ;;
        i386|i686)
            arch="x86"
            ;;
        *)
            arch="$(uname -m)"
            log_warning "Unknown architecture: $arch"
            ;;
    esac
    
    echo "${os}-${arch}"
}

# Legacy compatibility function
detect_os() {
    detect_platform | cut -d'-' -f1
}

# Validate stow prerequisites
validate_stow_environment() {
    local os="$1"
    local errors=0
    
    log_info "Validating stow environment..."
    
    # Check stow installation
    if ! command_exists stow; then
        log_error "GNU Stow is not installed"
        ((errors++))
    fi
    
    # Check dotfiles directory structure
    cd "$(dirname "$0")" || {
        log_error "Cannot access dotfiles directory"
        return 1
    }
    
    # Check required packages exist
    for package in "common" "$os"; do
        if [[ ! -d "$package" ]]; then
            log_error "Package directory '$package' not found"
            ((errors++))
        fi
    done
    
    # Check write permissions
    if [[ ! -w "$HOME" ]]; then
        log_error "No write permission to HOME directory: $HOME"
        ((errors++))
    fi
    
    # Check for conflicting management systems
    if [[ -d "$HOME/.oh-my-zsh" ]] && [[ -d "common/.config/zsh" || -d "$os/.config/zsh" ]]; then
        log_warning "Oh-My-Zsh detected - may conflict with zsh dotfiles"
    fi
    
    if [[ -d "$HOME/.vim" ]] && [[ -L "$HOME/.vim" ]] && [[ -d "common/.config/nvim" ]]; then
        log_warning "Existing vim setup detected - may conflict with nvim config"
    fi
    
    return $errors
}

# Cross-platform realpath implementation
portable_realpath() {
    local path="$1"
    
    if command_exists realpath; then
        realpath "$path" 2>/dev/null
    elif command_exists greadlink; then
        # macOS with GNU coreutils
        greadlink -f "$path" 2>/dev/null
    elif [[ "$(uname -s)" == "Darwin" ]]; then
        # macOS native fallback
        perl -MCwd -e 'print Cwd::abs_path shift' "$path" 2>/dev/null
    else
        # Fallback for other systems  
        echo "$(cd "$(dirname "$path")" 2>/dev/null && pwd -P)/$(basename "$path")" 2>/dev/null
    fi
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install stow based on OS
install_stow() {
    local os="$1"
    
    if command_exists stow; then
        log_info "GNU Stow is already installed"
        return 0
    fi
    
    log_info "Installing GNU Stow..."
    
    case "$os" in
        macos)
            if command_exists brew; then
                brew install stow
            else
                log_info "Homebrew not found. Installing Homebrew..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
                
                # Add Homebrew to PATH for current session
                if [[ -f "/opt/homebrew/bin/brew" ]]; then
                    eval "$(/opt/homebrew/bin/brew shellenv)"
                elif [[ -f "/usr/local/bin/brew" ]]; then
                    eval "$(/usr/local/bin/brew shellenv)"
                fi
                
                if command_exists brew; then
                    log_success "Homebrew installed successfully"
                    brew install stow
                else
                    log_error "Failed to install Homebrew. Please install manually: https://brew.sh/"
                    exit 1
                fi
            fi
            ;;
        linux)
            if command_exists apt; then
                sudo apt update && sudo apt install -y stow
            elif command_exists pacman; then
                sudo pacman -S --noconfirm stow
            elif command_exists dnf; then
                sudo dnf install -y stow
            elif command_exists yum; then
                sudo yum install -y stow
            elif command_exists zypper; then
                sudo zypper install -y stow
            elif command_exists apk; then
                sudo apk add stow
            elif command_exists xbps-install; then
                sudo xbps-install -S stow
            elif command_exists emerge; then
                sudo emerge -av stow
            else
                log_error "No supported package manager found for stow installation"
                log_info "Please install GNU Stow manually:"
                log_info "  - Debian/Ubuntu: sudo apt install stow"
                log_info "  - RHEL/CentOS: sudo dnf install stow"
                log_info "  - Arch Linux: sudo pacman -S stow"
                log_info "  - Alpine Linux: sudo apk add stow"
                log_info "  - From source: https://www.gnu.org/software/stow/"
                exit 1
            fi
            ;;
    esac
    
    log_success "GNU Stow installed successfully"
}

# Interactive prompts
ask_yes_no() {
    local question="$1"
    local default="${2:-n}"
    local response
    
    while true; do
        if [[ "$default" == "y" ]]; then
            read -p "$question [Y/n]: " response
            response=${response:-y}
        else
            read -p "$question [y/N]: " response
            response=${response:-n}
        fi
        
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

# Interactive backup selection
interactive_backup_choice() {
    local files_to_backup=(
        ".gitconfig"
        ".zshrc"
        ".bashrc"
        ".vimrc"
        ".tmux.conf"
        ".config/nvim"
        ".config/fish"
        ".config/ghostty"
        ".config/kitty"
        ".config/helix"
        ".config/lazygit"
        ".config/zellij"
        ".config/tmux"
        ".config/i3"
        ".config/waybar"
        ".config/hypr"
        ".config/foot"
        ".config/polybar"
        ".config/rofi"
        ".config/mise"
        ".yabairc"
        ".skhdrc"
        ".aerospace.toml"
        ".alacritty.toml"
        ".wezterm.lua"
    )
    
    local existing_files=()
    
    # Check which files exist
    log_info "Checking for existing dotfiles..."
    for file in "${files_to_backup[@]}"; do
        local full_path="$HOME/$file"
        if [[ -e "$full_path" ]] && [[ ! -L "$full_path" ]]; then
            existing_files+=("$file")
        fi
    done
    
    if [[ ${#existing_files[@]} -eq 0 ]]; then
        log_info "No existing dotfiles found that would conflict."
        return 0
    fi
    
    echo ""
    log_warning "Found ${#existing_files[@]} existing dotfile(s) that would be overwritten:"
    for file in "${existing_files[@]}"; do
        echo "  - $file"
    done
    echo ""
    
    # Ask for backup choice
    if ask_yes_no "Do you want to backup these files before installation?" "y"; then
        return 0  # Yes, backup
    else
        if ask_yes_no "Are you sure you want to proceed WITHOUT backing up? This may overwrite your existing configs!" "n"; then
            return 1  # No backup, but proceed
        else
            log_info "Installation cancelled by user."
            exit 0
        fi
    fi
}

# Backup existing dotfiles  
backup_existing_dotfiles() {
    local backup_dir="$HOME/dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
    local files_to_backup=(
        ".gitconfig"
        ".zshrc"
        ".bashrc"
        ".vimrc"
        ".tmux.conf"
        ".config/nvim"
        ".config/fish"
        ".config/ghostty"
        ".config/kitty"
        ".config/helix"
        ".config/lazygit"
        ".config/zellij"
        ".config/tmux"
        ".config/i3"
        ".config/waybar"
        ".config/hypr"
        ".config/foot"
        ".config/polybar"
        ".config/rofi"
        ".config/mise"
        ".yabairc"
        ".skhdrc"
        ".aerospace.toml"
        ".alacritty.toml"
        ".wezterm.lua"
    )
    
    local backup_created=false
    
    log_info "Checking for existing dotfiles to backup..."
    
    for file in "${files_to_backup[@]}"; do
        local full_path="$HOME/$file"
        
        # Check if file/directory exists and is not a symlink managed by stow
        if [[ -e "$full_path" ]] && [[ ! -L "$full_path" ]]; then
            # Create backup directory on first file found
            if [[ "$backup_created" == "false" ]]; then
                mkdir -p "$backup_dir"
                backup_created=true
                log_info "Creating backup directory: $backup_dir"
            fi
            
            # Backup the file/directory
            local backup_path="$backup_dir/$file"
            mkdir -p "$(dirname "$backup_path")"
            
            if [[ -d "$full_path" ]]; then
                cp -r "$full_path" "$backup_path"
                rm -rf "$full_path"
                log_info "Backed up and removed directory: $file"
            else
                cp "$full_path" "$backup_path"
                rm "$full_path"
                log_info "Backed up and removed file: $file"
            fi
        fi
    done
    
    if [[ "$backup_created" == "true" ]]; then
        log_success "Backup completed: $backup_dir"
        log_info "Backed up files are hidden (start with .). Use 'ls -la $backup_dir' to see them."
        log_info "You can restore files with: cp -r $backup_dir/.* ~/ (be careful with . and ..)"
    else
        log_info "No existing dotfiles found to backup"
    fi
}

# Interactive package selection
interactive_package_choice() {
    local os="$1"
    local packages_to_install=()
    
    echo "" >&2
    log_info "Available package groups for installation:" >&2
    echo "  1. common     - Cross-platform configs (nvim, fish, git, etc.)" >&2
    echo "  2. $os        - $os-specific configs" >&2
    echo "" >&2
    
    if ask_yes_no "Install common (cross-platform) configurations?" "y"; then
        packages_to_install+=("common")
    fi
    
    if ask_yes_no "Install $os-specific configurations?" "y"; then
        packages_to_install+=("$os")
    fi
    
    if [[ ${#packages_to_install[@]} -eq 0 ]]; then
        log_warning "No packages selected for installation." >&2
        if ask_yes_no "Exit without installing anything?" "y"; then
            log_info "Installation cancelled by user." >&2
            exit 0
        else
            # Recurse to ask again
            interactive_package_choice "$os"
            return
        fi
    fi
    
    echo "${packages_to_install[@]}"
}

# Stow packages
stow_packages() {
    local os="$1"
    local skip_backup="${2:-false}"
    local interactive="${3:-false}"
    local simulate="${4:-false}"
    
    if [[ "$simulate" == "true" ]]; then
        log_info "🔍 SIMULATION MODE: Stowing packages for $os (dry run)..."
    else
        log_info "Stowing packages for $os..."
    fi
    
    # Change to dotfiles directory
    cd "$(dirname "$0")"
    
    # Validate environment before proceeding (skip in simulation mode)
    if [[ "$simulate" != "true" ]]; then
        if ! validate_stow_environment "$os"; then
            log_error "Environment validation failed. Aborting installation."
            return 1
        fi
    fi
    
    # Interactive backup choice if not skipped and interactive mode
    if [[ "$skip_backup" != "true" && "$interactive" == "true" && "$simulate" != "true" ]]; then
        if interactive_backup_choice; then
            backup_existing_dotfiles
        fi
    elif [[ "$skip_backup" != "true" && "$simulate" != "true" ]]; then
        backup_existing_dotfiles
    elif [[ "$simulate" == "true" ]]; then
        log_info "🔍 SIMULATION: Would backup existing dotfiles (skipped in dry run)"
    fi
    
    # Interactive package selection
    if [[ "$interactive" == "true" ]]; then
        local packages_string
        packages_string=$(interactive_package_choice "$os")
        local packages=($packages_string)
        
        for package in "${packages[@]}"; do
            if [[ "$simulate" == "true" ]]; then
                log_info "🔍 SIMULATION: Would stow $package configurations..."
                stow -t "$HOME" -nv --ignore='.*\.DS_Store.*' "$package"
            else
                log_info "Stowing $package configurations..."
                stow -t "$HOME" -v --ignore='.*\.DS_Store.*' --adopt "$package"
            fi
        done
    else
        # Non-interactive: install both common and OS-specific
        if [[ "$simulate" == "true" ]]; then
            log_info "🔍 SIMULATION: Would stow common configurations..."
            stow -t "$HOME" -nv --ignore='.*\.DS_Store.*' common
            
            log_info "🔍 SIMULATION: Would stow $os-specific configurations..."
            stow -t "$HOME" -nv --ignore='.*\.DS_Store.*' "$os"
        else
            log_info "Stowing common configurations..."
            stow -t "$HOME" -v --ignore='.*\.DS_Store.*' --adopt common
            
            log_info "Stowing $os-specific configurations..."
            stow -t "$HOME" -v --ignore='.*\.DS_Store.*' --adopt "$os"
        fi
    fi
    
    log_success "All selected packages stowed successfully!"
    
    # Run stow verification check
    local script_dir="$(dirname "$0")"
    if [[ -x "$script_dir/scripts/check-stow.sh" && "$simulate" != "true" ]]; then
        echo ""
        log_info "Running stow verification check..."
        "$script_dir/scripts/check-stow.sh" || true  # Don't fail install on check failure
    fi
}

# Helper function to detect and clean orphaned dotfiles symlinks
cleanup_orphaned_symlinks() {
    log_info "Cleaning up orphaned dotfiles symlinks..."
    
    local orphans_found=false
    local dotfiles_dir="$(pwd)"
    
    # Function to check if a symlink points to our dotfiles directory
    is_dotfiles_symlink() {
        local symlink="$1"
        local target resolved_target
        
        target=$(readlink "$symlink" 2>/dev/null) || return 1
        
        # Convert to absolute path if relative
        if [[ "$target" == /* ]]; then
            # Already absolute
            resolved_target="$target"
        else
            # Convert relative to absolute using our portable function
            resolved_target="$(cd "$(dirname "$symlink")" 2>/dev/null && portable_realpath "$target")" || return 1
        fi
        
        # Check if target is within our dotfiles directory
        [[ "$resolved_target" == "$dotfiles_dir"* ]]
    }
    
    # Find and clean orphaned symlinks in common locations
    local search_paths=(
        "$HOME/.config"
        "$HOME"
    )
    
    for search_path in "${search_paths[@]}"; do
        if [[ -d "$search_path" ]]; then
            while IFS= read -r -d '' symlink; do
                if is_dotfiles_symlink "$symlink" && [[ ! -e "$symlink" ]]; then
                    log_info "Removing orphaned symlink: $symlink"
                    rm "$symlink" 2>/dev/null || true
                    orphans_found=true
                fi
            done < <(find "$search_path" -maxdepth 3 -type l -print0 2>/dev/null)
        fi
    done
    
    # Clean up empty directories
    find "$HOME/.config" -type d -empty 2>/dev/null | while read -r empty_dir; do
        if [[ "$empty_dir" != "$HOME/.config" ]]; then
            log_info "Removing empty directory: $empty_dir"
            rmdir "$empty_dir" 2>/dev/null || true
        fi
    done
    
    if [[ "$orphans_found" == "false" ]]; then
        log_info "No orphaned dotfiles symlinks found"
    fi
}

# Enhanced unstow packages with fallback cleanup
unstow_packages() {
    local os="$1"
    
    log_info "Unstowing packages for $os..."
    cd "$(dirname "$0")"
    
    # First, try regular stow unstow for packages that exist
    local unstow_success=true
    
    # Unstow in reverse order with verbose output and explicit target
    log_info "Unstowing $os-specific configurations..."
    if [[ -d "$os" ]]; then
        if stow -t "$HOME" -Dv --ignore='.*\.DS_Store.*' "$os" 2>/dev/null; then
            log_success "$os configurations unstowed successfully"
        else
            log_warning "Some $os configurations may not have been fully unstowed"
            unstow_success=false
        fi
    else
        log_warning "Package directory '$os' not found, skipping stow unstow"
        unstow_success=false
    fi
    
    log_info "Unstowing common configurations..."
    if [[ -d "common" ]]; then
        if stow -t "$HOME" -Dv --ignore='.*\.DS_Store.*' common 2>/dev/null; then
            log_success "Common configurations unstowed successfully"
        else
            log_warning "Some common configurations may not have been fully unstowed"
            unstow_success=false
        fi
    else
        log_warning "Package directory 'common' not found, skipping stow unstow"
        unstow_success=false
    fi
    
    # Fallback: Clean up any orphaned symlinks that stow couldn't handle
    if [[ "$unstow_success" == "false" ]]; then
        log_info "Running fallback cleanup for orphaned symlinks..."
        cleanup_orphaned_symlinks
    fi
    
    log_success "Unstow process completed!"
}

# Get available apps for stowing
get_available_apps() {
    local os="$1"
    local apps=()
    
    # Check common apps
    if [[ -d "common/.config" ]]; then
        for app_dir in common/.config/*/; do
            if [[ -d "$app_dir" ]]; then
                local app_name=$(basename "$app_dir")
                apps+=("$app_name")
            fi
        done
    fi
    
    # Check OS-specific apps
    if [[ -d "$os/.config" ]]; then
        for app_dir in "$os"/.config/*/; do
            if [[ -d "$app_dir" ]]; then
                local app_name=$(basename "$app_dir")
                apps+=("$app_name")
            fi
        done
    fi
    
    # Check for root-level configs in OS directories
    if [[ "$os" == "macos" ]]; then
        if [[ -f "macos/.yabairc" ]]; then apps+=("yabai"); fi
        if [[ -f "macos/.skhdrc" ]]; then apps+=("skhd"); fi
        if [[ -f "macos/.aerospace.toml" ]]; then apps+=("aerospace"); fi
        if [[ -f "macos/.alacritty.toml" ]]; then apps+=("alacritty"); fi
        if [[ -f "macos/.wezterm.lua" ]]; then apps+=("wezterm"); fi
    fi
    
    # Remove duplicates and sort
    printf '%s\n' "${apps[@]}" | sort -u
}

# Validate app name
validate_app() {
    local app_name="$1"
    local os="$2"
    local available_apps
    
    available_apps=($(get_available_apps "$os"))
    
    for available_app in "${available_apps[@]}"; do
        if [[ "$available_app" == "$app_name" ]]; then
            return 0
        fi
    done
    
    return 1
}

# Stow a specific app
stow_app() {
    local app_name="$1"
    local os="$2"
    local simulate="${3:-false}"
    
    # Change to dotfiles directory
    cd "$(dirname "$0")"
    
    if [[ "$simulate" == "true" ]]; then
        log_info "🔍 SIMULATION: Would stow $app_name configuration..."
    else
        log_info "Stowing $app_name configuration..."
    fi
    
    local stowed=false
    
    # Helper function to create symlink directly for individual app
    stow_app_config() {
        local package="$1"
        local simulate_flag="$2"
        local app_config_path="$package/.config/$app_name"
        local target_path="$HOME/.config/$app_name"
        local dotfiles_dir="$(pwd)"
        
        if [[ ! -d "$app_config_path" ]]; then
            return 1
        fi
        
        # Calculate relative path from target to source
        local relative_path="../.dotfiles/$app_config_path"
        
        if [[ "$simulate_flag" == "true" ]]; then
            log_info "🔍 SIMULATION: Would create symlink $target_path -> $relative_path"
        else
            # Create .config directory if it doesn't exist
            mkdir -p "$(dirname "$target_path")"
            
            # Remove existing file/directory if it exists
            if [[ -e "$target_path" ]] || [[ -L "$target_path" ]]; then
                if [[ -d "$target_path" ]] && [[ ! -L "$target_path" ]]; then
                    log_info "Backing up existing directory: $target_path -> ${target_path}_backup_$(date +%Y%m%d_%H%M%S)"
                    mv "$target_path" "${target_path}_backup_$(date +%Y%m%d_%H%M%S)"
                else
                    log_info "Removing existing file/symlink: $target_path"
                    rm -rf "$target_path"
                fi
            fi
            
            # Create the symlink
            ln -s "$relative_path" "$target_path"
            log_info "LINK: .config/$app_name -> $relative_path"
        fi
        
        return 0
    }
    
    # Check if app exists in common
    if [[ -d "common/.config/$app_name" ]]; then
        if [[ "$simulate" == "true" ]]; then
            log_info "🔍 SIMULATION: Would stow common/$app_name..."
            stow_app_config "common" "true"
        else
            log_info "Stowing common/$app_name..."
            stow_app_config "common" "false"
        fi
        stowed=true
    fi
    
    # Check if app exists in OS-specific (will override common if exists)
    if [[ -d "$os/.config/$app_name" ]]; then
        if [[ "$simulate" == "true" ]]; then
            log_info "🔍 SIMULATION: Would stow $os/$app_name..."
            stow_app_config "$os" "true"
        else
            log_info "Stowing $os/$app_name..."
            stow_app_config "$os" "false"
        fi
        stowed=true
    fi
    
    # Handle special macOS apps with root-level configs
    if [[ "$os" == "macos" ]]; then
        case "$app_name" in
            yabai)
                if [[ -f "macos/.yabairc" ]]; then
                    if [[ "$simulate" == "true" ]]; then
                        log_info "🔍 SIMULATION: Would stow macos/.yabairc..."
                        stow -t "$HOME" -nv --ignore='.*\.DS_Store.*' macos --adopt 2>/dev/null | grep "yabairc" || true
                    else
                        stow -t "$HOME" -v --ignore='.*\.DS_Store.*' --adopt macos
                    fi
                    stowed=true
                fi
                ;;
            skhd)
                if [[ -f "macos/.skhdrc" ]]; then
                    if [[ "$simulate" == "true" ]]; then
                        log_info "🔍 SIMULATION: Would stow macos/.skhdrc..."
                        stow -t "$HOME" -nv --ignore='.*\.DS_Store.*' macos --adopt 2>/dev/null | grep "skhdrc" || true
                    else
                        stow -t "$HOME" -v --ignore='.*\.DS_Store.*' --adopt macos
                    fi
                    stowed=true
                fi
                ;;
            aerospace)
                if [[ -f "macos/.aerospace.toml" ]]; then
                    if [[ "$simulate" == "true" ]]; then
                        log_info "🔍 SIMULATION: Would stow macos/.aerospace.toml..."
                        stow -t "$HOME" -nv --ignore='.*\.DS_Store.*' macos --adopt 2>/dev/null | grep "aerospace" || true
                    else
                        stow -t "$HOME" -v --ignore='.*\.DS_Store.*' --adopt macos
                    fi
                    stowed=true
                fi
                ;;
            alacritty)
                if [[ -f "macos/.alacritty.toml" ]]; then
                    if [[ "$simulate" == "true" ]]; then
                        log_info "🔍 SIMULATION: Would stow macos/.alacritty.toml..."
                        stow -t "$HOME" -nv --ignore='.*\.DS_Store.*' macos --adopt 2>/dev/null | grep "alacritty" || true
                    else
                        stow -t "$HOME" -v --ignore='.*\.DS_Store.*' --adopt macos
                    fi
                    stowed=true
                fi
                ;;
            wezterm)
                if [[ -f "macos/.wezterm.lua" ]]; then
                    if [[ "$simulate" == "true" ]]; then
                        log_info "🔍 SIMULATION: Would stow macos/.wezterm.lua..."
                        stow -t "$HOME" -nv --ignore='.*\.DS_Store.*' macos --adopt 2>/dev/null | grep "wezterm" || true
                    else
                        stow -t "$HOME" -v --ignore='.*\.DS_Store.*' --adopt macos
                    fi
                    stowed=true
                fi
                ;;
        esac
    fi
    
    if [[ "$stowed" == "true" ]]; then
        log_success "$app_name configuration stowed successfully!"
    else
        log_error "$app_name configuration not found for $os"
        return 1
    fi
}

# Unstow a specific app
unstow_app() {
    local app_name="$1"
    local os="$2"
    local simulate="${3:-false}"
    
    # Change to dotfiles directory
    cd "$(dirname "$0")"
    
    if [[ "$simulate" == "true" ]]; then
        log_info "🔍 SIMULATION: Would unstow $app_name configuration..."
    else
        log_info "Unstowing $app_name configuration..."
    fi
    
    local unstowed=false
    
    # Remove specific app symlinks from common
    if [[ -d "common/.config/$app_name" ]]; then
        local target_path="$HOME/.config/$app_name"
        if [[ -L "$target_path" ]]; then
            if [[ "$simulate" == "true" ]]; then
                log_info "🔍 SIMULATION: Would remove $target_path"
            else
                log_info "Removing symlink: $target_path"
                rm "$target_path"
            fi
            unstowed=true
        fi
    fi
    
    # Remove specific app symlinks from OS-specific
    if [[ -d "$os/.config/$app_name" ]]; then
        local target_path="$HOME/.config/$app_name"
        if [[ -L "$target_path" ]]; then
            if [[ "$simulate" == "true" ]]; then
                log_info "🔍 SIMULATION: Would remove $target_path"
            else
                log_info "Removing symlink: $target_path"
                rm "$target_path"
            fi
            unstowed=true
        fi
    fi
    
    # Handle special macOS apps with root-level configs
    if [[ "$os" == "macos" ]]; then
        case "$app_name" in
            yabai)
                if [[ -f "macos/.yabairc" ]] && [[ -L "$HOME/.yabairc" ]]; then
                    if [[ "$simulate" == "true" ]]; then
                        log_info "🔍 SIMULATION: Would remove $HOME/.yabairc"
                    else
                        log_info "Removing symlink: $HOME/.yabairc"
                        rm "$HOME/.yabairc"
                    fi
                    unstowed=true
                fi
                ;;
            skhd)
                if [[ -f "macos/.skhdrc" ]] && [[ -L "$HOME/.skhdrc" ]]; then
                    if [[ "$simulate" == "true" ]]; then
                        log_info "🔍 SIMULATION: Would remove $HOME/.skhdrc"
                    else
                        log_info "Removing symlink: $HOME/.skhdrc"
                        rm "$HOME/.skhdrc"
                    fi
                    unstowed=true
                fi
                ;;
            aerospace)
                if [[ -f "macos/.aerospace.toml" ]] && [[ -L "$HOME/.aerospace.toml" ]]; then
                    if [[ "$simulate" == "true" ]]; then
                        log_info "🔍 SIMULATION: Would remove $HOME/.aerospace.toml"
                    else
                        log_info "Removing symlink: $HOME/.aerospace.toml"
                        rm "$HOME/.aerospace.toml"
                    fi
                    unstowed=true
                fi
                ;;
            alacritty)
                if [[ -f "macos/.alacritty.toml" ]] && [[ -L "$HOME/.alacritty.toml" ]]; then
                    if [[ "$simulate" == "true" ]]; then
                        log_info "🔍 SIMULATION: Would remove $HOME/.alacritty.toml"
                    else
                        log_info "Removing symlink: $HOME/.alacritty.toml"
                        rm "$HOME/.alacritty.toml"
                    fi
                    unstowed=true
                fi
                ;;
            wezterm)
                if [[ -f "macos/.wezterm.lua" ]] && [[ -L "$HOME/.wezterm.lua" ]]; then
                    if [[ "$simulate" == "true" ]]; then
                        log_info "🔍 SIMULATION: Would remove $HOME/.wezterm.lua"
                    else
                        log_info "Removing symlink: $HOME/.wezterm.lua"
                        rm "$HOME/.wezterm.lua"
                    fi
                    unstowed=true
                fi
                ;;
            tmux)
                # Special handling for tmux which has multiple symlinks
                local tmux_files=("$HOME/.tmux.conf" "$HOME/.tmux.conf.local")
                for tmux_file in "${tmux_files[@]}"; do
                    if [[ -L "$tmux_file" ]]; then
                        if [[ "$simulate" == "true" ]]; then
                            log_info "🔍 SIMULATION: Would remove $tmux_file"
                        else
                            log_info "Removing symlink: $tmux_file"
                            rm "$tmux_file"
                        fi
                        unstowed=true
                    fi
                done
                ;;
        esac
    fi
    
    if [[ "$unstowed" == "true" ]]; then
        log_success "$app_name configuration unstowed successfully!"
    else
        log_warning "$app_name configuration was not found or already unstowed for $os"
    fi
}

# Show usage
show_usage() {
    echo "Usage: $0 [install|uninstall|restow|stow-app|unstow-app|tools|fonts|fish|submodules|all|backup|cleanup|status]"
    echo ""
    echo "Commands:"
    echo "  install           - Install dotfiles only (default)"
    echo "  uninstall         - Remove dotfiles symlinks"
    echo "  restow            - Remove and reinstall dotfiles"
    echo "  stow-app <app>    - Stow a specific app configuration (e.g., tmux, nvim)"
    echo "  unstow-app <app>  - Unstow a specific app configuration"
    echo "  tools             - Install development tools with mise"
    echo "  fonts             - Install Maple Mono Nerd Font for terminal applications"
    echo "  fish              - Install Fish shell, Fisher plugin manager, and set as default shell"
    echo "  submodules        - Update git submodules"
    echo "  all               - Install dotfiles, tools, and update submodules"
    echo "  backup            - Backup existing dotfiles only"
    echo "  cleanup           - Remove orphaned dotfiles symlinks"
    echo "  status            - Show current dotfiles installation status"
    echo ""
    echo "Options:"
    echo "  --with-tools     - Install tools along with dotfiles"
    echo "  --update-subs    - Update submodules along with dotfiles"
    echo "  --no-backup      - Skip backing up existing dotfiles"
    echo "  --interactive    - Interactive mode with prompts for choices"
    echo "  --simulate       - Dry run - show what would be done without doing it"
    echo ""
    echo "Examples:"
    echo "  $0 stow-app tmux                # Stow only tmux configuration"
    echo "  $0 unstow-app tmux              # Remove tmux configuration symlinks"
    echo "  $0 stow-app nvim --simulate     # Preview nvim stowing without changes"
    echo "  $0 unstow-app nvim --simulate   # Preview nvim unstowing without changes"
    echo ""
    echo "This script will automatically detect your OS and install appropriate configs."
    echo "By default, existing dotfiles are backed up before installation."
    echo "Use --interactive for guided installation with user prompts."
    echo "Use --simulate to preview changes before applying them."
}

# Install fonts required for terminal applications
install_fonts() {
    log_info "Installing required fonts..."
    
    # Create fonts directory
    mkdir -p ~/.local/share/fonts/MapleMono
    
    # Check if Maple Mono Nerd Font is already installed
    if fc-list | grep -q -i "Maple Mono NF"; then
        log_info "Maple Mono Nerd Font is already installed"
        return 0
    fi
    
    log_info "Downloading Maple Mono Nerd Font..."
    
    # Download Maple Mono Nerd Font zip file
    local font_dir="$HOME/.local/share/fonts/MapleMono"
    local temp_dir="/tmp/maple-font-$$"
    local zip_file="$temp_dir/MapleMono-NF.zip"
    
    # Create temporary directory
    mkdir -p "$temp_dir"
    
    # Download the latest Maple Mono NF zip from GitHub releases
    if curl -fL --max-time 60 \
        -o "$zip_file" \
        "https://github.com/subframe7536/Maple-font/releases/download/v7.6/MapleMono-NF-unhinted.zip"; then
        log_info "Downloaded MapleMono-NF-unhinted.zip"
    else
        log_error "Failed to download Maple Mono Nerd Font"
        rm -rf "$temp_dir"
        return 1
    fi
    
    # Extract zip file
    if command_exists unzip; then
        log_info "Extracting Maple Mono font files..."
        if unzip -q "$zip_file" -d "$temp_dir"; then
            log_info "Successfully extracted font archive"
        else
            log_error "Failed to extract font archive"
            rm -rf "$temp_dir"
            return 1
        fi
    else
        log_error "unzip command not found. Please install unzip and try again."
        rm -rf "$temp_dir"
        return 1
    fi
    
    # Copy TTF files to font directory
    local ttf_count=0
    if find "$temp_dir" -name "*.ttf" -print0 | while IFS= read -r -d '' ttf_file; do
        cp "$ttf_file" "$font_dir/"
        log_info "Installed $(basename "$ttf_file")"
        ((ttf_count++))
    done; then
        ttf_count=$(find "$font_dir" -name "*.ttf" | wc -l)
    fi
    
    # Clean up temporary directory
    rm -rf "$temp_dir"
    
    if [[ $ttf_count -eq 0 ]]; then
        log_error "No TTF files found in the downloaded archive"
        return 1
    fi
    
    log_info "Installed $ttf_count Maple Mono font variants"
    
    # Refresh font cache
    if command_exists fc-cache; then
        log_info "Refreshing font cache..."
        fc-cache -fv ~/.local/share/fonts/MapleMono >/dev/null 2>&1
        log_success "Font cache refreshed"
        
        # Brief pause to ensure fonts are available
        sleep 1
    else
        log_warning "fc-cache not found, fonts may not be immediately available"
    fi
    
    # Verify installation
    if fc-list | grep -q -i "Maple Mono NF"; then
        log_success "Maple Mono Nerd Font installed successfully"
    else
        log_warning "Font installation may not have completed successfully"
    fi
}

# Install development tools
install_tools() {
    log_info "Installing development tools..."
    local script_dir="$(dirname "$0")"
    
    if [[ -x "$script_dir/scripts/install-tools.sh" ]]; then
        "$script_dir/scripts/install-tools.sh"
    else
        log_error "install-tools.sh script not found or not executable"
        return 1
    fi
}

# Install Fish shell and Fisher plugin manager
install_fish() {
    local os="$1"
    
    # Check if fish is already installed
    if command_exists fish; then
        log_info "Fish shell is already installed"
    else
        log_info "Installing Fish shell..."
        case "$os" in
            macos)
                if command_exists brew; then
                    brew install fish
                else
                    log_info "Homebrew not found. Installing Homebrew..."
                    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
                    
                    # Add Homebrew to PATH for current session
                    if [[ -f "/opt/homebrew/bin/brew" ]]; then
                        eval "$(/opt/homebrew/bin/brew shellenv)"
                    elif [[ -f "/usr/local/bin/brew" ]]; then
                        eval "$(/usr/local/bin/brew shellenv)"
                    fi
                    
                    if command_exists brew; then
                        log_success "Homebrew installed successfully"
                        brew install fish
                    else
                        log_error "Failed to install Homebrew. Please install manually: https://brew.sh/"
                        return 1
                    fi
                fi
                ;;
            linux)
                if command_exists apt; then
                    sudo apt update && sudo apt install -y fish
                elif command_exists pacman; then
                    sudo pacman -S --noconfirm fish
                elif command_exists dnf; then
                    sudo dnf install -y fish
                elif command_exists zypper; then
                    sudo zypper install -y fish
                else
                    log_error "Package manager not found. Please install Fish shell manually."
                    return 1
                fi
                ;;
        esac
        log_success "Fish shell installed successfully"
    fi
    
    # Check if Fisher is installed
    if fish -c "fisher --version" >/dev/null 2>&1; then
        log_info "Fisher plugin manager is already installed"
    else
        log_info "Installing Fisher plugin manager..."
        fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"
        log_success "Fisher plugin manager installed successfully"
    fi
    
    # Install fish plugins if fish_plugins file exists
    if [[ -f "$HOME/.config/fish/fish_plugins" ]]; then
        log_info "Installing Fish plugins from fish_plugins..."
        fish -c "fisher update"
        log_success "Fish plugins installed successfully"
    else
        log_info "No fish_plugins file found, skipping plugin installation"
    fi
    
    # Change default shell to fish
    local fish_path
    fish_path=$(command -v fish)
    
    if [[ -n "$fish_path" ]]; then
        # Check if fish is in /etc/shells
        if ! grep -q "^$fish_path$" /etc/shells 2>/dev/null; then
            log_info "Adding fish to /etc/shells..."
            echo "$fish_path" | sudo tee -a /etc/shells >/dev/null
        fi
        
        # Check if fish is already the default shell
        if [[ "$SHELL" == "$fish_path" ]]; then
            log_info "Fish is already the default shell"
        else
            log_info "Changing default shell to fish..."
            if chsh -s "$fish_path"; then
                log_success "Default shell changed to fish"
                log_info "Please restart your terminal or log out and back in for the change to take effect"
            else
                log_warning "Failed to change default shell. You can manually run: chsh -s $fish_path"
            fi
        fi
    else
        log_error "Fish shell not found in PATH"
        return 1
    fi
}

# Update git submodules
update_submodules() {
    log_info "Updating git submodules..."
    local script_dir="$(dirname "$0")"
    
    if [[ -x "$script_dir/scripts/update-submodules.sh" ]]; then
        "$script_dir/scripts/update-submodules.sh"
    else
        log_error "update-submodules.sh script not found or not executable"
        return 1
    fi
}

# Show comprehensive dotfiles status
show_dotfiles_status() {
    local os="$1"
    local platform="$2"
    
    cd "$(dirname "$0")" || {
        log_error "Cannot access dotfiles directory"
        return 1
    }
    
    echo "🔧 Dotfiles Status Report"
    echo "========================"
    echo "Platform: $platform"
    echo "Dotfiles directory: $(pwd)"
    echo "Timestamp: $(date)"
    echo ""
    
    # System information
    echo "📋 System Information:"
    echo "  OS: $(uname -s) $(uname -r)"
    echo "  Architecture: $(uname -m)"
    echo "  Shell: $SHELL"
    echo "  User: $USER"
    echo "  Home: $HOME"
    echo ""
    
    # Stow availability
    echo "🔨 Tools Status:"
    if command_exists stow; then
        echo "  ✅ GNU Stow: $(stow --version | head -1)"
    else
        echo "  ❌ GNU Stow: Not installed"
    fi
    
    if command_exists git; then
        echo "  ✅ Git: $(git --version)"
    else
        echo "  ❌ Git: Not installed"  
    fi
    echo ""
    
    # Package directories status
    echo "📁 Package Directories:"
    for pkg in "common" "$os"; do
        if [[ -d "$pkg" ]]; then
            local app_count=$(find "$pkg/.config" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l)
            echo "  ✅ $pkg: $app_count applications"
        else
            echo "  ❌ $pkg: Directory not found"
        fi
    done
    echo ""
    
    # Symlinks status
    echo "🔗 Symlinks Status:"
    local total_links=0 valid_links=0 broken_links=0 missing_links=0
    
    # Check common config locations
    for config_dir in "$HOME/.config"/*; do
        if [[ -L "$config_dir" ]]; then
            ((total_links++))
            if [[ -e "$config_dir" ]]; then
                local target=$(portable_realpath "$config_dir")
                if [[ "$target" == "$(pwd)"* ]]; then
                    ((valid_links++))
                    echo "  ✅ $(basename "$config_dir"): $(readlink "$config_dir")"
                else
                    echo "  ⚠️  $(basename "$config_dir"): Points outside dotfiles"
                fi
            else
                ((broken_links++))
                echo "  ❌ $(basename "$config_dir"): Broken symlink"
            fi
        fi
    done
    
    # Check root-level configs
    for config in .gitconfig .zshrc .bashrc .vimrc .yabairc .skhdrc .aerospace.toml .alacritty.toml .wezterm.lua; do
        if [[ -L "$HOME/$config" ]]; then
            ((total_links++))
            if [[ -e "$HOME/$config" ]]; then
                local target=$(portable_realpath "$HOME/$config")
                if [[ "$target" == "$(pwd)"* ]]; then
                    ((valid_links++))
                    echo "  ✅ $config: $(readlink "$HOME/$config")"
                else
                    echo "  ⚠️  $config: Points outside dotfiles"
                fi
            else
                ((broken_links++))
                echo "  ❌ $config: Broken symlink"
            fi
        elif [[ -f "$HOME/$config" ]]; then
            echo "  ⚠️  $config: Regular file (not managed by dotfiles)"
        fi
    done
    
    echo ""
    echo "📊 Summary:"
    echo "  Total symlinks: $total_links"
    echo "  Valid dotfiles links: $valid_links"
    echo "  Broken links: $broken_links"
    
    if [[ $broken_links -gt 0 ]]; then
        echo ""
        echo "💡 Recommendations:"
        echo "  - Run './install.sh cleanup' to remove broken symlinks"
        echo "  - Run './install.sh restow' to reinstall dotfiles"
    fi
    
    # Git status if in repo
    if [[ -d ".git" ]]; then
        echo ""
        echo "📝 Git Repository Status:"
        if git status --porcelain | grep -q .; then
            echo "  ⚠️  Uncommitted changes detected"
            git status --short
        else
            echo "  ✅ Repository clean"
        fi
        
        local branch=$(git branch --show-current 2>/dev/null || echo "unknown")
        local commit=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
        echo "  Branch: $branch"
        echo "  Commit: $commit"
        
        # Check for submodules
        if [[ -f ".gitmodules" ]]; then
            echo "  Submodules:"
            git submodule status | while read status path; do
                case "${status:0:1}" in
                    "-") echo "    ❌ $path: Not initialized" ;;
                    "+") echo "    ⚠️  $path: Different commit checked out" ;;
                    " ") echo "    ✅ $path: Up to date" ;;
                    *) echo "    ❓ $path: $status" ;;
                esac
            done
        fi
    fi
}

# Parse command line arguments
parse_args() {
    local with_tools=false
    local update_subs=false
    local no_backup=false
    local interactive=false
    local simulate=false
    
    for arg in "$@"; do
        case "$arg" in
            --with-tools)
                with_tools=true
                ;;
            --update-subs)
                update_subs=true
                ;;
            --no-backup)
                no_backup=true
                ;;
            --interactive)
                interactive=true
                ;;
            --simulate)
                simulate=true
                ;;
        esac
    done
    
    echo "$with_tools $update_subs $no_backup $interactive $simulate"
}

# Get the app name from arguments (skipping command and options)
get_app_name() {
    local found_command=false
    
    for arg in "$@"; do
        case "$arg" in
            stow-app|unstow-app)
                found_command=true
                ;;
            --*)
                # Skip options
                ;;
            *)
                if [[ "$found_command" == "true" ]]; then
                    echo "$arg"
                    return 0
                fi
                ;;
        esac
    done
    
    echo ""
}

# Main function
main() {
    local command="${1:-install}"
    local os
    local args
    
    # Parse additional arguments
    args=($(parse_args "$@"))
    local with_tools="${args[0]}"
    local update_subs="${args[1]}"
    local no_backup="${args[2]}"
    local interactive="${args[3]}"
    local simulate="${args[4]}"
    
    case "$command" in
        stow-app)
            local app_name
            app_name=$(get_app_name "$@")
            
            if [[ -z "$app_name" ]]; then
                log_error "App name required for stow-app command"
                echo ""
                echo "Available apps:"
                os=$(detect_os)
                get_available_apps "$os" | sed 's/^/  - /'
                echo ""
                show_usage
                exit 1
            fi
            
            os=$(detect_os)
            log_info "Detected OS: $os"
            
            if ! validate_app "$app_name" "$os"; then
                log_error "App '$app_name' not found"
                echo ""
                echo "Available apps:"
                get_available_apps "$os" | sed 's/^/  - /'
                exit 1
            fi
            
            if [[ "$simulate" != "true" ]]; then
                install_stow "$os"
            fi
            
            stow_app "$app_name" "$os" "$simulate"
            ;;
        unstow-app)
            local app_name
            app_name=$(get_app_name "$@")
            
            if [[ -z "$app_name" ]]; then
                log_error "App name required for unstow-app command"
                echo ""
                echo "Available apps:"
                os=$(detect_os)
                get_available_apps "$os" | sed 's/^/  - /'
                echo ""
                show_usage
                exit 1
            fi
            
            os=$(detect_os)
            log_info "Detected OS: $os"
            
            if ! validate_app "$app_name" "$os"; then
                log_error "App '$app_name' not found"
                echo ""
                echo "Available apps:"
                get_available_apps "$os" | sed 's/^/  - /'
                exit 1
            fi
            
            unstow_app "$app_name" "$os" "$simulate"
            ;;
        install)
            os=$(detect_os)
            log_info "Detected OS: $os"
            
            if [[ "$simulate" == "true" ]]; then
                log_info "🔍 SIMULATION MODE: No actual changes will be made"
            else
                install_stow "$os"
            fi
            
            # Interactive mode prompts
            if [[ "$interactive" == "true" ]]; then
                echo ""
                if [[ "$simulate" == "true" ]]; then
                    log_info "=== Simulation + Interactive Installation Mode ==="
                else
                    log_info "=== Interactive Installation Mode ==="
                fi
                
                # Ask about additional components in interactive mode
                if [[ "$with_tools" != "true" ]] && ask_yes_no "Install development tools with mise?" "n"; then
                    with_tools=true
                fi
                
                if [[ "$update_subs" != "true" ]] && ask_yes_no "Update git submodules (editor configs)?" "n"; then
                    update_subs=true
                fi
            fi
            
            stow_packages "$os" "$no_backup" "$interactive" "$simulate"
            
            # Handle additional options
            if [[ "$with_tools" == "true" ]]; then
                if [[ "$simulate" == "true" ]]; then
                    log_info "🔍 SIMULATION: Would install development tools with mise"
                else
                    install_tools
                fi
            fi
            if [[ "$update_subs" == "true" ]]; then
                if [[ "$simulate" == "true" ]]; then
                    log_info "🔍 SIMULATION: Would update git submodules"
                else
                    update_submodules
                fi
            fi
            ;;
        uninstall)
            os=$(detect_os)
            log_info "Detected OS: $os"
            unstow_packages "$os"
            ;;
        restow)
            os=$(detect_os)
            log_info "Detected OS: $os"
            unstow_packages "$os"
            stow_packages "$os" "true"  # Skip backup on restow
            ;;
        backup)
            backup_existing_dotfiles
            ;;
        cleanup)
            cd "$(dirname "$0")"
            cleanup_orphaned_symlinks
            ;;
        status)
            os=$(detect_os)
            platform=$(detect_platform)
            show_dotfiles_status "$os" "$platform"
            ;;
        tools)
            install_tools
            ;;
        fonts)
            install_fonts
            ;;
        fish)
            os=$(detect_os)
            log_info "Detected OS: $os"
            install_fish "$os"
            ;;
        submodules)
            update_submodules
            ;;
        all)
            os=$(detect_os)
            log_info "Detected OS: $os"
            
            if [[ "$simulate" == "true" ]]; then
                log_info "🔍 SIMULATION MODE: Complete setup (dry run)"
                log_info "🔍 SIMULATION: Would install GNU Stow"
                stow_packages "$os" "$no_backup" "$interactive" "$simulate"
                log_info "🔍 SIMULATION: Would install development tools"
                log_info "🔍 SIMULATION: Would update git submodules"
            else
                install_stow "$os"
                stow_packages "$os" "$no_backup" "$interactive" "$simulate"
                install_tools
                update_submodules
            fi
            ;;
        -h|--help|help)
            show_usage
            exit 0
            ;;
        --simulate|--interactive|--no-backup|--with-tools|--update-subs)
            # Handle options passed as main command - default to install
            log_info "Detected option as command, defaulting to 'install'"
            os=$(detect_os)
            log_info "Detected OS: $os"
            
            if [[ "$simulate" == "true" ]]; then
                log_info "🔍 SIMULATION MODE: No actual changes will be made"
            else
                install_stow "$os"
            fi
            
            # Interactive mode prompts
            if [[ "$interactive" == "true" ]]; then
                echo ""
                if [[ "$simulate" == "true" ]]; then
                    log_info "=== Simulation + Interactive Installation Mode ==="
                else
                    log_info "=== Interactive Installation Mode ==="
                fi
                
                # Ask about additional components in interactive mode
                if [[ "$with_tools" != "true" ]] && ask_yes_no "Install development tools with mise?" "n"; then
                    with_tools=true
                fi
                
                if [[ "$update_subs" != "true" ]] && ask_yes_no "Update git submodules (editor configs)?" "n"; then
                    update_subs=true
                fi
            fi
            
            stow_packages "$os" "$no_backup" "$interactive" "$simulate"
            
            # Handle additional options
            if [[ "$with_tools" == "true" ]]; then
                if [[ "$simulate" == "true" ]]; then
                    log_info "🔍 SIMULATION: Would install development tools with mise"
                else
                    install_tools
                fi
            fi
            if [[ "$update_subs" == "true" ]]; then
                if [[ "$simulate" == "true" ]]; then
                    log_info "🔍 SIMULATION: Would update git submodules"
                else
                    update_submodules
                fi
            fi
            ;;
        *)
            log_error "Unknown command: $command"
            show_usage
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"