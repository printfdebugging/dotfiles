[[ -f ~/.zshrc ]] && . ~/.zshrc

if [ -z "$DISPLAY" ] && [ "$(fgconsole)" -eq 1 ]; then
    startx
fi

