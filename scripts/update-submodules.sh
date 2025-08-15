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

# Update git submodules
update_submodules() {
    local dotfiles_dir
    dotfiles_dir="$(dirname "$0")/.."
    
    cd "$dotfiles_dir"
    
    if [[ ! -f ".gitmodules" ]]; then
        log_warning "No .gitmodules file found in $(pwd)"
        log_info "No git submodules to update"
        return 0
    fi
    
    log_info "Updating git submodules..."
    
    # Initialize submodules if they haven't been initialized yet
    log_info "Initializing submodules..."
    git submodule init
    
    # Update all submodules to their latest commits
    log_info "Updating submodules to latest commits..."
    git submodule update --remote --recursive
    
    # Show submodule status
    log_info "Current submodule status:"
    git submodule status --recursive
    
    log_success "Git submodules updated successfully!"
}

# Update specific submodule
update_specific_submodule() {
    local submodule_path="$1"
    local dotfiles_dir
    dotfiles_dir="$(dirname "$0")/.."
    
    cd "$dotfiles_dir"
    
    if [[ ! -d "$submodule_path" ]]; then
        log_error "Submodule path '$submodule_path' does not exist"
        return 1
    fi
    
    log_info "Updating submodule: $submodule_path"
    
    git submodule update --remote "$submodule_path"
    
    log_success "Submodule '$submodule_path' updated successfully!"
}

# List all submodules
list_submodules() {
    local dotfiles_dir
    dotfiles_dir="$(dirname "$0")/.."
    
    cd "$dotfiles_dir"
    
    if [[ ! -f ".gitmodules" ]]; then
        log_info "No git submodules configured"
        return 0
    fi
    
    log_info "Configured submodules:"
    git submodule status --recursive
    
    echo ""
    log_info "Submodule details:"
    git config --file .gitmodules --get-regexp '^submodule\..*\.(path|url)$' | \
    sed 's/^submodule\.//' | \
    sed 's/\.path / -> /' | \
    sed 's/\.url / @ /'
}

# Show usage
show_usage() {
    echo "Usage: $0 [update|list|update-specific <path>]"
    echo ""
    echo "Commands:"
    echo "  update              - Update all git submodules (default)"
    echo "  list                - List all configured submodules"
    echo "  update-specific     - Update a specific submodule"
    echo ""
    echo "Examples:"
    echo "  $0                              # Update all submodules"
    echo "  $0 update                       # Update all submodules"
    echo "  $0 list                         # List all submodules"
    echo "  $0 update-specific nvim         # Update only nvim submodule"
}

# Main function
main() {
    local command="${1:-update}"
    
    case "$command" in
        update)
            update_submodules
            ;;
        list)
            list_submodules
            ;;
        update-specific)
            if [[ $# -lt 2 ]]; then
                log_error "Missing submodule path"
                show_usage
                exit 1
            fi
            update_specific_submodule "$2"
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