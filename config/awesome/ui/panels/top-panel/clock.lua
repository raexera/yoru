local wibox = require("wibox")
local beautiful = require("beautiful")
local helpers = require("helpers")
local wbutton = require("ui.widgets.button")

--- Clock Widget
--- ~~~~~~~~~~~~

return function(s)
	local accent_color = beautiful.white
	local clock = wibox.widget({
		widget = wibox.widget.textclock,
		format = "%a %b %e %l:%M %p",
		align = "center",
		valign = "center",
		font = beautiful.font_name .. "Medium 12",
	})

	clock.markup = helpers.ui.colorize_text(clock.text, accent_color)
	clock:connect_signal("widget::redraw_needed", function()
		clock.markup = helpers.ui.colorize_text(clock.text, accent_color)
	end)

	local widget = wbutton.elevated.state({
		child = clock,
		normal_bg = beautiful.wibar_bg,
		on_release = function()
			awesome.emit_signal("info_panel::toggle", s)
		end,
	})

	return widget
end
