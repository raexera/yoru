local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local window_switcher_first_client -- The client that was focused when the window_switcher was activated
local window_switcher_minimized_clients = {} -- The clients that were minimized when the window switcher was activated
local window_switcher_grabber

local get_num_clients = function()
	local minimized_clients_in_tag = 0
	local matcher = function(c)
		return awful.rules.match(c, {
			minimized = true,
			skip_taskbar = false,
			hidden = false,
			first_tag = awful.screen.focused().selected_tag,
		})
	end
	for c in awful.client.iterate(matcher) do
		minimized_clients_in_tag = minimized_clients_in_tag + 1
	end
	return minimized_clients_in_tag + #awful.screen.focused().clients
end

local window_switcher_hide = function(window_switcher_box)
	-- Add currently focused client to history
	if client.focus then
		local window_switcher_last_client = client.focus
		awful.client.focus.history.add(window_switcher_last_client)
		-- Raise client that was focused originally
		-- Then raise last focused client
		if window_switcher_first_client and window_switcher_first_client.valid then
			window_switcher_first_client:raise()
			window_switcher_last_client:raise()
		end
	end

	-- Minimize originally minimized clients
	local s = awful.screen.focused()
	for _, c in pairs(window_switcher_minimized_clients) do
		if c and c.valid and not (client.focus and client.focus == c) then
			c.minimized = true
		end
	end
	-- Reset helper table
	window_switcher_minimized_clients = {}

	-- Resume recording focus history
	awful.client.focus.history.enable_tracking()
	-- Stop and hide window_switcher
	awful.keygrabber.stop(window_switcher_grabber)
	window_switcher_box.visible = false
	window_switcher_box.widget = nil
	collectgarbage("collect")
end

local function draw_widget(mouse_keys)
	local tasklist_widget = awful.widget.tasklist({
		screen = awful.screen.focused(),
		filter = awful.widget.tasklist.filter.currenttags,
		buttons = mouse_keys,
		style = {
			font = beautiful.font,
			bg_normal = beautiful.black,
			bg_focus = beautiful.lighter_black,
			fg_normal = beautiful.white,
			fg_focus = beautiful.accent,
			shape = gears.shape.rounded_rect,
		},
		layout = {
			layout = wibox.layout.fixed.horizontal,
		},
		widget_template = {
			{
				{
					{
						awful.widget.clienticon,
						forced_height = dpi(80),
						forced_width = dpi(80),
						halign = "center",
						valign = "center",
						widget = wibox.container.place,
					},
					{
						{
							widget = wibox.container.scroll.horizontal,
							step_function = wibox.container.scroll.step_functions.waiting_nonlinear_back_and_forth,
							fps = 60,
							speed = 75,
							{
								id = "text_role",
								widget = wibox.widget.textbox,
							},
						},
						halign = "center",
						valign = "center",
						widget = wibox.container.place,
					},
					spacing = dpi(15),
					layout = wibox.layout.fixed.vertical,
				},
				margins = dpi(15),
				widget = wibox.container.margin,
			},
			forced_width = dpi(150),
			forced_height = dpi(150),
			id = "background_role",
			widget = wibox.container.background,
		},
	})

	return wibox.widget({
		{
			tasklist_widget,
			margins = dpi(15),
			widget = wibox.container.margin,
		},
		bg = beautiful.black,
		shape = gears.shape.rounded_rect,
		widget = wibox.container.background,
	})
end

local enable = function()
	local hide_window_switcher_key = "Escape"

	local select_client_key = 1
	local minimize_key = "n"
	local unminimize_key = "N"
	local kill_client_key = "q"

	local cycle_key = "Tab"

	local previous_key = "Left"
	local next_key = "Right"

	local vim_previous_key = "h"
	local vim_next_key = "l"

	local scroll_previous_key = 4
	local scroll_next_key = 5

	local window_switcher_box = awful.popup({
		bg = "#00000000",
		visible = false,
		ontop = true,
		placement = awful.placement.centered,
		screen = awful.screen.focused(),
		widget = wibox.container.background, -- A dummy widget to make awful.popup not scream
		widget = draw_widget(),
	})

	local mouse_keys = gears.table.join(
		awful.button({
			modifiers = { "Any" },
			button = select_client_key,
			on_press = function(c)
				client.focus = c
			end,
		}),

		awful.button({
			modifiers = { "Any" },
			button = scroll_previous_key,
			on_press = function()
				awful.client.focus.byidx(-1)
			end,
		}),

		awful.button({
			modifiers = { "Any" },
			button = scroll_next_key,
			on_press = function()
				awful.client.focus.byidx(1)
			end,
		})
	)

	local keyboard_keys = {
		[hide_window_switcher_key] = function()
			window_switcher_hide(window_switcher_box)
		end,

		[minimize_key] = function()
			if client.focus then
				client.focus.minimized = true
			end
		end,
		[unminimize_key] = function()
			if awful.client.restore() then
				client.focus = awful.client.restore()
			end
		end,
		[kill_client_key] = function()
			if client.focus then
				client.focus:kill()
			end
		end,

		[cycle_key] = function()
			awful.client.focus.byidx(1)
		end,

		[previous_key] = function()
			awful.client.focus.byidx(1)
		end,
		[next_key] = function()
			awful.client.focus.byidx(-1)
		end,

		[vim_previous_key] = function()
			awful.client.focus.byidx(1)
		end,
		[vim_next_key] = function()
			awful.client.focus.byidx(-1)
		end,
	}

	window_switcher_box:connect_signal("property::width", function()
		if window_switcher_box.visible and get_num_clients() == 0 then
			window_switcher_hide(window_switcher_box)
		end
	end)

	window_switcher_box:connect_signal("property::height", function()
		if window_switcher_box.visible and get_num_clients() == 0 then
			window_switcher_hide(window_switcher_box)
		end
	end)

	awesome.connect_signal("window_switcher::turn_on", function()
		local number_of_clients = get_num_clients()
		if number_of_clients == 0 then
			return
		end

		-- Store client that is focused in a variable
		window_switcher_first_client = client.focus

		-- Stop recording focus history
		awful.client.focus.history.disable_tracking()

		-- Go to previously focused client (in the tag)
		awful.client.focus.history.previous()

		-- Track minimized clients
		-- Unminimize them
		-- Lower them so that they are always below other
		-- originally unminimized windows
		local clients = awful.screen.focused().selected_tag:clients()
		for _, c in pairs(clients) do
			if c.minimized then
				table.insert(window_switcher_minimized_clients, c)
				c.minimized = false
				c:lower()
			end
		end

		-- Start the keygrabber
		window_switcher_grabber = awful.keygrabber.run(function(_, key, event)
			if event == "release" then
				-- Hide if the modifier was released
				-- We try to match Super or Alt or Control since we do not know which keybind is
				-- used to activate the window switcher (the keybind is set by the user in keys.lua)
				if key:match("Super") or key:match("Alt") or key:match("Control") then
					window_switcher_hide(window_switcher_box)
				end
				-- Do nothing
				return
			end

			-- Run function attached to key, if it exists
			if keyboard_keys[key] then
				keyboard_keys[key]()
			end
		end)

		window_switcher_box.widget = draw_widget(mouse_keys)
		window_switcher_box.visible = true
	end)
end

return { enable = enable }
