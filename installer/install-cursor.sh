#!/bin/bash
# Cursor Editor Installer for Arch Linux
# Installs Cursor from RPM package

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

find_rpm_file() {
    log_info "Looking for Cursor RPM file..."

    # Check in Downloads directory
    RPM_FILES=("$HOME"/Downloads/cursor-*.rpm)
    if [[ -f "${RPM_FILES[0]}" ]]; then
        RPM_FILE="${RPM_FILES[0]}"
        log_success "Found RPM file: $RPM_FILE"
        return 0
    fi

    # Check in current directory
    RPM_FILES=(cursor-*.rpm)
    if [[ -f "${RPM_FILES[0]}" ]]; then
        RPM_FILE="${RPM_FILES[0]}"
        log_success "Found RPM file: $RPM_FILE"
        return 0
    fi

    log_error "Cursor RPM file not found"
    log_info "Please download it from: https://cursor.com/download"
    log_info "Expected file name: cursor-*.rpm"
    exit 1
}

check_dependencies() {
    log_info "Checking dependencies..."

    # Check if rpmextract is installed
    if ! command -v rpmextract.sh &> /dev/null; then
        log_info "Installing rpmextract..."
        sudo pacman -S --needed --noconfirm rpmextract
        log_success "rpmextract installed"
    else
        log_success "rpmextract already installed"
    fi
}

extract_rpm() {
    log_info "Extracting Cursor RPM..."

    # Create temporary directory
    TEMP_DIR=$(mktemp -d)
    log_info "Using temporary directory: $TEMP_DIR"

    # Extract RPM
    cd "$TEMP_DIR"
    rpmextract.sh "$RPM_FILE"

    if [[ ! -d "$TEMP_DIR/usr" ]]; then
        log_error "Extraction failed - usr directory not found"
        rm -rf "$TEMP_DIR"
        exit 1
    fi

    log_success "RPM extracted successfully"
}

install_cursor() {
    log_info "Installing Cursor to /opt/cursor..."

    # Remove old installation if exists
    if [[ -d /opt/cursor ]]; then
        log_warning "Removing old Cursor installation..."
        sudo rm -rf /opt/cursor
    fi

    # Create /opt/cursor and copy files
    sudo mkdir -p /opt/cursor
    sudo cp -r "$TEMP_DIR/usr/"* /opt/cursor/

    log_success "Cursor files installed to /opt/cursor"
}

create_symlink() {
    log_info "Creating symlink..."

    # Remove old symlink if exists
    if [[ -L /usr/local/bin/cursor ]]; then
        sudo rm /usr/local/bin/cursor
    fi

    # Create new symlink pointing to the actual wrapper script
    sudo ln -s /opt/cursor/share/cursor/bin/cursor /usr/local/bin/cursor

    log_success "Symlink created: /usr/local/bin/cursor"
}

create_desktop_entry() {
    log_info "Creating desktop entry..."

    # Create desktop entry for application launchers
    sudo tee /usr/share/applications/cursor.desktop > /dev/null <<EOF
[Desktop Entry]
Name=Cursor
Comment=AI-powered code editor
GenericName=Text Editor
Exec=/opt/cursor/share/cursor/bin/cursor %F
Icon=/opt/cursor/share/pixmaps/cursor.png
Type=Application
StartupNotify=true
StartupWMClass=Cursor
Categories=Development;IDE;
MimeType=text/plain;inode/directory;
Keywords=cursor;editor;ide;development;
EOF

    # Update desktop database
    if command -v update-desktop-database &> /dev/null; then
        sudo update-desktop-database /usr/share/applications
    fi

    log_success "Desktop entry created"
}

cleanup() {
    log_info "Cleaning up temporary files..."

    if [[ -n "$TEMP_DIR" && -d "$TEMP_DIR" ]]; then
        rm -rf "$TEMP_DIR"
        log_success "Cleanup complete"
    fi
}

verify_installation() {
    log_info "Verifying installation..."

    if command -v cursor &> /dev/null; then
        log_success "Cursor is installed and available in PATH"
        CURSOR_VERSION=$(cursor --version 2>&1 | head -1 || echo "Version info not available")
        log_info "Version: $CURSOR_VERSION"
    else
        log_error "Cursor command not found in PATH"
        exit 1
    fi
}

post_install_info() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log_success "Cursor installation completed!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "📋 How to launch Cursor:"
    echo ""
    echo "  1. From terminal:"
    echo "     cursor"
    echo ""
    echo "  2. From application launcher (Niri):"
    echo "     Super+d → type 'cursor'"
    echo ""
    echo "  3. Open a file or directory:"
    echo "     cursor /path/to/file"
    echo "     cursor /path/to/project"
    echo ""
    echo "🔧 Installation details:"
    echo "     Binary:       /opt/cursor/share/cursor/cursor"
    echo "     Wrapper:      /opt/cursor/share/cursor/bin/cursor"
    echo "     Symlink:      /usr/local/bin/cursor"
    echo "     Desktop file: /usr/share/applications/cursor.desktop"
    echo ""
    echo "ℹ️  Wayland Support:"
    echo "     Cursor will use Wayland natively thanks to"
    echo "     ELECTRON_OZONE_PLATFORM_HINT=auto in your niri config"
    echo ""
    echo "🐛 If you encounter keyboard issues:"
    echo "     See: https://github.com/YaLTeR/niri/wiki/Application-Issues#vscode"
    echo ""
}

main() {
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Cursor Editor Installer for Arch Linux"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    check_root
    find_rpm_file
    check_dependencies
    extract_rpm
    install_cursor
    create_symlink
    create_desktop_entry
    cleanup
    verify_installation
    post_install_info
}

main "$@"
