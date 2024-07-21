<h1 align="center">Welcome to my Helix editor config 👋</h1>

> How to setup a Helix editor

[![IT Man - How to Set Up #Helix Like my #Neovim](https://i.ytimg.com/vi/5OOeqEqZEyE/hqdefault.jpg)](https://www.youtube.com/watch?v=5OOeqEqZEyE)

## Table of Contents

<!--toc:start-->

- [Install](#install)
- [Health Check](#health-check)
- [Usage](#usage)
- [What I enjoy](#what-i-enjoy)
- [What I'm missing from Neovim](#what-im-missing-from-neovim)
- [Resources](#resources)
- [Show your support](#show-your-support)
<!--toc:end-->

## Install

```sh
brew install helix
```

## Health Check

```sh
hx --health
```

## Usage

Clone this repo and copy the `helix` folder to `~/.config/helix`.

```sh
cp -R ~/.helix ~/.helix.bak
cp -R helix ~/.config/helix
```

## What I enjoy

- Easy to install, fast (rust)
- [LSP](https://docs.helix-editor.com/lang-support.html) support, [TreeSitter](https://docs.helix-editor.com/syntax-aware-motions.html), [Surround](https://docs.helix-editor.com/surround.html)
- The default visual mode provides clear visibility of the current work area.
- It includes a feature similar to 'which-key' ([Space mode](https://docs.helix-editor.com/keymap.html?highlight=space%20mode#space-mode)).
- The keybindings are more intuitive and easier to remember than those in Neovim.

## What I'm missing from Neovim

- Code folding capability.
- Snippet support.
- Built-in terminal
- A file explorer.
- LazyGit / [VCS/git support](https://github.com/helix-editor/helix/issues/227)
- Github Copilot
- Plugins https://github.com/helix-editor/helix/discussions/3806 and https://github.com/helix-editor/helix/pull/8675

## Resources

- `hx --tutor`
- [Helix vs Neovim](https://github.com/helix-editor/helix/wiki/Differences-from)
- [Language Server Configurations](https://github.com/helix-editor/helix/wiki/Language-Server-Configurations)
- Youtube videos:
  - https://youtu.be/tGYvUXYN-c0?si=vOsqblOeLUir5GBT
  - https://youtu.be/xHebvTGOdH8?si=A8BZxl6LPw7kSHCe
  - https://youtu.be/aiSI6vdZWgE?si=dBR6jNdW9JGoC37v

## Show your support

Give a ⭐️ if this project helped you!
