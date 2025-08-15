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

log_info "Mise Cleanup Utility"
echo ""

# Show current mise status
log_info "Current mise installations:"
mise ls
echo ""

# Show duplicates
log_info "Looking for duplicate tools..."
duplicates=$(mise ls | awk 'NF>=2 {print $1}' | sort | uniq -d)

if [[ -n "$duplicates" ]]; then
    log_warning "Found tools with multiple versions:"
    for tool in $duplicates; do
        echo "  - $tool"
        mise ls | grep "^$tool " | sed 's/^/    /'
    done
    echo ""
else
    log_success "No duplicate tools found"
fi

# Prune unused versions
log_info "Pruning unused tool versions..."
if mise prune -y; then
    log_success "Pruned unused versions successfully"
else
    log_warning "No unused versions to prune"
fi

echo ""

# Show final status
log_info "Final mise status:"
mise ls

echo ""
log_info "Cleanup completed!"
log_info "Use 'mise use -g tool@version' to install specific versions"
log_info "Use 'mise uninstall tool@version' to remove specific versions"