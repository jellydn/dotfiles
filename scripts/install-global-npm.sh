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

# Check if npm is available
check_npm() {
    if ! command -v npm >/dev/null 2>&1; then
        log_error "npm is not installed. Please install Node.js first."
        exit 1
    fi
    log_info "Using npm $(npm --version)"
}

# Install a single package with specific version
install_package() {
    local package="$1"
    local version="$2"
    
    log_info "Installing ${package}@${version}..."
    
    if npm install -g "${package}@${version}" 2>/dev/null; then
        log_success "✓ ${package}@${version} installed"
        return 0
    else
        log_warning "✗ Failed to install ${package}@${version}"
        return 1
    fi
}

# Main installation function
main() {
    log_info "Installing global npm packages..."
    check_npm

    # Define packages as "name:version" pairs to avoid @ symbol issues
    local packages=(
        "@antfu/ni:30.0.0"
        "@fsouza/prettierd:0.27.0"
        "@github/copilot:1.0.32"
        "@google/gemini-cli:0.38.2"
        "@kaitranntt/ccs:7.72.1"
        "@kilocode/cli:7.2.14"
        "@mariozechner/pi-coding-agent:0.67.68"
        "@mermaid-js/mermaid-cli:11.12.0"
        "@openai/codex:0.121.0"
        "@plannotator/pi-extension:0.17.10"
        "@tailwindcss/language-server:0.14.29"
        "@vtsls/language-server:0.3.0"
        "agent-browser:0.26.0"
        "basedpyright:1.39.2"
        "corepack:0.34.7"
        "cspell:10.0.0"
        "eas-cli:18.7.0"
        "eslint_d:15.0.2"
        "generate-license:1.0.0"
        "generate:0.14.0"
        "npm-check-updates:21.0.2"
        "npm:11.12.1"
        "openclaw:2026.4.15"
        "oxfmt:0.45.0"
        "oxlint:1.60.0"
        "pi-annotate:0.4.1"
        "pi-hooks:1.0.4"
        "pi-subagents:0.17.0"
        "pnpm:10.33.0"
        "prettier:3.8.3"
        "rustywind:0.24.3"
        "typescript-language-server:5.1.3"
        "typescript:6.0.3"
        "vscode-langservers-extracted:4.10.0"
    )

    local total=${#packages[@]}
    local installed=0
    local failed=0

    log_info "Found $total packages to install"
    echo

    for pkg in "${packages[@]}"; do
        # Split package:name into parts
        local name="${pkg%%:*}"
        local version="${pkg##*:}"
        
        if install_package "$name" "$version"; then
            ((installed++))
        else
            ((failed++))
        fi
    done

    echo
    log_success "Installation complete!"
    log_info "Installed: $installed / $total"
    
    if [[ $failed -gt 0 ]]; then
        log_warning "Failed: $failed packages"
    fi

    # Show npm list of global packages
    echo
    log_info "Current global packages:"
    npm list -g --depth=0 2>/dev/null || true
}

# Run main
main "$@"
