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

# Check if uv is available
check_uv() {
    if ! command -v uv >/dev/null 2>&1; then
        log_error "uv is not installed. Please install uv first: https://docs.astral.sh/uv/getting-started/installation/"
        exit 1
    fi
    log_info "Using uv $(uv --version)"
}

# Install a single uv tool
install_tool() {
    local tool="$1"
    
    log_info "Installing ${tool}..."
    
    if uv tool install "$tool" 2>/dev/null; then
        log_success "✓ ${tool} installed"
        return 0
    else
        log_warning "✗ Failed to install ${tool}"
        return 1
    fi
}

# Main installation function
main() {
    log_info "Installing uv tools..."
    check_uv

    # Define uv tools to install
    local tools=(
        "codespell"
        "isort"
        "openai"
        "pyright"
        "ruff"
        "specify-cli"
        "ty"
    )

    local total=${#tools[@]}
    local installed=0
    local failed=0

    log_info "Found $total tools to install"
    echo

    for tool in "${tools[@]}"; do
        if install_tool "$tool"; then
            ((installed++))
        else
            ((failed++))
        fi
    done

    echo
    log_success "Installation complete!"
    log_info "Installed: $installed / $total"
    
    if [[ $failed -gt 0 ]]; then
        log_warning "Failed: $failed tools"
    fi

    # Show uv tool list
    echo
    log_info "Current uv tools:"
    uv tool list 2>/dev/null || true
}

# Run main
main "$@"
