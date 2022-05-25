local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local clickable_container = require("ui.widgets.clickable-container")
local config_dir = gears.filesystem.get_configuration_dir()
local widget_dir = config_dir .. "ui/widgets/blue-light/"
local widget_icon_dir = widget_dir .. "icons/"
local device_state = false

local action_name = wibox.widget({
	text = "Blue Light",
	font = beautiful.font_name .. "Bold 10",
	align = "left",
	widget = wibox.widget.textbox,
})

local action_status = wibox.widget({
	text = "Off",
	font = beautiful.font_name .. "Regular 10",
	align = "left",
	widget = wibox.widget.textbox,
})

local action_info = wibox.widget({
	layout = wibox.layout.fixed.vertical,
	action_name,
	action_status,
})

local button_widget = wibox.widget({
	{
		id = "icon",
		image = widget_icon_dir .. "blue-light-off.svg",
		widget = wibox.widget.imagebox,
		resize = true,
	},
	layout = wibox.layout.align.horizontal,
})

local widget_button = wibox.widget({
	{
		{
			button_widget,
			margins = dpi(15),
			forced_height = dpi(48),
			forced_width = dpi(48),
			widget = wibox.container.margin,
		},
		widget = clickable_container,
	},
	bg = beautiful.control_center_button_bg,
	shape = gears.shape.circle,
	widget = wibox.container.background,
})

local update_widget = function()
	if blue_light_state then
		action_status:set_text("On")
		widget_button.bg = beautiful.accent
		button_widget.icon:set_image(widget_icon_dir .. "blue-light.svg")
	else
		action_status:set_text("Off")
		widget_button.bg = beautiful.control_center_button_bg
		button_widget.icon:set_image(widget_icon_dir .. "blue-light-off.svg")
	end
end

local kill_state = function()
	awful.spawn.easy_async_with_shell(
		[[
		redshift -x
		kill -9 $(pgrep redshift)
		]],
		function(stdout)
			stdout = tonumber(stdout)
			if stdout then
				blue_light_state = false
				update_widget()
			end
		end
	)
end

kill_state()

local toggle_action = function()
	awful.spawn.easy_async_with_shell(
		[[
		if [ ! -z $(pgrep redshift) ];
		then
			redshift -x && pkill redshift && killall redshift
			echo 'OFF'
		else
			redshift -l 0:0 -t 4500:4500 -r &>/dev/null &
			echo 'ON'
		fi
		]],
		function(stdout)
			if stdout:match("ON") then
				blue_light_state = true
			else
				blue_light_state = false
			end
			update_widget()
		end
	)
end

widget_button:buttons(gears.table.join(awful.button({}, 1, nil, function()
	toggle_action()
end)))

action_info:buttons(gears.table.join(awful.button({}, 1, nil, function()
	toggle_action()
end)))

local action_widget = wibox.widget({
	layout = wibox.layout.fixed.horizontal,
	spacing = dpi(10),
	widget_button,
	{
		layout = wibox.layout.align.vertical,
		expand = "none",
		nil,
		action_info,
		nil,
	},
})

awesome.connect_signal("widget::blue_light:toggle", function()
	toggle_action()
end)

return action_widget
