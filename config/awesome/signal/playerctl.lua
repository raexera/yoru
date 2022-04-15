-- Notification handling library
local naughty = require("naughty")

-- Playerctl
local playerctl = require("module.bling").signal.playerctl.lib()

playerctl:connect_signal("metadata", function(_, title, artist, album_path, album, new, player_name)
	if new == true then
		naughty.notify({
			app_name = "Music",
			title = title,
			text = artist,
			image = album_path,
		})
	end
end)
