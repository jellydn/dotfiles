#!/bin/sh
brew install python3
brew install neovim
cp init.vim ~/.config/nvim/init.vim
cp .vimrc.local ~/.config/nvim/local_init.vim
cp .vimrc.local.bundles ~/.config/nvim/local_bundles.vim
pip2 install --user --upgrade neovim
pip3 install --user --upgrade neovim
nvim +PlugInstall +qall
