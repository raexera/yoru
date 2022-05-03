local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local clickable_container = require("ui.widgets.clickable-container")
local helpers = require("helpers")
local day_night = {}

local function theme_container(widget, name)
	local container = wibox.widget({
		{
			{
				{
					widget,
					forced_height = dpi(70),
					forced_width = dpi(70),
					widget = wibox.container.margin,
				},
				margins = dpi(5),
				widget = wibox.container.margin,
			},
			widget = clickable_container,
		},
		shape = helpers.rrect(beautiful.control_center_widget_radius),
		bg = beautiful.control_center_widget_bg,
		widget = wibox.container.background,
	})

	return container
end

local night = wibox.widget({
	align = "center",
	valign = "center",
	font = "icomoon 50",
	markup = helpers.colorize_text("", beautiful.xforeground),
	widget = wibox.widget.textbox(),
})

night:connect_signal("button::press", function()
	awful.spawn.with_shell(gears.filesystem.get_configuration_dir() .. "configuration/themes-switcher night")
	awesome.restart()
end)

local day = wibox.widget({
	align = "center",
	valign = "center",
	font = "icomoon 50",
	markup = helpers.colorize_text("", beautiful.xforeground),
	widget = wibox.widget.textbox(),
})

day:connect_signal("button::press", function()
	awful.spawn.with_shell(gears.filesystem.get_configuration_dir() .. "configuration/themes-switcher day")
	awesome.restart()
end)

day_night.night = theme_container(night)
day_night.day = theme_container(day)

local update_themes = function()
	if theme == themes[2] then
		day_night.night.bg = beautiful.accent
	else
		day_night.day.bg = beautiful.accent
	end
end

update_themes()

return day_night
