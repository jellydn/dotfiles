-- ~/.config/rex/init.lua — Rex configuration (Rex reads one file, init.lua).
-- Docs: https://www.superlogical.com/rex/docs/customize/config.md
-- Validate: rex config check     Apply: rex config reload
--
-- This file lives in the dotfiles repo (common/.config/rex) and is linked
-- to ~/.config/rex (mise [dotfiles] on macOS, stow package "common" on Linux).
--
-- Rex needs no config to run; add rex.bind(...) entries here as you find
-- things you want to change. Bindings made in the Mac app itself win over
-- this file.
--
-- Appearance, tab/interface, terminal, and theme settings are app
-- preferences, not this file (they live in com.superlogical.rex.plist).
-- This machine's snapshot is in ./SETTINGS.md; importable theme files are
-- in ./themes/ (cobalt2 = active dark theme).

-- ---------------------------------------------------------------------------
-- Server setup (as configured on this machine, for the record):
-- Rex serves over this machine's Tailnet via a tsnet node:
--   rex server status   →  tailscale: running · itman-rex.whydah-gamma.ts.net
--   https://itman-rex.whydah-gamma.ts.net
-- Access is limited to the signed-in Tailscale account (jellydn@github).
-- The macOS app manages these settings in its own preferences; on a Linux
-- server managed by the CLI instead, reproduce them with:
--   rex server tailscale on                                  # serve over tailnet
--   rex server tailscale rename itman-rex                    # node hostname
--   rex server start --tailscale --tailscale-hostname itman-rex
--   rex server tailscale logout                              # stop serving
-- ---------------------------------------------------------------------------

-- ---------------------------------------------------------------------------
-- Keybindings
-- ---------------------------------------------------------------------------
-- Split the focused pane
rex.bind("cmd+d", "pane.split",       { direction = "right" })
rex.bind("shift+cmd+d", "pane.split", { direction = "down" })

-- Vim-style pane focus (alt+cmd+h/j/k/l), complementing the default
-- alt+cmd+arrow bindings
rex.bind("alt+cmd+h", "pane.focus.left")
rex.bind("alt+cmd+j", "pane.focus.down")
rex.bind("alt+cmd+k", "pane.focus.up")
rex.bind("alt+cmd+l", "pane.focus.right")

-- Other useful bindings (uncomment as desired):
-- rex.bind("cmd+e", "pane.zoom")
-- rex.bind("alt+cmd+enter", "pane.float")
-- rex.bind("cmd+k", "session.switch")   -- already a default
-- rex.unbind("cmd+q")                     -- remove a default shortcut
