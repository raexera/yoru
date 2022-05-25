local wibox = require("wibox")
local gears = require("gears")
local awful = require("awful")
local beautiful = require("beautiful")
local watch = awful.widget.watch
local dpi = beautiful.xresources.apply_dpi
local icons = require("icons")

local meter_name = wibox.widget({
	text = "CPU",
	font = beautiful.font_name .. "Bold 10",
	align = "left",
	widget = wibox.widget.textbox,
})

local icon = wibox.widget({
	layout = wibox.layout.align.vertical,
	expand = "none",
	nil,
	{
		image = icons.cpu,
		resize = true,
		widget = wibox.widget.imagebox,
	},
	nil,
})

local meter_icon = wibox.widget({
	{
		icon,
		margins = dpi(5),
		widget = wibox.container.margin,
	},
	bg = beautiful.control_center_button_bg,
	shape = gears.shape.circle,
	widget = wibox.container.background,
})

local slider = wibox.widget({
	nil,
	{
		id = "cpu_usage",
		max_value = 100,
		value = 29,
		forced_height = dpi(24),
		color = beautiful.xforeground,
		background_color = "#ffffff20",
		shape = gears.shape.rounded_rect,
		bar_shape = gears.shape.rounded_rect,
		widget = wibox.widget.progressbar,
	},
	nil,
	expand = "none",
	forced_height = dpi(24),
	layout = wibox.layout.align.vertical,
})

local total_prev = 0
local idle_prev = 0

watch(
	[[bash -c "
	cat /proc/stat | grep '^cpu '
	"]],
	10,
	function(_, stdout)
		local user, nice, system, idle, iowait, irq, softirq, steal, guest, guest_nice = stdout:match(
			"(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s"
		)

		local total = user + nice + system + idle + iowait + irq + softirq + steal

		local diff_idle = idle - idle_prev
		local diff_total = total - total_prev
		local diff_usage = (1000 * (diff_total - diff_idle) / diff_total + 5) / 10

		slider.cpu_usage:set_value(diff_usage)

		total_prev = total
		idle_prev = idle
		collectgarbage("collect")
	end
)

local cpu_meter = wibox.widget({
	layout = wibox.layout.fixed.vertical,
	spacing = dpi(5),
	meter_name,
	{
		layout = wibox.layout.fixed.horizontal,
		spacing = dpi(5),
		{
			layout = wibox.layout.align.vertical,
			expand = "none",
			nil,
			{
				layout = wibox.layout.fixed.horizontal,
				forced_height = dpi(28),
				forced_width = dpi(28),
				meter_icon,
			},
			nil,
		},
		slider,
	},
})

return cpu_meter
