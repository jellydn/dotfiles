#!/usr/bin/env bash
# Idempotent Mac extras that have no brew/cask token.
# Invoked by [tasks.bootstrap] in config.macos.toml.
set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
    exit 0
fi

font_tmp=""
sbarlua_tmp=""
cleanup() {
    [[ -z "$font_tmp" ]] || rm -f "$font_tmp"
    [[ -z "$sbarlua_tmp" ]] || rm -rf "$sbarlua_tmp"
}
trap cleanup EXIT

font_dir="$HOME/Library/Fonts"
font="$font_dir/sketchybar-app-font.ttf"
if [[ ! -f "$font" ]]; then
    mkdir -p "$font_dir"
    font_tmp="$(mktemp "$font_dir/.sketchybar-app-font.XXXXXX")"
    curl -fsSL -o "$font_tmp" \
        "https://github.com/kvndrsslr/sketchybar-app-font/releases/download/v2.0.19/sketchybar-app-font.ttf"
    chmod 0644 "$font_tmp"
    mv "$font_tmp" "$font"
    font_tmp=""
fi

sbarlua_so="$HOME/.local/share/sketchybar_lua/sketchybar.so"
if [[ ! -f "$sbarlua_so" ]]; then
    sbarlua_tmp="$(mktemp -d "${TMPDIR:-/tmp}/SbarLua.XXXXXX")"
    git clone --depth 1 https://github.com/FelixKratz/SbarLua.git "$sbarlua_tmp"
    (cd "$sbarlua_tmp" && make install)
    rm -rf "$sbarlua_tmp"
    sbarlua_tmp=""
fi
