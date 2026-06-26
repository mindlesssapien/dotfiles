if status is-interactive
# Commands to run in interactive sessions can go here
set -g fish_greeting

set PATH "$HOME/.local/bin:$PATH"

# Set up fzf key bindings
fzf --fish | source

# Environment variables
set -gx EDITOR nvim
set -gx HSA_OVERRIDE_GFX_VERSION 10.3.0
#set <SHIFT-TAB>

# Use uv tools installed in ~/.local/bin
fish_add_path ~/.local/bin

alias v="nvim"
alias ffv='nvim $(fzf -m --preview="bat -n {}")'
alias tmux='tmux -u'

# opencode
fish_add_path /home/sapien/.opencode/bin

end

