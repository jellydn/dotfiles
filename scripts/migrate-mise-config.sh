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

# Check if mise is available
if ! command -v mise >/dev/null 2>&1; then
    log_error "mise is not installed or not in PATH"
    exit 1
fi

log_info "Migrating from mise config.toml to .tool-versions approach"
echo ""

# Check for existing config.toml
config_file="$HOME/.config/mise/config.toml"
if [[ ! -f "$config_file" ]]; then
    log_info "No config.toml found at $config_file"
    log_info "Using .tool-versions from dotfiles repository"
    exit 0
fi

# Backup the existing config
backup_file="$HOME/.config/mise/config.toml.backup-$(date +%Y%m%d-%H%M%S)"
log_info "Backing up existing config.toml to: $backup_file"
cp "$config_file" "$backup_file"

# Remove the old config to let .tool-versions take precedence
log_info "Removing config.toml to use .tool-versions from dotfiles..."
rm "$config_file"

# Reinstall tools using .tool-versions
log_info "Installing tools from .tool-versions..."
cd "$(dirname "$0")/.."

if [[ -f ".tool-versions" ]]; then
    # Install each tool from .tool-versions
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
            if mise use -g "$tool@$version"; then
                log_success "✓ $tool@$version installed"
            else
                log_warning "✗ Failed to install $tool@$version"
            fi
        fi
    done < .tool-versions
    
    # Clean up old versions
    log_info "Cleaning up unused tool versions..."
    mise prune -y 2>/dev/null || log_info "No unused versions to prune"
    
    echo ""
    log_success "Migration completed!"
    echo ""
    log_info "Updated tool versions:"
    mise ls
    
    echo ""
    log_info "Config backed up to: $backup_file"
    log_info "Tools are now managed by .tool-versions in your dotfiles"
    
else
    log_error ".tool-versions file not found in dotfiles directory"
    log_info "Restoring config.toml backup..."
    cp "$backup_file" "$config_file"
    exit 1
fi