# Enable colors and change prompt:
autoload -U colors && colors
PROMPT='%F{green}%f%F{blue}%c%f %F{yellow}${vcs_info_msg_0_}%f %F{green}󰣇  %f'

# History in cache directory:
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.cache/zsh/history

# Basic auto/tab complete:
# setopt NO_CASE_GLOB
autoload -U compinit
# zstyle ':completion:*' menu select
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS} "ma=48;2;255;0;0;38;2;0;255;0"
# zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zmodload zsh/complist
compinit
_comp_options+=(globdots)		# Include hidden files.

# vi mode
bindkey -v
export KEYTIMEOUT=1

# Use vim keys in tab complete menu:
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -v '^?' backward-delete-char

# Change cursor shape for different vi modes.
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] ||
     [[ $1 = 'block' ]]; then
    echo -ne '\e[1 q'
  elif [[ ${KEYMAP} == main ]] ||
       [[ ${KEYMAP} == viins ]] ||
       [[ ${KEYMAP} = '' ]] ||
       [[ $1 = 'beam' ]]; then
    echo -ne '\e[5 q'
  fi
}
zle -N zle-keymap-select
zle-line-init() {
    zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
    echo -ne "\e[5 q"
}
zle -N zle-line-init
echo -ne '\e[5 q' # Use beam shape cursor on startup.
preexec() { echo -ne '\e[5 q' ;} # Use beam shape cursor for each new prompt.

# Use lf to switch directories and bind it to ctrl-o
lfcd () {
    tmp="$(mktemp)"
    lf -last-dir-path="$tmp" "$@"
    if [ -f "$tmp" ]; then
        dir="$(cat "$tmp")"
        rm -f "$tmp"
        [ -d "$dir" ] && [ "$dir" != "$(pwd)" ] && cd "$dir"
    fi
}
bindkey -s '^o' 'lfcd\n'

# Edit line in vim with ctrl-e:
autoload edit-command-line; zle -N edit-command-line
bindkey '^e' edit-command-line

# Load aliases and shortcuts if existent.
[ -f "$HOME/.config/shortcutrc" ] && source "$HOME/.config/shortcutrc"
[ -f "$HOME/.config/aliasrc" ] && source "$HOME/.config/aliasrc"

# Load zsh-syntax-highlighting; should be last.
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null



alias ls='ls --color=auto'
alias ll='ls -al --color=auto'
alias grep='grep --color=auto'

# keyboard settings
xset r rate 300 50
setxkbmap -option caps:swapescape
setxkbmap -option ctrl:swap_ralt_rctl

alias cr="cd ~/repos/"
alias cm="cd ~/repos/media/"
alias cr="cd ~/repos/"
alias msu="sudo make clean install"
alias md="cd ~/.local/src/dwm/ && msu"
alias ssha='eval $(ssh-agent) && ssh-add'
alias list="nvim /home/$USER/.local/share/bookmarks.md"
alias bin="nvim /home/$USER/repos/github/bin"

# GIT
alias tr="git log --all --oneline --graph --decorate"
alias stat="git status"
alias br="git branch"
alias gca="git commit --amend"
alias hss="hugo serve -D"

# NOTES
# alias s="cd /home/$USER/repos/website/content/ && nvim ."

# GENERAL TRAVEL AND TRANSACTIONS
alias t='tmux'
alias v='nvim'
alias n='cd ~/repos/github/notes/content/ && nvim _index.md'
alias c="cd /home/$USER/"
alias l="cd /home/$USER/repos/libreoffice/"
alias dif="git diff HEAD~ HEAD | delta"
alias e="[ -f '/home/printf/repos/libreoffice/instdir/program/libcurl.so.4' ] && rm /home/printf/repos/libreoffice/instdir/program/libcurl.so.4; SAL_USE_VCLPLUGIN=kf5 /home/printf/repos/libreoffice/instdir/program/soffice"
alias ee="/home/printf/repos/libreoffice/instdir/program/soffice"

if type rg &> /dev/null; then
  export FZF_DEFAULT_COMMAND='rg --files'
  export FZF_DEFAULT_OPTS='-m'
fi

# for libreoffice debugging.
export SAL_NO_MOUSEGRABS=T

autoload -Uz vcs_info
precmd() { vcs_info }

zstyle ':vcs_info:git:*' formats '%b '
setopt PROMPT_SUBST
export GPG_AGENT_INFO="$(gpgconf --list-dirs agent-socket)/S.gpg-agent:0:1"

export GOPATH=$HOME/.go
