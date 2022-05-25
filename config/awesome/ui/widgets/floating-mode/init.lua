local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local clickable_container = require("ui.widgets.clickable-container")
local icons = require("icons")

local global_floating_enabled = false

local action_name = wibox.widget({
	text = "Floating Mode",
	font = beautiful.font_name .. "Bold 10",
	align = "left",
	widget = wibox.widget.textbox,
})

local action_status = wibox.widget({
	text = "Off",
	font = beautiful.font_name .. "Regular 10",
	align = "left",
	widget = wibox.widget.textbox,
})

local action_info = wibox.widget({
	layout = wibox.layout.fixed.vertical,
	action_name,
	action_status,
})

local button_widget = wibox.widget({
	{
		id = "icon",
		image = icons.floating,
		widget = wibox.widget.imagebox,
		resize = true,
	},
	layout = wibox.layout.align.horizontal,
})

local widget_button = wibox.widget({
	{
		{
			button_widget,
			margins = dpi(15),
			forced_height = dpi(48),
			forced_width = dpi(48),
			widget = wibox.container.margin,
		},
		widget = clickable_container,
	},
	bg = beautiful.control_center_button_bg,
	shape = gears.shape.circle,
	widget = wibox.container.background,
})

local update_widget = function()
	if global_floating_enabled then
		action_status:set_text("On")
		widget_button.bg = beautiful.accent
	else
		action_status:set_text("Off")
		widget_button.bg = beautiful.control_center_button_bg
	end
end

local toggle_global_floating = function()
	local tags = awful.screen.focused().tags
	if not global_floating_enabled then
		for _, tag in ipairs(tags) do
			awful.layout.set(awful.layout.suit.floating, tag)
		end
		global_floating_enabled = true
		update_widget()
	else
		for _, tag in ipairs(tags) do
			awful.layout.set(awful.layout.suit.tile, tag)
		end
		global_floating_enabled = false
		update_widget()
	end
end

widget_button:buttons(gears.table.join(awful.button({}, 1, nil, function()
	toggle_global_floating()
end)))

action_info:buttons(gears.table.join(awful.button({}, 1, nil, function()
	toggle_global_floating()
end)))

local action_widget = wibox.widget({
	layout = wibox.layout.fixed.horizontal,
	spacing = dpi(10),
	widget_button,
	{
		layout = wibox.layout.align.vertical,
		expand = "none",
		nil,
		action_info,
		nil,
	},
})

return action_widget
