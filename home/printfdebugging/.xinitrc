#!/bin/bash

flameshot &
nm-applet &
pasystray &
blueman-applet &
gtimelog &
dunst &
[ "$(find /sys/class/power_supply | grep -c "BAT.*")" -ne 0 ] && cbatticon &
dispscript
xcompmgr &

while :; do
    ssh-agent dwm
done
