if status is-interactive
    # Commands to run in interactive sessions can go here
end

if test -f ~/.local/bin/mise
    ~/.local/bin/mise activate fish | source
end

# Lazy-load zoxide
if command -v zoxide >/dev/null
    function z --description "Lazy-load zoxide"
        if test -z "$_zoxide_initialized"
            zoxide init fish | source
            set -gx _zoxide_initialized 1
        end
        z $argv
    end
end

if test -f "$HOME/.cargo/env.fish"
    source "$HOME/.cargo/env.fish"
end

if test -f ~/.cmdk/cmdk.fish
    source ~/.cmdk/cmdk.fish
end

# Alias
alias v="nvim"
alias lg="lazygit"

if test -x ~/.claude/local/claude
    alias claude="~/.claude/local/claude"
end

# Git aliases (based on jhillyerd/plugin-git)
abbr -a g git
abbr -a ga "git add"
abbr -a gaa "git add --all"
abbr -a gau "git add --update"
abbr -a gapa "git add --patch"
abbr -a gb "git branch -vv"
abbr -a gba "git branch -a -v"
abbr -a gbd "git branch -d"
abbr -a gbD "git branch -D"
abbr -a gc "git commit -v"
abbr -a gca "git commit -v -a"
abbr -a gcm "git commit -m"
abbr -a gco "git checkout"
abbr -a gcb "git checkout -b"
abbr -a gd "git diff"
abbr -a gdca "git diff --cached"
abbr -a gl "git pull"
abbr -a glg "git log --stat"
abbr -a glog "git log --oneline --decorate --color --graph"
abbr -a gp "git push"
abbr -a gpo "git push origin"
abbr -a gpu "git push --set-upstream origin"
abbr -a grb "git rebase"
abbr -a grba "git rebase --abort"
abbr -a grbc "git rebase --continue"
abbr -a gsb "git status -sb"
abbr -a gst "git status"
abbr -a gsta "git stash"
abbr -a gstaa "git stash apply"
abbr -a gstd "git stash drop"
abbr -a gstl "git stash list"
abbr -a gstp "git stash pop"

set -gx EDITOR nvim

# Kanagawa Fish shell theme
# A template was taken and modified from Tokyonight:
# https://github.com/folke/tokyonight.nvim/blob/main/extras/fish_tokyonight_night.fish
set -l foreground DCD7BA normal
set -l selection 2D4F67 brcyan
set -l comment 727169 brblack
set -l red C34043 red
set -l orange FF9E64 brred
set -l yellow C0A36E yellow
set -l green 76946A green
set -l purple 957FB8 magenta
set -l cyan 7AA89F cyan
set -l pink D27E99 brmagenta

# Syntax Highlighting Colors
set -g fish_color_normal $foreground
set -g fish_color_command $cyan
set -g fish_color_keyword $pink
set -g fish_color_quote $yellow
set -g fish_color_redirection $foreground
set -g fish_color_end $orange
set -g fish_color_error $red
set -g fish_color_param $purple
set -g fish_color_comment $comment
set -g fish_color_selection --background=$selection
set -g fish_color_search_match --background=$selection
set -g fish_color_operator $green
set -g fish_color_escape $pink
set -g fish_color_autosuggestion $comment

# Completion Pager Colors
set -g fish_pager_color_progress $comment
set -g fish_pager_color_prefix $cyan
set -g fish_pager_color_completion $foreground
set -g fish_pager_color_description $comment

# Install https://github.com/tobi/try if available
if test -f ~/.local/try.rb
    ~/.local/try.rb init ~/src/tries | string collect | source
end

# pnpm
set -gx PNPM_HOME "/home/dunghuynhduc/.local/share/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end

# opencode
fish_add_path /Users/huynhdung/.opencode/bin
fish_add_path ~/go/bin
