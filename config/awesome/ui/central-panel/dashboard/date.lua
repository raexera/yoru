-- Standard awesome library
local awful = require("awful")

-- Theme handling library
local beautiful = require("beautiful")

-- Widget library
local wibox = require("wibox")

-- Helpers
local helpers = require("helpers")

-- Date
---------

local date_day = wibox.widget({
	font = beautiful.font_name .. "medium 8",
	format = helpers.colorize_text("%A", beautiful.xforeground .. "c6"),
	valign = "center",
	widget = wibox.widget.textclock,
})

local date_month = wibox.widget({
	font = beautiful.font_name .. "medium 11",
	format = "%d %B",
	valign = "center",
	widget = wibox.widget.textclock,
})

local date = wibox.widget({
	date_day,
	nil,
	date_month,
	expand = "none",
	widget = wibox.layout.align.vertical,
})

return date
