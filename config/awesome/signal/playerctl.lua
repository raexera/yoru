-- Notification handling library
local naughty = require("naughty")

-- Bling
local bling = require("module.bling")

bling.signal.playerctl.lib {
    ignore = {"firefox", "qutebrowser", "chromium", "brave"},
    update_on_activity = true
}

awesome.connect_signal("bling::playerctl::title_artist_album",
    function(title, artist, art_path)
    naughty.notification({title = "Now Playing", text = artist .. " - " .. title, image = art_path})
end)
