local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local helpers = require("helpers")
local volume = require(... .. "./volume")
local brightness = require(... .. "./brightness")

return wibox.widget({
	{
		{
			{
				brightness,
				volume,
				spacing = dpi(12),
				layout = wibox.layout.fixed.vertical,
			},
			margins = { top = dpi(12), bottom = dpi(12), left = dpi(18), right = dpi(12) },
			widget = wibox.container.margin,
		},
		widget = wibox.container.background,
		forced_height = dpi(120),
		forced_width = dpi(350),
		bg = beautiful.widget_bg,
		shape = helpers.ui.rrect(beautiful.border_radius),
	},
	margins = dpi(10),
	color = "#FF000000",
	widget = wibox.container.margin,
})
