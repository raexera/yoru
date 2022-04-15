local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local naughty = require("naughty")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local clickable_container = require("ui.widgets.clickable-container")
local helpers = require("helpers")
local day_night = {}

local function theme_container(widget)
	local container = wibox.widget({
		{
			{
				widget,
				margins = dpi(15),
				forced_height = dpi(30),
				forced_width = dpi(30),
				widget = wibox.container.margin,
			},
			widget = clickable_container,
		},
		shape = helpers.rrect(beautiful.control_center_widget_radius),
		bg = beautiful.lighter_bg,
		widget = wibox.container.background,
	})

	return container
end

local night = wibox.widget({
	{
		id = "icon",
		image = gears.color.recolor_image(beautiful.night, beautiful.xforeground),
		widget = wibox.widget.imagebox,
		resize = true,
	},
	layout = wibox.layout.align.horizontal,
})

night:connect_signal("button::press", function()
	awful.spawn.with_shell(gears.filesystem.get_configuration_dir() .. "theme/themes night")
	awesome.restart()
end)

local day = wibox.widget({
	{
		id = "icon",
		image = gears.color.recolor_image(beautiful.day, beautiful.xforeground),
		widget = wibox.widget.imagebox,
		resize = true,
	},
	layout = wibox.layout.align.horizontal,
})

day:connect_signal("button::press", function()
	awful.spawn.with_shell(gears.filesystem.get_configuration_dir() .. "theme/themes day")
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
