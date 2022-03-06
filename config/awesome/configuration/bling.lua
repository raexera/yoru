local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local bling = require("module.bling")

bling.module.flash_focus.enable()

-- Set Wallpaper
bling.module.tiled_wallpaper("", s, {
    fg = beautiful.lighter_bg,
    bg = beautiful.xbackground,
    offset_y = 6,
    offset_x = 18,
    font = "Iosevka",
    font_size = 17,
    padding = 70,
    zickzack = true
})

-- Enable Tag Preview Module from Bling
bling.widget.tag_preview.enable {
    show_client_content = false,
    placement_fn = function(c)
        awful.placement.left(c, {
            margins = {
                left = beautiful.wibar_width + 11
            }
        })
    end,
    scale = 0.15,
    honor_padding = true,
    honor_workarea = false,
    background_widget = wibox.widget {
        bg = beautiful.xbackground,
        widget = wibox.widget.background
    }
}

-- Enable Task Preview Module from Bling
bling.widget.task_preview.enable {
    placement_fn = function(c)
        awful.placement.top_left(c, {
            margins = {
                top = 10,
                left = beautiful.wibar_width + 11
            }
        })
    end
}

require('ui.widgets.window_switcher').enable()
