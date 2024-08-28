# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

export ZSH="$HOME/.config/.oh-my-zsh"
#ZSH_THEME="alanpeabody"

PROMPT='%F{167}ϟ%f %B%F{240}%1~ %f%b'
# PROMPT='%F{167}∂%f %B%F{240}%1~ %f%b'

plugins=(git)

source $ZSH/oh-my-zsh.sh

# Preferred editor for local and remote sessions
 if [[ -n $SSH_CONNECTION ]]; then
   export EDITOR='nvim'
 else
   export EDITOR='vim'
 fi

alias v="nvim"
alias jn="jupyter-notebook"
alias firefox="/mnt/c/Program\ Files/Mozilla\ Firefox/firefox.exe"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/sapien/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/sapien/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/home/sapien/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/sapien/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

