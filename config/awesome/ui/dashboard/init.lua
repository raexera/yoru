local gears = require("gears")
local awful = require("awful")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local wibox = require("wibox")
local rubato = require("module.rubato")
local helpers = require("helpers")

-- Aesthetic Dashboard
-------------------------

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

-- Time
local time_hour = wibox.widget({
	font = beautiful.font_name .. "bold 48",
	format = "%H",
	align = "center",
	valign = "center",
	widget = wibox.widget.textclock,
})

local time_min = wibox.widget({
	font = beautiful.font_name .. "bold 48",
	format = "%M",
	align = "center",
	valign = "center",
	widget = wibox.widget.textclock,
})

local time = wibox.widget({
	time_hour,
	time_min,
	spacing = dpi(25),
	widget = wibox.layout.fixed.horizontal,
})

-- Date
local date_day = wibox.widget({
	font = beautiful.font_name .. "Medium 8",
	format = helpers.colorize_text("%A", beautiful.xforeground .. "c6"),
	valign = "center",
	widget = wibox.widget.textclock,
})

local date_month = wibox.widget({
	font = beautiful.font_name .. "Medium 11",
	format = "%d %B",
	valign = "center",
	widget = wibox.widget.textclock,
})

local date = wibox.widget({
	date_day,
	nil,
	date_month,
	expand = "none",
	widget = wibox.layout.align.vertical,
})

-- pfp
local profile_pic_img = wibox.widget({
	image = beautiful.pfp,
	halign = "center",
	valign = "center",
	widget = wibox.widget.imagebox,
})

local profile_pic_container = wibox.widget({
	shape = helpers.rrect(5),
	forced_height = dpi(120),
	forced_width = dpi(120),
	widget = wibox.container.background,
})

local profile = wibox.widget({
	{
		profile_pic_img,
		widget = profile_pic_container,
	},
	margins = dpi(10),
	widget = wibox.container.margin,
})

awful.screen.connect_for_each_screen(function(s)
	local dashboard_width = dpi(600)
	local dashboard_height = dpi(610)

	-- widgets
	s.music_player = require("ui.widgets.music-player.music-player-dashboard")
	s.todo = require("ui.widgets.todo")
	s.weather = require("ui.widgets.weather.weather-dashboard")
	s.stats = require("ui.widgets.stats")

	s.time_boxed = create_boxed_widget(centered_widget(time), dpi(260), dpi(90), beautiful.transparent)
	s.date_boxed = create_boxed_widget(date, dpi(120), dpi(50), beautiful.widget_bg)
	s.todo_boxed = create_boxed_widget(s.todo, dpi(120), dpi(120), beautiful.widget_bg)
	s.weather_boxed = create_boxed_widget(s.weather, dpi(120), dpi(120), beautiful.widget_bg)
	s.stats_boxed = create_boxed_widget(s.stats, dpi(120), dpi(190), beautiful.widget_bg)

	local dashboard_item = wibox.widget({
		nil,
		{
			s.time_boxed,
			{
				{
					profile,
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
			s.music_player,
			layout = wibox.layout.fixed.vertical,
		},
		expand = "none",
		layout = wibox.layout.align.horizontal,
	})

	-- Dashboard and animations init
	dashboard = awful.popup({
		type = "dock",
		screen = s,
		maximum_height = dashboard_height,
		minimum_width = dashboard_width,
		maximum_width = dashboard_width,
		x = s.geometry.x + s.geometry.width / 2 - dpi(300), --half of the width
		bg = beautiful.transparent,
		ontop = true,
		visible = false,
		widget = {
			{
				layout = wibox.layout.flex.horizontal,
				spacing = dpi(10),
				spacing_widget = wibox.widget.separator({
					span_ratio = 0.80,
					color = beautiful.lighter_bg,
				}),
				dashboard_item,
				require("ui.widgets.notif-center")(s),
			},
			bg = beautiful.dashboard_bg,
			shape = helpers.rrect(beautiful.border_radius),
			widget = wibox.container.background,
		},
	})

	local anim_length = 0.7
	-- Gears Timer so awestore_compat can go
	local slide_end = gears.timer({
		single_shot = true,
		timeout = anim_length + 0.1, --so the panel doesnt disappear in the last bit
		callback = function()
			dashboard.visible = not dashboard.opened
		end,
	})

	-- Rubato
	local slide = rubato.timed({
		pos = -dashboard.height,
		rate = 60,
		duration = anim_length,
		intro = anim_length / 2,
		easing = rubato.linear,
		subscribed = function(pos)
			dashboard.y = pos
		end,
	})

	-- Make toogle button
	local dashboard_show = function()
		dashboard.visible = true
		slide.target = dpi(60)
		dashboard:emit_signal("opened")
	end

	local dashboard_hide = function()
		slide_end:again()
		slide.target = -dashboard.height
		dashboard:emit_signal("closed")
	end

	function dashboard:toggle()
		self.opened = not self.opened
		if self.opened then
			dashboard_hide()
		else
			dashboard_show()
		end
	end
end)
