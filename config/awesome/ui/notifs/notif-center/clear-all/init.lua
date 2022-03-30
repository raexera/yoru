local awful = require('awful')
local wibox = require('wibox')
local gears = require('gears')
local beautiful = require('beautiful')

local dpi = beautiful.xresources.apply_dpi
local button_container = require('ui.widgets.button')

local notifbox_core = require('ui.notifs.notif-center.build-notifbox')
local reset_notifbox_layout = notifbox_core.reset_notifbox_layout

local clear_all_icon = wibox.widget {
	{
		markup = "",
		font = beautiful.icon_font_name .. "Round 16",
		align = "center",
		valign = "center",
		widget = wibox.widget.textbox
	},
	layout = wibox.layout.fixed.horizontal
}

local clear_all_button = wibox.widget {
	{
		clear_all_icon,
		margins = dpi(7),
		widget = wibox.container.margin
	},
	widget = button_container
}

clear_all_button:buttons(
	gears.table.join(
		awful.button(
			{},
			1,
			nil,
			function()
				reset_notifbox_layout()
			end
		)
	)
)

local clear_all_button_wrapped = wibox.widget {
	nil,
	{
		clear_all_button,
		bg = beautiful.xcolor0,
		shape = gears.shape.circle,
		widget = wibox.container.background
	},
	nil,
	expand = 'none',
	layout = wibox.layout.align.vertical
}

return clear_all_button_wrapped