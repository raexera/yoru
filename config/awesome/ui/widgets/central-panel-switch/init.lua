local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local clickable_container = require("ui.widgets.clickable-container")

-- Variable used for switching panel modes
local central_panel_mode = "dashboard_mode"

local active_button = beautiful.lighter_bg
local inactive_button = beautiful.transparent

local settings_text = wibox.widget({
	text = "Settings",
	font = beautiful.font_name .. "Bold 11",
	align = "center",
	valign = "center",
	widget = wibox.widget.textbox,
})

local settings_button = clickable_container(wibox.container.margin(settings_text, dpi(0), dpi(0), dpi(7), dpi(7)))

local wrap_settings = wibox.widget({
	settings_button,
	forced_width = dpi(93),
	bg = inactive_button,
	border_width = dpi(1),
	border_color = beautiful.lighter_bg,
	shape = function(cr, width, height)
		gears.shape.partially_rounded_rect(cr, width, height, false, true, true, false, dpi(6))
	end,
	widget = wibox.container.background,
})

local dashboard_text = wibox.widget({
	text = "Dashboard",
	font = beautiful.font_name .. "Bold 11",
	align = "center",
	valign = "center",
	widget = wibox.widget.textbox,
})

local dashboard_button = clickable_container(wibox.container.margin(dashboard_text, dpi(0), dpi(0), dpi(7), dpi(7)))

local wrap_dashboard = wibox.widget({
	dashboard_button,
	forced_width = dpi(93),
	bg = active_button,
	border_width = dpi(1),
	border_color = beautiful.lighter_bg,
	shape = function(cr, width, height)
		gears.shape.partially_rounded_rect(cr, width, height, true, false, false, true, dpi(6))
	end,
	widget = wibox.container.background,
})

local switcher = wibox.widget({
	expand = "none",
	layout = wibox.layout.fixed.horizontal,
	wrap_dashboard,
	wrap_settings,
})

function switch_rdb_pane(central_panel_mode)
	if central_panel_mode == "dashboard_mode" then
		-- Update button color
		wrap_dashboard.bg = active_button
		wrap_settings.bg = inactive_button

		-- Change panel content of floating-panel.lua
		central_panel:switch_pane(central_panel_mode)
	elseif central_panel_mode == "settings_mode" then
		-- Update button color
		wrap_dashboard.bg = inactive_button
		wrap_settings.bg = active_button

		-- Change panel content of floating-panel.lua
		central_panel:switch_pane(central_panel_mode)
	end
end

dashboard_button:buttons(gears.table.join(awful.button({}, 1, nil, function()
	switch_rdb_pane("dashboard_mode")
end)))

settings_button:buttons(gears.table.join(awful.button({}, 1, nil, function()
	switch_rdb_pane("settings_mode")
end)))

return switcher
