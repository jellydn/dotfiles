#!/usr/bin/env bash
# Clone or safely update this repository, then run its platform installer.
set -euo pipefail

REPO_URL="${DOTFILES_REPO_URL:-https://github.com/jellydn/dotfiles.git}"
BRANCH="${DOTFILES_BRANCH:-master}"
INSTALL_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"

log() {
    printf '[dotfiles] %s\n' "$*"
}

fail() {
    printf '[dotfiles] ERROR: %s\n' "$*" >&2
    exit 1
}

run_as_root() {
    if [[ ${EUID:-$(id -u)} -eq 0 ]]; then
        "$@"
    elif command -v sudo >/dev/null 2>&1; then
        sudo "$@"
    else
        fail "Installing git requires root access, but sudo is not available."
    fi
}

install_git() {
    case "$(uname -s)" in
        Darwin)
            command -v xcode-select >/dev/null 2>&1 || fail "Install the Xcode Command Line Tools, then retry."
            if ! xcode-select -p >/dev/null 2>&1; then
                log "Starting the Xcode Command Line Tools installer (includes git)..."
                xcode-select --install
                fail "Finish the Command Line Tools installation, then run this command again."
            fi
            ;;
        Linux)
            log "Installing required tool: git"
            if command -v apt-get >/dev/null 2>&1; then
                run_as_root apt-get update
                run_as_root apt-get install -y git
            elif command -v dnf >/dev/null 2>&1; then
                run_as_root dnf install -y git
            elif command -v yum >/dev/null 2>&1; then
                run_as_root yum install -y git
            elif command -v pacman >/dev/null 2>&1; then
                run_as_root pacman -S --needed --noconfirm git
            elif command -v zypper >/dev/null 2>&1; then
                run_as_root zypper --non-interactive install git
            elif command -v apk >/dev/null 2>&1; then
                run_as_root apk add git
            else
                fail "No supported package manager found. Install git, then retry."
            fi
            ;;
        *)
            fail "This installer supports macOS and Linux. On Windows 11, use bootstrap.ps1."
            ;;
    esac
    command -v git >/dev/null 2>&1 || fail "git installation finished, but git is not on PATH. Open a new shell and retry."
}

command -v git >/dev/null 2>&1 || install_git

if [[ -e "$INSTALL_DIR" || -L "$INSTALL_DIR" ]]; then
    [[ -d "$INSTALL_DIR/.git" ]] || fail "$INSTALL_DIR exists but is not a Git checkout. Move it aside or set DOTFILES_DIR."

    current_origin="$(git -C "$INSTALL_DIR" remote get-url origin 2>/dev/null)" || \
        fail "$INSTALL_DIR has no origin remote. Refusing to update it."
    [[ "${current_origin%.git}" == "${REPO_URL%.git}" ]] || \
        fail "$INSTALL_DIR origin is '$current_origin', not '$REPO_URL'. Refusing to update it."
    changes="$(git -C "$INSTALL_DIR" status --porcelain=v1 --untracked-files=all --ignore-submodules=none)" || \
        fail "Could not inspect $INSTALL_DIR."
    [[ -z "$changes" ]] || \
        fail "$INSTALL_DIR has local changes. Commit or stash them before retrying."

    log "Updating $INSTALL_DIR (fast-forward only)..."
    git -C "$INSTALL_DIR" fetch --quiet origin "$BRANCH"
    git -C "$INSTALL_DIR" merge-base --is-ancestor HEAD FETCH_HEAD || \
        fail "$INSTALL_DIR is ahead of or has diverged from '$BRANCH'. Refusing to change it."
    git -C "$INSTALL_DIR" merge --ff-only FETCH_HEAD
    [[ "$(git -C "$INSTALL_DIR" rev-parse HEAD)" == "$(git -C "$INSTALL_DIR" rev-parse FETCH_HEAD)" ]] || \
        fail "$INSTALL_DIR did not reach the requested revision. Refusing to run the installer."
else
    [[ ! -e "$INSTALL_DIR" && ! -L "$INSTALL_DIR" ]] || fail "$INSTALL_DIR cannot be used."
    command -v dirname >/dev/null 2>&1 || fail "dirname is required."
    mkdir -p "$(dirname "$INSTALL_DIR")"
    log "Cloning $REPO_URL to $INSTALL_DIR..."
    git clone --quiet "$REPO_URL" "$INSTALL_DIR"
    git -C "$INSTALL_DIR" checkout --quiet "$BRANCH"
fi

[[ -f "$INSTALL_DIR/install.sh" ]] || fail "Missing installer: $INSTALL_DIR/install.sh"

if [[ $# -eq 0 ]]; then
    set -- all
fi

log "Running: $INSTALL_DIR/install.sh $*"
exec bash "$INSTALL_DIR/install.sh" "$@"
