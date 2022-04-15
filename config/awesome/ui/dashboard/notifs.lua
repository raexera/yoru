-- Standard awesome library
local gears = require("gears")
local awful = require("awful")

-- Theme handling library
local beautiful = require("beautiful")

-- Notification library
local naughty = require("naughty")

-- Widget library
local wibox = require("wibox")

-- Helpers
local helpers = require("helpers")
local clickable_container = require("ui.widgets.clickable-container")

-- Notification Center
------------------------

local notifs_text = wibox.widget({
	font = beautiful.font_name .. "medium 8",
	markup = helpers.colorize_text("Notifications", beautiful.dashboard_box_fg),
	valign = "center",
	widget = wibox.widget.textbox,
})

-- Clear button
local notifs_clear = wibox.widget({
	markup = "󰎟",
	font = beautiful.icon_font_name .. "13",
	align = "center",
	valign = "center",
	widget = wibox.widget.textbox,
})

helpers.add_hover_cursor(notifs_clear, "hand2")

notifs_clear:buttons(gears.table.join(awful.button({}, 1, function()
	_G.reset_notifs_container()
end)))

-- Empty notifs
local empty_notifbox = wibox.widget({
	{
		markup = helpers.colorize_text("You have no notifs!", beautiful.xforeground .. "e6"),
		font = beautiful.font_name .. "8",
		align = "center",
		valign = "center",
		widget = wibox.widget.textbox,
	},
	margins = dpi(20),
	widget = wibox.container.margin,
})

local separator_for_empty_msg = wibox.widget({
	orientation = "vertical",
	opacity = 0.0,
	widget = wibox.widget.separator,
})

local notifs_empty = wibox.widget({
	layout = wibox.layout.align.vertical,
	expand = "none",
	separator_for_empty_msg,
	empty_notifbox,
	separator_for_empty_msg,
})

-- Notifbox container
local notifs_container = wibox.widget({
	spacing = dpi(10),
	forced_width = dpi(240),
	layout = wibox.layout.fixed.vertical,
})

local remove_notifs_empty = true

reset_notifs_container = function()
	notifs_container:reset(notifs_container)
	notifs_container:insert(1, notifs_empty)
	remove_notifs_empty = true
end

remove_notif = function(box)
	notifs_container:remove_widgets(box)

	if #notifs_container.children == 0 then
		notifs_container:insert(1, notifs_empty)
		remove_notifs_empty = true
	end
end

-- Create notifbox
local create_notif = function(icon, n, width)
	local notifbox = {}

	-- Time
	local time = os.date("%H:%M")
	local notifbox_time = wibox.widget({
		markup = helpers.colorize_text(time, beautiful.xforeground .. "b3"),
		align = "right",
		valign = "bottom",
		font = beautiful.font,
		widget = wibox.widget.textbox,
	})

	-- Dismiss button
	local dismiss_icon = wibox.widget({
		{
			id = "dismiss_icon",
			markup = helpers.colorize_text("󰅖", beautiful.xcolor1),
			font = beautiful.icon_font_name .. "6",
			align = "center",
			valign = "center",
			widget = wibox.widget.textbox,
		},
		layout = wibox.layout.fixed.horizontal,
	})

	local dismiss_button = wibox.widget({
		{
			dismiss_icon,
			margins = dpi(2),
			widget = wibox.container.margin,
		},
		widget = clickable_container,
	})

	local notifbox_dismiss = wibox.widget({
		dismiss_button,
		visible = false,
		bg = beautiful.lighter_bg,
		shape = gears.shape.circle,
		widget = wibox.container.background,
	})

	-- Notifbox init
	notifbox = wibox.widget({
		{
			{
				{
					{
						image = icon,
						resize = true,
						clip_shape = helpers.rrect(dpi(2)),
						halign = "center",
						valign = "center",
						widget = wibox.widget.imagebox,
					},
					strategy = "exact",
					height = dpi(40),
					width = dpi(40),
					widget = wibox.container.constraint,
				},
				{
					{
						nil,
						{
							{
								{
									step_function = wibox.container.scroll.step_functions.waiting_nonlinear_back_and_forth,
									speed = 50,
									{
										markup = n.title,
										font = beautiful.font_name .. "medium 8",
										align = "left",
										widget = wibox.widget.textbox,
									},
									forced_width = dpi(140),
									widget = wibox.container.scroll.horizontal,
								},
								nil,
								{
									notifbox_time,
									notifbox_dismiss,
									layout = wibox.layout.fixed.horizontal,
								},
								expand = "none",
								layout = wibox.layout.align.horizontal,
							},
							{
								markup = helpers.colorize_text(n.message, beautiful.dashboard_box_fg),
								align = "left",
								font = beautiful.font_name .. "medium 8",
								forced_width = dpi(165),
								widget = wibox.widget.textbox,
							},
							spacing = dpi(2),
							layout = wibox.layout.fixed.vertical,
						},
						expand = "none",
						layout = wibox.layout.align.vertical,
					},
					left = dpi(12),
					widget = wibox.container.margin,
				},
				layout = wibox.layout.align.horizontal,
			},
			margins = dpi(8),
			widget = wibox.container.margin,
		},
		bg = beautiful.notif_center_notifs_bg,
		shape = helpers.rrect(dpi(4)),
		forced_height = dpi(64),
		widget = wibox.container.background,
	})

	notifbox_dismiss:buttons(gears.table.join(awful.button({}, 1, function()
		_G.remove_notif(notifbox)
	end)))

	notifbox:connect_signal("mouse::enter", function()
		notifbox_time.visible = false
		notifbox_dismiss.visible = true
	end)

	notifbox:connect_signal("mouse::leave", function()
		notifbox_time.visible = true
		notifbox_dismiss.visible = false
	end)

	return notifbox
end

-- Notifbox scroller
notifs_container:buttons(gears.table.join(
	awful.button({}, 4, nil, function()
		if #notifs_container.children == 1 then
			return
		end
		notifs_container:insert(1, notifs_container.children[#notifs_container.children])
		notifs_container:remove(#notifs_container.children)
	end),

	awful.button({}, 5, nil, function()
		if #notifs_container.children == 1 then
			return
		end
		notifs_container:insert(#notifs_container.children + 1, notifs_container.children[1])
		notifs_container:remove(1)
	end)
))

notifs_container:insert(1, notifs_empty)

naughty.connect_signal("request::display", function(n)
	if #notifs_container.children == 1 and remove_notifs_empty then
		notifs_container:reset(notifs_container)
		remove_notifs_empty = false
	end

	local notif_color = beautiful.groups_bg
	if n.urgency == "critical" then
		notif_color = beautiful.xcolor1 .. "66"
	end
	local appicon = n.icon or n.app_icon
	if not appicon then
		appicon = gears.color.recolor_image(beautiful.notification_icon, beautiful.accent)
	end

	notifs_container:insert(1, create_notif(appicon, n, width))
end)

-- Merge everthing and return notification center
local notif_center = wibox.widget({
	{
		{
			notifs_text,
			nil,
			notifs_clear,
			expand = "none",
			layout = wibox.layout.align.horizontal,
		},
		left = dpi(5),
		right = dpi(5),
		layout = wibox.container.margin,
	},
	notifs_container,
	spacing = dpi(10),
	layout = wibox.layout.fixed.vertical,
})

return notif_center
