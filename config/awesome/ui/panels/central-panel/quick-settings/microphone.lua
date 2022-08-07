local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local widgets = require("ui.widgets")

--- Mic Widget
--- ~~~~~~~~~~~~~~~~~

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

local widget = button("")

local update_widget = function()
	awful.spawn.easy_async_with_shell(
		[[
		amixer sget Capture toggle | tail -n 1 | awk '{print $6}' | tr -d '[]'
		]],
		function(stdout)
			if stdout:match("on") then
				widget:turn_off()
			else
				widget:turn_on()
			end
		end
	)
end

--- run once every startup/reload
update_widget()

--- buttons
widget:buttons(gears.table.join(awful.button({}, 1, nil, function()
	awful.spawn("amixer sset Capture toggle", false)
	update_widget()
end)))

return widget
