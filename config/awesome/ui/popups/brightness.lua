local gears = require("gears")
local awful = require("awful")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local wibox = require("wibox")
local icons = require("icons")

--- Brightness OSD
--- ~~~~~~~~~~~~~~
local icon = wibox.widget({
	{
		image = icons.brightness,
		resize = true,
		widget = wibox.widget.imagebox,
	},
	forced_height = dpi(150),
	top = dpi(12),
	bottom = dpi(12),
	widget = wibox.container.margin,
})

local osd_header = wibox.widget({
	text = "Brightness",
	font = beautiful.font_name .. "Bold 12",
	align = "left",
	valign = "center",
	widget = wibox.widget.textbox,
})

local osd_value = wibox.widget({
	text = "0%",
	font = beautiful.font_name .. "Bold 12",
	align = "center",
	valign = "center",
	widget = wibox.widget.textbox,
})

local slider_osd = wibox.widget({
	nil,
	{
		id = "bri_osd_slider",
		bar_shape = gears.shape.rounded_rect,
		bar_height = dpi(24),
		bar_color = "#ffffff20",
		bar_active_color = "#f2f2f2EE",
		handle_color = "#ffffff",
		handle_shape = gears.shape.circle,
		handle_width = dpi(24),
		handle_border_color = "#00000012",
		handle_border_width = dpi(1),
		maximum = 100,
		widget = wibox.widget.slider,
	},
	nil,
	expand = "none",
	layout = wibox.layout.align.vertical,
})

local bri_osd_slider = slider_osd.bri_osd_slider

bri_osd_slider:connect_signal("property::value", function()
	local brightness_level = bri_osd_slider:get_value()
	awful.spawn("brightnessctl set " .. brightness_level .. "%", false)

	-- Update textbox widget text
	osd_value.text = brightness_level .. "%"

	-- Update the brightness slider if values here change
	awesome.emit_signal("widget::brightness:update", brightness_level)

	if awful.screen.focused().show_bri_osd then
		awesome.emit_signal("module::brightness_osd:show", true)
	end
end)

bri_osd_slider:connect_signal("button::press", function()
	awful.screen.focused().show_bri_osd = true
end)

bri_osd_slider:connect_signal("mouse::enter", function()
	awful.screen.focused().show_bri_osd = true
end)

-- The emit will come from brightness slider
awesome.connect_signal("module::brightness_osd", function(brightness)
	bri_osd_slider:set_value(brightness)
end)

local brightness_osd_height = dpi(250)
local brightness_osd_width = dpi(250)

screen.connect_signal("request::desktop_decoration", function(s)
	local s = s or {}
	s.show_bri_osd = false

	s.brightness_osd_overlay = awful.popup({
		type = "notification",
		screen = s,
		height = brightness_osd_height,
		width = brightness_osd_width,
		maximum_height = brightness_osd_height,
		maximum_width = brightness_osd_width,
		bg = beautiful.transparent,
		ontop = true,
		visible = false,
		offset = dpi(5),
		preferred_anchors = "middle",
		preferred_positions = { "left", "right", "top", "bottom" },
		widget = {
			{
				{
					layout = wibox.layout.fixed.vertical,
					{
						{
							layout = wibox.layout.align.horizontal,
							expand = "none",
							nil,
							icon,
							nil,
						},
						{
							layout = wibox.layout.fixed.vertical,
							spacing = dpi(5),
							{
								layout = wibox.layout.align.horizontal,
								expand = "none",
								osd_header,
								nil,
								osd_value,
							},
							slider_osd,
						},
						spacing = dpi(10),
						layout = wibox.layout.fixed.vertical,
					},
				},
				left = dpi(24),
				right = dpi(24),
				widget = wibox.container.margin,
			},
			bg = beautiful.black,
			shape = gears.shape.rounded_rect,
			widget = wibox.container.background,
		},
	})

	-- Reset timer on mouse hover
	s.brightness_osd_overlay:connect_signal("mouse::enter", function()
		awful.screen.focused().show_bri_osd = true
		awesome.emit_signal("module::brightness_osd:rerun")
	end)
end)

local hide_osd = gears.timer({
	timeout = 2,
	autostart = true,
	callback = function()
		local focused = awful.screen.focused()
		focused.brightness_osd_overlay.visible = false
		focused.show_bri_osd = false
	end,
})

awesome.connect_signal("module::brightness_osd:rerun", function()
	if hide_osd.started then
		hide_osd:again()
	else
		hide_osd:start()
	end
end)

local placement_placer = function()
	local focused = awful.screen.focused()
	local brightness_osd = focused.brightness_osd_overlay
	awful.placement.next_to(brightness_osd, {
		preferred_positions = "top",
		preferred_anchors = "middle",
		geometry = focused.bottom_panel or s,
		offset = { x = 0, y = dpi(-20) },
	})
end

awesome.connect_signal("module::brightness_osd:show", function(bool)
	placement_placer()
	awful.screen.focused().brightness_osd_overlay.visible = bool
	if bool then
		awesome.emit_signal("module::brightness_osd:rerun")
		awesome.emit_signal("module::volume_osd:show", false)
	else
		if hide_osd.started then
			hide_osd:stop()
		end
	end
end)
