<h1 align="center">Welcome to tmux-super-easy-setup 👋</h1>

<p>
  Super easy setup for tmux with Tmux Plugin Manager, Tmux Resurrect and Tmux navigator.
</p>

[![IT Man - Oh my tmux: super easy configuration!](https://i.ytimg.com/vi/vrzkCz8Vl-4/hqdefault.jpg)](https://www.youtube.com/watch?v=vrzkCz8Vl-4)

## Introduction

This is my workflow for setting up tmux with Tmux Plugin Manager, Tmux Resurrect and Tmux navigator.

## Install .tmux

```sh
$ cd ~
$ git clone https://github.com/gpakosz/.tmux.git
$ ln -s -f .tmux/.tmux.conf
$ git clone https://github.com/jellydn/dotfiles.git
$ cp dotfiles/tmux/.tmux.conf.local .
```

## Force vi mode

```
# force Vi mode
#   really you should export VISUAL or EDITOR environment variable, see manual
set -g status-keys vi
set -g mode-keys vi
```

## Custom theme by https://github.com/rebelot/kanagawa.nvim

Search the color scheme you like and replace the color in `~/.tmux.conf.local`

[![Demo](https://i.gyazo.com/445e9608bd7808912e0279f4cb67bacf.png)](https://gyazo.com/445e9608bd7808912e0279f4cb67bacf)

## Plugins

- https://github.com/christoomey/vim-tmux-navigator
- https://github.com/tmux-plugins/tmux-resurrect

More detail on [tmux.conf.local](../.tmux.conf.local)

## Author

👤 **Huynh Duc Dung**

- Website: https://productsway.com/
- Twitter: [@jellydn](https://twitter.com/jellydn)
- Github: [@jellydn](https://github.com/jellydn)

## Show your support

If this guide has been helpful, please give it a ⭐️.

[![kofi](https://img.shields.io/badge/Ko--fi-F16061?style=for-the-badge&logo=ko-fi&logoColor=white)](https://ko-fi.com/dunghd)
[![paypal](https://img.shields.io/badge/PayPal-00457C?style=for-the-badge&logo=paypal&logoColor=white)](https://paypal.me/dunghd)
[![buymeacoffee](https://img.shields.io/badge/Buy_Me_A_Coffee-FFDD00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black)](https://www.buymeacoffee.com/dunghd)
