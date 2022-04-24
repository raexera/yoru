local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local notif_center = function(s)
	s.clear_all = require("ui.central-panel.notif-center.clear-all")
	s.notifbox_layout = require("ui.central-panel.notif-center.build-notifbox").notifbox_layout

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
				forced_height = dpi(550),
				widget = wibox.container.constraint,
			},
			margins = dpi(10),
			widget = wibox.container.margin,
		},
		nil,
		{
			nil,
			nil,
			s.clear_all,
			expand = "none",
			layout = wibox.layout.align.horizontal,
		},
	})
end

return notif_center
