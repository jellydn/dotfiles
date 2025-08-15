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
                log_error "Homebrew not found. Please install Homebrew first: https://brew.sh/"
                exit 1
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

# Stow packages
stow_packages() {
    local os="$1"
    
    log_info "Stowing packages for $os..."
    
    # Change to dotfiles directory
    cd "$(dirname "$0")"
    
    # Always stow common configs
    log_info "Stowing common configurations..."
    stow -v common
    
    # Stow OS-specific configs
    log_info "Stowing $os-specific configurations..."
    stow -v "$os"
    
    log_success "All packages stowed successfully!"
}

# Unstow packages (cleanup)
unstow_packages() {
    local os="$1"
    
    log_info "Unstowing packages for $os..."
    cd "$(dirname "$0")"
    
    # Unstow in reverse order
    stow -D "$os" 2>/dev/null || true
    stow -D common 2>/dev/null || true
    
    log_success "Packages unstowed successfully!"
}

# Show usage
show_usage() {
    echo "Usage: $0 [install|uninstall|restow|tools|submodules|all]"
    echo ""
    echo "Commands:"
    echo "  install      - Install dotfiles only (default)"
    echo "  uninstall    - Remove dotfiles symlinks"
    echo "  restow       - Remove and reinstall dotfiles"
    echo "  tools        - Install development tools with mise"
    echo "  submodules   - Update git submodules"
    echo "  all          - Install dotfiles, tools, and update submodules"
    echo ""
    echo "Options:"
    echo "  --with-tools     - Install tools along with dotfiles"
    echo "  --update-subs    - Update submodules along with dotfiles"
    echo ""
    echo "This script will automatically detect your OS and install appropriate configs."
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
    
    for arg in "$@"; do
        case "$arg" in
            --with-tools)
                with_tools=true
                ;;
            --update-subs)
                update_subs=true
                ;;
        esac
    done
    
    echo "$with_tools $update_subs"
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
    
    case "$command" in
        install)
            os=$(detect_os)
            log_info "Detected OS: $os"
            install_stow "$os"
            stow_packages "$os"
            
            # Handle additional options
            if [[ "$with_tools" == "true" ]]; then
                install_tools
            fi
            if [[ "$update_subs" == "true" ]]; then
                update_submodules
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
            stow_packages "$os"
            ;;
        tools)
            install_tools
            ;;
        submodules)
            update_submodules
            ;;
        all)
            os=$(detect_os)
            log_info "Detected OS: $os"
            install_stow "$os"
            stow_packages "$os"
            install_tools
            update_submodules
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