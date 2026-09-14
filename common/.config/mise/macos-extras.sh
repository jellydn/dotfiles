#!/usr/bin/env bash
# Idempotent Mac extras that have no brew/cask token.
# Invoked by [tasks.bootstrap] in config.macos.toml.
set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
    exit 0
fi

font_dir="$HOME/Library/Fonts"
font="$font_dir/sketchybar-app-font.ttf"
if [[ ! -f "$font" ]]; then
    mkdir -p "$font_dir"
    curl -fsSL -o "$font" \
        "https://github.com/kvndrsslr/sketchybar-app-font/releases/download/v2.0.19/sketchybar-app-font.ttf"
fi

sbarlua_so="$HOME/.local/share/sketchybar_lua/sketchybar.so"
if [[ ! -f "$sbarlua_so" ]]; then
    tmp="$(mktemp -d "${TMPDIR:-/tmp}/SbarLua.XXXXXX")"
    git clone --depth 1 https://github.com/FelixKratz/SbarLua.git "$tmp"
    (cd "$tmp" && make install)
    rm -rf "$tmp"
fi
