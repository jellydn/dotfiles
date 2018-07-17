#!/bin/sh
cp .vimrc ~/.vimrc
cp .vimrc.local ~/.vimrc.local
cp .vimrc.local.bundles ~/.vimrc.local.bundles
vim +PlugInstall +qall
