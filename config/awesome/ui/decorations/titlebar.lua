local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local helpers = require("helpers")

local button_commands = {
	["close"] = {
		fun = function(c)
			c:kill()
		end,
		track_property = nil,
	},
	["minimize"] = {
		fun = function(c)
			c.minimized = true
		end,
	},
	["maximize"] = {
		fun = function(c)
			c.maximized = not c.maximized
			c:raise()
		end,
		track_property = "maximized",
	},
	["floating"] = {
		fun = function(c)
			c.floating = not c.floating
			c:raise()
		end,
		track_property = "floating",
	},
}

local double_click_event_handler = function(double_click_event)
	if double_click_timer then
		double_click_timer:stop()
		double_click_timer = nil
		double_click_event()
		return
	end
	double_click_timer = gears.timer.start_new(0.20, function()
		double_click_timer = nil
		return false
	end)
end

local create_click_events = function(c)
	-- Titlebar button/click events
	local buttons = gears.table.join(
		awful.button({}, 1, function()
			double_click_event_handler(function()
				if c.floating then
					c.floating = false
					return
				end
				c.maximized = not c.maximized
				c:raise()
				return
			end)
			c:activate({ context = "titlebar", action = "mouse_move" })
		end),
		awful.button({}, 3, function()
			c:activate({ context = "titlebar", action = "mouse_resize" })
		end)
	)
	return buttons
end

local function create_titlebar_button(c, shape, color, unfocused_color, hover_color, cmd)
	local button = wibox.widget({
		forced_width = dpi(12),
		forced_height = dpi(12),
		bg = (client.focus and c == client.focus) and color or unfocused_color,
		shape = shape,
		widget = wibox.container.background,
	})

	button:buttons(gears.table.join(awful.button({}, 1, function()
		button_commands[cmd].fun(c)
	end)))

	local p = button_commands[cmd].track_property
	-- Track client property if needed
	if p then
		c:connect_signal("property::" .. p, function()
			button.bg = c[p] and color .. "40" or color
		end)
		c:connect_signal("focus", function()
			button.bg = c[p] and color .. "40" or color
		end)
		button:connect_signal("mouse::leave", function()
			if c == client.focus then
				button.bg = c[p] and color .. "40" or color
			else
				button.bg = unfocused_color
			end
		end)
	else
		button:connect_signal("mouse::leave", function()
			if c == client.focus then
				button.bg = color
			else
				button.bg = unfocused_color
			end
		end)
		c:connect_signal("focus", function()
			button.bg = color
		end)
	end

	button:connect_signal("mouse::enter", function()
		button.bg = hover_color
	end)

	c:connect_signal("unfocus", function()
		button.bg = unfocused_color
	end)

	return button
end

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
	-- buttons for the titlebar
	local close = create_titlebar_button(
		c,
		gears.shape.circle,
		beautiful.xcolor1,
		beautiful.titlebar_color_unfocused,
		beautiful.xcolor9,
		"close"
	)

	local minimize = create_titlebar_button(
		c,
		gears.shape.circle,
		beautiful.xcolor3,
		beautiful.titlebar_color_unfocused,
		beautiful.xcolor11,
		"minimize"
	)

	local maximize = create_titlebar_button(
		c,
		gears.shape.circle,
		beautiful.xcolor2,
		beautiful.titlebar_color_unfocused,
		beautiful.xcolor10,
		"maximize"
	)

	local floating = create_titlebar_button(
		c,
		gears.shape.circle,
		beautiful.xcolor4,
		beautiful.titlebar_color_unfocused,
		beautiful.xcolor12,
		"floating"
	)

	-- Titlebars setup
	--------------------
	awful.titlebar(c, { position = "left", size = dpi(36), bg = beautiful.transparent }):setup({
		{
			layout = wibox.layout.align.vertical,
			{
				{
					close,
					minimize,
					maximize,
					spacing = dpi(10),
					layout = wibox.layout.fixed.vertical,
				},
				margins = dpi(10),
				widget = wibox.container.margin,
			},
			{
				buttons = create_click_events(c),
				layout = wibox.layout.flex.vertical,
			},
			{
				{
					floating,
					spacing = dpi(10),
					layout = wibox.layout.fixed.vertical,
				},
				margins = dpi(10),
				widget = wibox.container.margin,
			},
		},
		bg = beautiful.titlebar_bg,
		shape = helpers.prrect(beautiful.corner_radius, true, false, false, true),
		widget = wibox.container.background,
	})
end)
