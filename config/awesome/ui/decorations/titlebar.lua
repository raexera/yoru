local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local helpers = require("helpers")

local function create_title_button(c, color_focus, color_unfocus, shp)
	local ico = wibox.widget({
		markup = "",
		widget = wibox.widget.textbox,
	})
	local tb = wibox.widget({
		ico,
		forced_width = dpi(16),
		forced_height = dpi(16),
		bg = color_focus .. 80,
		shape = shp,
		widget = wibox.container.background,
	})

	local function update()
		if client.focus == c then
			tb.bg = color_focus
		else
			tb.bg = color_unfocus
		end
	end
	update()

	c:connect_signal("focus", update)
	c:connect_signal("unfocus", update)

	tb:connect_signal("mouse::enter", function()
		local clr = client.focus ~= c and color_focus or color_focus .. 55
		tb.bg = clr
	end)
	tb:connect_signal("mouse::leave", function()
		local clr = client.focus == c and color_focus or color_unfocus
		tb.bg = clr
	end)

	tb.visible = true
	return tb
end

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
	-- buttons for the titlebar
	local buttons = gears.table.join(
		awful.button({}, 1, function()
			c:emit_signal("request::activate", "titlebar", { raise = true })
			awful.mouse.client.move(c)
		end),
		awful.button({}, 3, function()
			c:emit_signal("request::activate", "titlebar", { raise = true })
			awful.mouse.client.resize(c)
		end)
	)

	local close = create_title_button(c, beautiful.xcolor1, beautiful.xcolor8 .. 55, gears.shape.circle)
	close:connect_signal("button::press", function()
		c:kill()
	end)

	local minimize = create_title_button(c, beautiful.xcolor3, beautiful.xcolor8 .. 55, gears.shape.circle)
	minimize:connect_signal("button::press", function()
		c.minimized = true
	end)

	local maximize = create_title_button(c, beautiful.xcolor2, beautiful.xcolor8 .. 55, gears.shape.circle)
	maximize:connect_signal("button::press", function()
		helpers.maximize(c)
	end)

	-- Titlebars setup
	--------------------

	awful.titlebar(c, { position = "top", size = dpi(45), bg = beautiful.transparent }):setup({
		{
			layout = wibox.layout.align.horizontal,
			{
				{
					close,
					minimize,
					maximize,
					layout = wibox.layout.fixed.horizontal,
					spacing = dpi(10),
				},
				left = dpi(15),
				widget = wibox.container.margin,
			},
			{
				{
					{ -- Title
						align = "center",
						widget = awful.titlebar.widget.titlewidget(c),
					},
					layout = wibox.layout.flex.horizontal,
					spacing = dpi(10),
				},
				left = dpi(10),
				right = dpi(10),
				widget = wibox.container.margin,
				buttons = buttons,
			},
			{
				{
					layout = wibox.layout.fixed.horizontal,
					spacing = dpi(10),
				},
				left = dpi(10),
				right = dpi(10),
				widget = wibox.container.margin,
				buttons = buttons,
			},
		},
		bg = beautiful.titlebar_bg,
		shape = helpers.prrect(beautiful.border_radius, true, true, false, false),
		widget = wibox.container.background,
	})

	awful.titlebar(c, {
		position = "bottom",
		size = dpi(24),
		bg = beautiful.transparent,
	}):setup({
		bg = beautiful.titlebar_bg,
		shape = helpers.prrect(beautiful.border_radius, false, false, true, true),
		widget = wibox.container.background,
	})
end)
