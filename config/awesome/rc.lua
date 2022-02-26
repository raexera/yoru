--[[
 _____ __ _ __ _____ _____ _____ _______ _____
|     |  | |  |  ___|  ___|     |       |  ___|
|  -  |  | |  |  ___|___  |  |  |  | |  |  ___|
|__|__|_______|_____|_____|_____|__|_|__|_____|

--]]

pcall(require, "luarocks.loader")

-- Standard awesome library
local gfs = require("gears.filesystem")
local awful = require("awful")
require("awful.autofocus")

-- Theme handling library
local beautiful = require("beautiful")

-- Notification library
local naughty = require("naughty")

local hotkeys_popup = require("awful.hotkeys_popup")
require("awful.hotkeys_popup.keys")

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

-- Initialize Theme
beautiful.init(gfs.get_configuration_dir() .. "theme/theme.lua")

-- Import Configuration
require("configuration")

-- Screen Padding and Tags
screen.connect_signal("request::desktop_decoration", function(s)
    -- Screen padding
    screen[s].padding = {left = 0, right = 0, top = 0, bottom = 0}
    -- Each screen has its own tag table.
    awful.tag({"1", "2", "3", "4", "5"}, s, awful.layout.layouts[1])
end)

-- Import Daemons and Widgets
require("signal")
require("ui")

-- Create a launcher widget and a main menu
local awesomemenu = {
    {
        "Hotkeys",
        function() hotkeys_popup.show_help(nil, awful.screen.focused()) end
    }, 
    {"Restart", awesome.restart}, 
    {"Quit", function() awesome.quit() end}
}

local powermenu = {
    {"Power OFF", function() awful.spawn.with_shell("systemctl poweroff") end},
    {"Reboot", function() awful.spawn.with_shell("systemctl reboot") end},
    {"Suspend", function() 
        lock_screen_show()
        awful.spawn.with_shell("systemctl suspend")  
    end},
    {"Lock Screen", function() lock_screen_show() end}
}

local appmenu = {
    {"Terminal", terminal}, 
    {"Editor", vscode},
    {"File Manager", filemanager},
    {"Browser", browser},
    {"Discord", discord}
}

local mymainmenu = awful.menu({
    items = {
        {"AwesomeWM", awesomemenu, beautiful.awesome_logo}, {"Apps", appmenu}, {"Powermenu", powermenu}
    }
})

awful.mouse.append_global_mousebindings({
    awful.button({}, 3, function() mymainmenu:toggle() end)
})

-- Garbage Collector Settings
collectgarbage("setpause", 110)
collectgarbage("setstepmul", 1000)

-- EOF ------------------------------------------------------------------------
