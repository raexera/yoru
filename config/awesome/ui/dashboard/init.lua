-- Standard awesome library
local gears = require("gears")
local awful = require("awful")

-- Theme handling library
local beautiful = require("beautiful")

-- Widget library
local wibox = require("wibox")

-- rubato
local rubato = require("module.rubato")

-- Helpers
local helpers = require("helpers")

-- Helpers
local function centered_widget(widget)
	local w = wibox.widget({
		nil,
		{
			nil,
			widget,
			expand = "none",
			layout = wibox.layout.align.vertical,
		},
		expand = "none",
		layout = wibox.layout.align.horizontal,
	})

	return w
end

local function create_boxed_widget(widget_to_be_boxed, width, height, bg_color)
	local box_container = wibox.container.background()
	box_container.bg = bg_color
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
				top = dpi(9),
				bottom = dpi(9),
				left = dpi(10),
				right = dpi(10),
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

-- Aesthetic Dashboard
-------------------------
-- Dashboard and animations init
dashboard = wibox({
	type = "dock",
	screen = screen.primary,
	bg = beautiful.transparent,
	height = screen.primary.geometry.height,
	width = dpi(300),
	ontop = true,
	visible = false,
})

awful.placement.maximize_vertically(dashboard, { honor_workarea = true, margins = beautiful.useless_gap * 5 })

local slide = rubato.timed({
	pos = dpi(-300),
	rate = 60,
	intro = 0.2,
	duration = 0.6,
	easing = rubato.quadratic,
	awestore_compat = true,
	subscribed = function(pos)
		dashboard.x = pos
	end,
})

local slide_strut = rubato.timed({
	pos = dpi(0),
	rate = 60,
	intro = 0.2,
	duration = 0.6,
	easing = rubato.quadratic,
	awestore_compat = true,
	subscribed = function(width)
		dashboard:struts({ left = width, right = 0, top = 0, bottom = 0 })
	end,
})

local dashboard_status = false

slide.ended:subscribe(function()
	if dashboard_status then
		dashboard.visible = false
	end
end)

dashboard_show = function()
	dashboard.visible = true
	slide:set(100)
	slide_strut:set(375)
	dashboard_status = false
end

dashboard_hide = function()
	slide:set(-375)
	slide_strut:set(0)
	dashboard_status = true
end

dashboard_toggle = function()
	if dashboard.visible then
		dashboard_hide()
	else
		dashboard_show()
	end
end

-- Widget
local profile = require("ui.dashboard.profile")
local music = require("ui.dashboard.music")
local media = require("ui.dashboard.mediakeys")
local time = require("ui.dashboard.time")
local date = require("ui.dashboard.date")
local todo = require("ui.dashboard.todo")
local weather = require("ui.dashboard.weather")
local stats = require("ui.dashboard.stats")
local notifs = require("ui.dashboard.notifs")

local time_boxed = create_boxed_widget(centered_widget(time), dpi(260), dpi(95), beautiful.transparent)
local date_boxed = create_boxed_widget(date, dpi(120), dpi(50), beautiful.dashboard_box_bg)
local todo_boxed = create_boxed_widget(todo, dpi(120), dpi(120), beautiful.dashboard_box_bg)
local weather_boxed = create_boxed_widget(weather, dpi(120), dpi(120), beautiful.dashboard_box_bg)
local stats_boxed = create_boxed_widget(stats, dpi(120), dpi(190), beautiful.dashboard_box_bg)
local notifs_boxed = create_boxed_widget(notifs, dpi(260), dashboard.height - dpi(470), beautiful.dashboard_box_bg)

-- Dashboard setup
dashboard:setup({
	{
		{
			nil,
			{
				{
					{
						profile,
						stats_boxed,
						layout = wibox.layout.fixed.vertical,
					},
					{
						date_boxed,
						todo_boxed,
						weather_boxed,
						layout = wibox.layout.fixed.vertical,
					},
					layout = wibox.layout.fixed.horizontal,
				},
				{
					music,
					media,
					layout = wibox.layout.fixed.horizontal,
				},
				notifs_boxed,
				layout = wibox.layout.fixed.vertical,
			},
			expand = "none",
			layout = wibox.layout.align.horizontal,
		},
		margins = dpi(10),
		widget = wibox.container.margin,
	},
	bg = beautiful.dashboard_bg,
	shape = helpers.rrect(beautiful.dashboard_radius),
	widget = wibox.container.background,
})
