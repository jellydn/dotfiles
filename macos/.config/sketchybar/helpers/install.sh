#!/bin/sh
# SketchyBar extras. lua, sketchybar, and SF fonts are declared in
# common/.config/mise/config.macos.toml and installed by `mise bootstrap`.
# This script only installs artifacts that have no brew/cask token.
set -e
here="$(cd "$(dirname "$0")" && pwd -P)"
exec bash "$here/../../../../common/.config/mise/macos-extras.sh"
