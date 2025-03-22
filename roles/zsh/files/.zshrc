# ▄▄▄▄▄▄    ▄▄▄▄▄▄      ▄▄▄▄    ▄▄▄  ▄▄▄  ▄▄▄▄▄▄    ▄▄▄▄▄▄▄▄
# ██▀▀▀▀█▄  ██▀▀▀▀██   ██▀▀██   ███  ███  ██▀▀▀▀█▄  ▀▀▀██▀▀▀
# ██    ██  ██    ██  ██    ██  ████████  ██    ██     ██
# ██████▀   ███████   ██    ██  ██ ██ ██  ██████▀      ██
# ██        ██  ▀██▄  ██    ██  ██ ▀▀ ██  ██           ██
# ██        ██    ██   ██▄▄██   ██    ██  ██           ██
# ▀▀        ▀▀    ▀▀▀   ▀▀▀▀    ▀▀    ▀▀  ▀▀           ▀▀


# enable colors and change prompt:
autoload -U colors && colors
PROMPT='%F{green}%f%F{blue}%c%f %F{yellow}${vcs_info_msg_0_}%f%F{green}$ %f'


# git info on the prompt
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats '%b '
setopt PROMPT_SUBST


# use vi mode on terminal prompt
bindkey -v
export KEYTIMEOUT=1


# find file history in cache directory
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.cache/zsh/history


# tab autocompletion settings
autoload -U compinit
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS} "ma=48;2;255;0;0;38;2;0;255;0"
zmodload zsh/complist
compinit
_comp_options+=(globdots)


# edit line in editor with ctrl-e
autoload edit-command-line; zle -N edit-command-line
bindkey '^e' edit-command-line

# load zsh-syntax-highlighting
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null


# ▄▄▄▄▄▄▄▄  ▄▄▄  ▄▄▄  ▄▄▄▄▄▄      ▄▄▄▄    ▄▄▄▄▄▄    ▄▄▄▄▄▄▄▄    ▄▄▄▄
# ██▀▀▀▀▀▀   ██▄▄██   ██▀▀▀▀█▄   ██▀▀██   ██▀▀▀▀██  ▀▀▀██▀▀▀  ▄█▀▀▀▀█
# ██          ████    ██    ██  ██    ██  ██    ██     ██     ██▄
# ███████      ██     ██████▀   ██    ██  ███████      ██      ▀████▄
# ██          ████    ██        ██    ██  ██  ▀██▄     ██          ▀██
# ██▄▄▄▄▄▄   ██  ██   ██         ██▄▄██   ██    ██     ██     █▄▄▄▄▄█▀
# ▀▀▀▀▀▀▀▀  ▀▀▀  ▀▀▀  ▀▀          ▀▀▀▀    ▀▀    ▀▀▀    ▀▀      ▀▀▀▀▀


# libreoffice exports
export LOCOREPATH=/home/printfdebugging/repos/libreoffice
export COOL_SERVE_FROM_FS=1
export QT5DIR=/usr/lib/qt5
export QT6DIR=/usr/lib/qt6
export SAL_DISABLEGL=1
export SAL_DISABLE_OPENCL=1
export SAL_NO_MOUSEGRABS=T


# system exports
export PATH="/home/$USER/.local/bin:$PATH"
export EDITOR=nvim
export GPG_TTY=$(tty)
export GTK_THEME=Nordic-darker
# export GPG_AGENT_INFO="$(gpgconf --list-dirs agent-socket)/S.gpg-agent:0:1"


# golang exports
export PATH="${PATH}:${GOPATH}/bin"
export GOPATH="/home/$USER/.local/go"
export GO_TABWIDTH=4
export GOHOME=$HOME/.go


#    ▄▄     ▄▄         ▄▄▄▄▄▄      ▄▄       ▄▄▄▄    ▄▄▄▄▄▄▄▄    ▄▄▄▄
#   ████    ██         ▀▀██▀▀     ████    ▄█▀▀▀▀█   ██▀▀▀▀▀▀  ▄█▀▀▀▀█
#   ████    ██           ██       ████    ██▄       ██        ██▄
#  ██  ██   ██           ██      ██  ██    ▀████▄   ███████    ▀████▄
#  ██████   ██           ██      ██████        ▀██  ██             ▀██
# ▄██  ██▄  ██▄▄▄▄▄▄   ▄▄██▄▄   ▄██  ██▄  █▄▄▄▄▄█▀  ██▄▄▄▄▄▄  █▄▄▄▄▄█▀
# ▀▀    ▀▀  ▀▀▀▀▀▀▀▀   ▀▀▀▀▀▀   ▀▀    ▀▀   ▀▀▀▀▀    ▀▀▀▀▀▀▀▀   ▀▀▀▀▀

# alias functions
ascii() {
    figlet -t -f mono12 $@  | lolcat 
}


# program aliases
alias t='tmux'
alias v='nvim'


# path aliases
alias  c="cd /home/$USER/"
alias  l="cd /home/$USER/repos/libreoffice/"
alias cr="cd ~/repos/"
alias  d="cd ~/repos/dotfiles/"
alias  b="cd ~/.local/bin/"


# git aliases
alias stat="git status"
alias  gca="git commit --amend"
alias  dif="git diff HEAD~ HEAD | delta"
alias   tr="git log --all --oneline --graph --decorate"
alias   br="git branch"
alias   gc="git clone"


# command aliases
alias ssha='eval $(ssh-agent) && ssh-add'
alias  msu="sudo make clean install"
alias  sdm="sudo ln -s /etc/sv/sddm /var/service/"
alias  kdm="sudo rm -rf /var/service/sddm"
alias    e="export SAL_USE_VCLPLUGIN=kf5;  /home/printfdebugging/repos/libreoffice/instdir/program/soffice"
alias    f="export SAL_USE_VCLPLUGIN=kf6;  /home/printfdebugging/repos/libreoffice/instdir/program/soffice"
alias    g="export SAL_USE_VCLPLUGIN=gtk3; /home/printfdebugging/repos/libreoffice/instdir/program/soffice"
alias    p="projects"


# package manager aliases
alias xi="sudo xbps-install"
alias xr="sudo xbps-remove"
alias xf="xbps-fetch -o "


# system command overrides
alias grep='grep --color=auto'
alias   ls='ls --color=auto'
alias   ll='ls -al --color=auto'
