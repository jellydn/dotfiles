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

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
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

# Install mise
install_mise() {
    if command_exists mise; then
        log_info "mise is already installed ($(mise --version))"
        return 0
    fi
    
    log_info "Installing mise..."
    
    # Install mise using the official installer
    curl https://mise.run | sh
    
    # Add mise to PATH for current session
    export PATH="$HOME/.local/bin:$PATH"
    
    # Add to shell configuration
    local os=$(detect_os)
    case "$os" in
        macos)
            if [[ -f "$HOME/.zshrc" ]]; then
                echo 'eval "$(~/.local/bin/mise activate zsh)"' >> ~/.zshrc
                log_info "Added mise activation to ~/.zshrc"
            fi
            if [[ -f "$HOME/.config/fish/config.fish" ]]; then
                echo '~/.local/bin/mise activate fish | source' >> ~/.config/fish/config.fish
                log_info "Added mise activation to fish config"
            fi
            ;;
        linux)
            if [[ -f "$HOME/.bashrc" ]]; then
                echo 'eval "$(~/.local/bin/mise activate bash)"' >> ~/.bashrc
                log_info "Added mise activation to ~/.bashrc"
            fi
            if [[ -f "$HOME/.config/fish/config.fish" ]]; then
                echo '~/.local/bin/mise activate fish | source' >> ~/.config/fish/config.fish
                log_info "Added mise activation to fish config"
            fi
            ;;
    esac
    
    log_success "mise installed successfully"
}

# Install development tools using mise
install_dev_tools() {
    log_info "Installing development tools with mise..."
    
    # Change to dotfiles directory to find .tool-versions
    cd "$(dirname "$0")/.."
    
    if [[ ! -f ".tool-versions" ]]; then
        log_error ".tool-versions file not found in $(pwd)"
        return 1
    fi
    
    # Install tools from .tool-versions globally
    log_info "Installing tools globally..."
    while IFS= read -r line; do
        # Skip comments and empty lines
        if [[ "$line" =~ ^#.*$ ]] || [[ -z "$line" ]]; then
            continue
        fi
        
        # Parse tool and version
        tool=$(echo "$line" | awk '{print $1}')
        version=$(echo "$line" | awk '{print $2}')
        
        if [[ -n "$tool" && -n "$version" ]]; then
            log_info "Installing $tool@$version globally..."
            ~/.local/bin/mise use -g "$tool@$version"
        fi
    done < .tool-versions
    
    log_success "Development tools installed globally"
}

# Install system packages
install_system_packages() {
    local os="$1"
    
    log_info "Installing system packages for $os..."
    
    case "$os" in
        macos)
            if ! command_exists brew; then
                log_error "Homebrew not found. Please install Homebrew first: https://brew.sh/"
                return 1
            fi
            
            # Install essential tools
            brew install git stow tmux fish
            brew install --cask ghostty
            
            # Install fonts
            brew tap homebrew/cask-fonts
            brew install --cask font-jetbrains-mono-nerd-font
            ;;
        linux)
            if command_exists apt; then
                sudo apt update
                sudo apt install -y git stow tmux fish curl build-essential
            elif command_exists yay; then
                yay -S --noconfirm git stow tmux fish curl base-devel
            elif command_exists pacman; then
                sudo pacman -S --noconfirm git stow tmux fish curl base-devel
            elif command_exists dnf; then
                sudo dnf install -y git stow tmux fish curl gcc gcc-c++ make
            else
                log_warning "Package manager not found. Please install git, stow, tmux, and fish manually."
                return 1
            fi
            ;;
    esac
    
    log_success "System packages installed successfully"
}

# Main function
main() {
    local os
    os=$(detect_os)
    
    log_info "Detected OS: $os"
    log_info "Installing tools and dependencies..."
    
    # Install system packages first
    install_system_packages "$os"
    
    # Install mise
    install_mise
    
    # Install development tools
    install_dev_tools
    
    log_success "All tools installed successfully!"
    log_info "Please restart your shell or run: source ~/.zshrc (or ~/.bashrc)"
    log_info "Then run 'mise doctor' to verify installation"
}

# Run main function
main "$@"