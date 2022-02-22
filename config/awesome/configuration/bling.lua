local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local bling = require("module.bling")

-- Enable Playerctl Module from Bling
playerctl = bling.signal.playerctl.lib {
    ignore = {"firefox", "qutebrowser", "chromium", "brave"},
    update_on_activity = true
}

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

awful.keyboard.append_global_keybindings({
    awful.key({modkey}, "d", function() awful.spawn(launcher) end,
              {description = "show app launcher", group = "launcher"}),
})

require('ui.pop.window_switcher').enable()
