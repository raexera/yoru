#!/usr/bin/env bash

function run {
  if ! pgrep -f $1 ;
  then
    $@&
  fi
}

# music
run mpd
run mpDris2 # add playerctl support to mpd

# compositor
run picom --config $HOME/.config/picom/picom.conf

# redshift
run redshift

# power manager
run xfce4-power-manager

# auth
run /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1
