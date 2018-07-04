#! /bin/bash
# Uninstall script for the Neovim configuration files
brew uninstall --force neovim
rm /usr/local/bin/nvim
rm -r /usr/local/share/nvim/
