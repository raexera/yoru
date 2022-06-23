local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local config_dir = gears.filesystem.get_configuration_dir()
local widget_dir = config_dir .. "ui/panels/central-panel/quick-settings/airplane-mode/"
local widget_icon_dir = widget_dir .. "icons/"
local widgets = require("ui.widgets")

--- Airplane-Mode Widget
--- ~~~~~~~~~~~~~~~~~~~~

local airplane_mode_state = false

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

local widget = button("")

local update_widget = function()
	if airplane_mode_state then
		widget:turn_on()
	else
		widget:turn_off()
	end
end

local check_airplane_mode_state = function()
	local cmd = "cat " .. widget_dir .. "airplane_mode_status"

	awful.spawn.easy_async_with_shell(cmd, function(stdout)
		local status = stdout

		if status:match("true") then
			airplane_mode_state = true
		elseif status:match("false") then
			airplane_mode_state = false
		else
			airplane_mode_state = false
			awful.spawn.easy_async_with_shell('echo "false" > ' .. widget_dir .. "airplane_mode", function(stdout) end)
		end
		update_widget()
	end)
end

check_airplane_mode_state()

local airplane_off_cmd = [[
	
	rfkill unblock wlan

	# Create an AwesomeWM Notification
	awesome-client "
	naughty = require('naughty')
	naughty.notification({
		app_name = 'Network Manager',
		title = 'Airplane mode disabled!',
		message = 'Initializing network devices',
		icon = ']] .. widget_icon_dir .. "airplane-mode-off" .. ".svg" .. [['
	})
	"
	]] .. "echo false > " .. widget_dir .. "airplane_mode_status" .. [[
]]

local airplane_on_cmd = [[

	rfkill block wlan

	# Create an AwesomeWM Notification
	awesome-client "
	naughty = require('naughty')
	naughty.notification({
		app_name = 'Network Manager',
		title = 'Airplane mode enabled!',
		message = 'Disabling radio devices',
		icon = ']] .. widget_icon_dir .. "airplane-mode" .. ".svg" .. [['
	})
	"
	]] .. "echo true > " .. widget_dir .. "airplane_mode_status" .. [[
]]

local toggle_action = function()
	if airplane_mode_state then
		awful.spawn.easy_async_with_shell(airplane_off_cmd, function(stdout)
			airplane_mode_state = false
			update_widget()
		end)
	else
		awful.spawn.easy_async_with_shell(airplane_on_cmd, function(stdout)
			airplane_mode_state = true
			update_widget()
		end)
	end
end

widget:buttons(gears.table.join(awful.button({}, 1, nil, function()
	toggle_action()
end)))

gears.timer({
	timeout = 5,
	autostart = true,
	callback = function()
		check_airplane_mode_state()
	end,
})

return widget
