local awful = require("awful")
local watch = awful.widget.watch
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local active_color = beautiful.accent

local cpu_arc = wibox.widget({
	start_angle = 3 * math.pi / 2,
	min_value = 0,
	max_value = 100,
	value = 50,
	thickness = dpi(8),
	rounded_edge = true,
	bg = active_color .. "44",
	paddings = dpi(10),
	colors = { active_color },
	widget = wibox.container.arcchart,
})

awesome.connect_signal("signal::cpu", function(value)
	cpu_arc.value = value
end)

return cpu_arc
