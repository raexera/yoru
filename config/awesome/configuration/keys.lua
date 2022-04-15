-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
local hotkeys_popup = require("awful.hotkeys_popup")

-- Notifications library
local naughty = require("naughty")

-- Bling
local bling = require("module.bling")
local playerctl = bling.signal.playerctl.lib()

-- Machi
local machi = require("module.layout-machi")

-- Helpers
local helpers = require("helpers")

-- Default modkey.
modkey = "Mod4"
alt = "Mod1"
ctrl = "Control"
shift = "Shift"

-- Launcher
awful.keyboard.append_global_keybindings({
	awful.key({ modkey }, "Return", function()
		awful.spawn(terminal)
	end, { description = "open terminal", group = "launcher" }),
	awful.key({ modkey }, "d", function()
		awful.spawn(launcher)
	end, { description = "open applications menu", group = "launcher" }),
	awful.key({ modkey }, "f", function()
		awful.spawn(file_manager)
	end, { description = "open file manager", group = "launcher" }),
	awful.key({ modkey }, "w", function()
		awful.spawn.with_shell(browser)
	end, { description = "open web browser", group = "launcher" }),
	awful.key({ modkey }, "x", function()
		awful.spawn.with_shell("xcolor-pick")
	end, { description = "open color-picker", group = "launcher" }),
	awful.key({ modkey, shift }, "d", function()
		dashboard_toggle()
	end, { description = "toggle dashboard", group = "launcher" }),
	awful.key({ modkey, shift }, "c", function()
		control_center_toggle()
	end, { description = "toggle control center", group = "launcher" }),
	awful.key({ modkey, shift }, "n", function()
		notif_center_toggle()
	end, { description = "toggle notif center", group = "launcher" }),
	awful.key({ modkey, shift }, "t", function()
		systray_toggle()
	end, { description = "toggle systray", group = "launcher" }),
})

-- Client and Tabs Bindings
awful.keyboard.append_global_keybindings({
	awful.key({ alt }, "a", function()
		bling.module.tabbed.pick_with_dmenu()
	end, { description = "pick client to add to tab group", group = "tabs" }),
	awful.key({ alt }, "s", function()
		bling.module.tabbed.iter()
	end, { description = "iterate through tabbing group", group = "tabs" }),
	awful.key({ alt }, "d", function()
		bling.module.tabbed.pop()
	end, { description = "remove focused client from tabbing group", group = "tabs" }),
	awful.key({ modkey }, "Down", function()
		awful.client.focus.bydirection("down")
		bling.module.flash_focus.flashfocus(client.focus)
	end, { description = "focus down", group = "client" }),
	awful.key({ modkey }, "Up", function()
		awful.client.focus.bydirection("up")
		bling.module.flash_focus.flashfocus(client.focus)
	end, { description = "focus up", group = "client" }),
	awful.key({ modkey }, "Left", function()
		awful.client.focus.bydirection("left")
		bling.module.flash_focus.flashfocus(client.focus)
	end, { description = "focus left", group = "client" }),
	awful.key({ modkey }, "Right", function()
		awful.client.focus.bydirection("right")
		bling.module.flash_focus.flashfocus(client.focus)
	end, { description = "focus right", group = "client" }),
	awful.key({ modkey }, "j", function()
		awful.client.focus.byidx(1)
	end, { description = "focus next by index", group = "client" }),
	awful.key({ modkey }, "k", function()
		awful.client.focus.byidx(-1)
	end, { description = "focus previous by index", group = "client" }),
	awful.key({ modkey, "Shift" }, "j", function()
		awful.client.swap.byidx(1)
	end, { description = "swap with next client by index", group = "client" }),
	awful.key({ modkey, "Shift" }, "k", function()
		awful.client.swap.byidx(-1)
	end, { description = "swap with previous client by index", group = "client" }),
	awful.key({ modkey }, "u", awful.client.urgent.jumpto, { description = "jump to urgent client", group = "client" }),
	awful.key({ alt }, "Tab", function()
		awesome.emit_signal("bling::window_switcher::turn_on")
	end, { description = "window switcher", group = "client" }),
})

-- Hotkeys
awful.keyboard.append_global_keybindings({

	-- Brightness Control
	awful.key({}, "XF86MonBrightnessUp", function()
		awful.spawn("brightnessctl set 5%+ -q")
	end, { description = "increase brightness", group = "hotkeys" }),
	awful.key({}, "XF86MonBrightnessDown", function()
		awful.spawn("brightnessctl set 5%- -q")
	end, { description = "decrease brightness", group = "hotkeys" }),

	-- Volume control
	awful.key({}, "XF86AudioRaiseVolume", function()
		helpers.volume_control(5)
	end, { description = "increase volume", group = "hotkeys" }),
	awful.key({}, "XF86AudioLowerVolume", function()
		helpers.volume_control(-5)
	end, { description = "decrease volume", group = "hotkeys" }),
	awful.key({}, "XF86AudioMute", function()
		helpers.volume_control(0)
	end, { description = "mute volume", group = "hotkeys" }),

	-- Music
	awful.key({}, "XF86AudioPlay", function()
		playerctl:play_pause()
	end, { description = "toggle music", group = "hotkeys" }),

	awful.key({}, "XF86AudioPrev", function()
		playerctl:previous()
	end, { description = "previous music", group = "hotkeys" }),

	awful.key({}, "XF86AudioNext", function()
		playerctl:next()
	end, { description = "next music", group = "hotkeys" }),

	-- Screenshots
	awful.key({}, "Print", function()
		awful.spawn.with_shell("screensht full")
	end, { description = "take a full screenshot", group = "hotkeys" }),

	awful.key({ alt }, "Print", function()
		awful.spawn.with_shell("screensht area")
	end, { description = "take a area screenshot", group = "hotkeys" }),

	-- Lockscreen
	awful.key({ modkey, ctrl }, "l", function()
		lock_screen_show()
	end, { description = "lock screen", group = "hotkeys" }),
})

-- Awesome stuff
awful.keyboard.append_global_keybindings({
	awful.key({ modkey }, "F1", hotkeys_popup.show_help, { description = "show help", group = "awesome" }),
	awful.key({ modkey, ctrl }, "r", awesome.restart, { description = "reload awesome", group = "awesome" }),
	awful.key({ modkey, ctrl }, "q", awesome.quit, { description = "quit awesome", group = "awesome" }),
})

-- Layout Machi
awful.keyboard.append_global_keybindings({
	awful.key({ modkey }, ".", function()
		machi.default_editor.start_interactive()
	end, { description = "edit the current layout if it is a machi layout", group = "layout" }),
	awful.key({ modkey }, "/", function()
		machi.switcher.start(client.focus)
	end, { description = "switch between windows for a machi layout", group = "layout" }),
})

awful.keyboard.append_global_keybindings({
	-- Screen
	awful.key({ modkey, "Control" }, "j", function()
		awful.screen.focus_relative(1)
	end, { description = "focus the next screen", group = "screen" }),
	awful.key({ modkey, "Control" }, "k", function()
		awful.screen.focus_relative(-1)
	end, { description = "focus the previous screen", group = "screen" }),

	-- Layout
	awful.key({ modkey }, "l", function()
		awful.tag.incmwfact(0.05)
	end, { description = "increase master width factor", group = "layout" }),
	awful.key({ modkey }, "h", function()
		awful.tag.incmwfact(-0.05)
	end, { description = "decrease master width factor", group = "layout" }),
	awful.key({ modkey, "Shift" }, "h", function()
		awful.tag.incnmaster(1, nil, true)
	end, { description = "increase the number of master clients", group = "layout" }),
	awful.key({ modkey, "Shift" }, "l", function()
		awful.tag.incnmaster(-1, nil, true)
	end, { description = "decrease the number of master clients", group = "layout" }),
	awful.key({ modkey, "Control" }, "h", function()
		awful.tag.incncol(1, nil, true)
	end, { description = "increase the number of columns", group = "layout" }),
	awful.key({ modkey, "Control" }, "l", function()
		awful.tag.incncol(-1, nil, true)
	end, { description = "decrease the number of columns", group = "layout" }),
	awful.key({ modkey }, "space", function()
		awful.layout.inc(1)
	end, { description = "select next layout", group = "layout" }),
	awful.key({ modkey, "Shift" }, "space", function()
		awful.layout.inc(-1)
	end, { description = "select previous layout", group = "layout" }),

	-- Tag
	awful.key({ modkey, alt }, "Left", awful.tag.viewprev, { description = "view previous", group = "tag" }),
	awful.key({ modkey, alt }, "Right", awful.tag.viewnext, { description = "view next", group = "tag" }),
	awful.key({ modkey }, "Escape", awful.tag.history.restore, { description = "go back", group = "tag" }),

	-- Set Layout
	awful.key({ modkey, "Control" }, "w", function()
		awful.layout.set(awful.layout.suit.max)
	end, { description = "set max layout", group = "tag" }),
	awful.key({ modkey }, "s", function()
		awful.layout.set(awful.layout.suit.tile)
	end, { description = "set tile layout", group = "tag" }),
	awful.key({ modkey, shift }, "s", function()
		awful.layout.set(awful.layout.suit.floating)
	end, { description = "set floating layout", group = "tag" }),

	--Client
	awful.key({ modkey, "Control" }, "n", function()
		local c = awful.client.restore()
		-- Focus restored client
		if c then
			c:emit_signal("request::activate", "key.unminimize", { raise = true })
		end
	end, { description = "restore minimized", group = "client" }),
})

-- Client management keybinds
client.connect_signal("request::default_keybindings", function()
	awful.keyboard.append_client_keybindings({
		awful.key({ modkey, "Shift" }, "f", function(c)
			c.fullscreen = not c.fullscreen
			c:raise()
		end, { description = "toggle fullscreen", group = "client" }),
		awful.key({ modkey }, "q", function(c)
			c:kill()
		end, { description = "close", group = "client" }),
		-- Kill all visible clients for the current tag
		awful.key({ modkey, shift }, "q", function()
			local clients = awful.screen.focused().clients
			for _, c in pairs(clients) do
				c:kill()
			end
		end, { description = "kill all visible clients for the current tag", group = "client" }),
		awful.key(
			{ modkey, "Control" },
			"space",
			awful.client.floating.toggle,
			{ description = "toggle floating", group = "client" }
		),
		awful.key({ modkey, "Control" }, "Return", function(c)
			c:swap(awful.client.getmaster())
		end, { description = "move to master", group = "client" }),
		awful.key({ modkey }, "o", function(c)
			c:move_to_screen()
		end, { description = "move to screen", group = "client" }),
		awful.key({ modkey, shift }, "b", function(c)
			c.floating = not c.floating
			c.width = 400
			c.height = 200
			awful.placement.bottom_right(c)
			c.sticky = not c.sticky
		end, { description = "toggle keep on top", group = "client" }),

		awful.key({ modkey }, "n", function(c)
			-- The client currently has the input focus, so it cannot be
			-- minimized, since minimized clients can't have the focus.
			c.minimized = true
		end, { description = "minimize", group = "client" }),
		awful.key({ modkey }, "m", function(c)
			c.maximized = not c.maximized
			c:raise()
		end, { description = "(un)maximize", group = "client" }),
		awful.key({ modkey, "Control" }, "m", function(c)
			c.maximized_vertical = not c.maximized_vertical
			c:raise()
		end, { description = "(un)maximize vertically", group = "client" }),
		awful.key({ modkey, "Shift" }, "m", function(c)
			c.maximized_horizontal = not c.maximized_horizontal
			c:raise()
		end, { description = "(un)maximize horizontally", group = "client" }),

		-- On the fly padding change
		awful.key({ modkey, shift }, "=", function()
			helpers.resize_padding(5)
		end, { description = "add padding", group = "screen" }),
		awful.key({ modkey, shift }, "-", function()
			helpers.resize_padding(-5)
		end, { description = "subtract padding", group = "screen" }),

		-- On the fly useless gaps change
		awful.key({ modkey }, "=", function()
			helpers.resize_gaps(5)
		end, { description = "add gaps", group = "screen" }),

		awful.key({ modkey }, "-", function()
			helpers.resize_gaps(-5)
		end, { description = "subtract gaps", group = "screen" }),
		-- Single tap: Center client
		-- Double tap: Center client + Floating + Resize
		awful.key({ modkey }, "c", function(c)
			awful.placement.centered(c, {
				honor_workarea = true,
				honor_padding = true,
			})
			helpers.single_double_tap(nil, function()
				helpers.float_and_resize(c, screen_width * 0.25, screen_height * 0.28)
			end)
		end),
	})
end)

-- Num row keybinds
awful.keyboard.append_global_keybindings({
	awful.key({
		modifiers = { modkey },
		keygroup = "numrow",
		description = "only view tag",
		group = "tag",
		on_press = function(index)
			local screen = awful.screen.focused()
			local tag = screen.tags[index]
			if tag then
				tag:view_only()
			end
		end,
	}),
	awful.key({
		modifiers = { modkey, "Control" },
		keygroup = "numrow",
		description = "toggle tag",
		group = "tag",
		on_press = function(index)
			local screen = awful.screen.focused()
			local tag = screen.tags[index]
			if tag then
				awful.tag.viewtoggle(tag)
			end
		end,
	}),
	awful.key({
		modifiers = { modkey, "Shift" },
		keygroup = "numrow",
		description = "move focused client to tag",
		group = "tag",
		on_press = function(index)
			if client.focus then
				local tag = client.focus.screen.tags[index]
				if tag then
					client.focus:move_to_tag(tag)
				end
			end
		end,
	}),
	awful.key({
		modifiers = { modkey, "Control", "Shift" },
		keygroup = "numrow",
		description = "toggle focused client on tag",
		group = "tag",
		on_press = function(index)
			if client.focus then
				local tag = client.focus.screen.tags[index]
				if tag then
					client.focus:toggle_tag(tag)
				end
			end
		end,
	}),
})

-- Mouse bindings on desktop
------------------------------

awful.mouse.append_global_mousebindings({

	-- Left click
	awful.button({}, 1, function()
		naughty.destroy_all_notifications()
		if mymainmenu then
			mymainmenu:hide()
		end
	end),

	-- Middle click
	awful.button({}, 2, function()
		dashboard_toggle()
	end),

	-- Right click
	awful.button({}, 3, function()
		mymainmenu:toggle()
	end),

	-- Side key
	awful.button({}, 4, awful.tag.viewprev),
	awful.button({}, 5, awful.tag.viewnext),
})

-- Mouse buttons on the client
--------------------------------

client.connect_signal("request::default_mousebindings", function()
	awful.mouse.append_client_mousebindings({
		awful.button({}, 1, function(c)
			c:activate({ context = "mouse_click" })
		end),
		awful.button({ modkey }, 1, function(c)
			c:activate({ context = "mouse_click", action = "mouse_move" })
		end),
		awful.button({ modkey }, 3, function(c)
			c:activate({ context = "mouse_click", action = "mouse_resize" })
		end),
	})
end)
