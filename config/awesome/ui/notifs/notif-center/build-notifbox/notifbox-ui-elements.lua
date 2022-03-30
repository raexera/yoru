local wibox = require('wibox')
local beautiful = require('beautiful')
local naughty = require('naughty')
local gears = require('gears')

local dpi = beautiful.xresources.apply_dpi
local helpers = require('helpers')

local button_container = require('ui.widgets.button')

local ui_notif_builder = {}

-- Notification icon container
ui_notif_builder.notifbox_icon = function(ico_image)
	local noti_icon = wibox.widget {
		{
			id = 'icon',
			resize = true,
			forced_height = dpi(25),
			forced_width = dpi(25),
			widget = wibox.widget.imagebox
		},
		layout = wibox.layout.fixed.horizontal
	}
	noti_icon.icon:set_image(ico_image)
	return noti_icon
end

-- Notification title container
ui_notif_builder.notifbox_title = function(title)
	return wibox.widget {
		markup = title,
		font   = beautiful.font_name .. 'Bold 12',
		align  = 'left',
		valign = 'center',
		widget = wibox.widget.textbox
	}
end

-- Notification message container
ui_notif_builder.notifbox_message = function(msg)
	return wibox.widget {
		markup = msg,
		font   = beautiful.font_name .. 'medium 10',
		align  = 'left',
		valign = 'center',
		widget = wibox.widget.textbox
	}
end

-- Notification app name container
ui_notif_builder.notifbox_appname = function(app)
	return wibox.widget {
		markup  = app,
		font   = beautiful.font_name .. 'Bold 12',
		align  = 'left',
		valign = 'center',
		widget = wibox.widget.textbox
	}
end

-- Notification actions container
ui_notif_builder.notifbox_actions = function(n)
	actions_template = wibox.widget {
		notification = n,
		base_layout = wibox.widget {
			spacing        = dpi(0),
			layout         = wibox.layout.flex.horizontal
		},
		widget_template = {
			{
				{
					{
						{
							id     = 'text_role',
							font   = beautiful.font_name .. 'medium 10',
							widget = wibox.widget.textbox
						},
						widget = wibox.container.place
					},
					widget = button_container
				},
				bg                 = beautiful.lighter_bg,
				shape              = gears.shape.rounded_rect,
				forced_height      = dpi(30),
				widget             = wibox.container.background
			},
			margins = dpi(4),
			widget  = wibox.container.margin
		},
		style = { underline_normal = false, underline_selected = true },
		widget = naughty.list.actions,
	}

	return actions_template
end


-- Notification dismiss button
ui_notif_builder.notifbox_dismiss = function()

    local dismiss_icon = wibox.widget {
        {
            id = 'dismiss_icon',
			markup = helpers.colorize_text("", beautiful.xcolor1),
			font = beautiful.icon_font_name .. "Round 10",
			align = "center",
			valign = "center",
			widget = wibox.widget.textbox
        },
        layout = wibox.layout.fixed.horizontal
    }

    local dismiss_button = wibox.widget {
    	{
    		dismiss_icon,
    		margins = dpi(5),
    		widget = wibox.container.margin
    	},
    	widget = button_container
    }

    local notifbox_dismiss = wibox.widget {
    	dismiss_button,
    	visible = false,
        bg = beautiful.lighter_bg,
        shape = gears.shape.circle,
        widget = wibox.container.background
    }

    return notifbox_dismiss
end


return ui_notif_builder