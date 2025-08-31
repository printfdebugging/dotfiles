# PROMPT

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


# EXPORTS


# libreoffice exports
export LOCOREPATH=/home/printfdebugging/repos/libreoffice
export COOL_SERVE_FROM_FS=1
export COOL_DEBUG=1
export QT5DIR=/usr/lib/qt5
export QT6DIR=/usr/lib/qt6
export SAL_DISABLEGL=1
export SAL_DISABLE_OPENCL=1
export SAL_NO_MOUSEGRABS=T
export CMAKE_POLICY_VERSION_MINIMUM=3.5
export MANWIDTH=80

# use libreoffice logging utilities for printfdebugging
export SAL_LOG="+INFO"
export SAL_LOG_FILE=~/downloads/logfile


# system exports
export PATH="/home/$USER/.local/bin:$PATH"
export PATH="$PATH:/home/printfdebugging/.cargo/bin"
export EDITOR=nvim
export GPG_TTY=$(tty)
export GTK_THEME=Arc-Darkest
export GPG_AGENT_INFO="$(gpgconf --list-dirs agent-socket)/S.gpg-agent:0:1"


# golang exports
export PATH="${PATH}:${GOPATH}/bin"
export GOPATH="/home/$USER/.local/go"
export GO_TABWIDTH=4
export GOHOME=$HOME/.go


# ALIASES


# alias functions
ascii() {
    figlet -t -f mono12 $@  | lolcat 
}

dif() {
    git diff HEAD~1 HEAD > "$(git rev-parse --abbrev-ref HEAD).diff"
}

review() {
    [ -z "$1" ] && echo "please provide the pull request ID" && return 1
    [ -z "$2" ] && echo "please provide the branch name" && return 2
    git fetch upstream pull/$1/head:$2
    git checkout $2
}

cool_configure() {
    ./autogen.sh
    ./configure --enable-silent-rules --with-lokit-path=${LOCOREPATH}/include \
            --with-lo-path=${LOCOREPATH}/instdir \
            --enable-debug --enable-cypress --without-system-nss
}

# program aliases
alias t='tmux'
alias v='nvim'
alias vim=vim-huge
alias make="make -O"
alias p="projects"


# path aliases
alias  c="cd"
alias  l="cd /home/$USER/repos/libreoffice/"
alias  o="cd /home/$USER/repos/online"
alias cr="cd ~/repos/"
alias  d="cd ~/repos/dotfiles/"
alias  b="cd ~/.local/bin/"
alias  n="cd ~/repos/notes/ && nvim"


# git aliases
alias stat="git status"
alias  gca="git commit --amend"
alias   tr="git log --all --oneline --graph --decorate"
alias   br="git branch"
alias   gc="git clone"


# command aliases
alias ssha='eval $(ssh-agent) && ssh-add'
alias  msu="sudo make clean install"
alias  hss="zola serve"
alias  sdm="sudo ln -s /etc/sv/gdm /var/service/"
alias  kdm="sudo rm -rf /var/service/gdm"
alias    e="export SAL_USE_VCLPLUGIN=kf5;  /home/printfdebugging/repos/libreoffice/instdir/program/soffice"
alias    f="export SAL_USE_VCLPLUGIN=kf6;  /home/printfdebugging/repos/libreoffice/instdir/program/soffice"
alias    g="export SAL_USE_VCLPLUGIN=gtk3; /home/printfdebugging/repos/libreoffice/instdir/program/soffice"


# package manager aliases
alias xi="sudo xbps-install"
alias xr="sudo xbps-remove"
alias xf="xbps-fetch -o "


# system command overrides
alias grep='grep --color=auto'
alias   ls='ls --color=auto'
alias   ll='ls -al --color=auto'

# for gnome TEMPORARY (don't add to dotfiles)
xset r rate 300 50
setxkbmap -option caps:swapescape
