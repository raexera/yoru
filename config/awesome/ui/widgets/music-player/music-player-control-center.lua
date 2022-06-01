local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local clickable_container = require("ui.widgets.clickable-container")
local playerctl = require("module.bling").signal.playerctl.lib()

-- Album cover
local album_cover = wibox.widget({
	image = gears.filesystem.get_configuration_dir() .. "theme/assets/no_music.png",
	resize = true,
	clip_shape = gears.shape.rounded_rect,
	widget = wibox.widget.imagebox,
})

-- music info
local title_now = wibox.widget({
	font = beautiful.font_name .. "Bold 12",
	valign = "center",
	widget = wibox.widget.textbox,
})

local music_title = wibox.widget({
	step_function = wibox.container.scroll.step_functions.waiting_nonlinear_back_and_forth,
	fps = 60,
	speed = 75,
	title_now,
	forced_width = dpi(150),
	widget = wibox.container.scroll.horizontal,
})

local artist_now = wibox.widget({
	font = beautiful.font_name .. "Regular 10",
	valign = "center",
	widget = wibox.widget.textbox,
})

local music_artist = wibox.widget({
	step_function = wibox.container.scroll.step_functions.waiting_nonlinear_back_and_forth,
	fps = 60,
	speed = 75,
	artist_now,
	forced_width = dpi(150),
	widget = wibox.container.scroll.horizontal,
})

local music_info = wibox.widget({
	layout = wibox.layout.align.vertical,
	expand = "none",
	nil,
	{
		layout = wibox.layout.fixed.vertical,
		music_title,
		music_artist,
	},
	nil,
})

-- media buttons
local create_media_button = function(font, symbol, on_click, on_right_click)
	local button = wibox.widget({
		font = font,
		text = symbol,
		align = "center",
		valign = "center",
		widget = wibox.widget.textbox(),
	})

	button:buttons(gears.table.join(awful.button({}, 1, on_click), awful.button({}, 3, on_right_click)))

	return button
end

-- Play pause button
local music_play_pause = create_media_button(beautiful.icon_font .. "Round 26", "", function()
	playerctl:play_pause()
end)

-- Previous button
local music_previous = create_media_button(beautiful.icon_font .. "Round 20", "", function()
	playerctl:previous()
end)

-- Next button
local music_next = create_media_button(beautiful.icon_font .. "Round 20", "", function()
	playerctl:next()
end)

local play_pause_button = wibox.widget({
	{
		music_play_pause,
		widget = clickable_container,
	},
	forced_width = dpi(36),
	forced_height = dpi(36),
	bg = beautiful.transparent,
	shape = gears.shape.circle,
	widget = wibox.container.background,
})

local next_button = wibox.widget({
	{
		music_next,
		widget = clickable_container,
	},
	forced_width = dpi(36),
	forced_height = dpi(36),
	bg = beautiful.transparent,
	shape = gears.shape.circle,
	widget = wibox.container.background,
})

local prev_button = wibox.widget({
	{
		music_previous,
		widget = clickable_container,
	},
	forced_width = dpi(36),
	forced_height = dpi(36),
	bg = beautiful.transparent,
	shape = gears.shape.circle,
	widget = wibox.container.background,
})

local media_buttons = wibox.widget({
	layout = wibox.layout.fixed.horizontal,
	prev_button,
	play_pause_button,
	next_button,
})

-- Playerctl
playerctl:connect_signal("metadata", function(_, title, artist, album_path, album, ___, player_name)
	if title == "" then
		title = "Nothing Playing"
	end
	if artist == "" then
		artist = "Nothing Playing"
	end
	if album_path == "" then
		album_path = gears.filesystem.get_configuration_dir() .. "theme/assets/no_music.png"
	end

	album_cover:set_image(gears.surface.load_uncached(album_path))
	title_now:set_markup_silently(title)
	artist_now:set_markup_silently(artist)
end)

playerctl:connect_signal("playback_status", function(_, playing, player_name)
	if playing then
		music_play_pause:set_text("")
	else
		music_play_pause:set_text("")
	end
end)

local music_box = wibox.widget({
	layout = wibox.layout.align.horizontal,
	forced_height = dpi(46),
	{
		layout = wibox.layout.fixed.horizontal,
		spacing = dpi(10),
		album_cover,
		music_info,
	},
	nil,
	{
		layout = wibox.layout.align.vertical,
		expand = "none",
		nil,
		media_buttons,
		nil,
	},
})

return music_box
