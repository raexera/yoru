#!/usr/bin/env bash

#   ██╗  ██╗ ██████╗ ██████╗ ██╗      ██████╗ ██████╗ 
#   ╚██╗██╔╝██╔════╝██╔═══██╗██║     ██╔═══██╗██╔══██╗
#    ╚███╔╝ ██║     ██║   ██║██║     ██║   ██║██████╔╝
#    ██╔██╗ ██║     ██║   ██║██║     ██║   ██║██╔══██╗
#   ██╔╝ ██╗╚██████╗╚██████╔╝███████╗╚██████╔╝██║  ██║
#   ╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚══════╝ ╚═════╝ ╚═╝  ╚═╝
# color picker for X.
# Simple Script To Pick Color Quickly Using Gpick.
#
# @author rxyhn
# https://github.com/rxyhn 

CMD=$(gpick --no-newline -pso)
TMP=/tmp/xcolor_$CMD.png

check_dependencies() {
    ! command -v gpick &>/dev/null &&
        notify-send -u critical -a "Color Picker" xcolor-pick "gpick needs to be installed" && exit 1

    ! command -v magick &>/dev/null &&
        notify-send -u critical -a "Color Picker" xcolor-pick "imagemagick needs to be installed" && exit 1
}

main() {
    convert -size 120x120 xc:"$CMD" "$TMP"
    printf %s "$CMD" | xclip -selection clipboard

    notify-send -a "Color Picker" -i "$TMP" xcolor-pick "$CMD"
}

check_dependencies
main
