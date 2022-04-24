local awful = require("awful")
local watch = awful.widget.watch
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local active_color = beautiful.accent

local ram_arc = wibox.widget({
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

watch('bash -c "free | grep -z Mem.*Swap.*"', 10, function(_, stdout)
	local total, used, free, shared, buff_cache, available, total_swap, used_swap, free_swap = stdout:match(
		"(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*Swap:%s*(%d+)%s*(%d+)%s*(%d+)"
	)
	ram_arc:set_value(used / total * 100)
	collectgarbage("collect")
end)

return ram_arc
