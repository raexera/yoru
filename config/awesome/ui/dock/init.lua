local awful = require("awful")
local gears = require("gears")
local dock = require("ui.dock.dock")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

-- Minimalist Dock
awful.screen.connect_for_each_screen(function(s)
	dock.init({
		screen = s,
		height = dpi(50),
		offset = dpi(10),
		inner_shape = gears.shape.rounded_rect,
	})
end)
