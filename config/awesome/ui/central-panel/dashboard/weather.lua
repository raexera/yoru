-- Standard awesome library
local gears = require("gears")
local awful = require("awful")

-- Theme handling library
local beautiful = require("beautiful")

-- Widget library
local wibox = require("wibox")

-- Helpers
local helpers = require("helpers")

-- Weather
------------

local weather_text = wibox.widget({
	font = beautiful.font_name .. "medium 8",
	markup = helpers.colorize_text("Weather unavailable", beautiful.dashboard_box_fg),
	valign = "center",
	widget = wibox.widget.textbox,
})

local weather_temp = wibox.widget({
	font = beautiful.font_name .. "medium 11",
	markup = "999°C",
	valign = "center",
	widget = wibox.widget.textbox,
})

local weather_icon = wibox.widget({
	font = "icomoon 36",
	markup = helpers.colorize_text("", beautiful.xcolor2),
	align = "right",
	valign = "bottom",
	widget = wibox.widget.textbox,
})

local weather = wibox.widget({
	{
		weather_text,
		weather_temp,
		spacing = dpi(3),
		layout = wibox.layout.fixed.vertical,
	},
	nil,
	weather_icon,
	expand = "none",
	layout = wibox.layout.align.vertical,
})

awesome.connect_signal("signal::weather", function(temperature, description, icon_widget)
	local weather_temp_symbol
	if weather_units == "metric" then
		weather_temp_symbol = "°C"
	elseif weather_units == "imperial" then
		weather_temp_symbol = "°F"
	end

	weather_icon.markup = icon_widget
	weather_text.markup = helpers.colorize_text(description, beautiful.dashboard_box_fg)
	weather_temp.markup = temperature .. weather_temp_symbol
end)

return weather
