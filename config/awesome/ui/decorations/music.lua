-- Standard awesome library
local gears = require("gears")
local awful = require("awful")

-- Theme library
local beautiful = require("beautiful")

-- Ruled
local ruled = require("ruled")

-- Widget library
local wibox = require("wibox")

-- Helpers
local helpers = require("helpers")

-- Aesthetic Music Player
----------------------------

-- Music icon
----------------

local big_music_icon = wibox.widget({
	align = "center",
	font = beautiful.icon_font_name .. "15",
	markup = helpers.colorize_text("󰎇", beautiful.accent),
	widget = wibox.widget.textbox(),
})

local small_music_icon = wibox.widget({
	align = "center",
	font = beautiful.icon_font_name .. "11",
	markup = helpers.colorize_text("󰎇", beautiful.xforeground),
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

-- Helpers
-------------

local control_button_bg = "#00000000"
local control_button_bg_hover = beautiful.hover_effect
local control_button = function(c, symbol, color, font, size, on_click, on_right_click)
	local icon = wibox.widget({
		markup = helpers.colorize_text(symbol, color),
		font = font,
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
		width = dpi(30),
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

-- Play Pause button
local music_play_pause = control_button(
	c,
	"󰐊",
	beautiful.xforeground,
	beautiful.icon_font_name .. "22",
	dpi(30),
	function()
		awful.spawn.with_shell("mpc -q toggle")
	end
)

-- Loop button
local loop = control_button(c, "󰑖", beautiful.xforeground, beautiful.icon_font_name .. "12", dpi(30), function()
	awful.spawn.with_shell("mpc repeat")
end)

-- Shuffle playlist button
local shuffle = control_button(c, "󰒝", beautiful.xforeground, beautiful.icon_font_name .. "12", dpi(30), function()
	awful.spawn.with_shell("mpc random")
end)

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
		font = beautiful.font_name .. "bold 10",
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

-- Decorations
-----------------

local music_art = wibox.widget({
	image = gears.filesystem.get_configuration_dir() .. "theme/assets/no_music.png",
	resize = true,
	widget = wibox.widget.imagebox,
})

local music_art_container = wibox.widget({
	music_art,
	shape = helpers.rrect(dpi(5)),
	widget = wibox.container.background,
})

local music_now = wibox.widget({
	font = beautiful.font_name .. "bold 10",
	valign = "center",
	widget = wibox.widget.textbox,
})

local music_pos = wibox.widget({
	font = beautiful.font_name .. "bold 10",
	valign = "center",
	widget = wibox.widget.textbox,
})

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

local music_play_pause_textbox = music_play_pause:get_all_children()[1]:get_all_children()[1]
local loop_textbox = loop:get_all_children()[1]:get_all_children()[1]
local shuffle_textbox = shuffle:get_all_children()[1]:get_all_children()[1]

-- Volume
--------

local vol_color = beautiful.accent
local vol_slider = create_slider_widget(vol_color)
local vol_tooltip = create_tooltip(vol_slider)

local vol_icon = wibox.widget({
	align = "center",
	font = beautiful.icon_font_name .. "16",
	markup = helpers.colorize_text("󰕾", beautiful.accent),
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
	helpers.volume_control(0)
end)))

awesome.connect_signal("signal::volume", function(value, muted)
	local fill_color
	local vol_value = value or 0

	if muted then
		vol_icon.markup = helpers.colorize_text("󰖁", beautiful.xcolor8)
		fill_color = beautiful.xcolor8
	else
		vol_icon.markup = helpers.colorize_text("󰕾", beautiful.accent)
		fill_color = vol_color
	end

	vol_slider.slider.value = vol_value
	vol_slider.slider.color = fill_color
	vol_tooltip.markup = helpers.colorize_text(vol_value .. "%", vol_color)
end)

vol_slider:buttons(gears.table.join(
	awful.button({}, 1, function()
		helpers.volume_control(0)
	end),
	-- Scrolling
	awful.button({}, 4, function()
		helpers.volume_control(5)
	end),
	awful.button({}, 5, function()
		helpers.volume_control(-5)
	end)
))

-- Playerctl
---------------

local playerctl = require("module.bling").signal.playerctl.lib()
local music_length = 0

playerctl:connect_signal("metadata", function(_, title, artist, album_path, album, ___, player_name)
	if player_name == "mpd" then
		local m_now = artist .. " - " .. title .. "/" .. album

		music_art:set_image(gears.surface.load_uncached(album_path))
		music_now:set_markup_silently(m_now)
	end
end)

playerctl:connect_signal("position", function(_, interval_sec, length_sec, player_name)
	if player_name == "mpd" then
		local pos_now = tostring(os.date("!%M:%S", math.floor(interval_sec)))
		local pos_length = tostring(os.date("!%M:%S", math.floor(length_sec)))
		local pos_markup = pos_now .. helpers.colorize_text(" / " .. pos_length, beautiful.xforeground)

		music_art:set_image(gears.surface.load_uncached(album_path))
		music_pos:set_markup_silently(pos_markup)
		music_bar.value = (interval_sec / length_sec) * 100
		music_length = length_sec
	end
end)

playerctl:connect_signal("playback_status", function(_, playing, player_name)
	if player_name == "mpd" then
		if playing then
			music_play_pause_textbox:set_markup_silently(helpers.colorize_text("󰏤", beautiful.accent))
		else
			music_play_pause_textbox:set_markup_silently(helpers.colorize_text("󰐊", beautiful.accent))
		end
	end
end)

playerctl:connect_signal("loop_status", function(_, loop_status, player_name)
	if player_name == "mpd" then
		if loop_status == "none" then
			loop_textbox:set_markup_silently("󰑖")
		else
			loop_textbox:set_markup_silently(helpers.colorize_text("󰑖", beautiful.accent))
		end
	end
end)

playerctl:connect_signal("shuffle", function(_, shuffle, player_name)
	if player_name == "mpd" then
		if shuffle then
			shuffle_textbox:set_markup_silently(helpers.colorize_text("󰒝", beautiful.accent))
		else
			shuffle_textbox:set_markup_silently("󰒝")
		end
	end
end)

local music_create_decoration = function(c)
	-- Hide default titlebar
	awful.titlebar.hide(c, beautiful.titlebar_pos)

	-- Titlebar
	awful.titlebar(c, { position = "top", size = beautiful.titlebar_size, bg = beautiful.transparent }):setup({
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
				widget = wibox.container.background,
			},
			{
				widget = music_icon,
			},
			layout = wibox.layout.align.horizontal,
		},
		bg = beautiful.music_bg,
		shape = helpers.prrect(beautiful.border_radius, true, true, false, false),
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
			music_bar,
			{
				{
					{
						control_button(
							c,
							"󰒮",
							beautiful.xforeground,
							beautiful.icon_font_name .. "14",
							dpi(30),
							function()
								awful.spawn.with_shell("mpc -q prev")
							end
						),
						-- Toggle play pause
						music_play_pause,
						control_button(
							c,
							"󰒭",
							beautiful.xforeground,
							beautiful.icon_font_name .. "14",
							dpi(30),
							function()
								awful.spawn.with_shell("mpc -q next")
							end
						),
						layout = wibox.layout.flex.horizontal,
					},
					{
						{
							step_function = wibox.container.scroll.step_functions.waiting_nonlinear_back_and_forth,
							speed = 50,
							{
								widget = music_now,
							},
							-- forced_width = dpi(110),
							widget = wibox.container.scroll.horizontal,
						},
						left = dpi(15),
						right = dpi(20),
						widget = wibox.container.margin,
					},
					{
						music_pos,
						{
							loop,
							shuffle,
							-- Go to list of playlists
							control_button(
								c,
								"󰲸",
								beautiful.xforeground,
								beautiful.icon_font_name .. "12",
								dpi(30),
								function()
									helpers.send_key(c, "1")
								end
							),
							-- Go to visualizer
							control_button(c, "", beautiful.xforeground, "icomoon 12", dpi(30), function()
								helpers.send_key(c, "8")
							end),
							layout = wibox.layout.flex.horizontal,
						},
						spacing = dpi(10),
						layout = wibox.layout.fixed.horizontal,
					},
					layout = wibox.layout.align.horizontal,
				},
				margins = dpi(15),
				widget = wibox.container.margin,
			},
			layout = wibox.layout.align.vertical,
		},
		bg = beautiful.music_bg_accent,
		shape = helpers.prrect(beautiful.border_radius, false, false, true, true),
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
