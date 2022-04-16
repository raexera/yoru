-- Standard awesome library
local awful = require("awful")
require("awful.autofocus")
local gears = require("gears")
local gfs = gears.filesystem
local naughty = require("naughty")
local wibox = require("wibox")

-- Theme handling library
local beautiful = require("beautiful")

-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
naughty.connect_signal("request::display_error", function(message, startup)
	naughty.notification({
		urgency = "critical",
		title = "Oops, an error happened" .. (startup and " during startup!" or "!"),
		message = message,
	})
end)

client.connect_signal("request::manage", function(c)
	-- Add missing icon to client
	if not c.icon then
		local icon = gears.surface(beautiful.awesome_logo)
		c.icon = icon._native
		icon:finish()
	end

	-- Set the windows at the slave,
	if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
		-- Prevent clients from being unreachable after screen count changes.
		awful.placement.no_offscreen(c)
	end
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
	c:emit_signal("request::activate", "mouse_enter", { raise = false })
end)

-- Hide all windows when a splash is shown
awesome.connect_signal("widgets::splash::visibility", function(vis)
	local t = screen.primary.selected_tag
	if vis then
		for idx, c in ipairs(t:clients()) do
			c.hidden = true
		end
	else
		for idx, c in ipairs(t:clients()) do
			c.hidden = false
		end
	end
end)

--Bling
----------

local bling = require("module.bling")

bling.module.flash_focus.enable()

-- Tag Preview
bling.widget.tag_preview.enable({
	show_client_content = false,
	placement_fn = function(c)
		awful.placement.top_left(c, {
			margins = {
				top = dpi(83),
				left = beautiful.wibar_width + dpi(50),
			},
		})
	end,
	scale = 0.20,
	honor_padding = true,
	honor_workarea = false,
	background_widget = wibox.widget({
		-- image = beautiful.wallpaper,
		-- horizontal_fit_policy = "fit",
		-- vertical_fit_policy = "fit",
		-- widget = wibox.widget.imagebox
		bg = beautiful.darker_bg,
		widget = wibox.container.bg,
	}),
})
