#!/usr/bin/env bash
# Install the editor extensions that the checked-in VS Code and Cursor settings
# assume.
#
# The ID lists live next to the config they describe, mirroring
# jellydn/vscode-like-pro (the upstream source of truth for that config):
#
#   common/.config/Code/extensions.txt
#   common/.config/Code/extensions-vscode-marketplace.txt
#
# VS Code uses the Microsoft Marketplace, so it installs both lists. Cursor and
# other Open VSX editors install extensions.txt only: the names in the
# marketplace list are deliberately absent from Open VSX.
#
# Usage: scripts/install-editor-extensions.sh [--force]
#   --force reinstalls and updates everything instead of skipping what is there.
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
list_dir="$script_dir/../common/.config/Code"

force=false
case "${1:-}" in
    "") ;;
    --force) force=true ;;
    *)
        echo "Usage: $0 [--force]" >&2
        exit 2
        ;;
esac

list_ids() {
    # Comments and blank lines are not extension IDs. A missing list is not an
    # error so that an older checkout still works.
    if [[ -f "$1" ]]; then
        grep -vE '^[[:space:]]*(#|$)' "$1" || true
    fi
}

install_extensions() {
    local cli="$1"
    local label="$2"
    shift 2

    if ! command -v "$cli" >/dev/null 2>&1; then
        log_warning "$label is not installed, skipping"
        return 0
    fi

    local present
    present="$("$cli" --list-extensions 2>/dev/null || true)"

    local list id
    local total=0 skipped=0 installed=0 failed=0
    for list in "$@"; do
        while read -r id; do
            [[ -n "$id" ]] || continue
            total=$((total + 1))

            # --list-extensions prints lower case, the lists use upstream case.
            if [[ "$force" == false ]] && grep -qix "$id" <<<"$present"; then
                skipped=$((skipped + 1))
                continue
            fi

            if "$cli" --install-extension "$id" --force >/dev/null 2>&1; then
                log_success "$label: $id"
                installed=$((installed + 1))
            else
                log_warning "$label: could not install $id"
                failed=$((failed + 1))
            fi
        done < <(list_ids "$list")
    done

    log_info "$label: $installed installed, $skipped already present, $failed failed (of $total)"

    if [[ $failed -gt 0 ]]; then
        return 1
    fi
    return 0
}

main() {
    local failures=0

    install_extensions code "VS Code" \
        "$list_dir/extensions.txt" \
        "$list_dir/extensions-vscode-marketplace.txt" || failures=$((failures + 1))

    if command -v cursor >/dev/null 2>&1; then
        install_extensions cursor "Cursor" "$list_dir/extensions.txt" || failures=$((failures + 1))
    else
        log_info "Cursor is not installed, skipping (see scripts/cursor.sh)"
    fi

    if [[ $failures -gt 0 ]]; then
        log_warning "Some extensions could not be installed, see the warnings above"
        return 1
    fi
    log_success "Editor extensions are up to date"
}

main "$@"
