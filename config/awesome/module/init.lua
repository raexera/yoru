local gears = require("gears")
local dock = require("module.dock")
dock.init({
	screen = screen.primary,
	height = dpi(50),
	offset = dpi(5),
	inner_shape = gears.shape.rounded_rect
})

require("module.bling")
require("module.rubato")
require("module.layout-machi")
require("module.better-resize")
require("module.exit-screen")
require("module.tooltip")
require("module.savefloats")
require("module.window_switcher").enable()
