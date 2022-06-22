local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local notif_center = function(s)
	s.notifbox_layout = require("ui.panels.notification-panel.notif-center.build-notifbox").notifbox_layout

	return wibox.widget({
		{
			{
				s.notifbox_layout,
				layout = wibox.layout.fixed.vertical,
			},
			margins = dpi(10),
			widget = wibox.container.margin,
		},
		bg = beautiful.widget_bg,
		shape = function(cr, w, h)
			gears.shape.rounded_rect(cr, w, h, beautiful.border_radius)
		end,
		widget = wibox.container.background,
	})
end

return notif_center
