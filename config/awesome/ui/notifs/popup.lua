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


-- Pop Up Notification
------------

local pop_icon = wibox.widget{
	{
        id = "icon",
		resize = true,
		widget = wibox.widget.imagebox
	},
	forced_height = dpi(100),
	top = dpi(28),
	widget = wibox.container.margin
}

local pop_bar = wibox.widget {
    max_value = 100,
    value = 0,
    background_color = beautiful.pop_bar_bg,
    color = beautiful.bg_accent,
    shape = gears.shape.rounded_bar,
    bar_shape = gears.shape.rounded_bar,
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
                layout = wibox.layout.align.horizontal,
                expand = 'none',
                nil,
                pop_icon,
                nil
            },
            layout = wibox.layout.fixed.vertical
        },
        {
            pop_bar,
            margins = dpi(28),
            widget = wibox.container.margin
        },
        layout = wibox.layout.align.vertical
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

local vol_first_time = true
awesome.connect_signal("signal::volume", function(value, muted)
    local icon = beautiful.volume_icon

    if vol_first_time then
        vol_first_time = false
    else

        if muted then
            local muted_icon = gears.color.recolor_image(beautiful.volume_muted_icon, beautiful.xcolor8)
            icon = muted_icon
            pop_bar.color = beautiful.xcolor8
        else
            local vol_icon =  gears.color.recolor_image(icon, beautiful.pop_vol_color)
            icon = vol_icon
            pop_bar.color = beautiful.pop_vol_color
        end

        pop_bar.value = value
        pop_icon.icon.image = icon
        toggle_pop()
    end
end)

awesome.connect_signal("signal::brightness", function(value)
    local icon = beautiful.brightness_icon

    if value ~= 0 then
        local bri_icon = gears.color.recolor_image(icon, beautiful.pop_brightness_color)
        icon = bri_icon
        pop_bar.color = beautiful.pop_brightness_color
    else
        local bri_icon = gears.color.recolor_image(icon, beautiful.xcolor8)
        icon = bri_icon
    end


    pop_bar.value = value
    pop_icon.icon.image = icon
    toggle_pop()
end)


-- Layout list
-----------------

local layout_list = awful.widget.layoutlist {
    source = awful.widget.layoutlist.source.default_layouts, -- DOC_HIDE
    spacing = dpi(24),
    base_layout = wibox.widget {
        spacing = dpi(24),
        forced_num_cols = 4,
        layout = wibox.layout.grid.vertical
    },
    widget_template = {
        {
            {
                id = "icon_role",
                forced_height = dpi(68),
                forced_width = dpi(68),
                widget = wibox.widget.imagebox
            },
            margins = dpi(24),
            widget = wibox.container.margin
        },
        id = "background_role",
        forced_width = dpi(68),
        forced_height = dpi(68),
        widget = wibox.container.background
    }
}

local layout_popup = awful.popup {
    widget = wibox.widget {
        {layout_list, margins = dpi(24), widget = wibox.container.margin},
        bg = beautiful.xbackground,
        shape = helpers.rrect(beautiful.border_radius),
        border_color = beautiful.widget_border_color,
        border_width = beautiful.widget_border_width,
        widget = wibox.container.background
    },
    placement = awful.placement.centered,
    ontop = true,
    visible = false,
    bg = beautiful.xbackground .. "00"
}

function gears.table.iterate_value(t, value, step_size, filter, start_at)
    local k = gears.table.hasitem(t, value, true, start_at)
    if not k then return end

    step_size = step_size or 1
    local new_key = gears.math.cycle(#t, k + step_size)

    if filter and not filter(t[new_key]) then
        for i = 1, #t do
            local k2 = gears.math.cycle(#t, new_key + i)
            if filter(t[k2]) then return t[k2], k2 end
        end
        return
    end

    return t[new_key], new_key
end

awful.keygrabber {
    start_callback = function() layout_popup.visible = true end,
    stop_callback = function() layout_popup.visible = false end,
    export_keybindings = true,
    stop_event = "release",
    stop_key = {"Escape", "Super_L", "Super_R", "Mod4"},
    keybindings = {
        {
            {modkey, "Shift"}, " ", function()
                awful.layout.set(gears.table.iterate_value(layout_list.layouts,
                                                           layout_list.current_layout, -1),
                                 nil)
            end
        }, {
            {modkey}, " ", function()
                awful.layout.set(gears.table.iterate_value(layout_list.layouts,
                                                           layout_list.current_layout, 1),
                                 nil)
            end
        }
    }
}
