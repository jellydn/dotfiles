# dotfiles

A set of vim, zsh, and git configuration files.

## Tools

- [ohmyz](https://ohmyz.sh/) - a delightful, open source, community-driven
  framework for managing your Zsh configuration
- [romkatv/powerlevel10k](https://github.com/romkatv/powerlevel10k#oh-my-zsh) A
  Zsh theme
- [.tmux](https://github.com/gpakosz/.tmux) - oh my tmux! My self-contained,
  pretty & versatile tmux configuration made with ❤️
- [Alacritty](https://alacritty.org/) - A cross-platform, OpenGL terminal
  emulator
- [starship](https://starship.rs/) - the minimal, blazing-fast, and infinitely
  customizable prompt for any shell!
- [raycast](https://www.raycast.com/) - is a blazingly fast, totally extendable
  launcher.
- [delta](https://github.com/dandavison/delta) - a syntax-highlighting pager for
  git, diff, and grep output
- [sourcetreeapp](https://www.sourcetreeapp.com/) - simplicity and power in a
  beautiful Git GUI
- [spectacleapp](https://www.spectacleapp.com/) - move and resize windows with
  ease
- [f.lux](https://justgetflux.com/) - makes the color of your computer's display
  adapt to the time of day, warm at night and like sunlight during the day.
- [pock](https://pock.app/) - widgets manager for MacBook Touch Bar
- [caffeine](https://intelliscapesolutions.com/apps/caffeine) - don't let your
  Mac fall asleep.
- [git-credential-manager](https://github.com/GitCredentialManager/git-credential-manager/) -
  Git Credential Manager
- [karabiner-elements](https://karabiner-elements.pqrs.org) - a powerful and
  stable keyboard customizer for macOS.
- [fnm](https://github.com/Schniz/fnm) - 🚀 fast and simple Node.js version
  manager, built in Rust
- [gyazo](https://gyazo.com/) - share and search what you see. Instantly.

## Deprecated tools

- [Fig](https://fig.sh/) - adds IDE-style autocomplete to your existing terminal
- [iterm2](https://iterm2.com/) - a replacement for Terminal
- [warp](https://www.warp.dev/) - the terminal for the 21st century

### Neovim IDE

```sh
git clone https://github.com/jellydn/lazy-nvim-ide ~/.config/nvim
```

## CLI

### Install

```sh
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
brew install starship
brew install etuin
brew install wget

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
