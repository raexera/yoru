local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local clickable_container = require("ui.widgets.clickable-container")
local notifbox_core = require("ui.widgets.notif-center.build-notifbox")
local reset_notifbox_layout = notifbox_core.reset_notifbox_layout

local clear_all_textbox = wibox.widget({
	text = "Clear",
	font = beautiful.font_name .. "Bold 12",
	align = "center",
	valign = "center",
	widget = wibox.widget.textbox,
})

local clear_all_button = wibox.widget({
	{
		clear_all_textbox,
		top = dpi(5),
		bottom = dpi(5),
		left = dpi(20),
		right = dpi(20),
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
		shape = function(cr, width, height)
			gears.shape.rounded_rect(cr, width, height, dpi(5))
		end,
		widget = wibox.container.background,
	},
	nil,
	expand = "none",
	layout = wibox.layout.align.vertical,
})

return clear_all_button_wrapped
