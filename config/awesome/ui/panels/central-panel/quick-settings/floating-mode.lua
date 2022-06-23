local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local widgets = require("ui.widgets")

--- Floating-Mode Widget
--- ~~~~~~~~~~~~~~~~~~~~

local floating_mode_state = false

local function button(icon)
	return widgets.button.text.state({
		forced_width = dpi(60),
		forced_height = dpi(60),
		normal_bg = beautiful.one_bg3,
		normal_shape = gears.shape.circle,
		on_normal_bg = beautiful.accent,
		text_normal_bg = beautiful.accent,
		text_on_normal_bg = beautiful.one_bg3,
		font = "icomoon bold ",
		size = 17,
		text = icon,
	})
end

local widget = button("")

local update_widget = function()
	if floating_mode_state then
		widget:turn_on()
	else
		widget:turn_off()
	end
end

local toggle_action = function()
	local tags = awful.screen.focused().tags
	if not floating_mode_state then
		for _, tag in ipairs(tags) do
			awful.layout.set(awful.layout.suit.floating, tag)
		end
		floating_mode_state = true
		update_widget()
	else
		for _, tag in ipairs(tags) do
			awful.layout.set(awful.layout.suit.tile, tag)
		end
		floating_mode_state = false
		update_widget()
	end
end

widget:buttons(gears.table.join(awful.button({}, 1, nil, function()
	toggle_action()
end)))

return widget
