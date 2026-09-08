# Vicinae

Vicinae is the keyboard-driven application launcher used by the Linux Niri and
Hyprland configurations. It provides a similar workflow to Tuna on macOS.

## Install

On Arch Linux, the Niri installer installs the stable AUR package:

```bash
yay -S vicinae-bin
```

For other distributions, follow the [official Linux installation guide](https://docs.vicinae.com/install/linux).

## Start

The Niri and Hyprland configurations start the Vicinae server automatically and
bind `Super+D` to toggle the launcher. Vicinae can also be managed as a user
service:

```bash
systemctl --user enable --now vicinae.service
```

Vicinae's user configuration is generated and maintained by Vicinae at
`~/.config/vicinae/settings.json`. Keeping this directory documentation-only
avoids committing machine-specific settings while still making the setup
discoverable through GNU Stow.

See the [Vicinae documentation](https://docs.vicinae.com/) for configuration,
extensions, deeplinks, and compositor-specific setup.