-- Standard awesome library
local gears = require("gears")
local awful = require("awful")

-- Theme library
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

-- Widget library
local wibox = require("wibox")

-- Helpers
local helpers = require("helpers")

-- Keys
local keys = require("configuration.keys")


-- Titlebar
-------------

awful.titlebar.enable_tooltip = false
client.connect_signal("request::titlebars", function(c)

    -- Side titlebar setup
    awful.titlebar(c, {position = beautiful.titlebar_position, size = beautiful.titlebar_size}):setup {
        {
            {
                awful.titlebar.widget.closebutton(c),
                awful.titlebar.widget.maximizedbutton(c),
                awful.titlebar.widget.minimizebutton(c),
                layout = wibox.layout.fixed.vertical
            },
            {
               widget = wibox.widget.textbox("")
            },
            layout = wibox.layout.align.vertical
        },
        margins = dpi(4),
        widget = wibox.container.margin
    }

end)
