#!/bin/bash

# run various utility daemons
flameshot &
nm-applet &
pasystray &
blueman-applet &
alarm-clock-applet &
dunst &
[ "$(find /sys/class/power_supply | grep -c "BAT.*")" -ne 0 ] && cbatticon &

# run display script and compositor
dispscript
xcompmgr &

session=${1:-dwm}

case $session in
dwm) exec dwm ;;
*) exec $1 ;;
esac
