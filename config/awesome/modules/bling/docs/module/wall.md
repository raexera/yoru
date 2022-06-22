## 🎇 Wallpaper Easy Setup  <!-- {docsify-ignore} -->

This is a simple-to-use, extensible, declarative wallpaper manager.

### Practical Examples

```lua
-- A default Awesome wallpaper
bling.module.wallpaper.setup()

-- A slideshow with pictures from different sources changing every 30 minutes
bling.module.wallpaper.setup {
    wallpaper = {"/images/my_dog.jpg", "/images/my_cat.jpg"},
    change_timer = 1800
}

-- A random wallpaper with images from multiple folders
bling.module.wallpaper.setup {
    set_function = bling.module.wallpaper.setters.random,
    wallpaper = {"/path/to/a/folder", "/path/to/another/folder"},
    change_timer = 631, -- prime numbers are better for timers
    position = "fit",
    background = "#424242"
}

-- wallpapers based on a schedule, like awesome-glorious-widgets dynamic wallpaper
-- https://github.com/manilarome/awesome-glorious-widgets/tree/master/dynamic-wallpaper
bling.module.wallpaper.setup {
    set_function = bling.module.wallpaper.setters.simple_schedule,
    wallpaper = {
        ["06:22:00"] = "morning-wallpaper.jpg",
        ["12:00:00"] = "noon-wallpaper.jpg",
        ["17:58:00"] = "night-wallpaper.jpg",
        ["24:00:00"] = "midnight-wallpaper.jpg",
    },
    position = "maximized",
}

-- random wallpapers, from different folder depending on time of the day
bling.module.wallpaper.setup {
    set_function = bling.module.wallpaper.setters.simple_schedule,
    wallpaper = {
        ["09:00:00"] = "~/Pictures/safe_for_work",
        ["18:00:00"] = "~/Pictures/personal",
    },
    schedule_set_function = bling.module.wallpaper.setters.random
    position = "maximized",
    recursive = false,
    change_timer = 600
}

-- setup for multiple screens at once
-- the 'screen' argument can be a table of screen objects
bling.module.wallpaper.setup {
    set_function = bling.module.wallpaper.setters.random,
    screen = screen, -- The awesome 'screen' variable is an array of all screen objects
    wallpaper = {"/path/to/a/folder", "/path/to/another/folder"},
    change_timer = 631
}
```
### Details

The setup function will do 2 things: call the set-function when awesome requests a wallpaper, and manage a timer to call `set_function` periodically.

Its argument is a args table that is passed to ohter functions (setters and wallpaper functions), so you define everything with setup.

The `set_function` is a function called every times a wallpaper is needed.

The module provides some setters:

* `bling.module.wallpaper.setters.awesome_wallpaper`: beautiful.theme_assets.wallpaper with defaults from beautiful.
* `bling.module.wallpaper.setters.simple`: slideshow from the `wallpaper` argument.
* `bling.module.wallpaper.setters.random`: same as simple but in a random way.
* `bling.module.wallpaper.setters.simple_schedule`: takes a table of `["HH:MM:SS"] = wallpaper` arguments, where wallpaper is the `wallpaper` argument used by `schedule_set_function`.

A wallpaper is one of the following elements:

* a color
* an image
* a folder containing images
* a function that sets a wallpaper
* everything gears.wallpaper functions can manage (cairo surface, cairo pattern string)
* a list containing any of the elements above

To set up for multiple screens, two possible methods are:
* Call the `setup` function for each screen, passing the appropriate configuration and `screen` arg
* Call the `setup` function once, passing a table of screens as the `screen` arg. This applies the same configuration to all screens in the table
_Note_: Multiple screen setup only works for the `simple` and `random` setters

```lua
-- This is a valid wallpaper definition
bling.module.wallpaper.setup {
    wallpaper = {                  -- a list
        "black", "#112233",        -- colors
        "wall1.jpg", "wall2.png",  -- files
        "/path/to/wallpapers",     -- folders
        -- cairo patterns
        "radial:600,50,100:105,550,900:0,#2200ff:0.5,#00ff00:1,#101010",
        -- or functions that set a wallpaper
        function(args) bling.module.tiled_wallpaper("\\o/", args.screen) end,
        bling.module.wallpaper.setters.awesome_wallpaper,
    },
    change_timer = 10,
}
```
The provided setters `simple` and `random` will use 2 internal functions that you can use to write your own setter:

* `bling.module.wallpaper.prepare_list`: return a list of wallpapers directly usable by `apply` (for now, it just explores folders)
* `bling.module.wallpaper.apply`: a wrapper for gears.wallpaper functions, using the args table of setup

Here are the defaults:

```lua
-- Default parameters
bling.module.wallpaper.setup {
    screen = nil,       -- the screen to apply the wallpaper, as seen in gears.wallpaper functions
    screens = nil,      -- an array of screens to apply the wallpaper on. If 'screen' is also provided, this is overridden
    change_timer = nil, -- the timer in seconds. If set, call the set_function every change_timer seconds
    set_function = nil, -- the setter function

    -- parameters used by bling.module.wallpaper.prepare_list
    wallpaper = nil,                               -- the wallpaper object, see simple or simple_schedule documentation
    image_formats = {"jpg", "jpeg", "png", "bmp"}, -- when searching in folder, consider these files only
    recursive = true,                              -- when searching in folder, search also in subfolders

    -- parameters used by bling.module.wallpaper.apply
    position = nil,                              -- use a function of gears.wallpaper when applicable ("centered", "fit", "maximized", "tiled")
    background = beautiful.bg_normal or "black", -- see gears.wallpaper functions
    ignore_aspect = false,                       -- see gears.wallpaper.maximized
    offset = {x = 0, y = 0},                     -- see gears.wallpaper functions
    scale = 1,                                   -- see gears.wallpaper.centered

    -- parameters that only apply to bling.module.wallpaper.setter.awesome (as a setter or as a wallpaper function)
    colors = {                   -- see beautiful.theme_assets.wallpaper
        bg = beautiful.bg_color,  -- the actual default is this color but darkened or lightned
        fg = beautiful.fg_color,
        alt_fg = beautiful.fg_focus
    }
}
```

Check documentation in [module/wallpaper.lua](module/wallpaper.lua) for more details.
