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

local time_hour = wibox.widget({
	font = beautiful.font_name .. "bold 48",
	format = helpers.colorize_text("%H", "#cfcdcc"),
	align = "center",
	valign = "center",
	widget = wibox.widget.textclock,
})

local time_min = wibox.widget({
	font = beautiful.font_name .. "bold 48",
	format = "%M",
	align = "center",
	valign = "center",
	widget = wibox.widget.textclock,
})

local time = wibox.widget({
	time_hour,
	time_min,
	spacing = dpi(25),
	widget = wibox.layout.fixed.horizontal,
})

return time
