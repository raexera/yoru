-- Theme handling library
local beautiful = require("beautiful")

-- Widget library
local wibox = require("wibox")

-- Helpers
local helpers = require("helpers")

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

-- Widget

local dashboard = function(s)
	s.profile = require("ui.central-panel.dashboard.profile")
	s.music = require("ui.central-panel.dashboard.music")
	s.media = require("ui.central-panel.dashboard.mediakeys")
	s.time = require("ui.central-panel.dashboard.time")
	s.date = require("ui.central-panel.dashboard.date")
	s.todo = require("ui.central-panel.dashboard.todo")
	s.weather = require("ui.central-panel.dashboard.weather")
	s.stats = require("ui.central-panel.dashboard.stats")

	s.time_boxed = create_boxed_widget(centered_widget(s.time), dpi(260), dpi(90), beautiful.transparent)
	s.date_boxed = create_boxed_widget(s.date, dpi(120), dpi(50), beautiful.dashboard_box_bg)
	s.todo_boxed = create_boxed_widget(s.todo, dpi(120), dpi(120), beautiful.dashboard_box_bg)
	s.weather_boxed = create_boxed_widget(s.weather, dpi(120), dpi(120), beautiful.dashboard_box_bg)
	s.stats_boxed = create_boxed_widget(s.stats, dpi(120), dpi(190), beautiful.dashboard_box_bg)

	-- Dashboard setup
	return wibox.widget({
		nil,
		{
			s.time_boxed,
			{
				{
					s.profile,
					s.stats_boxed,
					layout = wibox.layout.fixed.vertical,
				},
				{
					s.date_boxed,
					s.todo_boxed,
					s.weather_boxed,
					layout = wibox.layout.fixed.vertical,
				},
				layout = wibox.layout.fixed.horizontal,
			},
			{
				s.music,
				s.media,
				layout = wibox.layout.fixed.horizontal,
			},
			s.notifs_boxed,
			layout = wibox.layout.fixed.vertical,
		},
		expand = "none",
		layout = wibox.layout.align.horizontal,
	})
end

return dashboard
