local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local clickable_container = require("ui.widgets.clickable-container")

local return_button = function()
	local widget = wibox.widget({
		{
			text = "",
			align = "center",
			valign = "center",
			font = beautiful.icon_font .. "Round 16",
			widget = wibox.widget.textbox,
		},
		layout = wibox.layout.align.horizontal,
	})

	local widget_button = wibox.widget({
		{
			widget,
			margins = dpi(8),
			widget = wibox.container.margin,
		},
		widget = clickable_container,
	})

	widget_button:buttons(gears.table.join(awful.button({}, 1, nil, function()
		control_center:toggle()
	end)))

	return widget_button
end

return return_button
