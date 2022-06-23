local awful = require("awful")
local watch = awful.widget.watch
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local widgets = require("ui.widgets")

--- Microphone Widget
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

local widget = button("")

widget:buttons(gears.table.join(awful.button({}, 1, nil, function()
	awful.spawn.with_shell("pamixer --default-source -t")
end)))

watch("pamixer --default-source --get-mute", 5, function(_, stdout)
	if stdout:match("true") then
		widget:turn_off()
	else
		widget:turn_on()
	end
	collectgarbage("collect")
end, widget)

return widget
