# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# We use Starship when available, so keep the Oh My Zsh theme quiet.
ZSH_THEME=""

plugins=(git)

source "$ZSH/oh-my-zsh.sh"

setopt hist_ignore_all_dups
setopt share_history
setopt auto_cd

HISTSIZE=1000
SAVEHIST=1000
HISTFILE="$HOME/.zsh_history"

bindkey -e

if command -v nvim >/dev/null 2>&1; then
  export EDITOR="nvim"
elif command -v vim >/dev/null 2>&1; then
  export EDITOR="vim"
else
  export EDITOR="nano"
fi
export VISUAL="$EDITOR"

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
  alias cd="z"
fi

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
  . "$NVM_DIR/nvm.sh"
fi

if [ -s "$NVM_DIR/bash_completion" ]; then
  . "$NVM_DIR/bash_completion"
fi

alias copy="pbcopy"
alias paste="pbpaste"
alias ccopy="pbcopy"

if command -v bat >/dev/null 2>&1; then
  alias cat="bat"
fi

if command -v eza >/dev/null 2>&1; then
  alias ls="eza"
elif command -v lsd >/dev/null 2>&1; then
  alias ls="lsd"
fi

alias ll="ls -alF"
alias la="ls -A"
alias l="ls -CF"

alias clauded="claude --dangerously-skip-permissions"
alias claudedr="claude --dangerously-skip-permissions --resume"
alias claudedc="claude --dangerously-skip-permissions --continue"
alias weather="curl wttr.in"
alias yupdate="brew update && brew upgrade"
alias gn="sudo shutdown -h now"

# Auto-start tmux for interactive Ghostty shells.
if command -v tmux >/dev/null 2>&1 && [ -z "$TMUX" ] && [ "$TERM_PROGRAM" = "ghostty" ]; then
  tmux new-session -A -s main
fi
