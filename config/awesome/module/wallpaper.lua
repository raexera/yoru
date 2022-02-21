-- Credits to https://github.com/WillPower3309/awesome-widgets/blob/master/wallpaper-blur.lua
-- @author William McKinnon
-- I tried implementing this with `gears.wallpaper` but the latency was just too much, so feh is preferable here
local awful = require("awful")
local gears = require("gears")
local naughty = require("naughty")
local beautiful = require("beautiful")

local blurred = false;

local wallpaper = beautiful.wallpaper
local blurredWallpaper = beautiful.wallpaper_blur

awful.spawn.with_shell("feh --bg-fill " .. wallpaper)

local function exists(file)
    local ok, err, code = os.rename(file, file)
    if not ok then if code == 13 then return true end end
    return ok, err
end

if not exists(blurredWallpaper) then
    naughty.notify({
        preset = naughty.config.presets.normal,
        title = 'Wallpaper',
        text = 'Generating blurred wallpaper...'
    })

    -- uses image magick to create a blurred version of the wallpaper
    awful.spawn.with_shell(
        "convert -filter Gaussian -blur 0x20 " .. wallpaper .. " " ..
            blurredWallpaper)

    naughty.notify({
        preset = naughty.config.presets.normal,
        title = 'Wallpaper',
        text = 'Blurred wallpaper generated!'
    })
end

-- changes to blurred wallpaper
local function blur()
    if not blurred then
        awful.spawn.with_shell("feh --bg-fill " .. blurredWallpaper)
        blurred = true
    end
end

-- changes to normal wallpaper
local function unblur()
    if blurred then
        awful.spawn.with_shell("feh --bg-fill " .. wallpaper)
        blurred = false
    end
end

-- blur / unblur on tag change
tag.connect_signal('property::selected', function(t)
    -- if tag has clients
    for _ in pairs(t:clients()) do
        blur()
        return
    end
    -- if tag has no clients
    unblur()
end)

-- check if wallpaper should be blurred on client open
client.connect_signal("manage", function(c) blur() end)

-- check if wallpaper should be unblurred on client close
client.connect_signal("unmanage", function(c)
    local t = awful.screen.focused().selected_tag
    -- check if any open clients
    for _ in pairs(t:clients()) do return end
    -- unblur if no open clients
    unblur()
end)
