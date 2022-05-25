local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gears = require("gears")
local apps = require("configuration.apps")
local clickable_container = require("ui.widgets.clickable-container")
local dpi = require("beautiful").xresources.apply_dpi
local helpers = require("helpers")

local battery = function()
	local happy_color = beautiful.xcolor2
	local sad_color = beautiful.xcolor1
	local ok_color = beautiful.xcolor3
	local charging_color = beautiful.xcolor6

	local charging_icon = wibox.widget({
		markup = helpers.colorize_text("", beautiful.xforeground),
		font = beautiful.icon_font .. "Round 14",
		align = "center",
		valign = "center",
		widget = wibox.widget.textbox,
	})

	local battery_bar = wibox.widget({
		max_value = 100,
		value = 50,
		forced_width = dpi(30),
		border_width = dpi(2),
		paddings = dpi(2),
		bar_shape = helpers.rrect(dpi(2)),
		shape = helpers.rrect(dpi(4)),
		color = beautiful.xforeground,
		background_color = beautiful.transparent,
		border_color = beautiful.xforeground,
		widget = wibox.widget.progressbar,
	})

	local battery_decoration = wibox.widget({
		{
			wibox.widget.textbox,
			widget = wibox.container.background,
			bg = beautiful.xforeground,
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
		font = beautiful.font_name .. "Bold 12",
		align = "center",
		valign = "center",
		widget = wibox.widget.textbox,
	})

	local battery_widget = wibox.widget({
		layout = wibox.layout.fixed.horizontal,
		spacing = dpi(5),
		battery,
		battery_percentage_text,
	})

	local battery_button = wibox.widget({
		{
			battery_widget,
			margins = { top = dpi(11), bottom = dpi(11), left = dpi(8), right = dpi(8) },
			widget = wibox.container.margin,
		},
		widget = clickable_container,
	})

	battery_button:buttons(gears.table.join(awful.button({}, 1, nil, function()
		awful.spawn(apps.default.power_manager, false)
	end)))

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

	return battery_button
end

return battery
