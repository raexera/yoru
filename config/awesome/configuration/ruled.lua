-- Standard awesome library
local gears = require("gears")
local awful = require("awful")

-- Theme handling library
local beautiful = require("beautiful")

-- Notification handling library
local naughty = require("naughty")

-- Ruled
local ruled = require("ruled")

-- Helpers
local helpers = require("helpers")

-- Get screen geometry
local screen_width = awful.screen.focused().geometry.width
local screen_height = awful.screen.focused().geometry.height

ruled.client.connect_signal("request::rules", function()
	-- Global
	ruled.client.append_rule({
		id = "global",
		rule = {},
		properties = {
			focus = awful.client.focus.filter,
			raise = true,
			size_hints_honor = false,
			screen = awful.screen.preferred,
			titlebars_enabled = beautiful.titlebar_enabled,
			placement = awful.placement.no_overlap + awful.placement.no_offscreen,
		},
	})

	-- Tasklist order
	ruled.client.append_rule({
		id = "tasklist_order",
		rule = {},
		properties = {},
		callback = awful.client.setslave,
	})

	-- Titlebar rules
	ruled.client.append_rule({
		id = "titlebars",
		rule_any = {
			class = {
				"discord",
				"Spotify",
				"Org.gnome.Nautilus",
			},
			type = {
				"splash",
			},
			name = {
				"^discord.com is sharing your screen.$", -- Discord (running in browser) screen sharing popup
			},
		},
		properties = {
			titlebars_enabled = false,
		},
	})

	-- Float
	ruled.client.append_rule({
		id = "floating",
		rule_any = {
			instance = {
				"Devtools", -- Firefox devtools
			},
			class = {
				"Lxappearance",
				"Nm-connection-editor",
			},
			name = {
				"Event Tester", -- xev
			},
			role = {
				"AlarmWindow",
				"pop-up",
				"GtkFileChooserDialog",
				"conversation",
			},
			type = {
				"dialog",
			},
		},
		properties = { floating = true, placement = helpers.centered_client_placement },
	})

	-- Centered
	ruled.client.append_rule({
		id = "centered",
		rule_any = {
			type = {
				"dialog",
			},
			class = {
				-- "discord",
			},
			role = {
				"GtkFileChooserDialog",
				"conversation",
			},
		},
		properties = { placement = helpers.centered_client_placement },
	})

	-- Music clients (usually a terminal running ncmpcpp)
	ruled.client.append_rule({
		rule_any = {
			class = {
				"music",
			},
			instance = {
				"music",
			},
		},
		properties = {
			floating = true,
			width = screen_width * 0.26,
			height = screen_height * 0.40,
			placement = helpers.centered_client_placement,
		},
	})

	-- Image viewers
	ruled.client.append_rule({
		rule_any = {
			class = {
				"feh",
				"imv",
			},
		},
		properties = {
			floating = true,
			width = screen_width * 0.7,
			height = screen_height * 0.75,
		},
		callback = function(c)
			awful.placement.centered(c, { honor_padding = true, honor_workarea = true })
		end,
	})

	-- Mpv
	ruled.client.append_rule({
		rule = { class = "mpv" },
		properties = {},
		callback = function(c)
			-- make it floating, ontop and move it out of the way if the current tag is maximized
			if awful.layout.get(awful.screen.focused()) == awful.layout.suit.floating then
				c.floating = true
				c.ontop = true
				c.width = screen_width * 0.30
				c.height = screen_height * 0.35
				awful.placement.bottom_right(c, {
					honor_padding = true,
					honor_workarea = true,
					margins = { bottom = beautiful.useless_gap * 2, right = beautiful.useless_gap * 2 },
				})
				awful.titlebar.hide(c, beautiful.titlebar_pos)
			end

			-- restore `ontop` after fullscreen is disabled
			c:connect_signal("property::fullscreen", function()
				if not c.fullscreen then
					c.ontop = true
				end
			end)
		end,
	})
end)
