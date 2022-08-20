local wibox = require("wibox")

local notif_center = function(s)
	s.notifbox_layout = require("ui.panels.notification-panel.notif-center.build-notifbox").notifbox_layout

	return wibox.widget({
		s.notifbox_layout,
		layout = wibox.layout.fixed.vertical,
	})
end

return notif_center
