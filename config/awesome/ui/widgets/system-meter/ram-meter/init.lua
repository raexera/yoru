local wibox = require("wibox")
local gears = require("gears")
local awful = require("awful")
local beautiful = require("beautiful")
local watch = awful.widget.watch
local dpi = beautiful.xresources.apply_dpi
local icons = require("icons")

local meter_name = wibox.widget({
	text = "RAM",
	font = beautiful.font_name .. "Bold 10",
	align = "left",
	widget = wibox.widget.textbox,
})

local icon = wibox.widget({
	layout = wibox.layout.align.vertical,
	expand = "none",
	nil,
	{
		image = icons.ram,
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
		id = "ram_usage",
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
	forced_height = dpi(36),
	layout = wibox.layout.align.vertical,
})

watch('bash -c "free | grep -z Mem.*Swap.*"', 10, function(_, stdout)
	local total, used, free, shared, buff_cache, available, total_swap, used_swap, free_swap = stdout:match(
		"(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*Swap:%s*(%d+)%s*(%d+)%s*(%d+)"
	)
	slider.ram_usage:set_value(used / total * 100)
	collectgarbage("collect")
end)

local ram_meter = wibox.widget({
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

return ram_meter
