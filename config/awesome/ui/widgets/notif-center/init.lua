local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local notif_header = wibox.widget {
	text   = 'Notification Center',
	font   = beautiful.font_name .. 'Bold 16',
	align  = 'left',
	valign = 'center',
	widget = wibox.widget.textbox
}

local notif_center = function(s)

	s.clear_all = require("ui.widgets.notif-center.clear-all")
	s.notifbox_layout = require("ui.widgets.notif-center.build-notifbox").notifbox_layout

	return wibox.widget {
		expand = 'none',
		layout = wibox.layout.fixed.vertical,
		spacing = dpi(10),
		{
			expand = 'none',
			layout = wibox.layout.align.horizontal,
			notif_header,
			nil,
			{
				layout = wibox.layout.fixed.horizontal,
				spacing = dpi(5),
				s.clear_all
			},
		},
		s.notifbox_layout
	}
end

return notif_center