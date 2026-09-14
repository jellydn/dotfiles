#!/bin/sh

# set codesigning certificate name here (default: yabai-cert)
export YABAI_CERT=
YABAI_BIN="${YABAI_BIN:-/opt/homebrew/opt/yabai/bin/yabai}"

# stop yabai
yabai --stop-service

# reinstall yabai (remove old service file because the prefix binary path can change)
yabai --uninstall-service
if command -v mise >/dev/null 2>&1; then
    mise bootstrap packages apply --yes "brew:koekeishiya/formulae/yabai"
elif command -v brew >/dev/null 2>&1; then
    brew reinstall koekeishiya/formulae/yabai
    YABAI_BIN="$(brew --prefix yabai)/bin/yabai"
fi
codesign -fs "${YABAI_CERT:-yabai-cert}" "$YABAI_BIN"

# finally, start yabai
yabai --start-service
