local wibox = require("wibox")
local naughty = require("naughty")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local empty_notifbox = require("ui.panels.notification-panel.notif-center.build-notifbox.empty-notifbox")
local notifbox_scroller = require("ui.panels.notification-panel.notif-center.build-notifbox.notifbox-scroller")

local notif_core = {}

notif_core.remove_notifbox_empty = true

notif_core.notifbox_layout = wibox.widget({
	layout = wibox.layout.fixed.vertical,
	spacing = dpi(10),
	empty_notifbox,
})

notifbox_scroller(notif_core.notifbox_layout)

notif_core.reset_notifbox_layout = function()
	notif_core.notifbox_layout:reset()
	notif_core.notifbox_layout:insert(1, empty_notifbox)
	notif_core.remove_notifbox_empty = true
end

local notifbox_add = function(n, notif_icon, notifbox_color)
	if #notif_core.notifbox_layout.children == 1 and notif_core.remove_notifbox_empty then
		notif_core.notifbox_layout:reset(notif_core.notifbox_layout)
		notif_core.remove_notifbox_empty = false
	end

	local notifbox_box = require("ui.panels.notification-panel.notif-center.build-notifbox.notifbox-builder")
	notif_core.notifbox_layout:insert(1, notifbox_box(n, notif_icon, n.title, n.message, n.app_name, notifbox_color))
end

naughty.connect_signal("request::display", function(n)
	local notifbox_color = beautiful.transparent
	if n.urgency == "critical" then
		notifbox_color = n.bg .. "66"
	end

	local notif_icon = n.icon or n.app_icon
	if not notif_icon then
		notif_icon = beautiful.theme_assets.awesome_icon(24, beautiful.color8, beautiful.widget_bg)
	end

	notifbox_add(n, notif_icon, notifbox_color)
end)

return notif_core
