local naughty = require("naughty")

Playerctl:connect_signal("metadata",
                       function(title, artist, album_path, album, new, player_name)
    if new == true then
        naughty.notify({title = title, text = artist, image = album_path})
    end
end)
