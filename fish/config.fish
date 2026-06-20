if status is-interactive
# Commands to run in interactive sessions can go here
end

set -g fish_greeting

set PATH "$HOME/.local/bin:$PATH"

# Environment variables
set -gx EDITOR nvim
set -gx HSA_OVERRIDE_GFX_VERSION 10.3.0

# Use uv tools installed in ~/.local/bin
fish_add_path ~/.local/bin

alias v="nvim"
