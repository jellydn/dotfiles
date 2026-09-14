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

  --dry-run   Preview mise bootstrap without applying
  --yes       Skip mise confirmation prompts
  -h, --help  Show this help

Typical new machine:

  curl https://mise.run | sh
  export PATH="\$HOME/.local/bin:\$PATH"
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

if ! xcode-select -p >/dev/null 2>&1; then
    log_warning "Xcode Command Line Tools are missing. Starting the installer..."
    xcode-select --install
    log_error "Re-run this script after the Command Line Tools finish installing."
    exit 1
fi

export PATH="$HOME/.local/bin:/opt/homebrew/bin:${PATH:-}"

if ! command -v mise >/dev/null 2>&1; then
    log_info "Installing mise via https://mise.run (not Homebrew)..."
    curl -fsSL https://mise.run | sh
    export PATH="$HOME/.local/bin:$PATH"
fi

if ! command -v mise >/dev/null 2>&1; then
    log_error "mise not on PATH. Add ~/.local/bin and retry."
    exit 1
fi

log_info "mise $(mise --version)"

if [[ ! -f "$MISE_SRC/config.toml" ]]; then
    log_error "mise config not found at $MISE_SRC/config.toml"
    exit 1
fi

mkdir -p "$(dirname "$MISE_DEST")"

if [[ -L "$MISE_DEST" || -d "$MISE_DEST" ]]; then
    dest_resolved="$(cd "$MISE_DEST" 2>/dev/null && pwd -P || true)"
    src_resolved="$(cd "$MISE_SRC" && pwd -P)"
    if [[ -n "$dest_resolved" && "$dest_resolved" == "$src_resolved" ]]; then
        log_info "mise config already linked: $MISE_DEST"
    elif [[ -f "$MISE_DEST/config.toml" ]]; then
        log_info "Using existing mise config directory at $MISE_DEST"
    else
        log_error "$MISE_DEST exists and is not this repo's mise config. Move it aside and retry."
        exit 1
    fi
else
    if [[ -e "$MISE_DEST" ]]; then
        log_error "$MISE_DEST exists and is not a mise config. Move it aside and retry."
        exit 1
    fi
    log_info "Linking $MISE_DEST -> $MISE_SRC"
    ln -sfn "$MISE_SRC" "$MISE_DEST"
fi

if [[ -f "$MISE_DEST/config.toml" ]]; then
    mise trust "$MISE_DEST/config.toml" >/dev/null 2>&1 || true
fi

bootstrap_args=()
if [[ "$DRY_RUN" == true ]]; then
    bootstrap_args+=(--dry-run)
    log_info "Dry run: mise bootstrap --dry-run"
elif [[ "$YES" == true ]]; then
    bootstrap_args+=(--yes)
    log_info "Applying: mise bootstrap --yes"
else
    log_info "Applying: mise bootstrap"
fi

mise bootstrap "${bootstrap_args[@]+"${bootstrap_args[@]}"}"

if [[ "$DRY_RUN" != true ]]; then
    log_info "Updating git submodules..."
    git -C "$DOTFILES" submodule update --init --recursive
    log_success "Mac bootstrap complete"
    log_info "Open a new shell. Then: mise bootstrap status"
    log_info "Host binaries live in /opt/homebrew/bin (no brew CLI required)."
else
    log_info "Dry run finished. Re-run without --dry-run to apply."
fi
