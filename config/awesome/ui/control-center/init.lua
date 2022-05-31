local gears = require("gears")
local awful = require("awful")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local wibox = require("wibox")

-- MacOS control_center
-------------------------
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
		bg = beautiful.widget_bg,
		shape = function(cr, width, height)
			gears.shape.rounded_rect(cr, width, height, dpi(16))
		end,
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
		bg = beautiful.widget_bg,
		shape = function(cr, width, height)
			gears.shape.rounded_rect(cr, width, height, dpi(16))
		end,
		widget = wibox.container.background,
	})
end

local vertical_separator = wibox.widget({
	orientation = "vertical",
	forced_height = dpi(1),
	forced_width = dpi(1),
	span_ratio = 0.55,
	widget = wibox.widget.separator,
})

local control_center_row_one = wibox.widget({
	layout = wibox.layout.align.horizontal,
	forced_height = dpi(48),
	nil,
	format_item(require("ui.widgets.user-profile.user-profile-control-center")),
	{
		format_item({
			layout = wibox.layout.fixed.horizontal,
			spacing = dpi(10),
			require("ui.widgets.control-center-switch")(),
			vertical_separator,
			require("ui.widgets.end-session")(),
		}),
		left = dpi(10),
		widget = wibox.container.margin,
	},
})

local main_control_row_two = wibox.widget({
	layout = wibox.layout.flex.horizontal,
	spacing = dpi(10),
	format_item_no_fix_height({
		layout = wibox.layout.fixed.vertical,
		spacing = dpi(5),
		nil,
		require("ui.widgets.airplane-mode"),
		require("ui.widgets.bluetooth"),
		require("ui.widgets.blue-light"),
		nil,
	}),
	{
		layout = wibox.layout.flex.vertical,
		spacing = dpi(10),
		format_item_no_fix_height({
			layout = wibox.layout.align.vertical,
			expand = "none",
			nil,
			require("ui.widgets.dnd"),
			nil,
		}),
		format_item_no_fix_height({
			layout = wibox.layout.align.vertical,
			expand = "none",
			nil,
			require("ui.widgets.floating-mode"),
			nil,
		}),
	},
})

local main_control_row_sliders = wibox.widget({
	layout = wibox.layout.fixed.vertical,
	spacing = dpi(10),
	format_item({
		require("ui.widgets.brightness-slider"),
		margins = dpi(10),
		widget = wibox.container.margin,
	}),
	format_item({
		require("ui.widgets.volume-slider"),
		margins = dpi(10),
		widget = wibox.container.margin,
	}),
})

local main_control_music_box = wibox.widget({
	layout = wibox.layout.fixed.vertical,
	format_item({
		require("ui.widgets.music-player.music-player-control-center"),
		margins = dpi(10),
		widget = wibox.container.margin,
	}),
})

local monitor_control_row_progressbars = wibox.widget({
	layout = wibox.layout.fixed.vertical,
	spacing = dpi(10),
	format_item(require("ui.widgets.system-meter.cpu-meter")),
	format_item(require("ui.widgets.system-meter.ram-meter")),
	format_item(require("ui.widgets.system-meter.temperature-meter")),
	format_item(require("ui.widgets.system-meter.harddrive-meter")),
})

awful.screen.connect_for_each_screen(function(s)
	local control_center_width = dpi(400)

	-- control_center and animations init
	control_center = awful.popup({
		type = "dock",
		screen = s,
		width = dpi(control_center_width),
		maximum_width = dpi(control_center_width),
		maximum_height = dpi(s.geometry.height - 38),
		bg = beautiful.transparent,
		ontop = true,
		visible = false,
		widget = {
			{
				{
					layout = wibox.layout.fixed.vertical,
					spacing = dpi(10),
					control_center_row_one,
					{
						layout = wibox.layout.stack,
						{
							id = "main_control",
							visible = true,
							layout = wibox.layout.fixed.vertical,
							spacing = dpi(10),
							main_control_row_two,
							main_control_row_sliders,
							main_control_music_box,
						},
						{
							id = "monitor_control",
							visible = false,
							layout = wibox.layout.fixed.vertical,
							spacing = dpi(10),
							monitor_control_row_progressbars,
						},
					},
				},
				margins = dpi(16),
				widget = wibox.container.margin,
			},
			id = "control_center",
			bg = beautiful.wibar_bg,
			shape = function(cr, w, h)
				gears.shape.rounded_rect(cr, w, h, dpi(16))
			end,
			widget = wibox.container.background,
		},
	})

	awful.placement.top_right(control_center, {
		honor_workarea = true,
		parent = s,
		margins = {
			top = dpi(60),
			right = dpi(15),
		},
	})

	-- Make toogle button
	local control_center_show = function()
		control_center.visible = true
		control_center:emit_signal("opened")
	end

	local control_center_hide = function()
		control_center.visible = false
		control_center:emit_signal("closed")
	end

	function control_center:toggle()
		if self.opened then
			control_center_hide()
		else
			control_center_show()
		end
		self.opened = not self.opened
	end
end)
