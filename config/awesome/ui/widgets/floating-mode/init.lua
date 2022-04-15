local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local clickable_container = require("ui.widgets.clickable-container")
local config_dir = gears.filesystem.get_configuration_dir()
local widget_dir = config_dir .. "ui/widgets/floating-mode/"
local widget_icon_dir = widget_dir .. "icons/"

local floating_state = false

local action_name = wibox.widget({
	text = "Floating Mode",
	font = beautiful.font_name .. "Bold 10",
	align = "left",
	widget = wibox.widget.textbox,
})

local action_status = wibox.widget({
	text = "Off",
	font = beautiful.font_name .. "10",
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
		image = gears.color.recolor_image(widget_icon_dir .. "floating.svg", beautiful.xforeground),
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
	if floating_state then
		action_status:set_text("On")
		widget_button.bg = beautiful.accent
		button_widget.icon:set_image(
			gears.color.recolor_image(widget_icon_dir .. "floating.svg", beautiful.xforeground)
		)
	else
		action_status:set_text("Off")
		widget_button.bg = beautiful.control_center_button_bg
		button_widget.icon:set_image(
			gears.color.recolor_image(widget_icon_dir .. "floating.svg", beautiful.xforeground)
		)
	end
end

local check_floating_mode_state = function()
	local cmd = "cat " .. widget_dir .. "floating_mode"

	awful.spawn.easy_async_with_shell(cmd, function(stdout)
		local status = stdout

		if status:match("true") then
			floating_state = true
		elseif status:match("false") then
			floating_state = false
		else
			floating_state = false
			awful.spawn.easy_async_with_shell('echo "false" > ' .. widget_dir .. "floating_mode", function(stdout) end)
		end
		update_widget()
	end)
end

check_floating_mode_state()

local ap_off_cmd = [[
	
	# Create an AwesomeWM Notification
	awesome-client "
	naughty = require('naughty')
	naughty.notification({
		app_name = 'Layout Manager',
		title = '<b>Floating mode disabled!</b>',
		message = 'Set global layout to tile',
		icon = ']] .. widget_icon_dir .. "tile" .. ".svg" .. [['
	})
	"
	]] .. "echo false > " .. widget_dir .. "floating_mode" .. [[
]]

local ap_on_cmd = [[

	# Create an AwesomeWM Notification
	awesome-client "
	naughty = require('naughty')
	naughty.notification({
		app_name = 'Layout Manager',
		title = '<b>Floating mode enabled!</b>',
		message = 'Set global layout to floating',
		icon = ']] .. widget_icon_dir .. "floating" .. ".svg" .. [['
	})
	"
	]] .. "echo true > " .. widget_dir .. "floating_mode" .. [[
]]

local toggle_global_floating = function()
	local tags = awful.screen.focused().tags
	if not floating_state then
		for _, tag in ipairs(tags) do
			awful.layout.set(awful.layout.suit.floating, tag)
		end
		awful.spawn.easy_async_with_shell(ap_on_cmd, function(stdout)
			floating_state = true
			update_widget()
		end)
	else
		for _, tag in ipairs(tags) do
			awful.layout.set(awful.layout.suit.tile, tag)
		end
		awful.spawn.easy_async_with_shell(ap_off_cmd, function(stdout)
			floating_state = false
			update_widget()
		end)
	end
end

widget_button:buttons(gears.table.join(awful.button({}, 1, nil, function()
	toggle_global_floating()
end)))

action_info:buttons(gears.table.join(awful.button({}, 1, nil, function()
	toggle_global_floating()
end)))

gears.timer({
	timeout = 5,
	autostart = true,
	callback = function()
		check_floating_mode_state()
	end,
})

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
