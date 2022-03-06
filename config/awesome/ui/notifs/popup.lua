-- Standard awesome library
local gears = require("gears")
local awful = require("awful")

-- Theme handling library
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

-- Widget library
local wibox = require("wibox")

-- Helpers
local helpers = require("helpers")


-- Pop up
------------

local pop_icon = wibox.widget{
    font = beautiful.icon_font_name .. "Round 48",
    align = "center",
    widget = wibox.widget.textbox
}

local pop_bar = wibox.widget {
    max_value = 100,
    value = 0,
    background_color = beautiful.pop_bar_bg,
    color = beautiful.bg_accent,
    shape = gears.shape.rounded_bar,
    bar_shape = gears.shape.rounded_bar,
    forced_height = dpi(5),
    widget = wibox.widget.progressbar
}

local pop = wibox({
    type = "dock",
    screen = screen.focused,
    height = beautiful.pop_size,
    width = beautiful.pop_size,
    shape = helpers.rrect(beautiful.pop_border_radius - 1),
    bg = beautiful.transparent,
    ontop = true,
    visible = false
})

pop:setup {
    {
        {
            {
                helpers.vertical_pad(dpi(10)),
                pop_icon,
                layout = wibox.layout.fixed.vertical
            },
            nil,
            pop_bar,
            layout = wibox.layout.align.vertical
        },
        margins = dpi(30),
        widget = wibox.container.margin
    },
    bg = beautiful.xbackground,
    shape = helpers.rrect(beautiful.pop_border_radius),
    widget = wibox.container.background
}
awful.placement.bottom(pop, {margins = {bottom = dpi(100)}})

local pop_timeout = gears.timer {
    timeout = 1.4,
    autostart = true,
    callback = function()
        pop.visible = false
    end
}

local function toggle_pop()
    if pop.visible then
        pop_timeout:again()
    else
        pop.visible = true
        pop_timeout:start()
    end
end

awesome.connect_signal("signal::volume", function(value, muted)
    pop_icon.markup = ""
    pop_bar.value = value

    if muted then
        pop_bar.color = beautiful.xcolor8
    else
        pop_bar.color = beautiful.pop_vol_color
    end

    toggle_pop()
end)

awesome.connect_signal("signal::brightness", function(value)
    pop_icon.markup = ""
    pop_bar.value = value
    pop_bar.color = beautiful.pop_brightness_color

    toggle_pop()
end)
