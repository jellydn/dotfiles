#!/usr/bin/env bash
# New Apple Silicon Mac: install mise (not Homebrew), link this repo's mise
# config, then `mise bootstrap` for packages, dotfiles, login shell, and tools.
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

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES="$(cd "$SCRIPT_DIR/.." && pwd)"
MISE_SRC="$DOTFILES/common/.config/mise"
MISE_DEST="${XDG_CONFIG_HOME:-$HOME/.config}/mise"
DRY_RUN=false
YES=false

usage() {
    cat <<EOF
Usage: $(basename "$0") [--dry-run] [--yes]

Apple Silicon Mac setup without installing the Homebrew CLI.
mise pours brew formulae/casks into /opt/homebrew itself.

  --dry-run   Print setup steps without changing the host
  --yes       Skip mise confirmation prompts
  -h, --help  Show this help

Typical new machine:

  git clone https://github.com/jellydn/dotfiles.git ~/.dotfiles
  ~/.dotfiles/scripts/bootstrap-mac.sh --dry-run
  ~/.dotfiles/scripts/bootstrap-mac.sh
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run|-n) DRY_RUN=true; shift ;;
        --yes|-y) YES=true; shift ;;
        -h|--help) usage; exit 0 ;;
        *)
            log_error "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

if [[ "$(uname -s)" != "Darwin" ]]; then
    log_error "This script is macOS-only. On Linux use ./install.sh all"
    exit 1
fi

if [[ "$(uname -m)" != "arm64" ]]; then
    log_error "mise's brew manager supports Apple Silicon only (this host is $(uname -m))"
    exit 1
fi

if [[ ! -f "$MISE_SRC/config.toml" ]]; then
    log_error "mise config not found at $MISE_SRC/config.toml"
    exit 1
fi

if [[ -e "$MISE_DEST" || -L "$MISE_DEST" ]]; then
    dest_resolved="$(cd "$MISE_DEST" 2>/dev/null && pwd -P)" || dest_resolved=""
    src_resolved="$(cd "$MISE_SRC" && pwd -P)"
    if [[ "$dest_resolved" != "$src_resolved" ]]; then
        log_error "$MISE_DEST is not this repo's mise config. Back it up, merge any settings into this repo's config.local.toml, then move the old destination aside and retry."
        exit 1
    fi
fi

if [[ "$DRY_RUN" == true ]]; then
    log_info "Would check Xcode Command Line Tools and install verified mise v2026.9.7 if missing."
    log_info "Would link $MISE_DEST -> $MISE_SRC and trust this repo's config."
    log_info "Would update submodules, then run mise bootstrap (packages, dotfiles, login shell, tools, extras)."
    log_info "No changes made. After setup, use mise bootstrap --dry-run for a detailed plan."
    exit 0
fi

if ! xcode-select -p >/dev/null 2>&1; then
    log_warning "Xcode Command Line Tools are missing. Starting the installer..."
    xcode-select --install
    log_error "Re-run this script after the Command Line Tools finish installing."
    exit 1
fi

export PATH="$HOME/.local/bin:/opt/homebrew/bin:${PATH:-}"

if ! command -v mise >/dev/null 2>&1; then
    log_info "Installing verified mise v2026.9.7 (not Homebrew)..."
    tmp="$(mktemp -d "${TMPDIR:-/tmp}/mise.XXXXXX")"
    trap 'rm -rf "$tmp"' EXIT
    curl -fsSL https://github.com/jdx/mise/releases/download/v2026.9.7/mise-v2026.9.7-macos-arm64 -o "$tmp/mise"
    # Digest from the versioned upstream GitHub release asset.
    (cd "$tmp" && echo '3c3f377e7123a466274a20f01502ddd8c58f76028907f471c9bc42fbf83846e1  mise' | shasum -a 256 -c -)
    mkdir -p "$HOME/.local/bin"
    install -m 0755 "$tmp/mise" "$HOME/.local/bin/mise"
fi

if ! command -v mise >/dev/null 2>&1; then
    log_error "mise not on PATH. Add ~/.local/bin and retry."
    exit 1
fi

log_info "mise $(mise --version)"

mkdir -p "$(dirname "$MISE_DEST")"
if [[ ! -e "$MISE_DEST" ]]; then
    log_info "Linking $MISE_DEST -> $MISE_SRC"
    ln -s "$MISE_SRC" "$MISE_DEST"
fi

# Select this configuration even when invoked from another mise project.
export MISE_CONFIG_DIR="$MISE_DEST"
export MISE_ENV=macos
mise trust "$MISE_DEST/config.toml"
mise trust "$MISE_DEST/config.macos.toml"

# The Neovim source must exist before mise creates its dotfile link.
log_info "Updating git submodules..."
git -C "$DOTFILES" submodule update --init --recursive

bootstrap_args=()
if [[ "$YES" == true ]]; then
    bootstrap_args+=(--yes)
    log_info "Applying: mise bootstrap --yes"
else
    log_info "Applying: mise bootstrap"
fi

mise -C "$HOME" bootstrap "${bootstrap_args[@]+"${bootstrap_args[@]}"}"

log_success "Mac bootstrap complete"
log_info "Open a new shell. Then: mise bootstrap status"
log_info "Host binaries live in /opt/homebrew/bin (no brew CLI required)."
