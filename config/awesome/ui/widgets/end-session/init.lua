local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local icons = require("icons")
local clickable_container = require("ui.widgets.clickable-container")

local return_button = function()
	local widget = wibox.widget({
		{
			id = "icon",
			image = icons.power,
			resize = true,
			widget = wibox.widget.imagebox,
		},
		layout = wibox.layout.align.horizontal,
	})

	local widget_button = wibox.widget({
		{
			{
				widget,
				margins = dpi(5),
				widget = wibox.container.margin,
			},
			widget = clickable_container,
		},
		bg = beautiful.transparent,
		shape = gears.shape.circle,
		widget = wibox.container.background,
	})

	widget_button:buttons(gears.table.join(awful.button({}, 1, nil, function()
		awesome.emit_signal("module::exit_screen:show")
		control_center:toggle()
	end)))

	return widget_button
end

return return_button
