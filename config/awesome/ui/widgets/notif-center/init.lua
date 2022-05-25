local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local notif_center = function(s)
	s.clear_all = require("ui.widgets.notif-center.clear-all")
	s.notifbox_layout = require("ui.widgets.notif-center.build-notifbox").notifbox_layout

	return wibox.widget({
		expand = "none",
		layout = wibox.layout.align.vertical,
		{
			{
				{
					s.notifbox_layout,
					spacing = dpi(10),
					layout = wibox.layout.fixed.vertical,
				},
				forced_height = dpi(520),
				widget = wibox.container.constraint,
			},
			margins = dpi(20),
			widget = wibox.container.margin,
		},
		nil,
		{
			nil,
			nil,
			{
				s.clear_all,
				margins = { bottom = dpi(20), right = dpi(20) },
				widget = wibox.container.margin,
			},
			expand = "none",
			layout = wibox.layout.align.horizontal,
		},
	})
end

return notif_center
