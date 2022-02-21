local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local bling = require("module.bling")


bling.widget.tag_preview.enable {
    show_client_content = false,
    placement_fn = function(c)
        awful.placement.left(c, {
            margins = {
                -- left = beautiful.wibar_width + beautiful.useless_gap * 2,
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

bling.widget.task_preview.enable {
    placement_fn = function(c)
        awful.placement.top_left(c, {
            margins = {
                -- bottom = beautiful.wibar_height + beautiful.useless_gap * 2,
                -- left = beautiful.useless_gap * 2
                top = 19,
                left = beautiful.wibar_width + 11
            }
        })
    end
}

awful.keyboard.append_global_keybindings({
    awful.key({modkey}, "d", function() awful.spawn(launcher) end,
              {description = "show app launcher", group = "launcher"})
})

require('ui.pop.window_switcher').enable()
