local wibox = require('wibox')
local beautiful = require('beautiful')
local dpi = require('beautiful').xresources.apply_dpi

-- Notification Center
-------------------------


-- header
local notif_header = wibox.widget {
	text   = 'Notification Center',
	font   = beautiful.font_name .. 'Bold 14',
	align  = 'left',
	valign = 'center',
	widget = wibox.widget.textbox
}

-- build notif-center
local notif_center = function(s)

	s.dont_disturb = require('ui.notifs.notif-center.dont-disturb')
	s.clear_all = require('ui.notifs.notif-center.clear-all')
	s.notifbox_layout = require('ui.notifs.notif-center.build-notifbox').notifbox_layout

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
				s.dont_disturb,
				s.clear_all
			},
		},
		s.notifbox_layout
	}
end

return notif_center