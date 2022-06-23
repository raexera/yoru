local awful = require("awful")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local wibox = require("wibox")
local helpers = require("helpers")

--- Information Panel
--- ~~~~~~~~~~~~~~~~~

return function(s)
	--- Date
	local time_format = "<span font='" .. beautiful.font_name .. "Light 36'> %I:%M </span> "
	local date_formate = "<span font='" .. beautiful.font_name .. "Bold 12'> %A %B %d </span>"
	local time = wibox.container.place(wibox.widget.textclock(time_format, 60))
	local date = wibox.container.place(wibox.widget.textclock(date_formate, 60))

	local date_time = wibox.widget({
		{
			time,
			date,
			layout = wibox.layout.fixed.vertical,
		},
		margins = dpi(20),
		widget = wibox.container.margin,
	})

	--- Calendar
	s.calendar = require("ui.panels.info-panel.calendar")()

	--- Weather
	s.weather = require("ui.panels.info-panel.weather")

	s.info_panel = awful.popup({
		type = "dock",
		screen = s,
		minimum_height = s.geometry.height - (beautiful.wibar_height + dpi(10)),
		maximum_height = s.geometry.height - (beautiful.wibar_height + dpi(10)),
		minimum_width = dpi(350),
		maximum_width = dpi(350),
		bg = beautiful.transparent,
		ontop = true,
		visible = false,
		placement = function(w)
			awful.placement.bottom_left(w, {
				margins = { top = dpi(5), bottom = beautiful.wibar_height + dpi(5), left = dpi(5), right = dpi(5) },
			})
		end,
		widget = {
			{
				{
					date_time,
					{
						{
							s.calendar,
							margins = { top = dpi(8), left = dpi(16), bottom = dpi(16), right = dpi(16) },
							widget = wibox.container.margin,
						},
						bg = beautiful.widget_bg,
						shape = helpers.ui.rrect(beautiful.border_radius),
						widget = wibox.container.background,
					},
					{
						top = dpi(20),
						widget = wibox.container.margin,
					},
					{
						{
							s.weather,
							margins = dpi(16),
							widget = wibox.container.margin,
						},
						bg = beautiful.widget_bg,
						shape = helpers.ui.rrect(beautiful.border_radius),
						widget = wibox.container.background,
					},

					layout = wibox.layout.fixed.vertical,
				},
				top = dpi(10),
				bottom = dpi(30),
				left = dpi(25),
				right = dpi(25),
				widget = wibox.container.margin,
			},
			bg = beautiful.wibar_bg,
			shape = helpers.ui.rrect(beautiful.border_radius),
			widget = wibox.container.background,
		},
	})

	--- Toggle container visibility
	awesome.connect_signal("info_panel::toggle", function(scr)
		if scr == s then
			s.info_panel.visible = not s.info_panel.visible
		end
	end)
end
