local gears = require("gears")
local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")
local helpers = require("helpers")

local function create_boxed_widget(widget_to_be_boxed, width, height)
	local box_container = wibox.container.background()
	box_container.bg = beautiful.tooltip_widget_bg
	box_container.forced_height = height
	box_container.forced_width = width
	box_container.shape = helpers.rrect(dpi(5))

	local boxed_widget = wibox.widget({
		-- Add margins
		{
			-- Add background color
			{
				-- The actual widget goes here
				widget_to_be_boxed,
				margins = dpi(10),
				widget = wibox.container.margin,
			},
			widget = box_container,
		},
		margins = dpi(10),
		color = "#FF000000",
		widget = wibox.container.margin,
	})

	return boxed_widget
end

-- Tooltip widgets
---------------------

awful.screen.connect_for_each_screen(function(s)
	-- Date
	local date_day = wibox.widget({
		font = beautiful.font_name .. "Bold 12",
		format = helpers.colorize_text("%A", beautiful.accent),
		align = "center",
		valign = "center",
		widget = wibox.widget.textclock,
	})

	local date_month = wibox.widget({
		font = beautiful.font_name .. "Medium 14",
		format = "%d %B %Y",
		align = "center",
		valign = "center",
		widget = wibox.widget.textclock,
	})

	local date = wibox.widget({
		date_day,
		nil,
		date_month,
		layout = wibox.layout.align.vertical,
	})

	-- Analog clock
	local analog_clock = require("ui.widgets.analog-clock")

	-- Battery
	local cute_battery_face = require("ui.widgets.cute-battery-face")
	local cute_battery_face_container = wibox.widget({
		cute_battery_face,
		margins = dpi(10),
		widget = wibox.container.margin,
	})

	-- Wifi
	local wifi_status_icon = wibox.widget({
		markup = "",
		font = beautiful.icon_font_name .. "Round 18",
		valign = "center",
		align = "center",
		widget = wibox.widget.textbox,
	})

	local wifi = wibox.widget({
		wifi_status_icon,
		forced_width = dpi(40),
		forced_height = dpi(40),
		bg = beautiful.tooltip_bg,
		shape = gears.shape.circle,
		widget = wibox.container.background,
	})

	local wifi_status = false

	awesome.connect_signal("signal::network", function(status, ssid)
		wifi_status = status
		awesome.emit_signal("widget::network")
	end)

	awesome.connect_signal("widget::network", function()
		local w, fill_color
		if wifi_status == true then
			w = ""
			fill_color = beautiful.xcolor2
		else
			w = ""
			fill_color = beautiful.xcolor1
		end

		wifi.shape_border_color = fill_color
		wifi_status_icon.markup = helpers.colorize_text(w, fill_color)
	end)

	-- UpTime
	local uptime_label = wibox.widget({
		font = beautiful.font_name .. "Bold 10",
		markup = helpers.colorize_text("Uptime", beautiful.accent),
		valign = "center",
		widget = wibox.widget.textbox,
	})

	local uptime_text = wibox.widget({
		font = beautiful.font_name .. "Medium 10",
		markup = helpers.colorize_text("-", beautiful.accent),
		valign = "center",
		widget = wibox.widget.textbox,
	})

	awesome.connect_signal("signal::uptime", function(uptime_value)
		uptime_text.markup = uptime_value
	end)

	local vertical_separator = wibox.widget({
		orientation = "vertical",
		color = beautiful.accent,
		thickness = dpi(3),
		forced_height = dpi(3),
		forced_width = dpi(3),
		span_ratio = 1,
		widget = wibox.widget.separator,
	})

	local uptime_container = wibox.widget({
		{
			vertical_separator,
			{
				uptime_label,
				nil,
				uptime_text,
				spacing = dpi(5),
				layout = wibox.layout.fixed.vertical,
			},
			spacing = dpi(10),
			layout = wibox.layout.fixed.horizontal,
		},
		nil,
		wifi,
		expand = "none",
		layout = wibox.layout.align.horizontal,
	})

	-- Widget
	local uptime_boxed = create_boxed_widget(uptime_container, dpi(190), dpi(60))
	local analog_clock_boxed = create_boxed_widget(analog_clock, dpi(110), dpi(110))

	-- Tooltip setup
	s.stats_tooltip = wibox({
		type = "dock",
		screen = s,
		height = beautiful.tooltip_height,
		width = beautiful.tooltip_width,
		bg = beautiful.transparent,
		ontop = true,
		visible = false,
	})

	awful.placement.top_right(s.stats_tooltip, {
		margins = {
			top = beautiful.useless_gap * 16,
			bottom = beautiful.useless_gap * 6,
			left = beautiful.useless_gap * 6,
			right = beautiful.useless_gap * 6,
		},
	})

	s.stats_tooltip:setup({
		{
			{
				{
					{
						date,
						{
							analog_clock_boxed,
							nil,
							cute_battery_face_container,
							expand = "none",
							layout = wibox.layout.fixed.horizontal,
						},
						layout = wibox.layout.fixed.vertical,
					},
					layout = wibox.layout.fixed.horizontal,
				},
				{
					uptime_boxed,
					layout = wibox.layout.fixed.horizontal,
				},
				layout = wibox.layout.fixed.vertical,
			},
			margins = dpi(10),
			widget = wibox.container.margin,
		},
		shape = helpers.rrect(beautiful.tooltip_border_radius),
		bg = beautiful.tooltip_bg,
		widget = wibox.container.background,
	})
end)

function tooltip_toggle()
	local s = awful.screen.focused()
	s.stats_tooltip.visible = not s.stats_tooltip.visible
end
