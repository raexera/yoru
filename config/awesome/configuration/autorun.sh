#!/usr/bin/env bash

function run {
  if ! pgrep -f $1 ;
  then
    $@&
  fi
}

# compositor
run picom --experimental-backends --config $HOME/.config/picom/picom.conf

# auth
run /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1
