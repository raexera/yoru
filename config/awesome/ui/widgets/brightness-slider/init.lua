local wibox = require("wibox")
local gears = require("gears")
local awful = require("awful")
local beautiful = require("beautiful")
local spawn = awful.spawn
local dpi = beautiful.xresources.apply_dpi
local clickable_container = require("ui.widgets.clickable-container")

local action_name = wibox.widget({
	text = "Brightness",
	font = beautiful.font_name .. "Bold 10",
	align = "left",
	widget = wibox.widget.textbox,
})

local icon = wibox.widget({
	layout = wibox.layout.align.vertical,
	expand = "none",
	nil,
	{
		text = "",
		font = beautiful.icon_font .. "Round 13",
		align = "center",
		valign = "center",
		widget = wibox.widget.textbox(),
	},
	nil,
})

local action_level = wibox.widget({
	{
		{
			icon,
			margins = dpi(5),
			widget = wibox.container.margin,
		},
		widget = clickable_container,
	},
	bg = beautiful.control_center_button_bg,
	shape = gears.shape.circle,
	widget = wibox.container.background,
})

local slider = wibox.widget({
	nil,
	{
		id = "brightness_slider",
		bar_shape = gears.shape.rounded_rect,
		bar_height = dpi(24),
		bar_color = "#ffffff20",
		bar_active_color = beautiful.xforeground,
		handle_color = "#ffffff",
		handle_shape = gears.shape.circle,
		handle_width = dpi(24),
		handle_border_color = "#00000012",
		handle_border_width = dpi(1),
		maximum = 100,
		widget = wibox.widget.slider,
	},
	nil,
	expand = "none",
	forced_height = dpi(24),
	layout = wibox.layout.align.vertical,
})

local brightness_slider = slider.brightness_slider

brightness_slider:connect_signal("property::value", function()
	local brightness_level = brightness_slider:get_value()

	spawn("brightnessctl s " .. brightness_level .. "%", false)

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
	awful.spawn.easy_async_with_shell("brightnessctl i | grep -oP '\\(\\K[^%\\)]+'", function(stdout)
		local brightness = string.match(stdout, "(%d+)")
		brightness_slider:set_value(tonumber(brightness))
	end)
end

-- Update on startup
update_slider()

local action_jump = function()
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

action_level:buttons(awful.util.table.join(awful.button({}, 1, nil, function()
	action_jump()
end)))

-- The emit will come from the global keybind
awesome.connect_signal("widget::brightness", function()
	update_slider()
end)

-- The emit will come from the OSD
awesome.connect_signal("widget::brightness:update", function(value)
	brightness_slider:set_value(tonumber(value))
end)

local brightness_setting = wibox.widget({
	layout = wibox.layout.fixed.vertical,
	spacing = dpi(5),
	action_name,
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
		slider,
	},
})

return brightness_setting
