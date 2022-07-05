local wibox = require("wibox")
local gears = require("gears")
local awful = require("awful")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local widgets = require("ui.widgets")

local action_level = widgets.button.text.normal({
	normal_shape = gears.shape.circle,
	font = beautiful.icon_font .. "Round ",
	size = 17,
	text_normal_bg = beautiful.accent,
	normal_bg = beautiful.one_bg3,
	text = "",
	paddings = dpi(5),
	animate_size = false,
	on_release = function()
		brightness_action_jump()
	end,
})

local osd_value = wibox.widget({
	text = "0%",
	font = beautiful.font_name .. "Medium 13",
	align = "center",
	valign = "center",
	widget = wibox.widget.textbox,
})

local slider = wibox.widget({
	nil,
	{
		id = "brightness_slider",
		shape = gears.shape.rounded_bar,
		bar_shape = gears.shape.rounded_bar,
		bar_color = beautiful.grey,
		bar_margins = { bottom = dpi(18), top = dpi(18) },
		bar_active_color = beautiful.accent,
		handle_color = beautiful.accent,
		handle_shape = gears.shape.circle,
		handle_width = dpi(15),
		handle_border_width = dpi(3),
		handle_border_color = beautiful.widget_bg,
		maximum = 100,
		widget = wibox.widget.slider,
	},
	nil,
	expand = "none",
	forced_width = dpi(200),
	layout = wibox.layout.align.vertical,
})

local brightness_slider = slider.brightness_slider

brightness_slider:connect_signal("property::value", function()
	local brightness_level = brightness_slider:get_value()
	awful.spawn("brightnessctl set " .. brightness_level .. "%", false)

	-- Update textbox widget text
	osd_value.text = brightness_level .. "%"

	-- Update brightness osd
	awesome.emit_signal("module::brightness_osd", brightness_level)
end)

brightness_slider:buttons(gears.table.join(
	awful.button({}, 4, nil, function()
		if brightness_slider:get_value() > 100 then
			brightness_slider:set_value(100)
			return
		end
		brightness_slider:set_value(brightness_slider:get_value() + 5)
	end),
	awful.button({}, 5, nil, function()
		if brightness_slider:get_value() < 0 then
			brightness_slider:set_value(0)
			return
		end
		brightness_slider:set_value(brightness_slider:get_value() - 5)
	end)
))

local update_slider = function()
	awful.spawn.easy_async_with_shell(
		"brightnessctl | grep -i  'current' | awk '{ print $4}' | tr -d \"(%)\"",
		function(stdout)
			local value = string.gsub(stdout, "^%s*(.-)%s*$", "%1")
			brightness_slider:set_value(tonumber(value))
			osd_value.text = value .. "%"
		end
	)
end

-- Update on startup
update_slider()

function brightness_action_jump()
	local sli_value = brightness_slider:get_value()
	local new_value = 0

	if sli_value >= 0 and sli_value < 50 then
		new_value = 50
	elseif sli_value >= 50 and sli_value < 100 then
		new_value = 100
	else
		new_value = 0
	end
	brightness_slider:set_value(new_value)
end

-- The emit will come from the global keybind
awesome.connect_signal("widget::brightness", function()
	update_slider()
end)

-- The emit will come from the OSD
awesome.connect_signal("widget::brightness:update", function(value)
	brightness_slider:set_value(tonumber(value))
end)

local brightness_setting = wibox.widget({
	{
		layout = wibox.layout.fixed.horizontal,
		spacing = dpi(5),
		{
			layout = wibox.layout.align.vertical,
			expand = "none",
			nil,
			action_level,
			nil,
		},
	},
	slider,
	osd_value,
	layout = wibox.layout.fixed.horizontal,
	forced_height = dpi(42),
	spacing = dpi(17),
})

return brightness_setting
