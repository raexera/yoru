local awful = require("awful")
local watch = awful.widget.watch
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local config_dir = gears.filesystem.get_configuration_dir()
local widget_dir = config_dir .. "ui/panels/central-panel/quick-settings/bluetooth/"
local widget_icon_dir = widget_dir .. "icons/"
local widgets = require("ui.widgets")

--- Bluetooth Widget
--- ~~~~~~~~~~~~~~~~

local bluetooth_state = false

local function button(icon)
	return widgets.button.text.state({
		forced_width = dpi(60),
		forced_height = dpi(60),
		normal_bg = beautiful.one_bg3,
		normal_shape = gears.shape.circle,
		on_normal_bg = beautiful.accent,
		text_normal_bg = beautiful.accent,
		text_on_normal_bg = beautiful.one_bg3,
		font = beautiful.icon_font .. "Round ",
		size = 17,
		text = icon,
	})
end

local widget = button("")

local update_widget = function()
	if bluetooth_state then
		widget:turn_on()
	else
		widget:turn_off()
	end
end

local check_bluetooth_state = function()
	awful.spawn.easy_async_with_shell("rfkill list bluetooth", function(stdout)
		if stdout:match("Soft blocked: yes") then
			bluetooth_state = false
		else
			bluetooth_state = true
		end

		update_widget()
	end)
end

check_bluetooth_state()

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
	if bluetooth_state then
		awful.spawn.easy_async_with_shell(power_off_cmd, function(stdout)
			bluetooth_state = false
			update_widget()
		end)
	else
		awful.spawn.easy_async_with_shell(power_on_cmd, function(stdout)
			bluetooth_state = true
			update_widget()
		end)
	end
end

widget:buttons(gears.table.join(awful.button({}, 1, nil, function()
	toggle_action()
end)))

watch("rfkill list bluetooth", 5, function(_, stdout)
	check_bluetooth_state()
	collectgarbage("collect")
end)

return widget
