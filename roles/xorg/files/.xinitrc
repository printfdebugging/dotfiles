#!/bin/bash

if [ $(find /sys/class/power_supply | grep -e "BAT*" | wc -l) -eq 0 ]; then
    export DEVICE_TYPE=computer
else
    export DEVICE_TYPE=laptop
    cbatticon &
fi

gpg-agent --daemon &
dispscript
flameshot &
nm-applet &
pasystray &
blueman-applet &
xcompmgr &
dunst &

session=${1:-dwm}
case $session in
    dwm) exec dwm;;
    *)   exec $1;;
esac

