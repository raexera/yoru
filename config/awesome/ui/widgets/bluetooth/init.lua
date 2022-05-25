local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local watch = awful.widget.watch
local dpi = beautiful.xresources.apply_dpi
local clickable_container = require("ui.widgets.clickable-container")
local config_dir = gears.filesystem.get_configuration_dir()
local widget_dir = config_dir .. "ui/widgets/bluetooth/"
local widget_icon_dir = widget_dir .. "icons/"
local device_state = false

local action_name = wibox.widget({
	text = "Bluetooth",
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
		image = widget_icon_dir .. "bluetooth-off.svg",
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
	if device_state then
		action_status:set_text("On")
		widget_button.bg = beautiful.accent
		button_widget.icon:set_image(widget_icon_dir .. "bluetooth.svg")
	else
		action_status:set_text("Off")
		widget_button.bg = beautiful.control_center_button_bg
		button_widget.icon:set_image(widget_icon_dir .. "bluetooth-off.svg")
	end
end

local check_device_state = function()
	awful.spawn.easy_async_with_shell("rfkill list bluetooth", function(stdout)
		if stdout:match("Soft blocked: yes") then
			device_state = false
		else
			device_state = true
		end

		update_widget()
	end)
end

check_device_state()
local power_on_cmd = [[
	rfkill unblock bluetooth

	# Create an AwesomeWM Notification
	awesome-client "
	naughty = require('naughty')
	naughty.notification({
		app_name = 'Bluetooth Manager',
		title = 'System Notification',
		message = 'Initializing bluetooth device...',
		icon = ']] .. widget_icon_dir .. "loading" .. ".svg" .. [['
	})
	"

	# Add a delay here so we can enable the bluetooth
	sleep 1
	
	bluetoothctl power on
]]

local power_off_cmd = [[
	bluetoothctl power off
	rfkill block bluetooth

	# Create an AwesomeWM Notification
	awesome-client "
	naughty = require('naughty')
	naughty.notification({
		app_name = 'Bluetooth Manager',
		title = 'System Notification',
		message = 'The bluetooth device has been disabled.',
		icon = ']] .. widget_icon_dir .. "bluetooth-off" .. ".svg" .. [['
	})
	"
]]

local toggle_action = function()
	if device_state then
		awful.spawn.easy_async_with_shell(power_off_cmd, function(stdout)
			device_state = false
			update_widget()
		end)
	else
		awful.spawn.easy_async_with_shell(power_on_cmd, function(stdout)
			device_state = true
			update_widget()
		end)
	end
end

widget_button:buttons(gears.table.join(awful.button({}, 1, nil, function()
	toggle_action()
end)))

action_info:buttons(gears.table.join(awful.button({}, 1, nil, function()
	toggle_action()
end)))

watch("rfkill list bluetooth", 5, function(_, stdout)
	check_device_state()
	collectgarbage("collect")
end)

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

return action_widget
