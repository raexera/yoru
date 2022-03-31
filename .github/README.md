<!-- Screenshot -->
<div align="center">
    <img src="https://awesomewm.org/images/awesome-logo.svg">
</div>

<br>

<div align="center">
    <img src="assets/awesome.png" alt="Rice Preview">
</div>

<br>
<br>

<a href="https://awesomewm.org/"><img alt="AwesomeWM Logo" height="160" align = "left" src="https://awesomewm.org/doc/api/images/AUTOGEN_wibox_logo_logo_and_name.svg"></a>
<b>  Aesthetic AwesomeWM Dotfiles  </b>

Welcome to my AwesomeWM configuration files! 

so yeah now i'm using awesomewm, looks like i'll be use this wm forever.

Because only this wm can satisfy me.

Fyi, I use night colorscheme, and it's so beautiful.

These dotfiles are made with love, for sure.

<h2></h2><br>

**Here are some details about my setup:**

| Programs   | Using             |
| ---------- | ----------------- |
| WM         | awesome           |
| OS         | arch linux        |
| Terminal   | alacritty         |
| Shell      | zsh               |
| Editor     | neovim / vscode   |
| Compositor | picom             |
| Launcher   | rofi              |

<h2></h2><br>

<details>
<summary><strong>S E T U P</strong></summary>

   > This is step-by-step how to install these dotfiles. Just [R.T.F.M](https://en.wikipedia.org/wiki/RTFM).

   1. Install dependencies and enable services

      + Dependencies

      - **Arch Linux** (and all Arch-based distributions)

            *Assuming your AUR helper is* `yay`

            ```shell
            yay -Sy awesome-git picom-git alacritty rofi todo-bin acpi acpid \
            wireless_tools jq inotify-tools polkit-gnome xdotool xclip maim \
            brightnessctl alsa-utils alsa-tools pulseaudio lm_sensors \
            mpd mpc mpdris2 ncmpcpp playerctl --needed 
            ```

      + Services

         ```shell
         # For automatically launching mpd on login
         systemctl --user enable mpd.service
         systemctl --user start mpd.service

         # For charger plug/unplug events (if you have a battery)
         sudo systemctl enable acpid.service
         sudo systemctl start acpid.service
         ```

   2. Install needed fonts

      You will need to install a few fonts (mainly icon fonts) in order for text and icons to be rendered properly.

      Necessary fonts:
      + **Iosevka**  - [here](https://github.com/ryanoasis/nerd-fonts/)
      + **Icomoon**  - [here](https://www.dropbox.com/s/hrkub2yo9iapljz/icomoon.zip?dl=0)
      + **Material** - [here](https://github.com/google/material-design-icons)

      Once you download them and unpack them, place them into `~/.fonts` or `~/.local/share/fonts`.
   
   3. Install my AwesomeWM configuration files

      > Clone this repository

      ```shell
      git clone https://github.com/rxyhn/dotfiles.git
      cd dotfiles
      ```

      > Copy config and binaries files

      ```shell
      cp -r config/* ~/.config/
      cp -r bin/* ~/.local/bin/
      cp -r misc/. ~/
      ```

      > You have to add `TODO_PATH` in your env variable

      ```shell
      export TODO_PATH="path/to/todo"
      ```

   4. Configure stuff

      The relevant files are inside your `~/.config/awesome` directory.

      + User preferences and default applications

         In `rc.lua` there is a *Default Applications* section where user preferences and default applications are defined.
         You should change those to your liking.

         Note: For the weather widgets to work, you will also need to create an account on [openweathermap](https://openweathermap.org), get your key, look for your city ID, and set `openweathermap_key` and `openweathermap_city_id` accordingly.

   5. Lastly, log out from your current desktop session and log in into AwesomeWM.

</details>

<br>

<details>
<summary><strong>F E A T U R E S</strong></summary>

<b>These are the features included in my AwesomeWM setups!</b>


   + Beautiful `colorscheme` ikr, named `night` and created by [ner0z](https://github.com/ner0z)
   + Aesthetic `Dashboard` ngl.
   + Custom mouse-friendly `ncmpcpp` UI with album art ofc.
      - <details>
         <summary>Preview</summary>

         *this is so aesthetic isn't it?*

         <div align="left">
         <img src="assets/ncmpcpp.png" width="500px" alt="ncmpcpp preview">
         </div>
         </details>
   + `Word Clock Lockscreen` with PAM Integration
      - <details>

         *A beautiful word clock is on the lockscreen!*

         <summary>Preview</summary>
         <div align="left">
         <img src="assets/lockscreen.png" width="500px" alt="word clock lockscreen preview">
         </div>
         </details>
   + Notification Center
   + Control Panel
   + ToDo Reminder
   + Battery Indicator
   + PopUp Notifications
   + Applications Launcher
   + Some Tooltip Widget
   + Hardware Monitor

</details>

<br>

<details>
<summary><strong>K E Y B I N D S</strong></summary>

I use <kbd>super</kbd> AKA Windows key as my main modifier.
also with <kbd>alt, shift, and ctrl</kbd>

**Keyboard**

| Keybind                                 | Action                                                    |
|-----------------------------------------|-----------------------------------------------------------|
| <kbd>super + enter</kbd>                | Spawn terminal                                            |
| <kbd>super + w</kbd>                    | Spawn web browser                                         |
| <kbd>super + x</kbd>                    | Spawn color picker                                        |
| <kbd>super + f</kbd>                    | Spawn file manager                                        |
| <kbd>super + d</kbd>                    | Launch applications launcher                              |
| <kbd>super + shift + d</kbd>            | Toggle dashboard                                          |
| <kbd>super + q</kbd>                    | Close client                                              |
| <kbd>super + ctrl + l</kbd>             | Toggle lock screen                                        |
| <kbd>super + [1-0]</kbd>                | View tag AKA change workspace (for you i3/bsp folks)      |
| <kbd>super + shift + [1-0]</kbd>        | Move focused client to tag                                |
| <kbd>super + space</kbd>                | Select next layout                                        |
| <kbd>super + s</kbd>                    | Set tiling layout                                         |
| <kbd>super + shift + s</kbd>            | Set floating layout                                       |
| <kbd>super + c</kbd>                    | Center floating client                                    |
| <kbd>super + [arrow keys]</kbd>         | Change focus by direction                                 |
| <kbd>super + shift + f</kbd>            | Toggle fullscreen                                         |
| <kbd>super + m</kbd>                    | Toggle maximize                                           |
| <kbd>super + n</kbd>                    | Minimize                                                  |
| <kbd>ctrl + shift + n</kbd>             | Restore minimized                                         |
| <kbd>alt + tab</kbd>                    | Window switcher                                           |

<br>

**Mouse on the desktop**

| Mousebind          | Action                                     |
|--------------------|--------------------------------------------|
| `left click`       | Dismiss all notifications                  |
| `right click`      | App drawer                                 |
| `middle click`     | Toggle Dashboard                           |
| `scroll up/down`   | Cycle through tags                         |

*... And many many more! for more information check `awesome/configuration/keys.lua`*

</details>

<h2></h2><br>

**Acknowledgements**

   - **Credits**
      + [ner0z](https://github.com/ner0z)

   - **Special thanks to**
      + [ChocolateBread799](https://github.com/ChocolateBread799)
      + [JavaCafe01](https://github.com/JavaCafe01)

<h2></h2><br>

<p align="center"><a href="https://github.com/rxyhn/AwesomeWM-Dotfiles/blob/main/.github/LICENSE"><img src="https://img.shields.io/static/v1.svg?style=flat-square&label=License&message=GPL-3.0&logoColor=eceff4&logo=github&colorA=061115&colorB=67AFC1"/></a></p>
