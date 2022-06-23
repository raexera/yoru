# <center> 🌟 Bling - Utilities for AwesomeWM 🌟 </center>

## Why

[AwesomeWM](https://awesomewm.org/) is literally what it stands for, an awesome window manager.

Its unique selling point has always been the widget system, which allows for fancy buttons, sliders, bars, dashboards and anything you can imagine. But that feature can be a curse. Most modules focus on the widget side of things which leave the actual window managing part of AwesomeWM underdeveloped compared to, for example, [xmonad](https://xmonad.org/) even though it's probably just as powerfull in that area.

This project focuses on that problem - adding new layouts and modules that make use of the widget system, but primarily focus on the new window managing features.

## Installation
- clone this repo into your `~/.config/awesome` folder
    - `git clone https://github.com/BlingCorp/bling.git ~/.config/awesome/bling`
- require the module in your `rc.lua`, and make sure it's under the beautiful module initialization

```lua
-- other imports

local beautiful = require("beautiful")

-- other configuration stuff here

beautiful.init("some_theme.lua")
local bling = require("bling")
```

## Contributors
A special thanks to all our contributors...

<a href="https://github.com/BlingCorp/bling/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=BlingCorp/bling" />
</a>

Made with [contributors-img](https://contrib.rocks).
