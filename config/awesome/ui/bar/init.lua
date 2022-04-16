-- Standard awesome library
local awful = require("awful")
local gears = require("gears")

-- Widget library
local wibox = require("wibox")

-- Theme handling library
local beautiful = require("beautiful")

-- Helpers
local helpers = require("helpers")

-- Aesthetic Wibar
---------------------

local wrap_widget = function(widget)
	return {
		widget,
		margins = dpi(6),
		widget = wibox.container.margin,
	}
end

awful.screen.connect_for_each_screen(function(s)
	-- Launcher
	-------------

	local awesome_icon = wibox.widget({
		{
			widget = wibox.widget.imagebox,
			image = beautiful.awesome_logo,
			resize = true,
		},
		margins = dpi(4),
		widget = wibox.container.margin,
	})

	helpers.add_hover_cursor(awesome_icon, "hand2")

	-- Battery
	-------------

	local charge_icon = wibox.widget({
		bg = beautiful.xcolor8,
		widget = wibox.container.background,
		visible = false,
	})

	local batt = wibox.widget({
		charge_icon,
		max_value = 100,
		value = 50,
		thickness = dpi(4),
		padding = dpi(2),
		start_angle = math.pi * 3 / 2,
		color = { beautiful.xcolor2 },
		bg = beautiful.xcolor2 .. "55",
		widget = wibox.container.arcchart,
	})

	local batt_last_value = 100
	local batt_low_value = 40
	local batt_critical_value = 20
	awesome.connect_signal("signal::battery", function(value)
		batt.value = value
		batt_last_value = value
		local color

		if charge_icon.visible then
			color = beautiful.xcolor6
		elseif value <= batt_critical_value then
			color = beautiful.xcolor1
		elseif value <= batt_low_value then
			color = beautiful.xcolor3
		else
			color = beautiful.xcolor2
		end

		batt.colors = { color }
		batt.bg = color .. "44"
	end)

	awesome.connect_signal("signal::charger", function(state)
		local color
		if state then
			charge_icon.visible = true
			color = beautiful.xcolor6
		elseif batt_last_value <= batt_critical_value then
			charge_icon.visible = false
			color = beautiful.xcolor1
		elseif batt_last_value <= batt_low_value then
			charge_icon.visible = false
			color = beautiful.xcolor3
		else
			charge_icon.visible = false
			color = beautiful.xcolor2
		end

		batt.colors = { color }
		batt.bg = color .. "44"
	end)

	-- Time
	----------

	local hour = wibox.widget({
		font = beautiful.font_name .. "bold 14",
		format = "%H",
		align = "center",
		valign = "center",
		widget = wibox.widget.textclock,
	})

	local min = wibox.widget({
		font = beautiful.font_name .. "bold 14",
		format = "%M",
		align = "center",
		valign = "center",
		widget = wibox.widget.textclock,
	})

	local clock = wibox.widget({
		{
			{
				hour,
				min,
				spacing = dpi(5),
				layout = wibox.layout.fixed.vertical,
			},
			top = dpi(5),
			bottom = dpi(5),
			widget = wibox.container.margin,
		},
		bg = beautiful.wibar_widget_bg,
		shape = helpers.rrect(beautiful.widget_radius),
		widget = wibox.container.background,
	})

	-- Stats
	-----------

	local stats = wibox.widget({
		{
			wrap_widget(batt),
			clock,
			spacing = dpi(5),
			layout = wibox.layout.fixed.vertical,
		},
		bg = beautiful.wibar_widget_alt_bg,
		shape = helpers.rrect(beautiful.widget_radius),
		widget = wibox.container.background,
	})

	stats:connect_signal("mouse::enter", function()
		stats.bg = beautiful.xcolor8
		tooltip_toggle()
	end)

	stats:connect_signal("mouse::leave", function()
		stats.bg = beautiful.wibar_widget_alt_bg
		tooltip_toggle()
	end)

	-- Notification center
	-------------------------

	local notif_center_button = wibox.widget({
		markup = helpers.colorize_text("󰂚", beautiful.accent),
		font = beautiful.icon_font_name .. "18",
		align = "center",
		valign = "center",
		widget = wibox.widget.textbox,
	})

	notif_center_button:connect_signal("mouse::enter", function()
		notif_center_button.markup = helpers.colorize_text(notif_center_button.text, beautiful.accent .. 55)
	end)

	notif_center_button:connect_signal("mouse::leave", function()
		notif_center_button.markup = helpers.colorize_text(notif_center_button.text, beautiful.accent)
	end)

	notif_center_button:buttons(gears.table.join(awful.button({}, 1, function()
		notif_center_toggle()
	end)))
	helpers.add_hover_cursor(notif_center_button, "hand2")

	-- Setup wibar
	-----------------

	-- Create a promptbox for each screen
	s.mypromptbox = awful.widget.prompt()

	-- Create the taglist widget
	s.mytaglist = require("ui.bar.pacman-taglist")(s)

	local taglist = wibox.widget({
		s.mytaglist,
		shape = beautiful.taglist_shape_focus,
		bg = beautiful.wibar_widget_alt_bg,
		widget = wibox.container.background,
	})

	-- Layoutbox
	---------------

	local layoutbox_buttons = gears.table.join(
		-- Left click
		awful.button({}, 1, function(c)
			awful.layout.inc(1)
		end),

		-- Right click
		awful.button({}, 3, function(c)
			awful.layout.inc(-1)
		end),

		-- Scrolling
		awful.button({}, 4, function()
			awful.layout.inc(-1)
		end),
		awful.button({}, 5, function()
			awful.layout.inc(1)
		end)
	)

	s.mylayoutbox = awful.widget.layoutbox(s)
	s.mylayoutbox:buttons(layoutbox_buttons)

	local layoutbox = wibox.widget({
		s.mylayoutbox,
		margins = { bottom = dpi(7), left = dpi(7), right = dpi(7) },
		widget = wibox.container.margin,
	})

	helpers.add_hover_cursor(layoutbox, "hand2")

	-- Systray
	-------------

	s.systray = wibox.widget.systray()
	s.systray.base_size = beautiful.systray_icon_size
	s.traybox = wibox({
		screen = s,
		width = dpi(100),
		height = dpi(150),
		bg = "#00000000",
		visible = false,
		ontop = true,
	})
	s.traybox:setup({
		{
			{
				nil,
				s.systray,
				direction = "west",
				widget = wibox.container.rotate,
			},
			margins = dpi(15),
			widget = wibox.container.margin,
		},
		bg = beautiful.wibar_bg,
		shape = helpers.rrect(beautiful.border_radius),
		widget = wibox.container.background,
	})
	awful.placement.bottom_right(s.traybox, { margins = beautiful.useless_gap * 5 })
	s.traybox:buttons(gears.table.join(awful.button({}, 2, function()
		s.traybox.visible = false
	end)))

	-- Create the wibar
	----------------------

	s.mywibar = awful.wibar({
		type = "dock",
		position = "left",
		screen = s,
		height = s.geometry.height - dpi(50),
		width = beautiful.wibar_width,
		bg = beautiful.transparent,
		ontop = true,
		visible = true,
	})

	awesome_icon:buttons(gears.table.join(awful.button({}, 1, function()
		dashboard_toggle()
	end)))

	-- Remove wibar on full screen
	local function remove_wibar(c)
		if c.fullscreen or c.maximized then
			c.screen.mywibar.visible = false
		else
			c.screen.mywibar.visible = true
		end
	end

	-- Remove wibar on full screen
	local function add_wibar(c)
		if c.fullscreen or c.maximized then
			c.screen.mywibar.visible = true
		end
	end

	client.connect_signal("property::fullscreen", remove_wibar)

	client.connect_signal("request::unmanage", add_wibar)

	-- Add widgets to wibar
	--------------------------

	s.mywibar:setup({
		{
			{
				layout = wibox.layout.align.vertical,
				expand = "none",
				{ -- top
					awesome_icon,
					taglist,
					spacing = dpi(10),
					layout = wibox.layout.fixed.vertical,
				},
				-- middle
				nil,
				{ -- bottom
					stats,
					notif_center_button,
					layoutbox,
					spacing = dpi(10),
					layout = wibox.layout.fixed.vertical,
				},
			},
			margins = dpi(8),
			widget = wibox.container.margin,
		},
		bg = beautiful.wibar_bg,
		shape = helpers.rrect(beautiful.border_radius),
		widget = wibox.container.background,
	})

	-- Wibar position
	awful.placement.left(s.mywibar, { margins = beautiful.useless_gap * 5 })
end)

-- Systray toggle
function systray_toggle()
	local s = awful.screen.focused()
	s.traybox.visible = not s.traybox.visible
end
