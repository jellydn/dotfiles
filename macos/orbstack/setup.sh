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
    exit 1
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Configure TMPDIR to avoid EXDEV cross-device link errors on OrbStack
configure_tmpdir() {
    export TMPDIR="$HOME/.tmp"
    mkdir -p "$TMPDIR"
    log_info "TMPDIR set to $TMPDIR (avoids cross-device link errors)"
}

# Install base system dependencies
install_base_deps() {
    log_info "Installing base dependencies..."

    if ! command_exists git; then
        sudo apt update
        sudo apt install -y git curl build-essential file
    else
        log_info "git is already installed"
    fi

    log_success "Base dependencies installed"
}

# Install Homebrew on Linux
install_homebrew() {
    if command_exists brew; then
        log_info "Homebrew is already installed ($(brew --version | head -n1))"
        return 0
    fi

    log_info "Installing Homebrew..."
    export NONINTERACTIVE=1

    # Install Homebrew
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for current session
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

    # Add to fish config if it exists
    if [[ -f "$HOME/.config/fish/config.fish" ]]; then
        if ! grep -q "brew shellenv" "$HOME/.config/fish/config.fish" 2>/dev/null; then
            echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> "$HOME/.config/fish/config.fish"
            log_info "Added Homebrew to fish config"
        fi
    fi

    log_success "Homebrew installed successfully"
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

    # Add to PATH for current session
    export PATH="$HOME/.local/bin:$PATH"

    log_success "mise installed successfully"
}

# Install fish shell and pure prompt
install_fish() {
    if ! command_exists fish; then
        log_info "Installing fish shell..."
        sudo apt update
        sudo apt install -y fish
    else
        log_info "fish is already installed ($(fish --version))"
    fi

    # Install fisher if not present
    if ! command_exists fisher; then
        log_info "Installing fisher and pure prompt..."
        # Install fisher and pure in the same fish session so functions persist
        fish -c "curl -sL https://git.io/fisher | source && fisher install pure-fish/pure"
    else
        log_info "fisher is already installed"
    fi

    log_success "fish and pure prompt installed successfully"

    # Ensure fish config directory exists
    mkdir -p "$HOME/.config/fish"

    # Add Homebrew to fish config if not already present
    if [[ -f "$HOME/.config/fish/config.fish" ]]; then
        if ! grep -q "brew shellenv" "$HOME/.config/fish/config.fish" 2>/dev/null; then
            echo '' >> "$HOME/.config/fish/config.fish"
            echo '# Homebrew' >> "$HOME/.config/fish/config.fish"
            echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> "$HOME/.config/fish/config.fish"
            log_info "Added Homebrew to fish config"
        fi
    fi

    # Add mise activation to fish config if not already present
    if [[ -f "$HOME/.config/fish/config.fish" ]]; then
        if ! grep -q "mise activate fish" "$HOME/.config/fish/config.fish" 2>/dev/null; then
            echo '' >> "$HOME/.config/fish/config.fish"
            echo '# mise (isolated data directory for OrbStack)' >> "$HOME/.config/fish/config.fish"
            echo 'set -gx MISE_DATA_DIR "/tmp/mise-local"' >> "$HOME/.config/fish/config.fish"
            echo '~/.local/bin/mise activate fish | source' >> "$HOME/.config/fish/config.fish"
            log_info "Added mise activation to fish config"
        fi
    fi

    # Add TMPDIR to fish config if not already present (avoids EXDEV errors)
    if [[ -f "$HOME/.config/fish/config.fish" ]]; then
        if ! grep -q "TMPDIR" "$HOME/.config/fish/config.fish" 2>/dev/null; then
            echo '' >> "$HOME/.config/fish/config.fish"
            echo '# TMPDIR for cross-device link fix (OrbStack)' >> "$HOME/.config/fish/config.fish"
            echo 'set -gx TMPDIR "$HOME/.tmp"' >> "$HOME/.config/fish/config.fish"
            log_info "Added TMPDIR to fish config"
        fi
    fi

    log_success "Shell configuration updated"

    # Set fish as default shell
    log_info "Setting fish as default shell..."
    if [[ "$SHELL" != *"fish"* ]]; then
        if command_exists chsh; then
            sudo chsh -s /usr/bin/fish "$USER" 2>/dev/null || \
            sudo chsh -s /usr/local/bin/fish "$USER" 2>/dev/null || \
            log_warning "Could not set fish as default shell. Run 'chsh -s /usr/bin/fish' manually."
        else
            log_warning "chsh not available. Run 'chsh -s /usr/bin/fish' manually."
        fi
    else
        log_info "fish is already the default shell"
    fi
}

# Install tiny-nvim
install_nvim() {
    local nvim_config_dir="$HOME/.config/nvim"

    if [[ -d "$nvim_config_dir" ]]; then
        log_info "tiny-nvim config already exists at $nvim_config_dir"
    else
        log_info "Cloning tiny-nvim..."
        git clone https://github.com/jellydn/tiny-nvim.git "$nvim_config_dir"
    fi

    # Install neovim via mise if not found
    if ! command_exists nvim; then
        log_info "Installing node.js first (required for mise package resolution)..."

        # Use isolated mise data directory to avoid macOS config conflicts
        export MISE_DATA_DIR="/tmp/mise-local"
        export MISE_CONFIG_DIR="/tmp/mise-config"
        mkdir -p "$MISE_DATA_DIR" "$MISE_CONFIG_DIR"

        # Create minimal config
        cat > "$MISE_CONFIG_DIR/config.toml" << 'EOF'
[settings]
auto_install = true
EOF

        # Install node and neovim to isolated location using env vars
        MISE_DATA_DIR="$MISE_DATA_DIR" MISE_CONFIG_DIR="$MISE_CONFIG_DIR" ~/.local/bin/mise install node@latest
        MISE_DATA_DIR="$MISE_DATA_DIR" MISE_CONFIG_DIR="$MISE_CONFIG_DIR" ~/.local/bin/mise install neovim@nightly

        # Find and add neovim to PATH
        NVIM_BIN=$(find "$MISE_DATA_DIR/tools/neovim" -name nvim -type f 2>/dev/null | head -1)
        if [[ -n "$NVIM_BIN" ]]; then
            export PATH="$(dirname "$NVIM_BIN"):$HOME/.local/bin"
            log_info "nvim installed at: $NVIM_BIN"
        else
            log_warning "Could not find neovim binary after installation"
        fi
    else
        log_info "nvim is already installed ($(nvim --version | head -n1))"
    fi

    # Install plugins using lazy.nvim
    if command_exists nvim; then
        log_info "Installing Neovim plugins..."
        NVIM_APPNAME=nvim nvim --headless -c "Lazy install" -c "qa" 2>/dev/null || true
    else
        log_warning "nvim not found, skipping plugin installation"
    fi

    log_success "tiny-nvim installed successfully"
}

# Main function
main() {
    log_info "Setting up OrbStack Ubuntu machine..."
    log_info "========================================"

    configure_tmpdir
    install_base_deps
    install_homebrew
    install_mise
    install_fish
    install_nvim

    log_info "========================================"
    log_success "Setup complete!"
    log_info ""
    log_info "To start using fish with your new configuration:"
    log_info "  fish"
    log_info ""
    log_info "To verify installations:"
    log_info "  brew --version"
    log_info "  mise --version"
    log_info "  fish --version"
    log_info "  nvim --version"
}

# Run main function
main "$@"
