local awful = require("awful")
local hotkeys_popup = require("awful.hotkeys_popup")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local naughty = require("naughty")
local decorations = require("ui.decorations")
local bling = require("modules.bling")
local playerctl_daemon = require("signal.playerctl")
local machi = require("modules.layout-machi")
local helpers = require("helpers")
local apps = require("configuration.apps")

--- Make key easier to call
--- ~~~~~~~~~~~~~~~~~~~~~~~
mod = "Mod4"
alt = "Mod1"
ctrl = "Control"
shift = "Shift"

--- Global key bindings
--- ~~~~~~~~~~~~~~~~~~~
awful.keyboard.append_global_keybindings({

	--- App
	--- ~~~
	-- Terminal
	awful.key({ mod }, "Return", function()
		awful.spawn(apps.default.terminal)
	end, { description = "open terminal", group = "app" }),

	--- App launcher
	awful.key({ mod }, "d", function()
		awful.spawn.with_shell(apps.default.app_launcher)
	end, { description = "open app launcher", group = "app" }),

	--- Code editor
	awful.key({ mod, shift }, "e", function()
		awful.spawn(apps.default.code_editor)
	end, { description = "open code editor", group = "app" }),

	--- File manager
	awful.key({ mod, shift }, "f", function()
		awful.spawn(apps.default.file_manager)
	end, { description = "open file manager", group = "app" }),

	--- Web browser
	awful.key({ mod, shift }, "w", function()
		awful.spawn(apps.default.web_browser)
	end, { description = "open web browser", group = "app" }),

	--- WM
	--- ~~
	--- Restart awesome
	awful.key({ mod, ctrl }, "r", awesome.restart, { description = "reload awesome", group = "WM" }),

	--- Quit awesome
	awful.key({ mod, ctrl }, "q", awesome.quit, { description = "quit awesome", group = "WM" }),

	--- Show help
	awful.key({ mod }, "F1", hotkeys_popup.show_help, { description = "show Help", group = "WM" }),

	--- Client
	--- ~~~~~~
	--- Focus client by direction
	awful.key({ mod }, "k", function()
		awful.client.focus.bydirection("up")
		bling.module.flash_focus.flashfocus(client.focus)
	end, { description = "focus up", group = "client" }),
	awful.key({ mod }, "j", function()
		awful.client.focus.bydirection("down")
		bling.module.flash_focus.flashfocus(client.focus)
	end, { description = "focus down", group = "client" }),
	awful.key({ mod }, "h", function()
		awful.client.focus.bydirection("left")
		bling.module.flash_focus.flashfocus(client.focus)
	end, { description = "focus left", group = "client" }),
	awful.key({ mod }, "l", function()
		awful.client.focus.bydirection("right")
		bling.module.flash_focus.flashfocus(client.focus)
	end, { description = "focus right", group = "client" }),

	awful.key({ mod }, "Up", function()
		awful.client.focus.bydirection("up")
		bling.module.flash_focus.flashfocus(client.focus)
	end, { description = "focus up", group = "client" }),
	awful.key({ mod }, "Down", function()
		awful.client.focus.bydirection("down")
		bling.module.flash_focus.flashfocus(client.focus)
	end, { description = "focus down", group = "client" }),
	awful.key({ mod }, "Left", function()
		awful.client.focus.bydirection("left")
		bling.module.flash_focus.flashfocus(client.focus)
	end, { description = "focus left", group = "client" }),
	awful.key({ mod }, "Right", function()
		awful.client.focus.bydirection("right")
		bling.module.flash_focus.flashfocus(client.focus)
	end, { description = "focus right", group = "client" }),

	--- Resize focused client
	awful.key({ mod, ctrl }, "k", function(c)
		helpers.client.resize_client(client.focus, "up")
	end, { description = "resize to the up", group = "client" }),
	awful.key({ mod, ctrl }, "j", function(c)
		helpers.client.resize_client(client.focus, "down")
	end, { description = "resize to the down", group = "client" }),
	awful.key({ mod, ctrl }, "h", function(c)
		helpers.client.resize_client(client.focus, "left")
	end, { description = "resize to the left", group = "client" }),
	awful.key({ mod, ctrl }, "l", function(c)
		helpers.client.resize_client(client.focus, "right")
	end, { description = "resize to the right", group = "client" }),

	awful.key({ mod, ctrl }, "Up", function(c)
		helpers.client.resize_client(client.focus, "up")
	end, { description = "resize to the up", group = "client" }),
	awful.key({ mod, ctrl }, "Down", function(c)
		helpers.client.resize_client(client.focus, "down")
	end, { description = "resize to the down", group = "client" }),
	awful.key({ mod, ctrl }, "Left", function(c)
		helpers.client.resize_client(client.focus, "left")
	end, { description = "resize to the left", group = "client" }),
	awful.key({ mod, ctrl }, "Right", function(c)
		helpers.client.resize_client(client.focus, "right")
	end, { description = "resize to the right", group = "client" }),

	--- Bling
	--- ~~~~~
	--- Add client to tabbed layout
	awful.key({ alt }, "a", function()
		bling.module.tabbed.pick_with_dmenu()
	end, { description = "pick client to add to tab group", group = "tabs" }),

	--- Remove client from tabbed layout
	awful.key({ alt }, "d", function()
		bling.module.tabbed.pop()
	end, { description = "remove focused client from tabbing group", group = "tabs" }),

	--- Cycle through client in tabbed layout
	awful.key({ alt }, "s", function()
		bling.module.tabbed.iter()
	end, { description = "iterate through tabbing group", group = "tabs" }),

	--- Hotkeys
	--- ~~~~~~~
	--- Music player
	awful.key({ mod }, "grave", function()
		awful.spawn.with_shell(apps.default.music_player)
	end, { description = "open music client", group = "hotkeys" }),

	--- Brightness Control
	awful.key({}, "XF86MonBrightnessUp", function()
		awful.spawn("brightnessctl set 5%+ -q", false)
		awesome.emit_signal("widget::brightness")
		awesome.emit_signal("module::brightness_osd:show", true)
	end, { description = "increase brightness", group = "hotkeys" }),
	awful.key({}, "XF86MonBrightnessDown", function()
		awful.spawn("brightnessctl set 5%- -q", false)
		awesome.emit_signal("widget::brightness")
		awesome.emit_signal("module::brightness_osd:show", true)
	end, { description = "decrease brightness", group = "hotkeys" }),

	--- Volume control
	awful.key({}, "XF86AudioRaiseVolume", function()
		awful.spawn("amixer sset Master 5%+", false)
		awesome.emit_signal("widget::volume")
		awesome.emit_signal("module::volume_osd:show", true)
	end, { description = "increase volume", group = "hotkeys" }),
	awful.key({}, "XF86AudioLowerVolume", function()
		awful.spawn("amixer sset Master 5%-", false)
		awesome.emit_signal("widget::volume")
		awesome.emit_signal("module::volume_osd:show", true)
	end, { description = "decrease volume", group = "hotkeys" }),
	awful.key({}, "XF86AudioMute", function()
		awful.spawn("amixer sset Master toggle", false)
	end, { description = "mute volume", group = "hotkeys" }),

	--- Music
	awful.key({}, "XF86AudioPlay", function()
		playerctl_daemon:play_pause()
	end, { description = "play pause music", group = "hotkeys" }),
	awful.key({}, "XF86AudioPrev", function()
		playerctl_daemon:previous()
	end, { description = "previous music", group = "hotkeys" }),
	awful.key({}, "XF86AudioNext", function()
		playerctl_daemon:next()
	end, { description = "next music", group = "hotkeys" }),

	--- Color picker
	awful.key({ mod, shift }, "x", function()
		awful.spawn.easy_async_with_shell(apps.utils.color_picker, function() end)
	end, { description = "open color picker", group = "hotkeys" }),

	--- Screenshots
	awful.key({}, "Print", function()
		awful.spawn.easy_async_with_shell(apps.utils.full_screenshot, function() end)
	end, { description = "take a full screenshot", group = "hotkeys" }),

	awful.key({ alt }, "Print", function()
		awful.spawn.easy_async_with_shell(apps.utils.area_screenshot, function() end)
	end, { description = "take a area screenshot", group = "hotkeys" }),

	--- Lockscreen
	awful.key({ mod, alt }, "l", function()
		lock_screen_show()
	end, { description = "lock screen", group = "hotkeys" }),

	--- Exit screen
	awful.key({ mod }, "Escape", function()
		awesome.emit_signal("module::exit_screen:show")
	end, { description = "exit screen", group = "hotkeys" }),
})

--- Client key bindings
--- ~~~~~~~~~~~~~~~~~~~
client.connect_signal("request::default_keybindings", function()
	awful.keyboard.append_client_keybindings({
		-- Move or swap by direction
		awful.key({ mod, shift }, "k", function(c)
			helpers.client.move_client(c, "up")
		end),
		awful.key({ mod, shift }, "j", function(c)
			helpers.client.move_client(c, "down")
		end),
		awful.key({ mod, shift }, "h", function(c)
			helpers.client.move_client(c, "left")
		end),
		awful.key({ mod, shift }, "l", function(c)
			helpers.client.move_client(c, "right")
		end),

		awful.key({ mod, shift }, "Up", function(c)
			helpers.client.move_client(c, "up")
		end),
		awful.key({ mod, shift }, "Down", function(c)
			helpers.client.move_client(c, "down")
		end),
		awful.key({ mod, shift }, "Left", function(c)
			helpers.client.move_client(c, "left")
		end),
		awful.key({ mod, shift }, "Right", function(c)
			helpers.client.move_client(c, "right")
		end),

		--- Relative move client
		awful.key({ mod, shift, ctrl }, "j", function(c)
			c:relative_move(0, dpi(20), 0, 0)
		end),

		awful.key({ mod, shift, ctrl }, "k", function(c)
			c:relative_move(0, dpi(-20), 0, 0)
		end),

		awful.key({ mod, shift, ctrl }, "h", function(c)
			c:relative_move(dpi(-20), 0, 0, 0)
		end),

		awful.key({ mod, shift, ctrl }, "l", function(c)
			c:relative_move(dpi(20), 0, 0, 0)
		end),

		--- Toggle titlebars (for focused client only)
		awful.key({ mod }, "t", function(c)
			decorations.cycle(c)
		end, { description = "toggle titlebar", group = "client" }),
		--- Toggle titlebars (for all visible clients in selected tag)
		awful.key({ mod, shift }, "t", function(c)
			local clients = awful.screen.focused().clients
			for _, c in pairs(clients) do
				decorations.cycle(c)
			end
		end, { description = "toggle titlebar", group = "client" }),

		--- Toggle floating
		awful.key({ mod, ctrl }, "space", awful.client.floating.toggle),

		--- Toggle fullscreen
		awful.key({ mod }, "f", function()
			client.focus.fullscreen = not client.focus.fullscreen
			client.focus:raise()
		end),

		--- Maximize windows
		awful.key({ mod }, "m", function(c)
			c.maximized = not c.maximized
		end, { description = "toggle maximize", group = "client" }),
		awful.key({ mod, ctrl }, "m", function(c)
			c.maximized_vertical = not c.maximized_vertical
			c:raise()
		end, { description = "(un)maximize vertically", group = "client" }),
		awful.key({ mod, shift }, "m", function(c)
			c.maximized_horizontal = not c.maximized_horizontal
			c:raise()
		end, { description = "(un)maximize horizontally", group = "client" }),

		--- Minimize windows
		awful.key({ mod }, "n", function(c)
			-- The client currently has the input focus, so it cannot be
			-- minimized, since minimized clients can't have the focus.
			c.minimized = true
		end, { description = "minimize", group = "client" }),

		--- Un-minimize windows
		awful.key({ mod, ctrl }, "n", function()
			local c = awful.client.restore()
			-- Focus restored client
			if c then
				c:activate({ raise = true, context = "key.unminimize" })
			end
		end, { description = "restore minimized", group = "client" }),

		--- Keep on top
		awful.key({ mod }, "p", function(c)
			c.ontop = not c.ontop
		end),

		--- Sticky
		awful.key({ mod, shift }, "p", function(c)
			c.sticky = not c.sticky
		end),

		--- Close window
		awful.key({ mod }, "q", function()
			client.focus:kill()
		end),

		--- Center window
		awful.key({ mod }, "c", function()
			awful.placement.centered(c, { honor_workarea = true, honor_padding = true })
		end),

		--- Window switcher
		awful.key({ alt }, "Tab", function()
			awesome.emit_signal("window_switcher::turn_on")
		end),
	})
end)

--- Layout
--- ~~~~~~
awful.keyboard.append_global_keybindings({
	--- Set tilling layout
	awful.key({ mod }, "s", function()
		awful.layout.set(awful.layout.suit.tile)
	end, { description = "set tile layout", group = "layout" }),

	--- Set floating layout
	awful.key({ mod, shift }, "s", function()
		awful.layout.set(awful.layout.suit.floating)
	end, { description = "set floating layout", group = "layout" }),

	--- Layout machi
	awful.key({ mod }, ".", function()
		machi.default_editor.start_interactive()
	end, { description = "edit the current layout if it is a machi layout", group = "layout" }),
	awful.key({ mod }, "/", function()
		machi.switcher.start(client.focus)
	end, { description = "switch between windows for a machi layout", group = "layout" }),

	--- Number of columns
	awful.key({ mod, alt }, "k", function()
		awful.tag.incncol(1, nil, true)
	end, { description = "increase the number of columns", group = "layout" }),
	awful.key({ mod, alt }, "j", function()
		awful.tag.incncol(-1, nil, true)
	end, { description = "decrease the number of columns", group = "layout" }),
	awful.key({ mod, alt }, "Up", function()
		awful.tag.incncol(1, nil, true)
	end, { description = "increase the number of columns", group = "layout" }),
	awful.key({ mod, alt }, "Down", function()
		awful.tag.incncol(-1, nil, true)
	end, { description = "decrease the number of columns", group = "layout" }),

	--- On the fly padding change
	awful.key({ mod, shift }, "=", function()
		helpers.client.resize_padding(5)
	end, { description = "add padding", group = "layout" }),
	awful.key({ mod, shift }, "-", function()
		helpers.client.resize_padding(-5)
	end, { description = "subtract padding", group = "layout" }),

	--- On the fly useless gaps change
	awful.key({ mod }, "=", function()
		helpers.client.resize_gaps(5)
	end, { description = "add gaps", group = "layout" }),

	awful.key({ mod }, "-", function()
		helpers.client.resize_gaps(-5)
	end, { description = "subtract gaps", group = "layout" }),
})

--- Move through workspaces
--- ~~~~~~~~~~~~~~~~~~~~~~~
awful.keyboard.append_global_keybindings({
	awful.key({ mod, alt }, "Left", awful.tag.viewprev, { description = "view previous", group = "tags" }),
	awful.key({ mod, alt }, "Right", awful.tag.viewnext, { description = "view next", group = "tags" }),
	awful.key({
		modifiers = { mod },
		keygroup = "numrow",
		description = "only view tag",
		group = "tags",
		on_press = function(index)
			local screen = awful.screen.focused()
			local tag = screen.tags[index]
			if tag then
				tag:view_only()
			end
		end,
	}),
	awful.key({
		modifiers = { mod, ctrl },
		keygroup = "numrow",
		description = "toggle tag",
		group = "tags",
		on_press = function(index)
			local screen = awful.screen.focused()
			local tag = screen.tags[index]
			if tag then
				awful.tag.viewtoggle(tag)
			end
		end,
	}),
	awful.key({
		modifiers = { mod, shift },
		keygroup = "numrow",
		description = "move focused client to tag",
		group = "tags",
		on_press = function(index)
			if client.focus then
				local tag = client.focus.screen.tags[index]
				if tag then
					client.focus:move_to_tag(tag)
				end
			end
		end,
	}),
})

-- Screen
-----------
--awful.keyboard.append_global_keybindings({
-- No need for these (single screen setup)
--awful.key({ superkey, ctrlkey }, "j", function () awful.screen.focus_relative( 1) end,
--{description = "focus the next screen", group = "screen"}),
--awful.key({ superkey, ctrlkey }, "k", function () awful.screen.focus_relative(-1) end,
--{description = "focus the previous screen", group = "screen"}),
--})

--- Mouse bindings on desktop
--- ~~~~~~~~~~~~~~~~~~~~~~~~~
local main_menu = require("ui.main-menu")
awful.mouse.append_global_mousebindings({
	--- Right click
	awful.button({
		modifiers = {},
		button = 3,
		on_press = function()
			main_menu:toggle()
		end,
	}),
})

awful.mouse.append_global_mousebindings({
	--- Left click
	awful.button({}, 1, function()
		naughty.destroy_all_notifications()
	end),

	--- Middle click
	awful.button({}, 2, function()
		awesome.emit_signal("central_panel::toggle", awful.screen.focused())
	end),
})

--- Mouse buttons on the client
--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~
client.connect_signal("request::default_mousebindings", function()
	awful.mouse.append_client_mousebindings({
		awful.button({}, 1, function(c)
			c:activate({ context = "mouse_click" })
		end),
		awful.button({ mod }, 1, function(c)
			c:activate({ context = "mouse_click", action = "mouse_move" })
		end),
		awful.button({ mod }, 3, function(c)
			c:activate({ context = "mouse_click", action = "mouse_resize" })
		end),
	})
end)
