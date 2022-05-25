local gears = require("gears")
local awful = require("awful")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local ruled = require("ruled")
local wibox = require("wibox")
local helpers = require("helpers")

-- Custom mouse friendly ncmpcpp UI with album art
-----------------------------------------------------

-- Music icon
local big_music_icon = wibox.widget({
	align = "center",
	font = beautiful.icon_font .. "Bold 15",
	markup = helpers.colorize_text("", beautiful.accent),
	widget = wibox.widget.textbox(),
})

local small_music_icon = wibox.widget({
	align = "center",
	font = beautiful.icon_font .. "Bold 11",
	markup = helpers.colorize_text("", beautiful.xforeground),
	widget = wibox.widget.textbox(),
})

local container_music_icon = wibox.widget({
	big_music_icon,
	{
		small_music_icon,
		top = dpi(11),
		widget = wibox.container.margin,
	},
	spacing = dpi(-9),
	layout = wibox.layout.fixed.horizontal,
})

local music_icon = wibox.widget({
	nil,
	{
		container_music_icon,
		spacing = dpi(14),
		layout = wibox.layout.fixed.horizontal,
	},
	expand = "none",
	layout = wibox.layout.align.horizontal,
})

-- Control button
local control_button_bg = "#00000000"
local control_button_bg_hover = beautiful.accent .. "44"
local control_button = function(c, font, symbol, color, size, on_click, on_right_click)
	local icon = wibox.widget({
		font = font,
		markup = helpers.colorize_text(symbol, color),
		align = "center",
		valign = "center",
		widget = wibox.widget.textbox(),
	})

	local button = wibox.widget({
		icon,
		bg = control_button_bg,
		shape = helpers.rrect(dpi(5)),
		widget = wibox.container.background,
	})

	local container = wibox.widget({
		button,
		strategy = "min",
		width = size,
		widget = wibox.container.constraint,
	})

	container:buttons(gears.table.join(awful.button({}, 1, on_click), awful.button({}, 3, on_right_click)))

	container:connect_signal("mouse::enter", function()
		button.bg = control_button_bg_hover
	end)
	container:connect_signal("mouse::leave", function()
		button.bg = control_button_bg
	end)

	return container
end

-- Volume slider
local function create_slider_widget(slider_color)
	local slider_widget = wibox.widget({
		{
			id = "slider",
			max_value = 100,
			value = 20,
			margins = {
				top = dpi(7),
				bottom = dpi(7),
				left = dpi(6),
				right = dpi(6),
			},
			forced_width = dpi(60),
			shape = gears.shape.rounded_bar,
			bar_shape = gears.shape.rounded_bar,
			color = slider_color,
			background_color = slider_color .. "44",
			widget = wibox.widget.progressbar,
		},
		expand = "none",
		forced_width = 60,
		layout = wibox.layout.align.horizontal,
	})

	return slider_widget
end

local stats_tooltip = wibox.widget({
	visible = false,
	top_only = true,
	layout = wibox.layout.stack,
})

local tooltip_counter = 0
local function create_tooltip(w)
	local tooltip = wibox.widget({
		font = beautiful.font_name .. "Bold 10",
		align = "right",
		valign = "center",
		widget = wibox.widget.textbox,
	})

	tooltip_counter = tooltip_counter + 1
	local index = tooltip_counter

	stats_tooltip:insert(index, tooltip)

	w:connect_signal("mouse::enter", function()
		-- Raise tooltip to the top of the stack
		stats_tooltip:set(1, tooltip)
		stats_tooltip.visible = true
	end)
	w:connect_signal("mouse::leave", function()
		stats_tooltip.visible = false
	end)

	return tooltip
end

local vol_color = beautiful.accent
local vol_slider = create_slider_widget(vol_color)
local vol_tooltip = create_tooltip(vol_slider)

local vol_icon = wibox.widget({
	align = "center",
	valign = "center",
	font = beautiful.icon_font .. "Round 16",
	markup = helpers.colorize_text("", beautiful.accent),
	widget = wibox.widget.textbox,
})

local vol_button = wibox.widget({
	vol_icon,
	bg = control_button_bg,
	shape = helpers.rrect(dpi(5)),
	widget = wibox.container.background,
})

local vol = wibox.widget({
	vol_button,
	strategy = "min",
	width = dpi(30),
	widget = wibox.container.constraint,
})

vol:connect_signal("mouse::enter", function()
	vol_button.bg = control_button_bg_hover
end)
vol:connect_signal("mouse::leave", function()
	vol_button.bg = control_button_bg
end)
vol:buttons(gears.table.join(awful.button({}, 1, function()
	awful.spawn("pamixer -t")
end)))

awesome.connect_signal("signal::volume", function(value, muted)
	local fill_color
	local vol_value = tonumber(value) or 0

	if muted == 1 or vol == 0 then
		vol_icon.markup = helpers.colorize_text("", beautiful.xcolor8)
		fill_color = beautiful.xcolor8
	else
		vol_icon.markup = helpers.colorize_text("", beautiful.accent)
		fill_color = vol_color
	end

	vol_slider.slider.value = vol_value
	vol_slider.slider.color = fill_color
	vol_tooltip.markup = helpers.colorize_text(vol_value .. "%", vol_color)
end)

vol_slider:buttons(gears.table.join(
	-- Scrolling
	awful.button({}, 4, function()
		awful.spawn("pamixer -i 5")
	end),
	awful.button({}, 5, function()
		awful.spawn("pamixer -d 5")
	end)
))

-- Music art cover
local music_art = wibox.widget({
	image = gears.filesystem.get_configuration_dir() .. "theme/assets/no_music.png",
	resize = true,
	widget = wibox.widget.imagebox,
})

local music_art_container = wibox.widget({
	music_art,
	shape = helpers.rrect(6),
	widget = wibox.container.background,
})

-- Music title
local title_now = wibox.widget({
	font = beautiful.font_name .. "Bold 10",
	valign = "center",
	widget = wibox.widget.textbox,
})

-- Music artist
local artist_now = wibox.widget({
	font = beautiful.font_name .. "Regular 10",
	valign = "center",
	widget = wibox.widget.textbox,
})

-- Music position
local music_pos = wibox.widget({
	font = beautiful.font_name .. "Regular 10",
	valign = "center",
	widget = wibox.widget.textbox,
})

-- Music position bar
local music_bar = wibox.widget({
	max_value = 100,
	value = 0,
	background_color = beautiful.accent .. "44",
	color = beautiful.accent,
	forced_height = dpi(3),
	widget = wibox.widget.progressbar,
})

music_bar:connect_signal("button::press", function(_, lx, __, button, ___, w)
	if button == 1 then
		awful.spawn.with_shell("mpc seek " .. math.ceil(lx * 100 / w.width) .. "%")
	end
end)

-- Play pause button
local music_play_pause = control_button(
	c,
	beautiful.icon_font .. "Round 26",
	"",
	beautiful.xforeground,
	dpi(30),
	function()
		awful.spawn.with_shell("mpc -q toggle")
	end
)

-- Previous button
local music_previous = control_button(
	c,
	beautiful.icon_font .. "Round 16",
	"",
	beautiful.xforeground,
	dpi(30),
	function()
		awful.spawn.with_shell("mpc -q prev")
	end
)

-- Next button
local music_next = control_button(
	c,
	beautiful.icon_font .. "Round 16",
	"",
	beautiful.xforeground,
	dpi(30),
	function()
		awful.spawn.with_shell("mpc -q next")
	end
)

-- Loop button
local loop = control_button(c, beautiful.icon_font .. "Round 12", "", beautiful.xforeground, dpi(30), function()
	awful.spawn.with_shell("mpc repeat")
end)

-- Shuffle playlist button
local shuffle = control_button(c, beautiful.icon_font .. "Round 12", "", beautiful.xforeground, dpi(30), function()
	awful.spawn.with_shell("mpc random")
end)

local music_play_pause_textbox = music_play_pause:get_all_children()[1]:get_all_children()[1]
local loop_textbox = loop:get_all_children()[1]:get_all_children()[1]
local shuffle_textbox = shuffle:get_all_children()[1]:get_all_children()[1]

-- Playerctl
local playerctl = require("module.bling").signal.playerctl.lib()
local music_length = 0

playerctl:connect_signal("metadata", function(_, title, artist, album_path, album, ___, player_name)
	if player_name == "mpd" then
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
		title_now:set_markup_silently(title)
		artist_now:set_markup_silently(artist)
	end
end)

playerctl:connect_signal("position", function(_, interval_sec, length_sec, player_name)
	if player_name == "mpd" then
		local pos_now = tostring(os.date("!%M:%S", math.floor(interval_sec)))
		local pos_length = tostring(os.date("!%M:%S", math.floor(length_sec)))
		local pos_markup = pos_now .. helpers.colorize_text(" / " .. pos_length, beautiful.xcolor8)

		music_pos:set_markup_silently(pos_markup)
		music_bar.value = (interval_sec / length_sec) * 100
		music_length = length_sec
	end
end)

playerctl:connect_signal("playback_status", function(_, playing, player_name)
	if player_name == "mpd" then
		if playing then
			music_play_pause_textbox:set_markup_silently(helpers.colorize_text("", beautiful.accent))
		else
			music_play_pause_textbox:set_markup_silently(helpers.colorize_text("", beautiful.accent))
		end
	end
end)

playerctl:connect_signal("loop_status", function(_, loop_status, player_name)
	if player_name == "mpd" then
		if loop_status == "none" then
			loop_textbox:set_markup_silently("")
		else
			loop_textbox:set_markup_silently(helpers.colorize_text("", beautiful.accent))
		end
	end
end)

playerctl:connect_signal("shuffle", function(_, shuffle, player_name)
	if player_name == "mpd" then
		if shuffle then
			shuffle_textbox:set_markup_silently(helpers.colorize_text("", beautiful.accent))
		else
			shuffle_textbox:set_markup_silently("")
		end
	end
end)

local music_create_decoration = function(c)
	-- Hide default titlebar
	awful.titlebar.hide(c, beautiful.titlebar_pos)

	-- Buttons for the titlebar
	local buttons = gears.table.join(
		-- Left click
		awful.button({}, 1, function()
			c:emit_signal("request::activate", "titlebar", { raise = true })
			awful.mouse.client.move(c)
		end),

		-- Middle click
		awful.button({}, 2, nil, function(c)
			c:kill()
		end),

		-- Right click
		awful.button({}, 3, function()
			c:emit_signal("request::activate", "titlebar", { raise = true })
			awful.mouse.client.resize(c)
		end)
	)

	-- Titlebar
	awful.titlebar(c, { position = "top", size = dpi(45), bg = beautiful.transparent }):setup({
		{
			{
				{
					{
						{
							vol,
							nil,
							vol_slider,
							spacing = dpi(2),
							layout = wibox.layout.fixed.horizontal,
						},
						stats_tooltip,
						layout = wibox.layout.align.horizontal,
					},
					top = dpi(10),
					bottom = dpi(10),
					right = dpi(10),
					left = dpi(15),
					widget = wibox.container.margin,
				},
				forced_width = dpi(200),
				widget = wibox.container.constraint,
			},
			{
				widget = music_icon,
			},
			layout = wibox.layout.align.horizontal,
		},
		bg = beautiful.music_bg,
		shape = helpers.prrect(beautiful.corner_radius, true, true, false, false),
		widget = wibox.container.background,
	})

	-- Sidebar
	awful.titlebar(c, { position = "left", size = dpi(200) }):setup({
		{
			nil,
			{
				music_art_container,
				bottom = dpi(20),
				left = dpi(25),
				right = dpi(25),
				widget = wibox.container.margin,
			},
			nil,
			expand = "none",
			layout = wibox.layout.align.vertical,
		},
		bg = beautiful.music_accent,
		shape = helpers.prrect(dpi(10), false, true, false, false),
		widget = wibox.container.background,
	})

	-- Toolbar
	awful.titlebar(c, { position = "bottom", size = dpi(63), bg = beautiful.transparent }):setup({
		{
			layout = wibox.layout.align.vertical,
			music_bar,
			{
				{
					layout = wibox.layout.align.horizontal,
					expand = "none",
					{
						music_art_container,
						{
							{
								step_function = wibox.container.scroll.step_functions.waiting_nonlinear_back_and_forth,
								fps = 60,
								speed = 75,
								title_now,
								forced_width = dpi(150),
								widget = wibox.container.scroll.horizontal,
							},
							{
								step_function = wibox.container.scroll.step_functions.waiting_nonlinear_back_and_forth,
								fps = 60,
								speed = 75,
								artist_now,
								forced_width = dpi(150),
								widget = wibox.container.scroll.horizontal,
							},
							spacing = dpi(2),
							layout = wibox.layout.flex.vertical,
						},
						spacing = dpi(10),
						layout = wibox.layout.fixed.horizontal,
					},
					{
						shuffle,
						music_previous, -- Toggle play pause
						music_play_pause,
						music_next,
						loop,
						spacing = dpi(10),
						layout = wibox.layout.fixed.horizontal,
					},
					{
						-- Music Position
						music_pos,
						-- Playlist button
						control_button(
							c,
							beautiful.icon_font .. "Round 14",
							"",
							beautiful.xforeground,
							dpi(30),
							function()
								helpers.send_key(c, "1")
							end
						),
						-- Visualizer button
						control_button(c, "icomoon 14", "", beautiful.xforeground, dpi(30), function()
							helpers.send_key(c, "8")
						end),
						spacing = dpi(10),
						layout = wibox.layout.fixed.horizontal,
					},
				},
				top = dpi(15),
				bottom = dpi(15),
				left = dpi(25),
				right = dpi(25),
				widget = wibox.container.margin,
			},
		},
		bg = beautiful.music_bg_accent,
		shape = helpers.prrect(beautiful.corner_radius, false, false, true, true),
		widget = wibox.container.background,
	})

	-- Set custom decoration flags
	c.custom_decoration = { top = true, left = true, bottom = true }
end

-- Add the titlebar whenever a new music client is spawned
ruled.client.connect_signal("request::rules", function()
	ruled.client.append_rule({
		id = "music",
		rule = { instance = "music" },
		callback = music_create_decoration,
	})
end)
