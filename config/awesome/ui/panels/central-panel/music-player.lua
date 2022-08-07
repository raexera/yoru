local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local wibox = require("wibox")
local helpers = require("helpers")
local widgets = require("ui.widgets")
local playerctl_daemon = require("signal.playerctl")

---- Music Player
---- ~~~~~~~~~~~~

local music_text = wibox.widget({
	font = beautiful.font_name .. "Medium 10",
	valign = "center",
	widget = wibox.widget.textbox,
})

local music_art = wibox.widget({
	image = beautiful.music,
	resize = true,
	widget = wibox.widget.imagebox,
})

local music_art_container = wibox.widget({
	music_art,
	forced_height = dpi(120),
	forced_width = dpi(120),
	widget = wibox.container.background,
})

local filter_color = {
	type = "linear",
	from = { 0, 0 },
	to = { 0, 120 },
	stops = { { 0, beautiful.widget_bg .. "cc" }, { 1, beautiful.widget_bg } },
}

local music_art_filter = wibox.widget({
	{
		bg = filter_color,
		forced_height = dpi(120),
		forced_width = dpi(120),
		widget = wibox.container.background,
	},
	direction = "east",
	widget = wibox.container.rotate,
})

local music_title = wibox.widget({
	font = beautiful.font_name .. "Regular 13",
	valign = "center",
	widget = wibox.widget.textbox,
})

local music_artist = wibox.widget({
	font = beautiful.font_name .. "Bold 16",
	valign = "center",
	widget = wibox.widget.textbox,
})

--- Volume Control
local function volume_control()
	local volume_bar = wibox.widget({
		max_value = 100,
		value = 100,
		shape = gears.shape.rounded_bar,
		bar_shape = gears.shape.rounded_bar,
		color = beautiful.accent,
		background_color = beautiful.grey,
		border_width = 0,
		widget = wibox.widget.progressbar,
	})

	-- Update bar
	local function set_slider_value(self, volume)
		volume_bar.value = volume * 100
	end

	playerctl_daemon:connect_signal("volume", set_slider_value)

	volume_bar:connect_signal("button::press", function()
		playerctl_daemon:disconnect_signal("volume", set_slider_value)
	end)

	volume_bar:connect_signal("button::release", function()
		playerctl_daemon:connect_signal("volume", set_slider_value)
	end)

	local volume = wibox.widget({
		volume_bar,
		direction = "east",
		widget = wibox.container.rotate,
	})

	volume:buttons(gears.table.join(
		-- Scroll - Increase or decrease volume
		awful.button({}, 4, function()
			awful.spawn.with_shell("playerctl volume 0.05+")
		end),
		awful.button({}, 5, function()
			awful.spawn.with_shell("playerctl volume 0.05-")
		end)
	))

	return volume
end

local function music()
	return wibox.widget({
		{
			{
				music_art_container,
				music_art_filter,
				layout = wibox.layout.stack,
			},
			{
				{
					{
						music_text,
						helpers.ui.vertical_pad(dpi(15)),
						{

							{
								widget = wibox.container.scroll.horizontal,
								step_function = wibox.container.scroll.step_functions.waiting_nonlinear_back_and_forth,
								fps = 60,
								speed = 75,
								music_artist,
							},
							{
								widget = wibox.container.scroll.horizontal,
								step_function = wibox.container.scroll.step_functions.waiting_nonlinear_back_and_forth,
								fps = 60,
								speed = 75,
								music_title,
							},
							forced_width = dpi(170),
							layout = wibox.layout.fixed.vertical,
						},
						layout = wibox.layout.fixed.vertical,
					},
					nil,
					{
						{
							widgets.playerctl.previous(20, beautiful.white, beautiful.transparent),
							widgets.playerctl.play(beautiful.accent, beautiful.transparent),
							widgets.playerctl.next(20, beautiful.white, beautiful.transparent),
							layout = wibox.layout.flex.horizontal,
						},
						forced_height = dpi(70),
						margins = dpi(10),
						widget = wibox.container.margin,
					},
					expand = "none",
					layout = wibox.layout.align.vertical,
				},
				top = dpi(9),
				bottom = dpi(9),
				left = dpi(10),
				right = dpi(10),
				widget = wibox.container.margin,
			},
			layout = wibox.layout.stack,
		},
		forced_width = dpi(260),
		shape = helpers.ui.prrect(beautiful.border_radius, false, true, true, false),
		bg = beautiful.widget_bg,
		widget = wibox.container.background,
	})
end

local music_widget = wibox.widget({
	{
		{
			music(),
			{
				volume_control(),
				margins = { top = dpi(20), bottom = dpi(20), left = dpi(10), right = dpi(10) },
				widget = wibox.container.margin,
			},
			layout = wibox.layout.align.horizontal,
		},
		forced_height = dpi(200),
		bg = beautiful.one_bg3,
		shape = helpers.ui.rrect(beautiful.border_radius),
		widget = wibox.container.background,
	},
	margins = dpi(10),
	color = "#FF000000",
	widget = wibox.container.margin,
})

--- playerctl
--- -------------
playerctl_daemon:connect_signal("metadata", function(_, title, artist, album_path, __, ___, ____)
	if title == "" then
		title = "Nothing Playing"
	end
	if artist == "" then
		artist = "Nothing Playing"
	end
	if album_path == "" then
		album_path = gears.filesystem.get_configuration_dir() .. "theme/assets/no_music.png"
	end

	music_art:set_image(gears.surface.load_uncached(album_path))
	music_title:set_markup_silently(helpers.ui.colorize_text(title, beautiful.white))
	music_artist:set_markup_silently(helpers.ui.colorize_text(artist, beautiful.accent))
end)

playerctl_daemon:connect_signal("playback_status", function(_, playing, __)
	if playing then
		music_text:set_markup_silently(helpers.ui.colorize_text("Now Playing", "#666c79"))
	else
		music_text:set_markup_silently(helpers.ui.colorize_text("Music", "#666c79"))
	end
end)

return music_widget
