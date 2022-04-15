local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local clickable_container = require("ui.widgets.clickable-container")
local config_dir = gears.filesystem.get_configuration_dir()
local widget_icon_dir = config_dir .. "ui/notifs/notif-center/icons/"
local notifbox_core = require("ui.notifs.notif-center.build-notifbox")
local reset_notifbox_layout = notifbox_core.reset_notifbox_layout

local clear_all_imagebox = wibox.widget({
	{
		image = widget_icon_dir .. "clear_all.svg",
		resize = true,
		forced_height = dpi(20),
		forced_width = dpi(20),
		widget = wibox.widget.imagebox,
	},
	layout = wibox.layout.fixed.horizontal,
})

local clear_all_button = wibox.widget({
	{
		clear_all_imagebox,
		margins = dpi(7),
		widget = wibox.container.margin,
	},
	widget = clickable_container,
})

clear_all_button:buttons(gears.table.join(awful.button({}, 1, nil, function()
	reset_notifbox_layout()
end)))

local clear_all_button_wrapped = wibox.widget({
	nil,
	{
		clear_all_button,
		bg = beautiful.notif_center_notifs_bg,
		shape = gears.shape.circle,
		widget = wibox.container.background,
	},
	nil,
	expand = "none",
	layout = wibox.layout.align.vertical,
})

return clear_all_button_wrapped
