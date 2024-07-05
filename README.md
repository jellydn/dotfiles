# dotfiles

A set of vim, zsh, and git configuration files.

## Tools

- [ohmyz](https://ohmyz.sh/) - a delightful, open source, community-driven
  framework for managing your Zsh configuration
- [powerlevel10k](https://github.com/romkatv/powerlevel10k#oh-my-zsh) A
  Zsh theme
- [.tmux](https://github.com/gpakosz/.tmux) - oh my tmux! My self-contained,
  pretty & versatile tmux configuration made with ❤️
- [WezTerm](https://wezfurlong.org/wezterm/) - Wez's Terminal Emulator
- [starship](https://starship.rs/) - the minimal, blazing-fast, and infinitely
  customizable prompt for any shell!
- [raycast](https://www.raycast.com/) - is a blazingly fast, totally extendable
  launcher.
- [delta](https://github.com/dandavison/delta) - a syntax-highlighting pager for
  git, diff, and grep output
- [lazygit](https://github.com/jesseduffield/lazygit): simple terminal UI for git commands
- [sourcetreeapp](https://www.sourcetreeapp.com/) - simplicity and power in a
  beautiful Git GUI
- [koekeishiya/yabai](https://github.com/koekeishiya/yabai): A tiling window manager for macOS based on binary space partitioning
- [koekeishiya/skhd](https://github.com/koekeishiya/skhd): Simple hotkey daemon for macOS
- [f.lux](https://justgetflux.com/) - makes the color of your computer's display
  adapt to the time of day, warm at night and like sunlight during the day.
- [caffeine](https://intelliscapesolutions.com/apps/caffeine) - don't let your
  Mac fall asleep.
- [git-credential-manager](https://github.com/GitCredentialManager/git-credential-manager/) -
  Git Credential Manager
- [karabiner-elements](https://karabiner-elements.pqrs.org) - a powerful and
  stable keyboard customizer for macOS.
- [fnm](https://github.com/Schniz/fnm) - 🚀 fast and simple Node.js version
  manager, built in Rust
- [poetry](https://github.com/python-poetry/poetry) - Python packaging and dependency management made easy
- [astral-sh/rye](https://github.com/astral-sh/rye) - a Hassle-Free Python Experience
- [direnv](https://github.com/direnv/direnv) - unclutter your .profile.
- [gyazo](https://gyazo.com/) - share and search what you see. Instantly.
- [colima](https://github.com/abiosoft/colima) - Container runtimes on macOS (and Linux) with minimal setup
- [medis](https://github.com/luin/medis) - Medis is a beautiful, easy-to-use Mac database management application for Redis
- [keycastr](https://github.com/keycastr/keycastr) - KeyCastr, an open-source keystroke visualizer
- [EVKey](https://evkeyvn.com/) - Vietnamese Keyboard
- [krisp AI](https://ref.krisp.ai/u/u458fbd216) - Noise cancellation App
- [BetterDisplay](https://github.com/waydabber/BetterDisplay?tab=readme-ov-file) - Unlock your displays on your Mac! Smooth scaling, HiDPI unlock, XDR/HDR extra brightness upscale, DDC, brightness and dimming, virtual screens, PIP and lots more!
- [SketchyBar](https://felixkratz.github.io/SketchyBar/) - A highly customizable macOS status bar replacement
- [OBS](https://obsproject.com/) - Open Broadcaster Software
- [AltTab](https://alt-tab-macos.netlify.app/) - Windows alt-tab on macOS
- [Hurl](https://hurl.dev/) - Run and Test HTTP Requests
- [restish](https://github.com/danielgtaylor/restish) - Restish is a CLI for interacting with REST-ish HTTP APIs with some nice features built-in

## Deprecated tools

- [Fig](https://fig.sh/) - adds IDE-style autocomplete to your existing terminal
- [iterm2](https://iterm2.com/) - a replacement for Terminal
- [warp](https://app.warp.dev/referral/2ENQM7) - the terminal for the 21st century
- [Alacritty](https://alacritty.org/) - A cross-platform, OpenGL terminal
  emulator
- [OrbStack](https://orbstack.dev/) - Fast, light, simple Docker & Linux on macOS
- [pock](https://pock.app/) - widgets manager for MacBook Touch Bar
- [httpie](https://github.com/httpie/httpie) - HTTPie for Terminal — modern, user-friendly command-line HTTP client for the API era. JSON support, colors, sessions, downloads, plugins & more
- [spectacleapp](https://www.spectacleapp.com/) - move and resize windows with ease

### Neovim IDE

```sh
git clone https://github.com/jellydn/my-nvim-ide ~/.config/nvim
```

## CLI

### Install

```sh
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
brew install starship
brew install atuin
brew install zoxide
brew install bat
brew install fd
brew install ripgrep
brew install the_silver_searcher
brew install jq
brew install wget
brew install mkcert
brew install tree
brew install nss # if you use Firefox
brew install make
brew install gnu-sed
brew install ast-grep # structural search and replace

cd ~/.oh-my-zsh/themes/
wget https://raw.githubusercontent.com/wesbos/Cobalt2-iterm/master/cobalt2.zsh-theme

cd ~/.oh-my-zsh/custom/plugins/
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git
git clone https://github.com/zsh-users/zsh-autosuggestions.git
git clone https://github.com/grigorii-zander/zsh-npm-scripts-autocomplete.git
```

### Install powerlevel10k theme

1. Clone the theme to oh-my-zsh/

```sh
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
```

2. Set ZSH_THEME="powerlevel10k/powerlevel10k" in ~/.zshrc

### Config

```sh
cp .zshrc ~/.zshrc
```

### Theme

- Import cobalt2.itermcolors
- Install font and choose `Meslo LG DZ for Powerline` or download directly from
  https://github.com/ryanoasis/nerd-fonts#patched-fonts

```sh
git clone https://github.com/powerline/fonts.git
```

### Alacritty

```sh
cp .alacritty.yml ~/.alacritty.yml
```

Or install other theme with below command

```sh
npx alacritty-themes
```

### Yabai

```sh
cp .yabairc ~/.yabairc
cp .skhdrc ~/.skhdrc
```

## Git

### Install

```sh
brew install git-lfs
brew install git-delta
```

### Config

```sh
cp .gitconfig ~/.gitconfig
```

### Tip

Use commitizen

```sh
yarn global add commitizen cz-conventional-changelog
brew install commitizen
echo '{ "path": "cz-conventional-changelog" }' > ~/.czrc
```

Hide desktop icon

```sh
defaults write com.apple.finder CreateDesktop false
killall Finder
```

### OBS setting for Blue Yeti Microphone

- Noise Suppression

[![Image from Gyazo](https://i.gyazo.com/d56efbfb5526573702527574f6fa00c7.png)](https://gyazo.com/d56efbfb5526573702527574f6fa00c7)

- Noise Gate

[![Image from Gyazo](https://i.gyazo.com/5c21fd448eea64903b62e1faf7b2309b.png)](https://gyazo.com/5c21fd448eea64903b62e1faf7b2309b)

- Compressor

[![Image from Gyazo](https://i.gyazo.com/f96c1d8d35126cc5f259629f61eea64e.png)](https://gyazo.com/f96c1d8d35126cc5f259629f61eea64e)

### Oh My Tmux

- Enable vi mode

```sh
# force Vi mode
#   really you should export VISUAL or EDITOR environment variable, see manual
set -g status-keys vi
set -g mode-keys vi
```

- Enable Tmux Resurrect

```sh
set -g @plugin 'tmux-plugins/tmux-resurrect'
```
