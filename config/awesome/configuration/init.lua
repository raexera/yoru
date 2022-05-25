local awful = require("awful")
local gears = require("gears")
local naughty = require("naughty")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local helpers = require("helpers")
local hotkeys_popup = require("awful.hotkeys_popup")
local apps = require("configuration.apps")

-- Bling Module
local bling = require("module.bling")

-- Layout Machi
local machi = require("module.layout-machi")
beautiful.layout_machi = machi.get_icon()

-- Desktop
-------------

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
		local icon = gears.surface(beautiful.awesome_icon)
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

-- Flash focus
bling.module.flash_focus.enable()

-- Custom Layouts
local mstab = bling.layout.mstab
local centered = bling.layout.centered
local horizontal = bling.layout.horizontal
local equal = bling.layout.equalarea
local deck = bling.layout.deck

machi.editor.nested_layouts = {
	["0"] = deck,
	["1"] = awful.layout.suit.spiral,
	["2"] = awful.layout.suit.fair,
	["3"] = awful.layout.suit.fair.horizontal,
}

-- Set the layouts
tag.connect_signal("request::default_layouts", function()
	awful.layout.append_default_layouts({
		awful.layout.suit.tile,
		awful.layout.suit.floating,
		centered,
		mstab,
		horizontal,
		machi.default_layout,
		equal,
		deck,
	})
end)

-- Screen Padding and Tags
screen.connect_signal("request::desktop_decoration", function(s)
	-- Screen padding
	screen[s].padding = dpi(5)
	-- -- Each screen has its own tag table.
	awful.tag({ "1", "2", "3", "4", "5" }, s, awful.layout.layouts[1])
end)

-- Helper function to be used by decoration themes to enable client rounding
local function enable_rounding()
	-- Apply rounded corners to clients if needed
	if beautiful.corner_radius and beautiful.corner_radius > 0 then
		client.connect_signal("manage", function(c, startup)
			if not c.fullscreen and not c.maximized then
				c.shape = helpers.rrect(beautiful.corner_radius)
			end
		end)

		-- Fullscreen and maximized clients should not have rounded corners
		local function no_round_corners(c)
			if c.fullscreen or c.maximized then
				c.shape = gears.shape.rectangle
			else
				c.shape = helpers.rrect(beautiful.corner_radius)
			end
		end

		client.connect_signal("property::fullscreen", no_round_corners)
		client.connect_signal("property::maximized", no_round_corners)

		beautiful.snap_shape = helpers.rrect(beautiful.corner_radius * 2)
	else
		beautiful.snap_shape = gears.shape.rectangle
	end
end

enable_rounding()

-- Create a launcher widget and a main menu
awful.screen.connect_for_each_screen(function(s)
	-- Submenu
	awesomemenu = {
		{
			"Hotkeys",
			function()
				hotkeys_popup.show_help(nil, awful.screen.focused())
			end,
		},
		{ "Manual", apps.default.terminal .. " -e man awesome" },
		{ "Edit Config", apps.default.text_editor .. " " .. awesome.conffile },
		{ "Restart", awesome.restart },
		{
			"Quit",
			function()
				awesome.quit()
			end,
		},
	}

	-- Mainmenu
	mymainmenu = awful.menu({
		items = {
			{
				"Terminal",
				function()
					awful.spawn(apps.default.terminal)
				end,
			},
			{
				"Code Editor",
				function()
					awful.spawn(apps.default.code_editor)
				end,
			},
			{
				"File Manager",
				function()
					awful.spawn(apps.default.file_manager)
				end,
			},
			{
				"Web Browser",
				function()
					awful.spawn(apps.default.web_browser)
				end,
			},
			{ "AwesomeWM", awesomemenu, beautiful.awesome_icon },
		},
	})
end)

-- Import configuration stuff
require("configuration.keys")
require("configuration.ruled")
