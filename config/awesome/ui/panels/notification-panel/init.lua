local awful = require("awful")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local wibox = require("wibox")
local helpers = require("helpers")

--- Notification Panel
--- ~~~~~~~~~~~~~~~~~~

return function(s)
	s.notification_panel = awful.popup({
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
			awful.placement.bottom_right(w, {
				margins = { top = dpi(5), bottom = beautiful.wibar_height + dpi(5), left = dpi(5), right = dpi(5) },
			})
		end,
		widget = {
			{
				{
					layout = wibox.layout.flex.vertical,
					spacing = dpi(20),
					nil,
					require("ui.panels.notification-panel.notif-center")(s),
					require("ui.panels.notification-panel.github-activity"),
					nil,
				},
				margins = dpi(20),
				widget = wibox.container.margin,
			},
			id = "notification_panel",
			bg = beautiful.wibar_bg,
			shape = helpers.ui.rrect(beautiful.border_radius),
			widget = wibox.container.background,
		},
	})

	--- Toggle container visibility
	awesome.connect_signal("notification_panel::toggle", function(scr)
		if scr == s then
			s.notification_panel.visible = not s.notification_panel.visible
		end
	end)
end
