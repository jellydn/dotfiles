# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="/Users/huynhdung/.oh-my-zsh"

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to load
# Setting this variable when ZSH_THEME=random
# cause zsh load theme from this variable instead of
# looking in ~/.oh-my-zsh/themes/
# An empty array have no effect
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-npm-scripts-autocomplete
)
source $ZSH/oh-my-zsh.sh

# User configuration

# Set locale
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Python3

if [ -d "$HOME/Library/Python/3.11/bin" ]; then
    PATH="$HOME/Library/Python/3.11/bin:$PATH"
fi

if [ -d "$HOME/Library/Python/3.12/bin" ]; then
    PATH="$HOME/Library/Python/3.12/bin:$PATH"
fi

if [ -d "$HOME/Library/Python/3.13/bin" ]; then
    PATH="$HOME/Library/Python/3.13/bin:$PATH"
fi

# tabtab source for packages
# uninstall by removing these lines
[[ -f ~/.config/tabtab/zsh/__tabtab.zsh ]] && . ~/.config/tabtab/zsh/__tabtab.zsh || true

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

eval "$(starship init zsh)"
eval "$(atuin init zsh)"
eval "$(zoxide init zsh)"

# Sublime
export PATH="/Applications/Sublime Text.app/Contents/SharedSupport/bin:$PATH"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# direnv
eval "$(direnv hook zsh)"

# nvim
export PATH=$PATH:~/.local/share/bob/nvim-bin

# alias
alias vi='nvim'
alias vim='nvim'
alias cat='bat'
alias lvim="NVIM_APPNAME=lazyvim nvim"

export PATH="/usr/local/sbin:$PATH"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

# bun completions
[ -s "/Users/huynhdung/.bun/_bun" ] && source "/Users/huynhdung/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Deno
export DENO_INSTALL="/Users/huynhdung/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"

# Encore
export ENCORE_INSTALL="/Users/huynhdung/.encore"
export PATH="$ENCORE_INSTALL/bin:$PATH"

# Support Poetry
export LOCAL_BIN="/Users/huynhdung/.local/bin/"
export PATH="$LOCAL_BIN:$PATH"

# Herd injected PHP binary.
export PATH="/Users/huynhdung/Library/Application Support/Herd/bin/":$PATH
export PHP_INI_SCAN_DIR="/Users/huynhdung/Library/Application Support/Herd/config/php/":$PHP_INI_SCAN_DIR

export NVM_DIR="$HOME/.reflex/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# bun completions
[ -s "/Users/huynhdung/.reflex/.bun/_bun" ] && source "/Users/huynhdung/.reflex/.bun/_bun"

# Peotry
fpath+=~/.zfunc
FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
autoload -Uz compinit && compinit

# Walk
export WALK_EDITOR=nvim
function lk {
  cd "$(walk --icons "$@")"
}

# Herd injected PHP 8.2 configuration.
export HERD_PHP_82_INI_SCAN_DIR="/Users/huynhdung/Library/Application Support/Herd/config/php/82/"

# Herd injected PHP 8.3 configuration.
export HERD_PHP_83_INI_SCAN_DIR="/Users/huynhdung/Library/Application Support/Herd/config/php/83/"

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
export MODULAR_HOME="/Users/huynhdung/.modular"
export PATH="/Users/huynhdung/.modular/pkg/packages.modular.com_mojo/bin:$PATH"

# Flutter
export PATH="/Users/huynhdung/Projects/research/flutter/bin:$PATH"

# Java
export JAVA_HOME=/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools

# pnpm
export PNPM_HOME="/Users/huynhdung/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# increase memory for nodejs
export NODE_OPTIONS=--max_old_space_size=8192

# Moon
export PATH="/Users/huynhdung/.moon/bin:$PATH"

. "$HOME/.cargo/env"

# Pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
source "$HOME/.rye/env"

# grit
export GRIT_INSTALL="$HOME/.grit"
export PATH="$GRIT_INSTALL/bin:$PATH"

# Mise
eval "$(~/.local/bin/mise activate zsh)"
eval "$(mise hook-env -s zsh)"

# Go
export PATH="$PATH:$(go env GOPATH)/bin"
export PATH="$PATH:$(go env GOROOT)/bin"
export GOPATH="$(go env GOPATH)"
export GOROOT="$(go env GOROOT)"

[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"

alias claude-mem='bun "/Users/huynhdung/.claude/plugins/marketplaces/thedotmack/plugin/scripts/worker-service.cjs"'

if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init zsh)"; fi
