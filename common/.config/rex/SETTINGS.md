# Rex for Mac — settings snapshot

Rex's Lua config file (`init.lua`) only manages **keybindings, custom
actions, key modes, and hosts**. Appearance, tab/interface, terminal
typography, and theme settings are app preferences stored by Rex in

```
~/Library/Preferences/com.superlogical.rex.plist   (keys Workspace.*)
```

They are **not** read from `init.lua`, so they can't be applied automatically
from this repo. This file is a human-readable record of the settings on this
machine so a new Mac can be set back up quickly. Restore manually in
**Rex ▸ Settings** and by importing the theme files in [`themes/`](themes/).

## Themes

Importable theme files (Ghostty palette format, re-importable via
**Settings ▸ Themes ▸ Import**):

| Theme | File | Appearance |
| --- | --- | --- |
| cobalt2 (dark, active) | [`themes/cobalt2.toml`](themes/cobalt2.toml) | dark |
| kanagawa-dragon | [`themes/kanagawadragon.toml`](themes/kanagawadragon.toml) | dark |
| kanagawa-wave | [`themes/kanagawawave.toml`](themes/kanagawawave.toml) | dark |

Active theme IDs: dark = `cobalt2`, light = `merino-light`. The two kanagawa
themes are also vendored as Ghostty themes in
`../../ghostty/themes/{kanagawa-dragon,kanagawa-wave}` (this repo).

## Interface ▸ Appearance

| Setting | Value | plist key |
| --- | --- | --- |
| Color scheme | Dark | `Workspace.appearance` |
| Interface style | Tint with theme | `Workspace.interfaceStyle` = `blendTheme` |
| Tabs fill available space | On | `Workspace.tabsFillAvailableSpace` |
| Tab style | Above (horizontal) | `Workspace.tabStyle` = `horizontal` |
| Show tab icons | 1 | `Workspace.tabIconCount` |
| Color for tab icons | For active panes | `Workspace.tabIconColorMode` = `activePanes` |
| Shell icon theme | Use theme | `Workspace.shellIconTheme` = `themed` |

## Interface ▸ Panes

| Setting | Value | plist key |
| --- | --- | --- |
| Pane style | Comfortable | `Workspace.paneDensity` = `comfortable` |
| Show pane headers | Off | `Workspace.showsPaneHeaders` = `false` |
| Match program backgrounds | On | `Workspace.tintsPanesWithProgramBackground` |

## Terminal ▸ Typography

| Setting | Value | plist key |
| --- | --- | --- |
| Font | Maple Mono NF | `Workspace.terminalFontName` |
| Size | 18 pt | `Workspace.terminalFontPointSize` = 18 |
| Force theme palette for text | On | `Workspace.terminalUseThemePalette` |
| Font smoothing | On | `Workspace.terminalFontSmoothing` |

Also set: smooth scrolling, forced cursor style, copy on select.

## Integrations ▸ Coding Agents

| Setting | Value | plist key |
| --- | --- | --- |
| Integrate with available agents | On (installs skill + hooks for Claude Code / Codex / OpenCode / Pi) | `rex skill setup` |
| Let agents name sessions | On | `rex.agents.names-sessions` |

## Server

| Setting | Value |
| --- | --- |
| Serve over Tailscale | On |
| Tailscale account | jellydn@github |
| Preferred hostname | itman-rex |
| Limit access to | Your Tailscale account |
| Remote address | `https://itman-rex.whydah-gamma.ts.net` |

Server run-mode `bundled`, automatic restart on.

## Reproduce on a new Mac

1. Install Rex for Mac, sign in to Tailscale (Server ▸ Tailscale), set
   Preferred hostname to `itman-rex`.
2. **Settings ▸ Themes ▸ Import** → pick the `.toml` files in [`themes/`](themes/);
   set dark theme to cobalt2.
3. Re-apply the Interface and Typography values in the tables above.
4. Keybindings come automatically from [`init.lua`](init.lua).