local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local helpers = require("helpers")
local dpi = beautiful.xresources.apply_dpi

local width = dpi(50)
local height = dpi(300)

local active_color_1 = {
    type = 'linear',
    from = {0, 0},
    to = {200, 50}, -- replace with w,h later
    stops = {{0, beautiful.xcolor6}, {0.50, beautiful.xcolor4}}
}

local bright_icon = wibox.widget {
    markup = "<span foreground='" .. beautiful.xcolor4 .. "'><b></b></span>",
    align = 'center',
    valign = 'center',
    font = beautiful.font_name .. '25',
    widget = wibox.widget.textbox
}

local bright_adjust = awful.popup({
    type = "notification",
    maximum_width = width,
    maximum_height = height,
    visible = false,
    ontop = true,
    widget = wibox.container.background,
    bg = "#00000000",
    placement = function(c)
        awful.placement
            .right(c, {margins = {right = beautiful.useless_gap * 2}})
    end
})

local bright_bar = wibox.widget {
    bar_shape = gears.shape.rectangle,
    shape = gears.shape.rounded_rect,
    background_color = beautiful.lighter_bg,
    color = active_color_1,
    max_value = 100,
    value = 0,
    widget = wibox.widget.progressbar
}

local bright_ratio = wibox.widget {
    layout = wibox.layout.ratio.vertical,
    {
        {bright_bar, direction = "east", widget = wibox.container.rotate},
        top = dpi(20),
        left = dpi(20),
        right = dpi(20),
        widget = wibox.container.margin
    },
    bright_icon,
    nil
}

bright_ratio:adjust_ratio(2, 0.72, 0.28, 0)

bright_adjust.widget = wibox.widget {
    bright_ratio,
    shape = helpers.rrect(beautiful.border_radius),
    bg = beautiful.xbackground,
    widget = wibox.container.background
}

-- create a 3 second timer to hide the volume adjust
-- component whenever the timer is started
local hide_bright_adjust = gears.timer {
    timeout = 3,
    autostart = true,
    callback = function() bright_adjust.visible = false end
}

awesome.connect_signal("signal::brightness", function(value)
    bright_bar.value = value
    if bright_adjust.visible then
        hide_bright_adjust:again()
    else
        bright_adjust.visible = true
        hide_bright_adjust:start()
    end
end)
