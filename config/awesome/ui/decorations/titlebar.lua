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

--- Tabbed
local bling = require("modules.bling")
local tabbed_misc = bling.widget.tabbed_misc

--- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
	awful
		.titlebar(c, { position = "top", size = dpi(36), font = beautiful.font_name .. "Medium 10", bg = beautiful.transparent })
		:setup({
			{
				layout = wibox.layout.align.horizontal,
				{ --- Left
					{
						{
							awful.titlebar.widget.closebutton(c),
							margins = { top = dpi(6), bottom = dpi(6), left = dpi(2), right = dpi(2) },
							widget = wibox.container.margin,
						},
						{
							awful.titlebar.widget.minimizebutton(c),
							margins = { top = dpi(6), bottom = dpi(6), left = dpi(2), right = dpi(2) },
							widget = wibox.container.margin,
						},
						{
							awful.titlebar.widget.maximizedbutton(c),
							margins = { top = dpi(6), bottom = dpi(6), left = dpi(2), right = dpi(2) },
							widget = wibox.container.margin,
						},
						layout = wibox.layout.fixed.horizontal,
					},
					top = dpi(2),
					bottom = dpi(2),
					left = dpi(8),
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
							icon_size = dpi(16),
							icon_margin = dpi(6),
							layout_spacing = dpi(0),
							bg_color_focus = beautiful.color0,
							bg_color = beautiful.lighter_black,
							icon_shape = gears.shape.rectangle,
						}),
						bg = beautiful.darker_black,
						shape = gears.shape.rounded_rect,
						widget = wibox.container.background,
					},
					top = dpi(6),
					bottom = dpi(6),
					right = dpi(12),
					widget = wibox.container.margin,
				},
			},
			bg = beautiful.titlebar_bg,
			shape = helpers.ui.prrect(beautiful.border_radius, true, true, false, false),
			widget = wibox.container.background,
		})

	awful
		.titlebar(c, {
			position = "bottom",
			size = dpi(18),
			bg = beautiful.transparent,
		})
		:setup({
			bg = beautiful.titlebar_bg,
			shape = helpers.ui.prrect(beautiful.border_radius, false, false, true, true),
			widget = wibox.container.background,
		})
end)
