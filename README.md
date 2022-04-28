# dotfiles

A set of vim, zsh, and git configuration files.

## Tools

- [ohmyz](https://ohmyz.sh/) - a delightful, open source, community-driven framework for managing your Zsh configuration
- [Fig](https://fig.sh/) - adds IDE-style autocomplete to your existing terminal
- [iterm2](https://iterm2.com/) - a replacement for Termina
- [starship](https://starship.rs/) - the minimal, blazing-fast, and infinitely customizable prompt for any shell!
- [raycast](https://www.raycast.com/) - is a blazingly fast, totally extendable launcher.
- [delta](https://github.com/dandavison/delta) - a syntax-highlighting pager for git, diff, and grep output
- [spectacleapp](https://www.spectacleapp.com/) - move and resize windows with ease
- [f.lux](https://justgetflux.com/) - makes the color of your computer's display adapt to the time of day, warm at night and like sunlight during the day.
- [pock](https://pock.app/) - widgets manager for MacBook Touch Bar
- [git-credential-manager](https://github.com/GitCredentialManager/git-credential-manager/) - Git Credential Manager

## Vim

Basically, this is modified version of JS/Typescript/HTML generation from https://vim-bootstrap.com/

### Config

```sh
cp .vimrc ~/.vimrc
cp .vimrc.local ~/.vimrc.local
cp .vimrc.local.bundles ~/.vimrc.local.bundles
```

### Install

```sh
vim +PlugInstall +qall
:VimBootstrapUpdate
:PlugInstall
```

## CLI

### Install

```sh
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
brew install zsh-autosuggestions
brew install zsh-syntax-highlighting
brew install starship
brew install atuin
git clone \
  git@github.com:grigorii-zander/zsh-npm-scripts-autocomplete.git \
  ~/.oh-my-zsh/custom/plugins/zsh-npm-scripts-autocomplete
```

### Config

```sh
cp .zshrc ~/.zshrc
```

### Theme

- Import cobalt2.itermcolors
- Install font and choose `Meslo LG DZ for Powerline` or download directly from https://github.com/ryanoasis/nerd-fonts#patched-fonts

```sh
git clone https://github.com/powerline/fonts.git
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
echo '{ "path": "cz-conventional-changelog" }' > ~/.czrc
```
