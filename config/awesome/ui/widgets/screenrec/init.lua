local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local naughty = require("naughty")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local clickable_container = require("ui.widgets.clickable-container")
local helpers = require("helpers")

-- Screenrec
---------------
-- Stolen from Manilarome

-- Status variables
local status_recording = false
local status_audio = true
local ffmpeg_pid = nil

-- User preferences
local user_preferences = {
	resolution = "1366x768",
	offset = "0,0",
	audio = false,
	save_directory = "$(xdg-user-dir VIDEOS)/Recordings/",
	mic_lvl = "20",
	fps = "30",
}

-- Script
local create_save_directory = function()
	local create_dir_cmd = [[
	dir="]] .. user_preferences.save_directory .. [["

	if [ ! -d "$dir" ]; then
		mkdir -p "$dir"
	fi
	]]

	awful.spawn.easy_async_with_shell(create_dir_cmd, function(stdout) end)
end

create_save_directory()

local kill_existing_recording_ffmpeg = function()
	awful.spawn.easy_async_with_shell(
		[[
		ps x | grep 'ffmpeg -video_size' | grep -v grep | awk '{print $1}' | xargs kill
		]],
		function(stdout) end
	)
end

kill_existing_recording_ffmpeg()

local turn_on_the_mic = function()
	awful.spawn.easy_async_with_shell([[
		amixer set Capture cap
		amixer set Capture ]] .. user_preferences.mic_lvl .. [[%
		]], function() end)
end

local ffmpeg_stop_recording = function()
	awful.spawn.easy_async_with_shell(
		[[
		ps x | grep 'ffmpeg -video_size' | grep -v grep | awk '{print $1}' | xargs kill -2
		]],
		function(stdout) end
	)
end

local create_notification = function(file_dir)
	local open_video = naughty.action({
		name = "Open",
		icon_only = false,
	})

	local delete_video = naughty.action({
		name = "Delete",
		icon_only = false,
	})

	open_video:connect_signal("invoked", function()
		awful.spawn("xdg-open " .. file_dir, false)
	end)

	delete_video:connect_signal("invoked", function()
		awful.spawn("gio trash " .. file_dir, false)
	end)

	naughty.notification({
		app_name = "Screenrecorder Tool",
		timeout = 6,
		title = "<b>Screenrec!</b>",
		message = "Recording Finished",
		actions = { open_video, delete_video },
	})
end

local ffmpeg_start_recording = function(audio, filename)
	local add_audio_str = " "

	if audio then
		turn_on_the_mic()
		add_audio_str = "-f pulse -ac 2 -i default"
	end

	ffmpeg_pid = awful.spawn.easy_async_with_shell([[		
		file_name=]] .. filename .. [[

		ffmpeg -video_size ]] .. user_preferences.resolution .. [[ -framerate ]] .. user_preferences.fps .. [[ -f x11grab \
		-i :0.0+]] .. user_preferences.offset .. " " .. add_audio_str .. [[ -c:v libx264 -crf 20 -profile:v baseline -level 3.0 -pix_fmt yuv420p $file_name
		]], function(stdout, stderr)
		if stderr and stderr:match("Invalid argument") then
			naughty.notification({
				app_name = "Screenrecorder Tool",
				title = "<b>Screenrec!</b>",
				message = "Invalid Configuration! please, put a valid settings!",
				timeout = 3,
				urgency = "normal",
			})
			awesome.emit_signal("widget::screen_recorder")
			return
		end
		create_notification(filename)
	end)
end

local create_unique_filename = function(audio)
	awful.spawn.easy_async_with_shell([[
		dir="]] .. user_preferences.save_directory .. [["
		date=$(date '+%Y-%m-%d_%H-%M-%S')
		format=.mp4

		echo "${dir}${date}${format}" | tr -d '\n'
		]], function(stdout)
		local filename = stdout
		ffmpeg_start_recording(audio, filename)
	end)
end

local start_recording = function(audio_mode)
	create_save_directory()
	create_unique_filename(audio_mode)
end

local stop_recording = function()
	ffmpeg_stop_recording()
end

-- Buttons
local screen_rec_toggle_imgbox = wibox.widget({
	id = "icon",
	markup = helpers.colorize_text("󰻃", beautiful.xforeground),
	font = beautiful.icon_font_name .. "18",
	align = "center",
	valign = "center",
	widget = wibox.widget.textbox,
})

local screen_rec_toggle_button = wibox.widget({
	{
		{
			screen_rec_toggle_imgbox,
			margins = dpi(12),
			forced_height = dpi(48),
			forced_width = dpi(48),
			widget = wibox.container.margin,
		},
		widget = clickable_container,
	},
	bg = beautiful.control_center_button_bg,
	shape = gears.shape.circle,
	widget = wibox.container.background,
})

-- Start Recording
local sr_recording_start = function()
	status_recording = true
	screen_rec_toggle_button.bg = beautiful.accent

	start_recording(status_audio)
	control_center_toggle()
end

-- Stop Recording
local sr_recording_stop = function()
	status_recording = false
	status_audio = false
	screen_rec_toggle_button.bg = beautiful.control_center_button_bg

	stop_recording()
end

awesome.connect_signal("widget::screen_recorder", function()
	sr_recording_stop()
end)

-- Main button functions and buttons
local status_checker = function()
	if status_recording then
		sr_recording_stop()
		return
	else
		sr_recording_start()
		return
	end
end

screen_rec_toggle_button:buttons(gears.table.join(awful.button({}, 1, nil, function()
	status_checker()
end)))

local return_button = function()
	return screen_rec_toggle_button
end

return return_button
