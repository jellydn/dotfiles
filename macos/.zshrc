# ── Locale ──
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# ── Editor ──
export EDITOR=nvim
export VISUAL=nvim

# ── Pure prompt ──
# https://github.com/sindresorhus/pure
fpath+=("$(brew --prefix)/share/zsh/site-functions")
autoload -U promptinit; promptinit
prompt pure

# ── History ──
HISTSIZE=100000
SAVEHIST=100000
HISTFILE="$HOME/.zsh_history"
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE

# ── Tools ──
eval "$(atuin init zsh)"
eval "$(zoxide init zsh)"
eval "$(direnv hook zsh)"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# ── Python ──
for ver in 3.11 3.12 3.13; do
  p="$HOME/Library/Python/$ver/bin"
  [ -d "$p" ] && PATH="$p:$PATH"
done
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# ── Rust / Cargo ──
. "$HOME/.cargo/env"

# ── Go ──
if command -v go &>/dev/null; then
  export GOPATH="$(go env GOPATH)"
  export GOROOT="$(go env GOROOT)"
  export PATH="$GOPATH/bin:$GOROOT/bin:$PATH"
fi

# ── JS runtimes ──
export BUN_INSTALL="$HOME/.bun"
export DENO_INSTALL="$HOME/.deno"
export PNPM_HOME="$HOME/Library/pnpm"
export PATH="$BUN_INSTALL/bin:$DENO_INSTALL/bin:$PNPM_HOME:$PATH"
export NODE_OPTIONS="--max_old_space_size=8192"

# ── Paths ──
export PATH="$PATH:/usr/local/sbin"
export PATH="$PATH:$HOME/.local/bin"
export PATH="$PATH:$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin"
export PATH="$PATH:$HOME/.grit/bin"
export PATH="$PATH:$HOME/.moon/bin"
export PATH="$PATH:$HOME/go/bin"
export PATH="$PATH:$HOME/.opencode/bin"
export PATH="$PATH:$HOME/.grok/bin"
export PATH="$PATH:$HOME/.antigravity-ide/antigravity-ide/bin"

# ── Java / Android ──
export JAVA_HOME=/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home
export ANDROID_HOME="$HOME/Library/Android/sdk"
export PATH="$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools"

# ── Aliases ──
alias v='nvim'
alias vi='nvim'
alias vim='nvim'
alias cat='bat'
alias lvim="NVIM_APPNAME=lazyvim nvim"
alias lg='lazygit'

# Git aliases (mirrors fish abbr)
alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gau='git add --update'
alias gapa='git add --patch'
alias gb='git branch -vv'
alias gba='git branch -a -v'
alias gbd='git branch -d'
alias gbD='git branch -D'
alias gc='git commit -v'
alias gca='git commit -v -a'
alias gcm='git commit -m'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gd='git diff'
alias gdca='git diff --cached'
alias gl='git pull'
alias glg='git log --stat'
alias glog='git log --oneline --decorate --color --graph'
alias gp='git push'
alias gpo='git push origin'
alias gpu='git push --set-upstream origin'
alias grb='git rebase'
alias grba='git rebase --abort'
alias grbc='git rebase --continue'
alias gsb='git status -sb'
alias gst='git status'
alias gsta='git stash'
alias gstaa='git stash apply'
alias gstd='git stash drop'
alias gstl='git stash list'
alias gstp='git stash pop'

# Conditional aliases
if [ -x ~/.claude/local/claude ]; then
  alias claude='~/.claude/local/claude'
fi

# Walk
export WALK_EDITOR=nvim
function lk { cd "$(walk --icons "$@")"; }

# try — interactive project selector (https://github.com/tobi/try)
if [ -f "$HOME/.local/try.rb" ]; then
  function try {
    local cmd
    cmd=$(/usr/bin/env ruby "$HOME/.local/try.rb" cd --path "$HOME/src/tries" "$@" 2>/dev/tty)
    local rc=$?
    if [ $rc -eq 0 ]; then
      if echo "$cmd" | grep -q ' && '; then
        eval "$cmd"
      else
        cd "$cmd"
      fi
    else
      echo "$cmd" >&2
    fi
  }
fi

# ── Misc integrations ──
[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"
if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init zsh)"; fi

# ── mise (last so shims take precedence) ──
eval "$(~/.local/bin/mise activate zsh)"
eval "$(mise hook-env -s zsh)"
