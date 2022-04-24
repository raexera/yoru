-- Standard awesome library
local awful = require("awful")

-- Theme handling library
local beautiful = require("beautiful")

-- Widget library
local wibox = require("wibox")

-- Helpers
local helpers = require("helpers")

-- Time
---------
local hours = wibox.widget.textclock("%H")
local minutes = wibox.widget.textclock("%M")

local make_little_dot = function(color)
	return wibox.widget({
		bg = color,
		forced_width = dpi(10),
		forced_height = dpi(10),
		shape = helpers.rrect(dpi(2)),
		widget = wibox.container.background,
	})
end

local time = {
	{
		font = beautiful.font_name .. "bold 44",
		align = "right",
		valign = "top",
		widget = hours,
	},
	{
		nil,
		{
			make_little_dot(beautiful.xcolor1),
			make_little_dot(beautiful.xcolor4),
			make_little_dot(beautiful.xcolor5),
			spacing = dpi(10),
			widget = wibox.layout.fixed.vertical,
		},
		expand = "none",
		widget = wibox.layout.align.vertical,
	},
	{
		font = beautiful.font_name .. "bold 44",
		align = "left",
		valign = "top",
		widget = minutes,
	},
	spacing = dpi(20),
	layout = wibox.layout.fixed.horizontal,
}

return time
