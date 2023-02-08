#!/bin/env bash
set -e

echo "Welcome!" && sleep 2

#Default vars
HELPER="paru"

# does full system update
echo "Doing a system update, cause stuff may break if it's not the latest version..."
sudo pacman --noconfirm -Syu

echo "###########################################################################"
echo "Will do stuff, get ready"
echo "###########################################################################"

# install base-devel if not installed
sudo pacman -S --noconfirm --needed base-devel wget git

# Choose an AUR helper and install needed dependencies + Awesome itself (the git version of course)
echo "We need an AUR helper. It is essential. 1) paru       2) yay"
read -r -p "What is the AUR helper of your choice? (Default is paru): " num

if [ $num -eq 2 ]
then
    HELPER="yay"
fi

if ! command -v $HELPER &> /dev/null
then
    echo "It seems that you don't have $HELPER installed, I'll install that for you before continuing."
        git clone https://aur.archlinux.org/$HELPER.git ~/.srcs/$HELPER
        (cd ~/.srcs/$HELPER/ && makepkg -si )
fi

$HELPER -Sy --needed picom-git  \
            wezterm             \
            rofi                \
            acpi                \
            acpid               \
            acpi_call           \
            upower              \
            lxappearance-gtk3   \
            jq                  \
            inotify-tools       \
            polkit-gnome        \
            xdotool             \
            xclip               \
            gpick               \
            ffmpeg              \
            blueman             \ 
            redshift            \
            pipewire            \
            pipewire-alsa       \
            pipewire-pulse      \
            alsa-utils          \
            brightnessctl       \
            feh                 \
            maim                \
            mpv                 \
            mpd                 \
            mpc                 \
            mpdris2             \
            python-mutagen      \
            ncmpcpp             \
            playerctl           \
            awesome-git         \

sudo systemctl --user enable mpd.service
sudo systemctl --user start mpd.service

# Clone the repo :D
git clone --depth 1 --recurse-submodules https://github.com/rxyhn/yoru.git
cd yoru && git submodule update --remote --merge