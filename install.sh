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
            elif command_exists zypper; then
                sudo zypper install -y stow
            else
                log_error "Package manager not found. Please install GNU Stow manually."
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
                stow -t "$HOME" -nv "$package"
            else
                log_info "Stowing $package configurations..."
                stow -t "$HOME" -v --adopt "$package"
            fi
        done
    else
        # Non-interactive: install both common and OS-specific
        if [[ "$simulate" == "true" ]]; then
            log_info "🔍 SIMULATION: Would stow common configurations..."
            stow -t "$HOME" -nv common
            
            log_info "🔍 SIMULATION: Would stow $os-specific configurations..."
            stow -t "$HOME" -nv "$os"
        else
            log_info "Stowing common configurations..."
            stow -t "$HOME" -v --adopt common
            
            log_info "Stowing $os-specific configurations..."
            stow -t "$HOME" -v --adopt "$os"
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

# Unstow packages (cleanup)
unstow_packages() {
    local os="$1"
    
    log_info "Unstowing packages for $os..."
    cd "$(dirname "$0")"
    
    # Unstow in reverse order with verbose output and explicit target
    log_info "Unstowing $os-specific configurations..."
    if stow -t "$HOME" -Dv "$os"; then
        log_success "$os configurations unstowed successfully"
    else
        log_warning "Some $os configurations may not have been fully unstowed"
    fi
    
    log_info "Unstowing common configurations..."
    if stow -t "$HOME" -Dv common; then
        log_success "Common configurations unstowed successfully"
    else
        log_warning "Some common configurations may not have been fully unstowed"
    fi
    
    log_success "Unstow process completed!"
}

# Show usage
show_usage() {
    echo "Usage: $0 [install|uninstall|restow|tools|submodules|all|backup|fish]"
    echo ""
    echo "Commands:"
    echo "  install      - Install dotfiles only (default)"
    echo "  uninstall    - Remove dotfiles symlinks"
    echo "  restow       - Remove and reinstall dotfiles"
    echo "  tools        - Install development tools with mise"
    echo "  fish         - Install Fish shell and Fisher plugin manager"
    echo "  submodules   - Update git submodules"
    echo "  all          - Install dotfiles, tools, and update submodules"
    echo "  backup       - Backup existing dotfiles only"
    echo ""
    echo "Options:"
    echo "  --with-tools     - Install tools along with dotfiles"
    echo "  --update-subs    - Update submodules along with dotfiles"
    echo "  --no-backup      - Skip backing up existing dotfiles"
    echo "  --interactive    - Interactive mode with prompts for choices"
    echo "  --simulate       - Dry run - show what would be done without doing it"
    echo ""
    echo "This script will automatically detect your OS and install appropriate configs."
    echo "By default, existing dotfiles are backed up before installation."
    echo "Use --interactive for guided installation with user prompts."
    echo "Use --simulate to preview changes before applying them."
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
        tools)
            install_tools
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
        *)
            log_error "Unknown command: $command"
            show_usage
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"