local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local helpers = require("helpers")
local decorations = require("ui.decorations")

--- MacOS like window decorations
--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

--- Disable this if using `picom` to round your corners
--- decorations.enable_rounding()

local button_size = dpi(16)
local button_margin = { top = dpi(2), bottom = dpi(2), left = dpi(5), right = dpi(5) }
local button_color_unfocused = beautiful.xcolor8
local button_shape = gears.shape.circle

local function close(c)
	return decorations.button(
		c,
		button_shape,
		beautiful.xcolor1,
		button_color_unfocused,
		beautiful.xcolor9,
		button_size,
		button_margin,
		"close"
	)
end

local function minimize(c)
	return decorations.button(
		c,
		button_shape,
		beautiful.xcolor3,
		button_color_unfocused,
		beautiful.xcolor11,
		button_size,
		button_margin,
		"minimize"
	)
end

local function maximize(c)
	return decorations.button(
		c,
		button_shape,
		beautiful.xcolor2,
		button_color_unfocused,
		beautiful.xcolor10,
		button_size,
		button_margin,
		"maximize"
	)
end

--- Tabbed
local bling = require("modules.bling")
local tabbed_misc = bling.widget.tabbed_misc

--- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
	awful.titlebar(
		c,
		{ position = "top", size = dpi(38), font = beautiful.font_name .. "Medium 10", bg = beautiful.transparent }
	):setup({
		{
			layout = wibox.layout.align.horizontal,
			{ --- Left
				{
					close(c),
					minimize(c),
					maximize(c),
					--- Create some extra padding at the edge
					helpers.ui.horizontal_pad(dpi(5)),
					layout = wibox.layout.fixed.horizontal,
				},
				left = dpi(10),
				widget = wibox.container.margin,
			},
			{ --- Middle
				{ --- Title
					align = "center",
					font = beautiful.font_name .. "Medium 10",
					widget = awful.titlebar.widget.titlewidget(c),
					buttons = {
						--- Move client
						awful.button({
							modifiers = {},
							button = 1,
							on_press = function()
								c.maximized = false
								c:activate({ context = "mouse_click", action = "mouse_move" })
							end,
						}),

						--- Kill client
						awful.button({
							modifiers = {},
							button = 2,
							on_press = function()
								c:kill()
							end,
						}),

						--- Resize client
						awful.button({
							modifiers = {},
							button = 3,
							on_press = function()
								c.maximized = false
								c:activate({ context = "mouse_click", action = "mouse_resize" })
							end,
						}),

						--- Side button up
						awful.button({
							modifiers = {},
							button = 9,
							on_press = function()
								c.floating = not c.floating
							end,
						}),

						--- Side button down
						awful.button({
							modifiers = {},
							button = 8,
							on_press = function()
								c.ontop = not c.ontop
							end,
						}),
					},
				},
				layout = wibox.layout.flex.horizontal,
			},
			--- Right
			{
				{
					tabbed_misc.titlebar_indicator(c, {
						icon_size = dpi(15),
						icon_margin = dpi(6),
						layout_spacing = dpi(0),
						bg_color_focus = beautiful.xcolor0,
						bg_color = beautiful.lighter_xbackground,
						icon_shape = gears.shape.rectangle,
					}),
					bg = beautiful.darker_xbackground,
					shape = gears.shape.rounded_rect,
					widget = wibox.container.background,
				},
				top = dpi(7),
				bottom = dpi(7),
				right = dpi(14),
				widget = wibox.container.margin,
			},
		},
		bg = beautiful.titlebar_bg,
		shape = helpers.ui.prrect(beautiful.border_radius, true, true, false, false),
		widget = wibox.container.background,
	})

	awful.titlebar(c, {
		position = "bottom",
		size = dpi(19),
		bg = beautiful.transparent,
	}):setup({
		bg = beautiful.titlebar_bg,
		shape = helpers.ui.prrect(beautiful.border_radius, false, false, true, true),
		widget = wibox.container.background,
	})
end)
