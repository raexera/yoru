-- Standard awesome library
local awful = require("awful")
local gears = require("gears")

-- Widget library
local wibox = require("wibox")

-- Theme handling library
local beautiful = require("beautiful")

-- Rubato
local rubato = require("module.rubato")

-- Helpers
local helpers = require("helpers")
local dpi = beautiful.xresources.apply_dpi

local notif_header = wibox.widget({
	text = "Notification Center",
	font = beautiful.font_name .. "Bold 16",
	align = "left",
	valign = "center",
	widget = wibox.widget.textbox,
})

local clear_all = require("ui.notifs.notif-center.clear-all")
local notifbox_layout = require("ui.notifs.notif-center.build-notifbox").notifbox_layout

local notifs = wibox.widget({
	expand = "none",
	layout = wibox.layout.fixed.vertical,
	spacing = dpi(10),
	{
		expand = "none",
		layout = wibox.layout.align.horizontal,
		notif_header,
		nil,
		{
			layout = wibox.layout.fixed.horizontal,
			spacing = dpi(5),
			clear_all,
		},
	},
	notifbox_layout,
})

notif_center = wibox({
	type = "dock",
	screen = screen.primary,
	height = screen.primary.geometry.height,
	width = dpi(300),
	bg = beautiful.transparent,
	ontop = true,
	visible = false,
})

awful.placement.maximize_vertically(notif_center, { honor_workarea = true, margins = beautiful.useless_gap * 5 })

-- Rubato
local slide = rubato.timed({
	pos = dpi(-300),
	rate = 60,
	intro = 0.2,
	duration = 0.6,
	easing = rubato.quadratic,
	awestore_compat = true,
	subscribed = function(pos)
		notif_center.x = pos
	end,
})

local notif_center_status = false

slide.ended:subscribe(function()
	if notif_center_status then
		notif_center.visible = false
	end
end)

-- Make toogle button
local notif_center_show = function()
	notif_center.visible = true
	slide:set(dpi(100))
	notif_center_status = false
end

local notif_center_hide = function()
	slide:set(dpi(-300))
	notif_center_status = true
end

notif_center_toggle = function()
	if notif_center.visible then
		notif_center_hide()
	else
		notif_center_show()
	end
end

notif_center:setup({
	{
		notifs,
		margins = dpi(15),
		widget = wibox.container.margin,
	},
	bg = beautiful.xbackground,
	shape = helpers.rrect(beautiful.notif_center_radius),
	widget = wibox.container.background,
})
