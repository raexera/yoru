local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local helpers = require("helpers")
local clickable_container = require("ui.widgets.clickable-container")

awful.screen.connect_for_each_screen(function(s)
	-- Clock
	local clock = wibox.widget({
		{
			{
				font = beautiful.font_name .. "Bold 12",
				format = "%I:%M %p",
				align = "center",
				valign = "center",
				widget = wibox.widget.textclock,
			},
			margins = dpi(8),
			widget = wibox.container.margin,
		},
		widget = clickable_container,
	})

	clock:buttons(gears.table.join(awful.button({}, 1, nil, function()
		info_center:toggle()
	end)))

	-- Layoutbox
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
		{
			s.mylayoutbox,
			margins = dpi(9),
			widget = wibox.container.margin,
		},
		widget = clickable_container,
	})

	-- Systray
	s.systray = wibox.widget({
		visible = false,
		base_size = dpi(20),
		horizontal = true,
		screen = "primary",
		widget = wibox.widget.systray,
	})

	-- Widgets
	s.mytaglist = require("ui.widgets.taglist")(s)
	s.github_activity = require("ui.widgets.github-activity")
	s.tray_toggler = require("ui.widgets.tray-toggle")
	s.battery = require("ui.widgets.battery")()
	s.network = require("ui.widgets.network")()
	s.dashboard_toggle = require("ui.widgets.dashboard-toggle")()
	s.control_center_toggle = require("ui.widgets.hamburger")(awful.button({}, 1, function()
		control_center:toggle()
	end))

	local control_center_toggle = wibox.widget({
		{
			s.control_center_toggle,
			margins = { top = dpi(2), bottom = dpi(2), left = dpi(3), right = dpi(3) },
			widget = wibox.container.margin,
		},
		widget = clickable_container,
	})

	-- Create the wibar
	----------------------
	s.mywibar = awful.wibar({
		type = "dock",
		ontop = true,
		stretch = false,
		visible = true,
		height = dpi(40),
		width = s.geometry.width - dpi(30),
		screen = s,
		bg = beautiful.transparent,
	})

	awful.placement.top(s.mywibar, { margins = beautiful.useless_gap * 2 })

	s.mywibar:struts({
		top = dpi(45),
	})

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

	-- Hide bar when a splash widget is visible
	awesome.connect_signal("widgets::splash::visibility", function(vis)
		screen.primary.mywibar.visible = not vis
	end)

	client.connect_signal("property::fullscreen", remove_wibar)

	client.connect_signal("request::unmanage", add_wibar)

	-- Add widgets to the wibox
	s.mywibar:setup({
		{
			{
				layout = wibox.layout.align.horizontal,
				expand = "none",
				{
					s.dashboard_toggle,
					s.mytaglist,
					spacing = dpi(5),
					layout = wibox.layout.fixed.horizontal,
				},
				clock,
				{
					{
						s.systray,
						margins = dpi(10),
						widget = wibox.container.margin,
					},
					s.tray_toggler,
					s.battery,
					s.network,
					s.github_activity,
					control_center_toggle,
					layoutbox,
					layout = wibox.layout.fixed.horizontal,
				},
			},
			left = dpi(10),
			right = dpi(10),
			widget = wibox.container.margin,
		},
		bg = beautiful.wibar_bg,
		shape = helpers.rrect(beautiful.border_radius),
		widget = wibox.container.background,
	})
end)
