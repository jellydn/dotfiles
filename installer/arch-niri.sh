#!/bin/bash
# Arch Linux + Niri Automated Installer
# Installs and configures Niri window manager with all dependencies

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() { echo -e "${BLUE}ℹ${NC} $1"; }
log_success() { echo -e "${GREEN}✓${NC} $1"; }
log_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
log_error() { echo -e "${RED}✗${NC} $1"; }

check_root() {
    if [[ $EUID -eq 0 ]]; then
        log_error "This script should NOT be run as root"
        log_info "Run as normal user. It will request sudo when needed"
        exit 1
    fi
}

check_arch() {
    if [[ ! -f /etc/arch-release ]]; then
        log_error "This script is designed for Arch Linux"
        exit 1
    fi
}

install_aur_helper() {
    log_info "Checking AUR helper..."

    # Check if yay or paru is already installed
    if command -v yay &> /dev/null; then
        log_success "yay is already installed"
        AUR_HELPER="yay"
        return 0
    elif command -v paru &> /dev/null; then
        log_success "paru is already installed"
        AUR_HELPER="paru"
        return 0
    fi

    log_info "Installing yay AUR helper..."

    # Install dependencies for building AUR packages
    log_info "Installing build dependencies (base-devel, git)..."
    sudo pacman -S --needed --noconfirm base-devel git

    # Save current directory
    local ORIGINAL_DIR=$(pwd)
    local TEMP_DIR=$(mktemp -d)

    # Clone and build yay
    log_info "Cloning yay from AUR..."
    if ! git clone https://aur.archlinux.org/yay.git "$TEMP_DIR/yay"; then
        log_error "Failed to clone yay repository"
        rm -rf "$TEMP_DIR"
        exit 1
    fi

    cd "$TEMP_DIR/yay"
    log_info "Building yay..."
    if ! makepkg -si --noconfirm; then
        log_error "Failed to build yay"
        cd "$ORIGINAL_DIR"
        rm -rf "$TEMP_DIR"
        exit 1
    fi

    # Return to original directory and cleanup
    cd "$ORIGINAL_DIR"
    rm -rf "$TEMP_DIR"

    # Verify installation
    if ! command -v yay &> /dev/null; then
        log_error "yay installation failed"
        exit 1
    fi

    AUR_HELPER="yay"
    log_success "yay installed successfully"

    # Configure yay for better defaults
    log_info "Configuring yay..."
    yay --save --answerclean All --answerdiff None --removemake
    log_success "yay configured"
}

install_packages() {
    log_info "Installing packages..."

    # Core system packages (official repos)
    local CORE_PACKAGES=(
        # Session and authentication
        greetd
        greetd-agreety
        polkit-gnome
        gnome-keyring

        # Terminal emulators
        foot
        alacritty

        # Application launcher (Niri default)
        fuzzel

        # Status bar
        waybar

        # Audio
        pipewire
        pipewire-pulse
        pipewire-alsa
        wireplumber
        # Sound mixer
        pavucontrol

        # Brightness control
        brightnessctl

        # Screen locker
        swaylock

        # Idle management
        swayidle

        # Logout menu
        # wlogout

        # Notifications
        mako
        dunst

        # Screen sharing support and desktop integration
        xdg-desktop-portal
        xdg-desktop-portal-gtk
        xdg-desktop-portal-gnome
        xdg-utils

        # File managers
        thunar
        nautilus

        # Fonts
        ttf-jetbrains-mono-nerd
        otf-font-awesome

        # Screenshot and clipboard tools
        grim
        slurp
        wl-clipboard
        wtype        # Wayland input emulation for universal copy/paste
        jq           # JSON parsing for niri window info
        swaybg

        # System information
        btop
        fastfetch

        # Network
        networkmanager
        nm-connection-editor

        # Bluetooth
        bluez
    )

    # AUR packages
    local AUR_PACKAGES=(
        # Niri window manager
        niri

        # Wallpaper daemon
        swww

        # X11 app support for Wayland
        xwayland-satellite
    )

    # Optional AUR packages
    local OPTIONAL_AUR_PACKAGES=(
        # Better greeter (alternative to agreety)
        greetd-tuigreet
    )

    # Optional but recommended packages
    local OPTIONAL_PACKAGES=(
        # Browser
        firefox

        # System monitor
        htop

        # Archive support
        file-roller
        xarchiver

        # Image viewer
        imv
        ristretto

        # PDF viewer
        zathura
        zathura-pdf-mupdf

        # Media player
        mpv

    )

    log_info "Installing core packages..."
    sudo pacman -S --needed --noconfirm "${CORE_PACKAGES[@]}"
    log_success "Core packages installed"

    log_info "Installing optional packages (failures will be skipped)..."
    for pkg in "${OPTIONAL_PACKAGES[@]}"; do
        if ! sudo pacman -S --needed --noconfirm "$pkg" 2>/dev/null; then
            log_warning "Optional package $pkg not available, skipping"
        fi
    done
    log_success "Optional packages processed"

    # Install AUR helper first
    install_aur_helper
    echo ""

    # Install AUR packages
    log_info "Installing AUR packages..."
    $AUR_HELPER -S --needed --noconfirm "${AUR_PACKAGES[@]}"
    log_success "AUR packages installed"

    log_info "Installing optional AUR packages (failures will be skipped)..."
    for pkg in "${OPTIONAL_AUR_PACKAGES[@]}"; do
        if ! $AUR_HELPER -S --needed --noconfirm "$pkg" 2>/dev/null; then
            log_warning "Optional AUR package $pkg not available, skipping"
        fi
    done
    log_success "Optional AUR packages processed"
}

enable_services() {
    log_info "Enabling system services..."

    # Enable greetd (display manager)
    sudo systemctl enable greetd.service
    log_success "Enabled greetd service"

    # Enable NetworkManager
    sudo systemctl enable NetworkManager.service
    log_success "Enabled NetworkManager"

    # Enable Bluetooth
    sudo systemctl enable bluetooth.service
    log_success "Enabled Bluetooth"
}

deploy_configs() {
    log_info "Deploying configuration files..."

    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

    # Check if dotfiles exist
    if [[ ! -d "$DOTFILES_DIR/linux/.config/niri" ]]; then
        log_error "Niri configuration not found in $DOTFILES_DIR/linux/.config/niri"
        log_info "Please run this script from the dotfiles repository"
        exit 1
    fi

    # Deploy greetd config
    if [[ -f "$DOTFILES_DIR/linux/etc/greetd/config.toml" ]]; then
        log_info "Deploying greetd configuration..."
        sudo mkdir -p /etc/greetd
        sudo cp "$DOTFILES_DIR/linux/etc/greetd/config.toml" /etc/greetd/config.toml
        log_success "Greetd configuration deployed"
    fi

    # Create necessary directories
    mkdir -p ~/.config
    mkdir -p ~/Pictures/Screenshots

    # Use stow to deploy configurations
    if command -v stow &> /dev/null; then
        log_info "Using stow to deploy dotfiles..."
        cd "$DOTFILES_DIR"

        # Stow common configs
        if [[ -d "$DOTFILES_DIR/common" ]]; then
            stow -t ~ common 2>/dev/null || log_warning "Some common configs already exist"
            log_success "Common configs deployed"
        fi

        # Stow linux-specific configs
        if [[ -d "$DOTFILES_DIR/linux" ]]; then
            stow -t ~ linux 2>/dev/null || log_warning "Some linux configs already exist"
            log_success "Linux configs deployed"
        fi
    else
        log_warning "stow not found, manually copying configs..."

        # Manual copy fallback
        cp -r "$DOTFILES_DIR/linux/.config/"* ~/.config/ 2>/dev/null || true

        if [[ -d "$DOTFILES_DIR/common/.config" ]]; then
            cp -r "$DOTFILES_DIR/common/.config/"* ~/.config/ 2>/dev/null || true
        fi

        log_success "Configurations copied manually"
    fi
}

setup_systemd_user_services() {
    log_info "Setting up systemd user services..."

    # Enable waybar service
    if [[ -f ~/.config/systemd/user/waybar.service ]]; then
        systemctl --user enable waybar.service
        log_success "Enabled waybar service"
    fi

    # Enable wallpaper service
    if [[ -f ~/.config/systemd/user/wallpaper.service ]]; then
        systemctl --user enable wallpaper.service
        log_success "Enabled wallpaper service"
    fi

    # Enable swayidle service
    if [[ -f ~/.config/systemd/user/swayidle.service ]]; then
        systemctl --user enable swayidle.service
        log_success "Enabled swayidle service"
    fi

    log_success "User services configured"
}

setup_vm_compatibility() {
    log_info "Checking VM compatibility..."

    # Check if running in a VM
    if systemd-detect-virt &> /dev/null; then
        VIRT_TYPE=$(systemd-detect-virt)
        log_warning "Running in virtual environment: $VIRT_TYPE"

        if [[ -f "$SCRIPT_DIR/../scripts/fix-niri-vm-graphics.sh" ]]; then
            log_info "VM graphics fix script available at scripts/fix-niri-vm-graphics.sh"
            log_info "Run it if you encounter display issues after installation"
        fi
    else
        log_success "Not running in VM, no special configuration needed"
    fi
}

post_install_info() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log_success "Niri installation completed!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "📋 Next Steps:"
    echo ""
    echo "  1. Reboot your system:"
    echo "     sudo reboot"
    echo ""
    echo "  2. At login screen, select niri-session"
    echo ""
    echo "  3. Essential keybindings (Super = Windows key):"
    echo "     Super+Return       → Open terminal (alacritty/foot)"
    echo "     Super+d            → Application launcher (fuzzel)"
    echo "     Super+e            → File manager (thunar)"
    echo "     Super+b            → Browser (firefox)"
    echo "     Super+Shift+q      → Close window"
    echo "     Super+Shift+e      → Exit Niri"
    echo "     Super+Shift+Delete → Lock screen"
    echo ""
    echo "  4. Window navigation:"
    echo "     Super+h/j/k/l      → Focus left/down/up/right"
    echo "     Super+1-9          → Switch to workspace"
    echo "     Super+Shift+1-9    → Move window to workspace"
    echo ""
    echo "  5. Screenshots:"
    echo "     Super+Shift+s      → Selection (save)"
    echo "     Super+Ctrl+s       → Selection (clipboard)"
    echo ""
    echo "🔧 Configuration:"
    echo "     ~/.config/niri/config.kdl    → Niri configuration"
    echo "     ~/.config/waybar/            → Status bar config"
    echo "     ~/.config/alacritty/         → Terminal config"
    echo "     ~/.config/foot/              → Alternative terminal"
    echo ""
    echo "📚 Resources:"
    echo "     Niri docs: https://yalter.github.io/niri/"
    echo "     Niri wiki: https://wiki.archlinux.org/title/Niri"
    echo "     Run 'niri msg --help' for IPC commands"
    echo ""
    echo "ℹ️  X11 App Support:"
    echo "     xwayland-satellite installed for X11 app compatibility"
    echo "     Most apps should work natively on Wayland"
    echo ""
    echo "🐛 Troubleshooting:"
    echo "     scripts/niri-status.sh       → Check Niri status"
    echo "     scripts/niri-health-check.sh → Comprehensive diagnostics"
    echo "     scripts/fix-niri-vm-graphics.sh → Fix VM display issues"
    echo ""
}

main() {
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Arch Linux + Niri + XFCE4 Automated Installer"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    check_root
    check_arch

    log_info "Starting installation..."
    echo ""

    # Update system
    log_info "Updating system packages..."
    sudo pacman -Syu --noconfirm
    log_success "System updated"
    echo ""

    # Install packages
    install_packages
    echo ""

    # Enable system services
    enable_services
    echo ""

    # Deploy configurations
    deploy_configs
    echo ""

    # Setup user services
    setup_systemd_user_services
    echo ""

    # Check VM compatibility
    setup_vm_compatibility
    echo ""

    # Show post-install information
    post_install_info
}

main "$@"
