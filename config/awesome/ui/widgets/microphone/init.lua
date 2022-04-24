local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local clickable_container = require("ui.widgets.clickable-container")
local helpers = require("helpers")

local mic_state = false

local button_widget = wibox.widget({
	id = "icon",
	markup = helpers.colorize_text("󰍬", beautiful.xforeground),
	font = beautiful.icon_font_name .. "18",
	align = "center",
	valign = "center",
	widget = wibox.widget.textbox,
})

local widget_button = wibox.widget({
	{
		{
			button_widget,
			margins = dpi(12),
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
	if mic_state then
		widget_button.bg = beautiful.accent
	else
		widget_button.bg = beautiful.control_center_button_bg
	end
end

local initial_action = function(button)
	awful.spawn.easy_async_with_shell(
		[[sh -c amixer | grep 'Front Left: Capture' | awk -F' ' '{print $6}' | sed -e 's/\[//' -e 's/\]//']],
		function(stdout)
			if stdout:match("on") then
				mic_state = true
			else
				mic_state = false
			end
			update_widget()
		end
	)
end

local onclick_action = function()
	awful.spawn.with_shell("amixer set Capture toggle")
end

widget_button:connect_signal("button::press", function(self, _, _, button)
	if button == 1 then
		onclick_action()
		initial_action(self)
	end
end)

initial_action(widget_button)

return widget_button
