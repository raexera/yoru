local wibox = require('wibox')
local gears = require('gears')

local beautiful = require('beautiful')
local dpi = require('beautiful').xresources.apply_dpi

local empty_notifbox = wibox.widget {
	{
		layout = wibox.layout.fixed.vertical,
		spacing = dpi(20),
		{
			expand = 'none',
			layout = wibox.layout.align.horizontal,
			nil,
			{
				image = gears.color.recolor_image(beautiful.notification_bell_icon, beautiful.xcolor4),
				resize = true,
				forced_height = dpi(90),
				forced_width = dpi(90),
				widget = wibox.widget.imagebox,
			},
			nil
		},
		{
			text = "No Notifications? :(",
			font =  beautiful.font_name .. 'medium 12',
			align = 'center',
			valign = 'center',
			widget = wibox.widget.textbox
		},
	},
	margins = dpi(20),
	widget = wibox.container.margin

}


local separator_for_empty_msg =  wibox.widget
{
	orientation = 'vertical',
	opacity = 0.0,
	widget = wibox.widget.separator
}

-- Make empty_notifbox center
local centered_empty_notifbox = wibox.widget {
	expand = 'none',
	layout = wibox.layout.align.vertical,
	separator_for_empty_msg,
	empty_notifbox,
	separator_for_empty_msg
}

return centered_empty_notifbox

