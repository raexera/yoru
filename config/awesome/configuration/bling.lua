local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local helpers = require("helpers")
local bling = require("module.bling")
local rubato = require("module.rubato")

-- Enable Playerctl Module from Bling
Playerctl = bling.signal.playerctl.lib()

bling.widget.tag_preview.enable {
    show_client_content = false,
    placement_fn = function(c)
        awful.placement.left(c, {
            margins = {
                -- left = beautiful.wibar_width + beautiful.useless_gap * 2,
                left = beautiful.wibar_width + 19
            }
        })
    end,
    scale = 0.15,
    honor_padding = true,
    honor_workarea = false,
    background_widget = wibox.widget {
        image = beautiful.wallpaper,
        horizontal_fit_policy = "fit",
        vertical_fit_policy = "fit",
        widget = wibox.widget.imagebox
    }
}

bling.widget.task_preview.enable {
    placement_fn = function(c)
        awful.placement.top_left(c, {
            margins = {
                -- bottom = beautiful.wibar_height + beautiful.useless_gap * 2,
                -- left = beautiful.useless_gap * 2
                top = 19,
                left = beautiful.wibar_width + 19
            }
        })
    end
}

--[[
local app_launcher = require("module.bling").widget.app_launcher({
    rubato = {
        y = rubato.timed {
            pos = 1920,
            rate = 120,
            easing = rubato.quadratic,
            intro = 0.1,
            duration = 0.3,
            awestore_compat = true
        }
    },
    prompt_icon = "",
    app_show_name = true,
    app_shape = helpers.rrect(beautiful.border_radius),
    apps_per_row = 5,
    apps_per_column = 1
})
]] --

awful.keyboard.append_global_keybindings({
    awful.key({modkey}, "d", function() awful.spawn(launcher) end,
              {description = "show app launcher", group = "launcher"}),
    awful.key({modkey}, "e", function() awful.spawn(emoji_launcher) end,
              {description = "show emoji launcher", group = "launcher"})
})

require('ui.pop.window_switcher').enable()
