local gears = require("gears")
local awful = require("awful")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local wibox = require("wibox")
local helpers = require("helpers")

-- Stats
----------
local bg_color = beautiful.accent
local vol_color = bg_color
local brightness_color = bg_color

-- Helpers
local function create_slider_widget(slider_color)
	local slider_widget = wibox.widget({
		{
			id = "slider",
			max_value = 100,
			value = 40,
			background_color = bg_color .. "55",
			color = slider_color,
			shape = helpers.rrect(dpi(20)),
			bar_shape = helpers.rrect(dpi(20)),
			widget = wibox.widget.progressbar,
		},
		forced_width = dpi(178),
		forced_height = dpi(50),
		widget = wibox.container.background,
	})
	return slider_widget
end

local function create_icons(icon, color)
	local icon_widget = wibox.widget({
		{
			markup = helpers.colorize_text(icon, color),
			font = beautiful.icon_font_name .. "14",
			align = "left",
			valign = "center",
			widget = wibox.widget.textbox,
		},
		left = dpi(10),
		widget = wibox.container.margin,
	})

	return icon_widget
end

-- Widget
local vol = create_slider_widget(vol_color)
local brightness = create_slider_widget(brightness_color)

local vol_slider_container = wibox.widget({
	vol,
	create_icons("󰕾", beautiful.xforeground),
	layout = wibox.layout.stack,
})

local brightness_slider_container = wibox.widget({
	brightness,
	create_icons("󰖨", beautiful.xforeground),
	layout = wibox.layout.stack,
})

awesome.connect_signal("signal::volume", function(value, muted)
	local fill_color
	local vol_value = value or 0

	if muted then
		fill_color = beautiful.xcolor8
		vol.slider.background_color = fill_color .. "44"
	else
		fill_color = vol_color
	end

	vol.slider.value = vol_value
	vol.slider.color = fill_color
	vol.slider.background_color = fill_color .. "44"
end)

awesome.connect_signal("signal::brightness", function(value)
	brightness.slider.value = value
	brightness.slider.background_color = brightness_color .. "44"
end)

vol:buttons(gears.table.join(
	awful.button({}, 1, function()
		helpers.volume_control(0)
	end),
	-- Scrolling
	awful.button({}, 4, function()
		helpers.volume_control(5)
	end),
	awful.button({}, 5, function()
		helpers.volume_control(-5)
	end)
))

brightness:buttons(gears.table.join(
	-- Scrolling
	awful.button({}, 4, function()
		awful.spawn.with_shell("brightnessctl set 5%+ -q")
	end),
	awful.button({}, 5, function()
		awful.spawn.with_shell("brightnessctl set 5%- -q")
	end)
))

local stats = wibox.widget({
	{
		{
			brightness_slider_container,
			vol_slider_container,
			spacing = dpi(15),
			layout = wibox.layout.fixed.horizontal,
		},
		expand = "none",
		layout = wibox.layout.fixed.vertical,
	},
	expand = "none",
	layout = wibox.layout.align.horizontal,
})

return stats
