<!-- inspired by owl4ce's readme -->


<!-- DOTFILES BANNER -->
<div align="center">
   <a href="#--------">
      <img src="assets/rxhyn-dotfile-header.png" alt="Home Preview">
   </a>
</div>

<p align="center">
<a href="#wrench--setup"><img width="150px" style="padding: 0 10px;" src="assets/button-setup.png"></a>
<a href="https://github.com/rxyhn/dotfiles/wiki"><img width="150px" style="padding: 0 10px;" src="assets/button-wiki.png"></a>
<a href="#ocean--gallery"><img width="150px" style="padding: 0 10px;" src="assets/button-gallery.png"></a>
<a href="#money_with_wings--tip-jar"><img width="150px" style="padding: 0 10px;" src="assets/button-tipjar.png"></a>
</p>

<br>

<!-- RICE PREVIEW -->
<div align="center">
   <a href="#--------">
      <img src="assets/aesthetic.png" alt="Rice Preview">
   </a>
</div>

<br>

<!-- BADGES -->
<h1>
  <a href="#--------">
    <img alt="" align="left" src="https://img.shields.io/github/stars/rxyhn/dotfiles?color=162026&labelColor=162026&style=for-the-badge"/>
  </a>
  <a href="#--------">
    <img alt="" align="right" src="https://badges.pufler.dev/visits/rxyhn/dotfiles?style=for-the-badge&color=162026&logoColor=white&labelColor=162026"/>
  </a>
</h1>

<br>

## Hi there! Thanks for dropping by! :blue_heart:
<a href="https://awesomewm.org/"><img alt="AwesomeWM Logo" height="150" align = "left" src="https://awesomewm.org/doc/api/images/AUTOGEN_wibox_logo_logo_and_name.svg"></a>

<b>  Rxyhn's Aesthetic AwesomeWM Configuration Files!  </b>

Welcome to my AwesomeWM configuration files!

This is my personal collection of configuration files.

You might be here for looking my AwesomeWM configuration files? or looking for **Linux Rice** reference?

feel free to steal anything from here but don't forget to give me **credits** :)

AwesomeWM is the most powerful and highly configurable, next generation framework window manager for X, 
Although it takes time and effort to configure it, but I'm very satisfied with the result.

This is a beautiful user interface isn't it?

These dotfiles are made with love, for sure.

<!-- INFORMATION -->
## :snowflake: ‎ <samp>Information</samp> 

Here are some details about my setup:

- **OS:** [Arch Linux](https://archlinux.org)
- **WM:** [awesome](https://github.com/awesomeWM/awesome)
- **Terminal:** [alacritty](https://github.com/alacritty/alacritty)
- **Shell:** [zsh](https://www.zsh.org/)
- **Editor:** [neovim](https://github.com/neovim/neovim) / [vscode](https://github.com/microsoft/vscode)
- **Compositor:** [picom](https://github.com/yshui/picom)
- **Application Launcher:** [rofi](https://github.com/davatorium/rofi)
- **Music Player** [ncmpcpp](https://github.com/ncmpcpp/ncmpcpp)

AwesomeWM Modules:

- **[bling](https://github.com/blingcorp/bling)**
   + Adds new layouts, modules, and widgets that try to primarily focus on window management
- **[rubato](https://github.com/andOrlando/rubato)**
   + Creates smooth animations with a slope curve for awesomeWM
- **[layout-machi](https://github.com/xinhaoyuan/layout-machi)**
   + Manual layout for Awesome with an interactive editor
- **[color](https://github.com/andOrlando/color)**
   + Clean and efficient api for color conversion in lua 
- **[UPower Battery Widget](https://github.com/Aire-One/awesome-battery_widget)**
   + A UPowerGlib based battery widget for the Awesome WM

Main Features: 

- **Dashboard**
- **Full Animated Dock**
- **Info Center**
- **Control Center**
- **Notification Center**
- **Word Clock Lockscreen**
- **Exit Screen**
- **Music Player**
- **App Launcher**
- **Github Activity Previews**
- **Brightness / Volume OSD**
- **Battery Indicator**
- **Wifi Indicator**

<br>

> This repo has a wiki! You can check it by clicking ~~[here](https://www.youtube.com/watch?v=UIp6_0kct_U)~~ [here](https://github.com/rxyhn/dotfiles/wiki).

<!-- SETUP -->
## :wrench: ‎ <samp>Setup</samp>

>This is step-by-step how to install these dotfiles. Just [R.T.F.M](https://en.wikipedia.org/wiki/RTFM).

<details>
<summary><b>1. Install Required Dependencies and Enable Services</b></summary>

:warning: ‎ **This setup instructions only provided for Arch Linux (and other Arch-based distributions)** 

Assuming your *AUR Helper* is [paru](https://github.com/Morganamilo/paru).

> First of all you should install the [git version of AwesomeWM](https://github.com/awesomeWM/awesome/).

   ```sh
   paru -S awesome-git
   ```

> Install necessary dependencies

   ```sh
   paru -Sy picom-git alacritty rofi todo-bin acpi acpid acpi_call upower \
   jq inotify-tools polkit-gnome xdotool xclip gpick ffmpeg blueman \
   pipewire pipewire-alsa pipewire-pulse pamixer brightnessctl scrot redshift \
   feh mpv mpd mpc mpdris2 ncmpcpp playerctl --needed 
   ```

> Enable Services

   ```sh
   systemctl --user enable mpd.service
   systemctl --user start mpd.service
   ```

</details>

<details>
<summary><b>2. Install My AwesomeWM Dotfiles</b></summary>

> Clone this repository

   ```sh
   git clone --recurse-submodules https://github.com/rxyhn/dotfiles.git
   cd dotfiles && git submodule update --remote --merge
   ```

> Copy config files

   ```sh
   cp -r config/* ~/.config/
   ```

> Install a few fonts (mainly icon fonts) in order for text and icons to be rendered properly.

   ```sh
   cp -r misc/fonts/* ~/.fonts/
   # or to ~/.local/share/fonts
   cp -r misc/fonts/* ~/.local/share/fonts/
   ```

And run this command for your system to detect the newly installed fonts.

   ```sh
   fc-cache -v
   ```

> Finally, now you can login with AwesomeWM

   Congratulations, at this point you have installed this aesthetic dotfiles! :tada:

   Log out from your current desktop session and log in into AwesomeWM

</details>

<!-- MISCELLANEOUS -->
## :four_leaf_clover: ‎ <samp>Miscellaneous</samp>

<details>
<summary><b>VSCode Theme</b></summary>

<a href="#--------">
   <img src="https://user-images.githubusercontent.com/93292023/170319552-a42b920d-9f59-44d9-a9ad-b3aeed55bf6a.png" alt="VSCode Preview" width="500px">
</a>

:milky_way: ‎ <samp>Aesthetic VSCode</samp>

Setup:

1. Install required extension
    - [Customize UI](https://marketplace.visualstudio.com/items?itemName=iocave.customize-ui)
    - [Carbon Product Icons](https://marketplace.visualstudio.com/items?itemName=antfu.icons-carbon)

    note: You can use any themes, but some of the colors will be overwritten by mine
2. copy config file
    ```sh
    cp misc/vscode/User/settings.json ~/.config/Code/User

    ```

</details>

<details>
<summary><b>GTK Theme</b></summary>

<a href="#--------">
   <img src="https://user-images.githubusercontent.com/93292023/172054111-51b8e48f-d558-45da-8480-73e574fee6dc.png" alt="gtk theme preview" width="500px">
</a>

:sparkles: ‎ <samp>Aesthetic-Dark gtk theme</samp>

Setup:

   ```sh
   cp -rf misc/themes/* ~/.themes/
   # or to /usr/share/themes
   sudo cp -rf misc/themes/* /usr/share/themes/
   ``` 

to apply the theme can use ~~[lxappearance](https://archlinux.org/packages/community/x86_64/lxappearance)~~ [](https://archlinux.org/packages/community/x86_64/lxappearance-gtk3)

</details>

<details>
<summary><b>Touchpad tap-to-click & natural (reverse) scrolling (<a href="https://wiki.archlinux.org/title/Libinput#Tapping_button_re-mapping">libinput</a>)</b></summary>

`/etc/X11/xorg.conf.d/30-touchpad.conf`

```cfg
Section "InputClass"
    Identifier "touchpad"
    Driver "libinput"
    MatchIsTouchpad "on"
    Option "Tapping" "on"
    Option "TappingButtonMap" "lmr"
    Option "NaturalScrolling" "true"
EndSection
```

</details>

<!-- GALLERY -->
## :ocean: ‎ <samp>Gallery</samp>

| <b>Simple, Minimalist and Modern Bar</b> |
| --- |
| <a href="#--------"><img src="assets/wibar.png" width="500px" alt="dashboard preview"></a> |

| <b>Aesthetic Dashboard with neat grid layout and Notification Center</b> |
| --- |
| <a href="#--------"><img src="assets/dashboard.png" width="500px" alt="dashboard preview"></a> |

| <b>Complete information, Info Center</b>
| --- |
| <a href="#--------"><img src="assets/info-center.png" width="500px" alt="dashboard preview"></a> |

| <b>MacOS like control center</b> |
| --- |
| <a href="#--------"><img src="assets/control-center.png" width="500px" alt="control center preview"></a> |

| <b>Custom mouse-friendly ncmpcpp UI</b> |
| --- |
| <a href="#--------"><img src="assets/ncmpcpp.png" width="500px" alt="ncmpcpp preview"></a> |

| <b>Lockscreen with [PAM Integration](https://github.com/RMTT/lua-pam)</b> |
| --- |
| <a href="#--------"><img src="assets/lockscreen.png" width="500px" alt="word clock lockscreen preview"></a> |

| <b>Minimalist Exitscreen</b> |
| --- |
| <a href="#--------"><img src="assets/exitscreen.png" width="500px" alt="exitscreen preview"></a> |

<!-- HISTORY -->
## :japan: ‎ <samp>History</samp>

Ngl this is started when im feel bored lol and decided to start using Linux, more precisely in January 2022. Fyi im a **new Linux user,** when it's in [Linuxer Desktop Art](https://facebook.com/groups/linuxart) i saw a linux setup that caught my eye, then I'm interested in and trying something similar, So yeaaaaaah this is my current setup, my purpose of doing this is to hone my skills to make an attractive UI and also as a hobby. I wanna say thank you to those of you who like and love my setup <3 

<pre align="center">
<a href="#japan--history">
<img alt="" align="center" width="96%" src="https://api.star-history.com/svg?repos=rxyhn/dotfiles&type=Date"/>
</a>
</pre>

<!-- TIP JAR -->
## :money_with_wings: ‎ <samp>TIP JAR</samp>

If you enjoyed it and would like to show your appreciation, you may want to tip me here.

It is never required but always appreciated.

Thanks from the bottom of my heart! ‎ :heartpulse:

[![](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/rxyhn)

<!-- ACKNOWLEDGEMENTS -->
## :bulb: ‎ <samp>Acknowledgements</samp>

- **Special thanks to**

   + *Contributors*
      - [`rxyhn`](https://github.com/rxyhn) *there's nothing wrong with thanking yourself right?*
      - [`ner0z`](https://github.com/ner0z)
      - [`paulhersch`](https://github.com/paulhersch)
      - [`ChocolateBread799`](https://github.com/ChocolateBread799)
      - [`janleigh`](https://github.com/janleigh)
      - [`rototrash`](https://github.com/rototrash)
      - [`Deathemonic`](https://github.com/Deathemonic)

   + *And for them, ofc.*
      - [`elenapan`](https://github.com/elenapan)
      - [`manilarome`](https://github.com/manilarome)
      - [`JavaCafe01`](https://github.com/JavaCafe01)
      - [`andOrlando`](https://github.com/andOrlando)

<br>

<p align="center"><a href="https://github.com/rxyhn/AwesomeWM-Dotfiles/blob/main/.github/LICENSE"><img src="https://img.shields.io/static/v1.svg?style=flat-square&label=License&message=GPL-3.0&logoColor=eceff4&logo=github&colorA=162026&colorB=162026"/></a></p>
