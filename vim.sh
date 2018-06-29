#!/bin/sh
cp .vimrc ~/.vimrc
cp .rc.local ~/.rc.local
cp .rc.local.bundles ~/.rc.local.bundles
vim +PlugInstall +qall
