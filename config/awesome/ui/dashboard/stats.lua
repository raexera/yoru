-- Standard awesome library
local gears = require("gears")
local awful = require("awful")

-- Theme handling library
local beautiful = require("beautiful")

-- Notification library
local naughty = require("naughty")

-- Widget library
local wibox = require("wibox")

-- rubato
local rubato = require("module.rubato")

-- Helpers
local helpers = require("helpers")

-- Stats
----------

local stats_text = wibox.widget({
	font = beautiful.font_name .. "medium 8",
	markup = helpers.colorize_text("Stats", beautiful.dashboard_box_fg),
	valign = "center",
	widget = wibox.widget.textbox,
})

-- Vars
local vol_color = beautiful.xcolor4
local brightness_color = beautiful.xcolor5
local cpu_color = beautiful.xcolor6
local ram_color = beautiful.xcolor2

-- Helpers
local function create_slider_widget(slider_color)
	local slider_widget = wibox.widget({
		{
			id = "slider",
			max_value = 100,
			value = 20,
			background_color = slider_color .. "44",
			color = slider_color,
			shape = gears.shape.rounded_rect,
			bar_shape = gears.shape.rounded_rect,
			widget = wibox.widget.progressbar,
		},
		forced_width = dpi(4),
		forced_height = dpi(145),
		direction = "east",
		widget = wibox.container.rotate,
	})

	return slider_widget
end

local stats_tooltip = wibox.widget({
	visible = false,
	top_only = true,
	layout = wibox.layout.stack,
})

local tooltip_counter = 0
local function create_tooltip(w)
	local tooltip = wibox.widget({
		font = beautiful.font_name .. "medium 8",
		align = "right",
		valign = "center",
		widget = wibox.widget.textbox,
	})

	tooltip_counter = tooltip_counter + 1
	local index = tooltip_counter

	stats_tooltip:insert(index, tooltip)

	w:connect_signal("mouse::enter", function()
		-- Raise tooltip to the top of the stack
		stats_tooltip:set(1, tooltip)
		stats_tooltip.visible = true
	end)
	w:connect_signal("mouse::leave", function()
		stats_tooltip.visible = false
	end)

	return tooltip
end

-- Widget
local vol = create_slider_widget(vol_color)
local brightness = create_slider_widget(brightness_color)
local cpu = create_slider_widget(cpu_color)
local ram = create_slider_widget(ram_color)

local vol_tooltip = create_tooltip(vol)
local brightness_tooltip = create_tooltip(brightness)
local cpu_tooltip = create_tooltip(cpu)
local ram_tooltip = create_tooltip(ram)

awesome.connect_signal("signal::volume", function(value, muted)
	local fill_color
	local vol_value = value or 0

	if muted then
		fill_color = beautiful.xcolor8
	else
		fill_color = vol_color
	end

	vol.slider.value = vol_value
	vol.slider.color = fill_color
	vol_tooltip.markup = helpers.colorize_text(vol_value .. "%", vol_color)
end)

awesome.connect_signal("signal::brightness", function(value)
	brightness.slider.value = value
	brightness_tooltip.markup = helpers.colorize_text(value .. "%", brightness_color)
end)

awesome.connect_signal("signal::cpu", function(value)
	cpu.slider.value = value
	cpu_tooltip.markup = helpers.colorize_text(value .. "%", cpu_color)
end)

awesome.connect_signal("signal::ram", function(used, total)
	local r_average = (used / total) * 100
	local r_used = string.format("%.1f", used / 1000) .. "G"

	ram.slider.value = r_average
	ram_tooltip.markup = helpers.colorize_text(r_used, ram_color)
end)

vol:buttons(gears.table.join(
	awful.button({}, 1, function()
		helpers.volume_control(0)
	end),
	-- Scrolling
	awful.button({}, 4, function()
		helpers.volume_control(5)
	end),
	awful.button({}, 5, function()
		helpers.volume_control(-5)
	end)
))

brightness:buttons(gears.table.join(
	-- Scrolling
	awful.button({}, 4, function()
		awful.spawn.with_shell("brightnessctl set 5%+ -q")
	end),
	awful.button({}, 5, function()
		awful.spawn.with_shell("brightnessctl set 5%- -q")
	end)
))

local stats = wibox.widget({
	{
		stats_text,
		nil,
		stats_tooltip,
		expand = "none",
		layout = wibox.layout.align.horizontal,
	},
	{
		nil,
		{
			nil,
			{
				vol,
				brightness,
				cpu,
				ram,
				spacing = dpi(24),
				layout = wibox.layout.fixed.horizontal,
			},
			expand = "none",
			layout = wibox.layout.fixed.vertical,
		},
		expand = "none",
		layout = wibox.layout.align.horizontal,
	},
	spacing = dpi(10),
	layout = wibox.layout.fixed.vertical,
})

return stats
