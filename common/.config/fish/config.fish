if status is-interactive
    # Commands to run in interactive sessions can go here
end
~/.local/bin/mise activate fish | source
if command -v zoxide >/dev/null
    zoxide init fish | source
end
source "$HOME/.cargo/env.fish"
if test -f ~/.cmdk/cmdk.fish
    source ~/.cmdk/cmdk.fish
end

# Alias
alias v="nvim"
alias lg="lazygit"
alias claude="~/.claude/local/claude"
alias ccs="~/.claude/local/claude --dangerously-skip-permissions"

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

# Need to install https://github.com/tobi/try
eval "$(~/.local/try.rb init ~/src/tries | string collect)"
