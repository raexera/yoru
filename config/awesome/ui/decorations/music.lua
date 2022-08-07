local gears = require("gears")
local awful = require("awful")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local ruled = require("ruled")
local wibox = require("wibox")
local playerctl_daemon = require("signal.playerctl")
local widgets = require("ui.widgets")
local helpers = require("helpers")

--- Custom mouse friendly ncmpcpp UI with album art
--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

--- Music icon
local function music_icon()
	local big_music_icon = wibox.widget({
		align = "center",
		font = beautiful.icon_font .. "Round 15",
		markup = helpers.ui.colorize_text("", beautiful.accent),
		widget = wibox.widget.textbox(),
	})

	local small_music_icon = wibox.widget({
		align = "center",
		font = beautiful.icon_font .. "Round 11",
		markup = helpers.ui.colorize_text("", beautiful.white),
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

	return music_icon
end

--- Music art cover
local music_art = wibox.widget({
	image = beautiful.music,
	resize = true,
	clip_shape = helpers.ui.rrect(beautiful.border_radius),
	widget = wibox.widget.imagebox,
})

--- Music title
local title_now = wibox.widget({
	font = beautiful.font_name .. "Bold 12",
	valign = "center",
	widget = wibox.widget.textbox,
})

--- Music artist
local artist_now = wibox.widget({
	font = beautiful.font_name .. "Medium 10",
	valign = "center",
	widget = wibox.widget.textbox,
})

--- Music position
local music_length = 0
local music_pos = wibox.widget({
	font = beautiful.font_name .. "Medium 10",
	valign = "center",
	widget = wibox.widget.textbox,
})

--- Music position bar
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

--- Playlist button
local playlist = function(c)
	return widgets.button.text.normal({
		normal_shape = gears.shape.rounded_rect,
		font = beautiful.icon_font .. "Round ",
		size = 14,
		text_normal_bg = beautiful.white,
		normal_bg = beautiful.music_bg_accent,
		text = "",
		on_release = function()
			helpers.misc.send_key(c, "1")
		end,
	})
end

--- Visualizer button
local visualizer = function(c)
	return widgets.button.text.normal({
		normal_shape = gears.shape.rounded_rect,
		font = "icomoon ",
		size = 14,
		text_normal_bg = beautiful.white,
		normal_bg = beautiful.music_bg_accent,
		text = "",
		on_release = function()
			helpers.misc.send_key(c, "8")
		end,
	})
end

--- Volume Control
local function volume_control()
	local volume_bar = wibox.widget({
		max_value = 100,
		value = 50,
		margins = {
			top = dpi(15),
			bottom = dpi(15),
			left = dpi(5),
			right = dpi(5),
		},
		forced_width = dpi(80),
		shape = gears.shape.rounded_bar,
		bar_shape = gears.shape.rounded_bar,
		color = beautiful.accent,
		background_color = beautiful.white .. "11",
		border_width = 0,
		widget = wibox.widget.progressbar,
	})

	-- Update bar
	-- MPD Volume
	local function volume_info()
		awful.spawn.easy_async_with_shell("mpc volume | awk '{print substr($2, 1, length($2)-1)}'", function(stdout)
			local volume = tonumber(stdout)
			volume_bar.value = volume and volume <= 100 and volume or 100
		end)
	end

	-- Run once to initialize widgets
	volume_info()

	-- Sleeps until mpd volume changes
	-- >> We use `sed '1~2d'` to remove every other line since the mixer event
	-- is printed twice for every volume update.
	-- >> The `-u` option forces sed to work in unbuffered mode in order to print
	-- without waiting for `mpc idleloop mixer` to finish
	local mpd_volume_script = [[
	  sh -c "
		mpc idleloop mixer | sed -u '1~2d'
	  "]]

	-- Kill old mpc idleloop mixer process
	awful.spawn.easy_async_with_shell(
		"ps x | grep \"mpc idleloop mixer\" | grep -v grep | awk '{print $1}' | xargs kill",
		function()
			-- Emit song info with each line printed
			awful.spawn.with_line_callback(mpd_volume_script, {
				stdout = function()
					volume_info()
				end,
			})
		end
	)

	-- Set up volume bar buttons
	volume_bar:connect_signal("button::press", function(_, lx, __, button)
		if button == 1 then
			awful.spawn.with_shell("mpc volume " .. tostring(math.ceil(lx * 100 / volume_bar.forced_width)))
		end
	end)

	local volume = wibox.widget({
		{
			align = "left",
			font = "icomoon 16",
			markup = helpers.ui.colorize_text("", beautiful.accent),
			widget = wibox.widget.textbox(),
		},
		helpers.ui.horizontal_pad(dpi(3)),
		volume_bar,
		helpers.ui.horizontal_pad(dpi(2)),
		layout = wibox.layout.fixed.horizontal,
	})

	volume:buttons(gears.table.join(
		-- Scroll - Increase or decrease volume
		awful.button({}, 4, function()
			awful.spawn.with_shell("mpc volume +5")
		end),
		awful.button({}, 5, function()
			awful.spawn.with_shell("mpc volume -5")
		end)
	))

	return volume
end

--- PLayerctl
--- ~~~~~~~~~
playerctl_daemon:connect_signal("metadata", function(_, title, artist, album_path, album, ___, player_name)
	if player_name == "mpd" then
		if title == "" then
			title = "Nothing Playing"
		end
		if artist == "" then
			artist = "Nothing Playing"
		end
		if album_path == "" then
			album_path = beautiful.music
		end

		music_art:set_image(gears.surface.load_uncached(album_path))
		title_now:set_markup_silently(helpers.ui.colorize_text(string.upper(title), beautiful.accent))
		artist_now:set_markup_silently(artist)
	end
end)

playerctl_daemon:connect_signal("position", function(_, interval_sec, length_sec, player_name)
	if player_name == "mpd" then
		local pos_now = tostring(os.date("!%M:%S", math.floor(interval_sec)))
		local pos_length = tostring(os.date("!%M:%S", math.floor(length_sec)))
		local pos_markup = pos_now .. helpers.ui.colorize_text(" / " .. pos_length, beautiful.color8)

		music_pos:set_markup_silently(pos_markup)
		music_bar.value = (interval_sec / length_sec) * 100
		music_length = length_sec
	end
end)

local music_create_decoration = function(c)
	--- Hide default titlebar
	awful.titlebar.hide(c, beautiful.titlebar_pos)

	--- Decoration Init
	awful.titlebar(c, { position = "top", size = dpi(45), bg = beautiful.transparent }):setup({
		{
			{
				{
					volume_control(),
					forced_width = dpi(200),
					widget = wibox.container.constraint,
				},
				music_icon(),
				layout = wibox.layout.align.horizontal,
			},
			left = dpi(10),
			right = dpi(10),
			widget = wibox.container.margin,
		},
		bg = beautiful.music_bg,
		shape = helpers.ui.prrect(beautiful.border_radius, true, true, false, false),
		widget = wibox.container.background,
	})

	--- Sidebar
	awful.titlebar(c, { position = "left", size = dpi(200) }):setup({
		{
			nil,
			{
				music_art,
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
		shape = helpers.ui.prrect(beautiful.border_radius * 2, false, true, false, false),
		widget = wibox.container.background,
	})

	--- Toolbar
	awful.titlebar(c, { position = "bottom", size = dpi(70), bg = beautiful.transparent }):setup({
		{
			layout = wibox.layout.align.vertical,
			music_bar,
			{
				{
					layout = wibox.layout.align.horizontal,
					expand = "none",
					{
						music_art,
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
						widgets.playerctl.shuffle(beautiful.white, beautiful.music_bg_accent),
						widgets.playerctl.previous(12, beautiful.white, beautiful.music_bg_accent),
						widgets.playerctl.play(beautiful.music_bg_accent, beautiful.accent),
						widgets.playerctl.next(12, beautiful.white, beautiful.music_bg_accent),
						widgets.playerctl.loop(beautiful.white, beautiful.music_bg_accent),
						spacing = dpi(10),
						layout = wibox.layout.fixed.horizontal,
					},
					{
						--- Music Position
						music_pos,
						{
							playlist(c),
							visualizer(c),
							spacing = dpi(5),
							layout = wibox.layout.fixed.horizontal,
						},
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
		shape = helpers.ui.prrect(beautiful.border_radius, false, false, true, true),
		widget = wibox.container.background,
	})

	--- Set custom decoration flags
	c.custom_decoration = { top = true, left = true, bottom = true }
end

--- Add the titlebar whenever a new music client is spawned
ruled.client.connect_signal("request::rules", function()
	ruled.client.append_rule({
		id = "music",
		rule = { instance = "music" },
		callback = music_create_decoration,
	})
end)
