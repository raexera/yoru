local gears = require("gears")
local awful = require("awful")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local wibox = require("wibox")
local helpers = require("helpers")

local brightness_osd_icon = wibox.widget({
	{
		id = "popup_icon",
		markup = helpers.colorize_text("", beautiful.xforeground),
		font = beautiful.icon_font .. "Round 96",
		align = "center",
		valign = "center",
		widget = wibox.widget.textbox(),
	},
	forced_height = dpi(150),
	top = dpi(12),
	bottom = dpi(12),
	widget = wibox.container.margin,
})

local brightness_osd_bar = wibox.widget({
	nil,
	{
		id = "brightness_osd_progressbar",
		max_value = 100,
		value = 0,
		background_color = "#ffffff20",
		color = beautiful.xforeground,
		shape = gears.shape.rounded_rect,
		bar_shape = gears.shape.rounded_rect,
		forced_height = dpi(24),
		widget = wibox.widget.progressbar,
	},
	nil,
	expand = "none",
	layout = wibox.layout.align.vertical,
})

local brightness_osd_height = dpi(200)
local brightness_osd_width = dpi(200)

screen.connect_signal("request::desktop_decoration", function(s)
	s.brightness_osd = awful.popup({
		type = "notification",
		screen = s,
		height = brightness_osd_height,
		width = brightness_osd_width,
		maximum_height = brightness_osd_height,
		maximum_width = brightness_osd_width,
		bg = beautiful.transparent,
		ontop = true,
		visible = false,
		widget = {
			{
				{
					layout = wibox.layout.fixed.vertical,
					{
						{
							layout = wibox.layout.align.horizontal,
							expand = "none",
							nil,
							brightness_osd_icon,
							nil,
						},
						brightness_osd_bar,
						spacing = dpi(10),
						layout = wibox.layout.fixed.vertical,
					},
				},
				left = dpi(24),
				right = dpi(24),
				bottom = dpi(24),
				widget = wibox.container.margin,
			},
			bg = beautiful.xbackground,
			shape = gears.shape.rounded_rect,
			widget = wibox.container.background,
		},
	})

	awful.placement.centered(s.brightness_osd, {
		offset = {
			y = 200,
		},
	})

	local brightness_osd_timeout = gears.timer({
		timeout = 2,
		autostart = true,
		callback = function()
			s.brightness_osd.visible = false
		end,
	})

	local function toggle_brightness_osd()
		if s.brightness_osd.visible then
			brightness_osd_timeout:again()
		else
			s.brightness_osd.visible = true
			brightness_osd_timeout:start()
		end
	end

	awesome.connect_signal("signal::brightness", function(value)
		brightness_osd_bar.brightness_osd_progressbar.value = value
		brightness_osd_bar.brightness_osd_progressbar.color = beautiful.xforeground

		toggle_brightness_osd()
	end)
end)
