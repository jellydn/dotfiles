# Recommend using Fish Shell: https://fishshell.com/
# Fisher: https://github.com/jorgebucaran/fisher
# Pure Prompt: https://pure-fish.github.io/pure/
# fisher install pure-fish/pure
# Git alias
# fisher install jhillyerd/plugin-git
# Theme: fisher install uajqq/fish-kanagawa
# fish_config theme save "Kanagawa"

# Interactive session setup
if status is-interactive
    # zoxide setup: https://github.com/ajeetdsouza/zoxide
    if type -q zoxide
        zoxide init fish | source
    end

    # direnv setup: https://direnv.net/docs/hook.html#fish
    if type -q direnv
        direnv hook fish | source
    end

    # mise setup: https://mise.jdx.dev/installing-mise.html#fish
    if test -f ~/.local/bin/mise
        ~/.local/bin/mise activate fish | source
        ~/.local/bin/mise hook-env -s fish | source
    end
end

# Locale configuration
set -x LANG en_US.UTF-8
set -x LC_ALL en_US.UTF-8

# Aliases
alias v 'nvim'
alias lvim 'env NVIM_APPNAME=lazyvim nvim'
# Bat: https://github.com/sharkdp/bat
alias cat 'bat'

# Add paths
fish_add_path "/usr/local/sbin" "/opt/homebrew/bin" "/opt/homebrew/sbin"
fish_add_path "$HOME/.cargo/bin" "$HOME/.warpstream" "$HOME/.moon/bin" "$HOME/.grit/bin"
fish_add_path "$HOME/Library/Python/3.11/bin/"

# Bun setup: https://bun.sh/docs/installation or https://mise.jdx.dev/lang/bun.html
# mise use -g bun@latest  # install latest bun
set -gx BUN_INSTALL "$HOME/.bun"
fish_add_path "$BUN_INSTALL/bin"

# Deno setup: https://deno.com/runtime or https://mise.jdx.dev/lang/deno.html
# mise use -g deno@latest  # install latest deno
set -gx DENO_INSTALL "$HOME/.deno"
fish_add_path "$DENO_INSTALL/bin"

# Encore setup: https://encore.dev/docs/ts/install
set -gx ENCORE_INSTALL "$HOME/.encore"
fish_add_path "$ENCORE_INSTALL/bin"

# Rust setup: https://rustup.rs/ or https://mise.jdx.dev/lang/rust.html
if test -f "$HOME/.cargo/env.fish"
    source "$HOME/.cargo/env.fish"
end

# Walk setup: https://github.com/antonmedv/walk
set -x WALK_EDITOR nvim
function lk
    cd (walk --icons $argv)
end

# Install with mise: mise use -g go@latest
# https://mise.jdx.dev/lang/go.html#go
# Go configuration
if not set -q GOPATH
    set -gx GOPATH (go env GOPATH)
end
if not set -q GOROOT
    set -gx GOROOT (go env GOROOT)
end
fish_add_path $GOPATH/bin $GOROOT/bin

# Python setup
# https://mise.jdx.dev/lang/python.html
# Install with mise: mise use -g python@3.13
# Poetry: pipx install poetry
# Pyenv: https://github.com/pyenv/pyenv
function load_pyenv
    set -gx PYENV_ROOT "$HOME/.pyenv"
    fish_add_path "$PYENV_ROOT/bin"
    pyenv init - | source
end
function pyenv
    load_pyenv
    command pyenv $argv
end

# Node.js setup
# https://mise.jdx.dev/lang/node.html
# mise use -g node@lts
# Increase memory for Node.js
set -x NODE_OPTIONS --max_old_space_size=8192
