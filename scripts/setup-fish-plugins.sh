#!/bin/bash
# Simple fish plugins setup - installs Fisher and 3 plugins
# Run this after stowing fish config

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check if fish is installed
if ! command -v fish >/dev/null 2>&1; then
    log_error "Fish shell not found. Please install fish first."
    exit 1
fi

log_info "Installing Fisher and Fish plugins..."

# Install Fisher and the 3 plugins in one go
fish -c "
# Install Fisher
curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source
fisher install jorgebucaran/fisher

# Install the 3 plugins
fisher install pure-fish/pure
fisher install jhillyerd/plugin-git
" || {
    log_error "Failed to install Fisher or plugins"
    exit 1
}

log_success "Fisher and plugins installed successfully!"
log_info "Installed plugins: Fisher, Pure theme, Git plugin"
log_info "Restart your shell or run 'exec fish' to see changes"