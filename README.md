# dotfiles

A set of vim, zsh, and git configuration files.

## Vim

Step 1:

```bash
cp .vimrc ~/.vimrc
cp .vimrc.local ~/.vimrc.local
cp .vimrc.local.bundles ~/.vimrc.local.bundles
```

Step 2:

```bash
vim +PlugInstall +qall
```

Step 3: Update to latest version

```bash
:VimBootstrapUpdate
:PlugInstall
```

## Iterm2 with Oh-my-shell

Step 0:

```bash
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
```

Step 1:

```bash
brew install zsh-autosuggestions
brew install zsh-syntax-highlighting
cp .zshrc ~/.zshrc
```

Step 2:
Import cobalt2.itermcolors

Step 3: Install font and choose `Meslo LG DZ for Powerline`

```bash
git clone https://github.com/powerline/fonts.git
```

## Git

### Config

```bash
cp .gitconfig ~/.gitconfig
```

### commitizen

```bash
yarn global add commitizen cz-conventional-changelog
echo '{ "path": "cz-conventional-changelog" }' > ~/.czrc
```
