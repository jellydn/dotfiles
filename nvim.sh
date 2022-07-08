#!/bin/sh
brew install python3
brew install neovim
mkdir ~/.config/nvim
cp init.vim ~/.config/nvim/init.vim
cp .vimrc.local ~/.config/nvim/local_init.vim
cp .vimrc.local.bundles ~/.config/nvim/local_bundles.vim
pip3 install --user --upgrade neovim
nvim +PlugInstall +qall
