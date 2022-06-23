local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local dpi = beautiful.xresources.apply_dpi
local helpers = require("helpers")
local wibox = require("wibox")

--- Slider Widget
--- ~~~~~~~~~~~~~

local function sliders(icons)
	local icon = wibox.widget({
		markup = icons,
		font = beautiful.icon_font .. "Round 17",
		align = "center",
		valign = "center",
		widget = wibox.widget.textbox,
	})

	local widget = wibox.widget({
		icon,
		{
			id = "slider",
			value = 10,
			maximum = 100,
			forced_width = dpi(220),
			shape = gears.shape.rounded_bar,
			bar_shape = gears.shape.rounded_bar,
			bar_color = beautiful.grey,
			bar_margins = { bottom = dpi(18), top = dpi(18) },
			bar_active_color = beautiful.accent,
			handle_width = dpi(14),
			handle_shape = gears.shape.circle,
			handle_color = beautiful.accent,
			handle_border_width = dpi(3),
			handle_border_color = beautiful.widget_bg,
			widget = wibox.widget.slider,
		},
		{
			id = "text",
			markup = "10%",
			font = beautiful.font_name .. "13",
			align = "center",
			valign = "center",
			widget = wibox.widget.textbox,
		},
		layout = wibox.layout.fixed.horizontal,
		forced_height = dpi(42),
		spacing = dpi(17),
	})

	return widget
end

--- Brightness
--- ~~~~~~~~~~
local brightness = sliders("")
local brightness_slider = brightness:get_children_by_id("slider")[1]
local brightness_text = brightness:get_children_by_id("text")[1]

awful.spawn.easy_async_with_shell(
	"brightnessctl | grep -i  'current' | awk '{ print $4}' | tr -d \"(%)\"",
	function(stdout)
		local value = string.gsub(stdout, "^%s*(.-)%s*$", "%1")
		brightness_slider.value = tonumber(value)
		brightness_text.markup = value .. "%"
	end
)

brightness_slider:connect_signal("property::value", function(_, new_value)
	brightness_text.markup = new_value .. "%"
	brightness_slider.value = new_value
	awful.spawn("brightnessctl set " .. new_value .. "%", false)
end)

--- Volume
--- ~~~~~~
local volume = sliders("")
local volume_slider = volume:get_children_by_id("slider")[1]
local volume_text = volume:get_children_by_id("text")[1]

awful.spawn.easy_async_with_shell("pamixer --get-volume", function(stdout)
	local value = string.gsub(stdout, "^%s*(.-)%s*$", "%1")
	volume_slider.value = tonumber(value)
	volume_text.markup = value .. "%"
end)

volume_slider:connect_signal("property::value", function(_, new_value)
	volume_text.markup = new_value .. "%"
	volume_slider.value = new_value
	awful.spawn("pamixer --set-volume " .. new_value, false)
end)

return wibox.widget({
	{
		{
			{
				brightness,
				volume,
				spacing = dpi(12),
				layout = wibox.layout.fixed.vertical,
			},
			margins = { top = dpi(12), bottom = dpi(12), left = dpi(18), right = dpi(12) },
			widget = wibox.container.margin,
		},
		widget = wibox.container.background,
		forced_height = dpi(120),
		forced_width = dpi(350),
		bg = beautiful.widget_bg,
		shape = helpers.ui.rrect(beautiful.border_radius),
	},
	margins = dpi(10),
	color = "#FF000000",
	widget = wibox.container.margin,
})
