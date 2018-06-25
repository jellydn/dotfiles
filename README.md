# dotfiles

A set of vim, zsh, and git configuration files.

## Neovim

Step 1:

```bash
cp init.vim ~/.config/nvim/init.vim
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

Step 1:

```bash
cp .zshrc ~/.zshrc
```

Step 2:
Import cobalt2.itermcolors

Step 3: Install font and choose `Meslo LG DZ for Powerline`

```bash
git clone https://github.com/powerline/fonts.git
```
