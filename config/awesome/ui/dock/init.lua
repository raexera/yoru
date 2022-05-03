local awful = require("awful")
local gears = require("gears")
local dock = require("ui.dock.dock")

-- Minimalist Dock
awful.screen.connect_for_each_screen(function(s)
	dock.init({
		screen = s,
		height = dpi(50),
		offset = dpi(5),
		inner_shape = gears.shape.rounded_rect,
	})
end)
