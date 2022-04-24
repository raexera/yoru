local gears = require("gears")
local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")
local helpers = require("helpers")
local icons = require("theme.assets.icons")

local format_item = function(widget)
	return wibox.widget({
		{
			{
				layout = wibox.layout.align.vertical,
				expand = "none",
				nil,
				widget,
				nil,
			},
			margins = dpi(10),
			widget = wibox.container.margin,
		},
		forced_height = dpi(88),
		bg = beautiful.control_center_widget_bg,
		shape = helpers.rrect(beautiful.control_center_widget_radius),
		widget = wibox.container.background,
	})
end

local format_item_no_fix_height = function(widget)
	return wibox.widget({
		{
			{
				layout = wibox.layout.align.vertical,
				expand = "none",
				nil,
				widget,
				nil,
			},
			margins = dpi(10),
			widget = wibox.container.margin,
		},
		bg = beautiful.control_center_widget_bg,
		shape = helpers.rrect(beautiful.control_center_widget_radius),
		widget = wibox.container.background,
	})
end

local function format_progress_bar(bar, icon)
	local widget_icon = wibox.widget({
		image = gears.color.recolor_image(icon, beautiful.xforeground),
		widget = wibox.widget.imagebox,
		resize = true,
	})
	local w = wibox.widget({
		{
			{
				{
					bar,
					reflection = { horizontal = true },
					widget = wibox.container.mirror,
				},
				{
					nil,
					{
						nil,
						{
							widget_icon,
							margins = dpi(20),
							widget = wibox.container.margin,
						},
						expand = "none",
						layout = wibox.layout.align.vertical,
					},
					expand = "none",
					layout = wibox.layout.align.horizontal,
				},
				layout = wibox.layout.stack,
			},
			margins = dpi(10),
			widget = wibox.container.margin,
		},
		layout = wibox.layout.fixed.vertical,
	})

	return w
end

local function create_boxed_widget(widget_to_be_boxed, width, height, radius, bg_color)
	local box_container = wibox.container.background()
	box_container.bg = bg_color
	box_container.forced_height = height
	box_container.forced_width = width
	box_container.shape = helpers.rrect(radius)

	local boxed_widget = wibox.widget({
		{
			nil,
			{
				widget_to_be_boxed,
				layout = wibox.layout.align.vertical,
				expand = "none",
			},
			layout = wibox.layout.align.horizontal,
		},
		widget = box_container,
	})
	return boxed_widget
end

local function create_arc_container(markup, widget)
	local text = wibox.widget({
		font = beautiful.font_name .. "Bold 10",
		markup = helpers.colorize_text(markup, beautiful.dashboard_box_fg),
		valign = "center",
		widget = wibox.widget.textbox,
	})

	local arc_container = wibox.widget({
		{
			{
				text,
				nil,
				expand = "none",
				layout = wibox.layout.align.horizontal,
			},
			widget,
			layout = wibox.layout.fixed.vertical,
		},
		margins = dpi(10),
		widget = wibox.container.margin,
	})

	return arc_container
end

local function create_buttons(icon, color)
	local button = wibox.widget({
		id = "icon",
		markup = helpers.colorize_text(icon, color),
		font = beautiful.icon_font_name .. "16",
		align = "center",
		valign = "center",
		widget = wibox.widget.textbox,
	})

	local button_container = wibox.widget({
		{
			{
				button,
				margins = dpi(15),
				forced_height = dpi(48),
				forced_width = dpi(48),
				widget = wibox.container.margin,
			},
			widget = require("ui.widgets.clickable-container"),
		},
		bg = beautiful.control_center_button_bg,
		shape = gears.shape.circle,
		widget = wibox.container.background,
	})

	return button_container
end

-- widgets
-------------

-- color indicator
local off = beautiful.control_center_button_bg
local on = beautiful.accent

-- wifi button
local wifi = create_buttons("󰤨", beautiful.xforeground)
local wifi_status = false

awesome.connect_signal("signal::network", function(status, ssid)
	wifi_status = status
	awesome.emit_signal("widget::network")
end)

awesome.connect_signal("widget::network", function()
	local w, fill_color
	if wifi_status == true then
		fill_color = on
		wifi:buttons({
			awful.button({}, 1, function()
				awful.spawn("nmcli radio wifi off")
			end),
		})
	else
		fill_color = off
		wifi:buttons({
			awful.button({}, 1, function()
				awful.spawn("nmcli radio wifi on")
			end),
		})
	end
	wifi.bg = fill_color
end)

-- bluetooth button
local bluetooth = create_buttons("󰂯", beautiful.xforeground)
local bluetooth_status = true

bluetooth:buttons({
	awful.button({}, 1, function()
		bluetooth_status = not bluetooth_status
		if bluetooth_status then
			bluetooth.bg = off
			awful.spawn("bluetoothctl power off")
		else
			bluetooth.bg = on
			awful.spawn("bluetoothctl power on")
		end
	end),
})

-- screenrec button
local mic = require("ui.widgets.microphone")

-- screenrec button
local screenrec = require("ui.widgets.screenrec")()

-- screenshot button
local screenshot = create_buttons("󰆞", beautiful.xforeground)
screenshot:buttons({
	awful.button({}, 1, function()
		central_panel:toggle()
		awful.spawn.with_shell("screensht area")
	end),
})

-- cpu arc
local cpu_bar = require("ui.widgets.arc.cpu_arc")
local cpu = format_progress_bar(cpu_bar, icons.cpu)
local cpu_details = create_arc_container("Cpu", cpu)
local cpu_box = create_boxed_widget(
	cpu_details,
	dpi(50),
	dpi(150),
	beautiful.control_center_widget_radius,
	beautiful.control_center_widget_bg
)

-- ram arc
local ram_bar = require("ui.widgets.arc.ram_arc")
local ram = format_progress_bar(ram_bar, icons.ram)
local ram_details = create_arc_container("Ram", ram)
local ram_box = create_boxed_widget(
	ram_details,
	dpi(50),
	dpi(150),
	beautiful.control_center_widget_radius,
	beautiful.control_center_widget_bg
)

-- temp arc
local temp_bar = require("ui.widgets.arc.temp_arc")
local temp = format_progress_bar(temp_bar, icons.temp)
local temp_details = create_arc_container("Temp", temp)
local temp_box = create_boxed_widget(
	temp_details,
	dpi(50),
	dpi(150),
	beautiful.control_center_widget_radius,
	beautiful.control_center_widget_bg
)

-- disk arc
local disk_bar = require("ui.widgets.arc.disk_arc")
local disk = format_progress_bar(disk_bar, icons.disk)
local disk_details = create_arc_container("Disk", disk)
local disk_box = create_boxed_widget(
	disk_details,
	dpi(50),
	dpi(150),
	beautiful.control_center_widget_radius,
	beautiful.control_center_widget_bg
)

-- Control Center
--------------------
local control_center = function(s)
	s.control_center_row_one = wibox.widget({
		layout = wibox.layout.align.horizontal,
		forced_height = dpi(60),
		nil,
		format_item(require("ui.widgets.user-profile")()),
		{
			format_item({
				layout = wibox.layout.fixed.horizontal,
				require("ui.widgets.end-session")(),
			}),
			left = dpi(20),
			widget = wibox.container.margin,
		},
	})

	s.control_center_row_two = wibox.widget({
		{
			{
				wifi,
				bluetooth,
				mic,
				screenrec,
				screenshot,
				spacing = dpi(6),
				layout = wibox.layout.flex.horizontal,
			},
			margins = dpi(12),
			widget = wibox.container.margin,
		},
		shape = helpers.rrect(beautiful.control_center_widget_radius),
		bg = beautiful.control_center_widget_bg,
		widget = wibox.container.background,
	})

	s.control_center_row_five = wibox.widget({
		layout = wibox.layout.flex.horizontal,
		spacing = dpi(20),
		ram_box,
		cpu_box,
		temp_box,
		disk_box,
	})

	s.control_center_row_three = wibox.widget({
		layout = wibox.layout.flex.horizontal,
		spacing = dpi(20),
		format_item_no_fix_height({
			layout = wibox.layout.fixed.vertical,
			spacing = dpi(5),
			nil,
			require("ui.widgets.dnd"),
			require("ui.widgets.blue-light"),
			require("ui.widgets.airplane-mode"),
			nil,
		}),
		{
			layout = wibox.layout.flex.vertical,
			spacing = dpi(20),
			format_item_no_fix_height({
				layout = wibox.layout.align.vertical,
				expand = "none",
				nil,
				require("ui.widgets.floating-mode"),
				nil,
			}),
			{
				layout = wibox.layout.flex.horizontal,
				spacing = dpi(20),
				require("ui.widgets.theme-switcher").day,
				nil,
				require("ui.widgets.theme-switcher").night,
			},
		},
	})

	s.control_center_row_four = require("ui.widgets.vol-bri-slider")

	return wibox.widget({
		{
			s.control_center_row_one,
			s.control_center_row_two,
			s.control_center_row_three,
			s.control_center_row_four,
			s.control_center_row_five,
			spacing = dpi(20),
			layout = wibox.layout.fixed.vertical,
		},
		margins = dpi(10),
		widget = wibox.container.margin,
	})
end

return control_center
