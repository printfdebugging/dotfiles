# Enable colors and change prompt:
autoload -U colors && colors
PROMPT='%F{green}%f%F{blue}%c%f %F{yellow}${vcs_info_msg_0_}%f%F{green}$ %f'

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

# Load zsh-syntax-highlighting; should be last.
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null



if type rg &> /dev/null; then
  export FZF_DEFAULT_COMMAND='rg --files'
  export FZF_DEFAULT_OPTS='-m'
fi

autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats '%b '
setopt PROMPT_SUBST

##############
#   EXPORTS  #
##############
export GPG_AGENT_INFO="$(gpgconf --list-dirs agent-socket)/S.gpg-agent:0:1"
export SAL_NO_MOUSEGRABS=T
export PATH="/home/$USER/.local/bin:$PATH"
export EDITOR=nvim
export GTK_THEME=Adwaita:dark
export GPG_AGENT_INFO="$(gpgconf --list-dirs agent-socket)/S.gpg-agent:0:1"
export GOHOME=$HOME/.go
export GOPATH="/home/$USER/.local/go"
export PATH="${PATH}:${GOPATH}/bin"
export GO_TABWIDTH=4

export XDG_DESKTOP_DIR="$HOME/downloads"
export XDG_DOCUMENTS_DIR="$HOME/downloads"
export XDG_DOWNLOAD_DIR="$HOME/downloads"
export XDG_MUSIC_DIR="$HOME/downloads"
export XDG_PICTURES_DIR="$HOME/downloads"
export XDG_PUBLICSHARE_DIR="$HOME/downloads"
export XDG_TEMPLATES_DIR="$HOME/downloads"
export XDG_VIDEOS_DIR="$HOME/downloads"


##############
#   ALIASES  #
##############
alias t='tmux'
alias v='nvim'
alias c="cd /home/$USER/"
alias l="cd /home/$USER/repos/libreoffice/"
alias x="clear"
alias dif="git diff HEAD~ HEAD | delta"

alias e="[ -f '/home/printfdebugging/repos/libreoffice/instdir/program/libcurl.so.4' ] \
    && rm /home/printfdebugging/repos/libreoffice/instdir/program/libcurl.so.4; \
    SAL_USE_VCLPLUGIN=kf5 /home/printfdebugging/repos/libreoffice/instdir/program/soffice"

alias f="[ -f '/home/printfdebugging/repos/libreoffice/instdir/program/libcurl.so.4' ] \
    && rm /home/printfdebugging/repos/libreoffice/instdir/program/libcurl.so.4; \
    SAL_USE_VCLPLUGIN=kf6 /home/printfdebugging/repos/libreoffice/instdir/program/soffice"

alias g="SAL_USE_VCLPLUGIN=gtk3 /home/printfdebugging/repos/libreoffice/instdir/program/soffice"

alias cr="cd ~/repos/"
alias cm="cd ~/repos/media/"
alias cr="cd ~/repos/"
alias msu="sudo make clean install"
alias ssha='eval $(ssh-agent) && ssh-add'
alias list="nvim /home/$USER/repos/notes/bookmarks.md"
alias bin="nvim /home/$USER/.local/bin"
alias hss="zola serve"

alias ls='ls --color=auto'
alias ll='ls -al --color=auto'
alias grep='grep --color=auto'
alias n="cd ~/repos/website/content && nvim README.md"
alias b="cmake -B build && cd build && make && ./application && cd .."

## GIT
alias tr="git log --all --oneline --graph --decorate"
alias stat="git status"
alias br="git branch"
alias gca="git commit --amend"
alias xi="sudo xbps-install"
alias xr="sudo xbps-remove"

# export QT_QPA_PLATFORMTHEME=gtk3
export LOCOREPATH=/home/printfdebugging/repos/libreoffice
export COOL_SERVE_FROM_FS=1

if grep -q '^NAME="Arch Linux"' /etc/os-release; then
    export QT5DIR=/usr/lib/qt
else
    export QT5DIR=/usr/lib/qt5
fi

export QT6DIR=/usr/lib/qt6
