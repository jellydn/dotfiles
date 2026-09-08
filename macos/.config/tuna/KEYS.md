# Tuna keys

Tuna is the launcher. FlashSpace is workspaces (`opt+letter`). Do not mix them.

```
Hyper  =  ctrl + opt + cmd + shift   (Right-Cmd is mapped to Hyper)
Combo  =  hold Right-Cmd   or   double-tap Left-Cmd
```

## Modes

| Key | Mode | Remember |
| --- | --- | --- |
| `cmd+space` | Fuzzy | Spotlight-style search |
| `opt+space` | Text | type / calc / convert |
| `hyper+space` | Talk | dictate |
| hold Right-Cmd, or double-tap Left-Cmd | Combo | Leader Key sequences |

## Combo (after the Combo trigger)

First letter of the thing:

| Key | Opens | Remember |
| --- | --- | --- |
| `e` | Zen | brows**e**r |
| `t` | Ghostty | **t**erminal (app may be missing) |
| `f` | Finder | **f**iles |
| `m` | Canary Mail | **m**ail |
| `n` | Notes | **n**otes |
| `d` | ~/Downloads | **d**ownloads |
| `h` | ~ | **h**ome |

## Hyper + key (jump to an app)

Mostly the first letter. Collisions use a nearby letter.

| Key | Opens | Remember |
| --- | --- | --- |
| `hyper+a` | Delta | delt**a** |
| `hyper+b` | Grok Bot | **b**ot |
| `hyper+c` | VS Code Insiders | **c**ode |
| `hyper+d` | OrbStack | **d**ocker |
| `hyper+e` | Zen | brows**e** |
| `hyper+g` | ChatGPT Classic | **G**PT |
| `hyper+k` | Activity Monitor | tas**k** |
| `hyper+m` | Canary Mail | **m**ail |
| `hyper+r` | Spotify | **r**adio / relax |
| `hyper+s` | Slack | **s**lack |
| `hyper+t` | Teams | **t**eams |
| `hyper+w` | ChatGPT | **w**hisper / write |
| `hyper+y` | Brave | **y** (b was Bot) |
| `hyper+z` | Zed Preview | **z**ed |
| `hyper+return` | Alacritty | enter a shell |

## vs FlashSpace

| Want | Use |
| --- | --- |
| Switch the **space** (hide/show a group) | FlashSpace `opt+c` / `opt+b` / … |
| **Open** one app right now | Tuna Combo or `hyper+letter` |
| Search anything | Tuna `cmd+space` |

Config lives in `~/Library/Application Support/Tuna/` and is symlinked from `macos/.config/tuna/`. After edits: `tuna config reload`.
