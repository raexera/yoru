-- Standard awesome library
local gears = require("gears")
local naughty = require("naughty")
local awful = require("awful")
require("awful.autofocus")

-- Theme handling library
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
naughty.connect_signal("request::display_error", function(message, startup)
    naughty.notification {
        urgency = "critical",
        title = "Oops, an error happened" ..
            (startup and " during startup!" or "!"),
        message = message
    }
end)

-- set wallpapers
awful.screen.connect_for_each_screen(function(s)
    gears.wallpaper.maximized(beautiful.wallpaper, s, false, nil)

end)

-- Screen Padding and Tags
screen.connect_signal("request::desktop_decoration", function(s)
    -- Screen padding
    screen[s].padding = {left = 0, right = 0, top = 0, bottom = 0}
    -- Each screen has its own tag table.
    awful.tag({"1", "2", "3", "4", "5"}, s, awful.layout.layouts[1])
end)

