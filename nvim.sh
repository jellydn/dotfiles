#!/bin/sh
cp init.vim ~/.config/nvim/init.vim
cp .rc.local ~/.rc.local
cp .rc.local.bundles ~/.rc.local.bundles
nvim +PlugInstall +qall
