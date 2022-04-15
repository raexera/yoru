-- Standard awesome library
local gears = require("gears")
local awful = require("awful")

-- Theme handling library
local beautiful = require("beautiful")

-- Widget library
local wibox = require("wibox")

-- Helpers
local helpers = require("helpers")

-- Music
----------

local music_text = wibox.widget({
	font = beautiful.font_name .. "medium 8",
	valign = "center",
	widget = wibox.widget.textbox,
})

local music_art = wibox.widget({
	image = gears.filesystem.get_configuration_dir() .. "theme/assets/no_music.png",
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
	stops = { { 0, beautiful.dashboard_box_bg .. "cc" }, { 1, beautiful.dashboard_box_bg } },
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
	font = beautiful.font_name .. "medium 9",
	valign = "center",
	widget = wibox.widget.textbox,
})

local music_artist = wibox.widget({
	font = beautiful.font_name .. "medium 12",
	valign = "center",
	widget = wibox.widget.textbox,
})

local music_pos = wibox.widget({
	font = beautiful.font_name .. "medium 8",
	valign = "center",
	widget = wibox.widget.textbox,
})

-- playerctl
---------------

local playerctl = require("module.bling").signal.playerctl.lib()

playerctl:connect_signal("metadata", function(_, title, artist, album_path, __, ___, ____)
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
	music_title:set_markup_silently(helpers.colorize_text(title, beautiful.xforeground .. "b3"))
	music_artist:set_markup_silently(helpers.colorize_text(artist, beautiful.xforeground .. "e6"))
end)

playerctl:connect_signal("playback_status", function(_, playing, __)
	if playing then
		music_text:set_markup_silently(helpers.colorize_text("Now Playing", beautiful.xforeground .. "cc"))
	else
		music_text:set_markup_silently(helpers.colorize_text("Music", beautiful.xforeground .. "cc"))
	end
end)

playerctl:connect_signal("position", function(_, interval_sec, length_sec, player_name)
	local pos_now = tostring(os.date("!%M:%S", math.floor(interval_sec)))
	local pos_length = tostring(os.date("!%M:%S", math.floor(length_sec)))
	local pos_markup = helpers.colorize_text(pos_now .. " / " .. pos_length, beautiful.xforeground .. "66")

	music_pos:set_markup_silently(pos_markup)
end)

local music = wibox.widget({
	{
		{
			{
				music_art_container,
				music_art_filter,
				layout = wibox.layout.stack,
			},
			{
				{
					music_text,
					{
						{
							{
								step_function = wibox.container.scroll.step_functions.waiting_nonlinear_back_and_forth,
								speed = 50,
								{
									widget = music_artist,
								},
								forced_width = dpi(180),
								widget = wibox.container.scroll.horizontal,
							},
							{
								step_function = wibox.container.scroll.step_functions.waiting_nonlinear_back_and_forth,
								speed = 50,
								{
									widget = music_title,
								},
								forced_width = dpi(180),
								widget = wibox.container.scroll.horizontal,
							},
							layout = wibox.layout.fixed.vertical,
						},
						bottom = dpi(15),
						widget = wibox.container.margin,
					},
					music_pos,
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
		bg = beautiful.dashboard_box_bg,
		shape = helpers.rrect(dpi(5)),
		forced_width = dpi(200),
		forced_height = dpi(120),
		widget = wibox.container.background,
	},
	margins = dpi(10),
	widget = wibox.container.margin,
})

return music
