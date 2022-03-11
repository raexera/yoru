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

-- Titlebar
-------------

awful.titlebar.enable_tooltip = false
client.connect_signal("request::titlebars", function(c)


    -- Hide default titlebar
    awful.titlebar.hide(c, beautiful.titlebar_pos)

    -- Buttons for the titlebar
    local buttons = gears.table.join(
        -- Left click
        awful.button({}, 1, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.move(c)
        end),

        -- Middle click
        awful.button({}, 2, nil, function(c) 
            c:kill() 
        end),

        -- Right click
        awful.button({}, 3, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.resize(c)
        end)
    )


    -- Side titlebar setup
    awful.titlebar(c, {position = beautiful.titlebar_position, size = beautiful.titlebar_size}):setup {
        {
            {
                awful.titlebar.widget.closebutton(c),
                awful.titlebar.widget.minimizebutton(c),
                awful.titlebar.widget.maximizedbutton(c),
                layout = wibox.layout.fixed.vertical
            },
            {
                buttons = buttons,
                widget = wibox.widget.textbox("")
            },
            layout = wibox.layout.align.vertical
        },
        top = dpi(5),
        bottom = dpi(5),
        right = dpi(5),
        widget = wibox.container.margin
    }

end)
