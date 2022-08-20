require(... .. ".notifications")
require(... .. ".popups")

local decorations = require(... .. ".decorations")
decorations.init()

local top_panel = require(... .. ".panels.top-panel")
local central_panel = require(... .. ".panels.central-panel")
local info_panel = require(... .. ".panels.info-panel")
local notification_panel = require(... .. ".panels.notification-panel")

local awful = require("awful")
awful.screen.connect_for_each_screen(function(s)
	--- Panels
	top_panel(s)
	central_panel(s)
	info_panel(s)
	notification_panel(s)
end)
