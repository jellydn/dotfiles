# Terminal keys

Ghostty, Kitty, Foot, and Alacritty use the **same letters**.

```
Linux:   Ctrl+Shift + letter
macOS:   Cmd + letter
Always:  Ctrl+-  is Neovim, never font size
```

## Remember the letter

| Letter | Remember | Action |
| --- | --- | --- |
| `-` | toggle / split | Neovim terminal (`<c-_>` / tiny-term) |
| `c` `v` | **c**opy / paste | Clipboard |
| `n` | **n**ew | New window |
| `f` | **f**ind | Search / scrollback |
| `l` | **l**ist files | Run `cmdk -s` (recursive file picker in this directory) |
| `,` | config | Reload config (not Alacritty) |
| `=` `-` | bigger / smaller | Font size — **with Shift on Linux** (`Ctrl+Shift+=/-`). macOS is `Cmd+=/-`. |

Word jump: `Alt+Left` / `Alt+Right` (Option is Alt on macOS).

Clear the screen with `Ctrl+L`, not `Cmd+K`.

`cmdk -s` is [cmdk](https://github.com/mieubrisse/cmdk): fuzzy-pick files under the current directory (including subdirectories), then `cd` or open them in `$EDITOR`. Without `-s` it only lists the current directory. Sourced from `~/.cmdk/cmdk.fish`.

## macOS extras

| Chord | Remember |
| --- | --- |
| `Cmd+Q` | **Q**uit |
| `Cmd+K` `Cmd+J` `Cmd+[` `Cmd+]` | Unbound for jcode prompt jump |
| `Cmd+\`` | Ghostty quick terminal only |

## Config files

Keep this doc and the configs in sync:

| Emulator | File |
| --- | --- |
| Ghostty | `common/.config/ghostty/config` |
| Kitty | `common/.config/kitty/kitty.conf` |
| Foot | `linux/.config/foot/foot.ini` |
| Alacritty | `common/.config/alacritty/keys.toml` (imported by macOS + Linux) |

Reload: Ghostty / Kitty / Foot `Ctrl+Shift+,` (macOS Ghostty also `Cmd+Shift+,`). Alacritty has no reload action — restart the app.
