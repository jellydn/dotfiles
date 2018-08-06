#!/bin/sh
cp init.vim ~/.config/nvim/init.vim
cp .vimrc.local ~/.config/nvim/local_init.vim
cp .vimrc.local.bundles ~/.config/nvim/local_bundles.vim
pip2 install --user neovim
pip3 install --user neovim
nvim +PlugInstall +qall
