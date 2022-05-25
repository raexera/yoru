local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local wibox = require("wibox")
local helpers = require("helpers")
local playerctl = require("module.bling").signal.playerctl.lib()

-- Music
----------

local music_text = wibox.widget({
	font = beautiful.font_name .. "Medium 8",
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
	font = beautiful.font_name .. "Medium 9",
	valign = "center",
	widget = wibox.widget.textbox,
})

local music_artist = wibox.widget({
	font = beautiful.font_name .. "Medium 12",
	valign = "center",
	widget = wibox.widget.textbox,
})

local music_pos = wibox.widget({
	font = beautiful.font_name .. "Medium 8",
	valign = "center",
	widget = wibox.widget.textbox,
})

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
		bg = beautiful.widget_bg,
		shape = helpers.rrect(dpi(5)),
		forced_width = dpi(200),
		forced_height = dpi(120),
		widget = wibox.container.background,
	},
	margins = dpi(10),
	widget = wibox.container.margin,
})

-- Media Keys
local create_media_button = function(symbol, color, command, playpause)
	local icon = wibox.widget({
		markup = helpers.colorize_text(symbol, color),
		font = beautiful.icon_font .. "16",
		align = "center",
		valign = "center",
		widget = wibox.widget.textbox(),
	})

	playerctl:connect_signal("playback_status", function(_, playing, __)
		if playpause then
			if playing then
				icon:set_markup_silently(helpers.colorize_text("", color))
			else
				icon:set_markup_silently(helpers.colorize_text("", color))
			end
		end
	end)

	icon:buttons(gears.table.join(awful.button({}, 1, function()
		command()
	end)))

	icon:connect_signal("mouse::enter", function()
		icon.markup = helpers.colorize_text(icon.text, beautiful.xcolor15)
	end)

	icon:connect_signal("mouse::leave", function()
		icon.markup = helpers.colorize_text(icon.text, color)
	end)

	return icon
end

local media_play_command = function()
	playerctl:play_pause()
end
local media_prev_command = function()
	playerctl:previous()
end
local media_next_command = function()
	playerctl:next()
end

local media_play = create_media_button("", beautiful.xforeground, media_play_command, true)
local media_prev = create_media_button("", beautiful.xforeground, media_prev_command, false)
local media_next = create_media_button("", beautiful.xforeground, media_next_command, false)

local media = wibox.widget({
	{
		{
			{
				media_prev,
				media_play,
				media_next,
				expand = "none",
				layout = wibox.layout.align.vertical,
			},
			margins = dpi(9),
			widget = wibox.container.margin,
		},
		bg = beautiful.widget_bg,
		shape = helpers.rrect(5),
		forced_width = dpi(40),
		forced_height = dpi(120),
		widget = wibox.container.background,
	},
	margins = dpi(10),
	widget = wibox.container.margin,
})

-- Music Player init
-----------------------

local music_player = wibox.widget({
	music,
	media,
	layout = wibox.layout.fixed.horizontal,
})

-- playerctl
---------------
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

return music_player
