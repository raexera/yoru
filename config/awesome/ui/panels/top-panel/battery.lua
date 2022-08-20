local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
require("signal.battery")
local gears = require("gears")
local apps = require("configuration.apps")
local dpi = require("beautiful").xresources.apply_dpi
local helpers = require("helpers")
local wbutton = require("ui.widgets.button")

--- Battery Widget
--- ~~~~~~~~~~~~~~

return function()
	local happy_color = beautiful.color2
	local sad_color = beautiful.color1
	local ok_color = beautiful.color3
	local charging_color = beautiful.color6

	local charging_icon = wibox.widget({
		markup = helpers.ui.colorize_text("", beautiful.white),
		font = beautiful.icon_font .. "Round 14",
		align = "center",
		valign = "center",
		widget = wibox.widget.textbox,
	})

	local battery_bar = wibox.widget({
		max_value = 100,
		value = 50,
		forced_width = dpi(30),
		border_width = dpi(1),
		paddings = dpi(2),
		bar_shape = helpers.ui.rrect(2),
		shape = helpers.ui.rrect(5),
		color = beautiful.white,
		background_color = beautiful.transparent,
		border_color = beautiful.white,
		widget = wibox.widget.progressbar,
	})

	local battery_decoration = wibox.widget({
		{
			wibox.widget.textbox,
			widget = wibox.container.background,
			bg = beautiful.white,
			forced_width = dpi(8.2),
			forced_height = dpi(8.2),
			shape = function(cr, width, height)
				gears.shape.pie(cr, width, height, 0, math.pi)
			end,
		},
		direction = "east",
		widget = wibox.container.rotate(),
	})

	local battery = wibox.widget({
		charging_icon,
		{
			battery_bar,
			battery_decoration,
			layout = wibox.layout.fixed.horizontal,
			spacing = dpi(-1.6),
		},
		layout = wibox.layout.fixed.horizontal,
		spacing = dpi(1),
	})

	local battery_percentage_text = wibox.widget({
		id = "percent_text",
		text = "50%",
		font = beautiful.font_name .. "Medium 12",
		align = "center",
		valign = "center",
		widget = wibox.widget.textbox,
	})

	local battery_widget = wibox.widget({
		layout = wibox.layout.fixed.horizontal,
		spacing = dpi(5),
		{
			battery,
			top = dpi(1),
			bottom = dpi(1),
			widget = wibox.container.margin,
		},
		battery_percentage_text,
	})

	local widget = wbutton.elevated.state({
		child = battery_widget,
		normal_bg = beautiful.wibar_bg,
		on_release = function()
			awful.spawn(apps.default.power_manager, false)
		end,
	})

	local last_value = 100
	awesome.connect_signal("signal::battery", function(value, state)
		battery_bar.value = value
		last_value = value

		battery_percentage_text:set_text(math.floor(value) .. "%")

		if charging_icon.visible then
			battery_bar.color = charging_color
		elseif value <= 15 then
			battery_bar.color = sad_color
		elseif value <= 30 then
			battery_bar.color = ok_color
		else
			battery_bar.color = happy_color
		end

		if state == 1 then
			charging_icon.visible = true
			battery_bar.color = charging_color
		elseif last_value <= 15 then
			charging_icon.visible = false
			battery_bar.color = sad_color
		elseif last_value <= 30 then
			charging_icon.visible = false
			battery_bar.color = ok_color
		else
			charging_icon.visible = false
			battery_bar.color = happy_color
		end
	end)

	return widget
end
