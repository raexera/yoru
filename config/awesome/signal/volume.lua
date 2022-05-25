-- Provides:
-- signal::volume
--      percentage (integer)
--      muted (boolean)
local awful = require("awful")

local volume_old = -1
local muted_old = -1
local function emit_volume_info()
	-- Get volume info of the currently active sink
	awful.spawn.easy_async_with_shell('echo -n $(pamixer --get-mute); echo "_$(pamixer --get-volume)"', function(stdout)
		local bool = string.match(stdout, "(.-)_")
		local volume = string.match(stdout, "%d+")
		local muted_int = -1
		if bool == "true" then
			muted_int = 1
		else
			muted_int = 0
		end
		local volume_int = tonumber(volume)

		-- Only send signal if there was a change
		-- We need this since we use `pactl subscribe` to detect
		-- volume events. These are not only triggered when the
		-- user adjusts the volume through a keybind, but also
		-- through `pavucontrol` or even without user intervention,
		-- when a media file starts playing.
		if volume_int ~= volume_old or muted_int ~= muted_old then
			awesome.emit_signal("signal::volume", volume_int, muted_int)
			volume_old = volume_int
			muted_old = muted_int
		end
	end)
end

-- Run once to initialize widgets
emit_volume_info()

-- Sleeps until pactl detects an event (volume up/down/toggle mute)
local volume_script = [[
    bash -c "
    LANG=C pactl subscribe 2> /dev/null | grep --line-buffered \"Event 'change' on sink #\"
    "]]

-- Kill old pactl subscribe processes
awful.spawn.easy_async({
	"pkill",
	"--full",
	"--uid",
	os.getenv("USER"),
	"^pactl subscribe",
}, function()
	-- Run emit_volume_info() with each line printed
	awful.spawn.with_line_callback(volume_script, {
		stdout = function(line)
			emit_volume_info()
		end,
	})
end)
