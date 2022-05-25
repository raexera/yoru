local gears = require("gears")
local awful = require("awful")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local wibox = require("wibox")
local helpers = require("helpers")

local volume_osd_icon = wibox.widget({
	{
		id = "popup_icon",
		markup = helpers.colorize_text("", beautiful.xforeground),
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

local volume_osd_bar = wibox.widget({
	nil,
	{
		id = "volume_osd_progressbar",
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

local volume_osd_height = dpi(200)
local volume_osd_width = dpi(200)

screen.connect_signal("request::desktop_decoration", function(s)
	s.volume_osd = awful.popup({
		type = "notification",
		screen = s,
		height = volume_osd_height,
		width = volume_osd_width,
		maximum_height = volume_osd_height,
		maximum_width = volume_osd_width,
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
							volume_osd_icon,
							nil,
						},
						volume_osd_bar,
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

	awful.placement.centered(s.volume_osd, {
		offset = {
			y = 200,
		},
	})

	local volume_osd_timeout = gears.timer({
		timeout = 2,
		autostart = true,
		callback = function()
			s.volume_osd.visible = false
		end,
	})

	local function toggle_volume_osd()
		if s.volume_osd.visible then
			volume_osd_timeout:again()
		else
			s.volume_osd.visible = true
			volume_osd_timeout:start()
		end
	end

	awesome.connect_signal("signal::volume", function(value, muted)
		volume_osd_bar.volume_osd_progressbar.value = value

		if muted == 1 or value == 0 then
			volume_osd_icon.popup_icon:set_markup_silently(helpers.colorize_text("", beautiful.xcolor8))
			volume_osd_bar.volume_osd_progressbar.color = beautiful.xcolor8
		else
			volume_osd_icon.popup_icon:set_markup_silently(helpers.colorize_text("", beautiful.xforeground))
			volume_osd_bar.volume_osd_progressbar.color = beautiful.xforeground
		end

		toggle_volume_osd()
	end)
end)
