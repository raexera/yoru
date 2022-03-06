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

-- Theme handling library
local beautiful = require("beautiful")
beautiful.init(gfs.get_configuration_dir() .. "theme/theme.lua")

-- Default Applications
terminal = "alacritty"
browser = "firefox"
filemanager = "nautilus"
vscode = "code"
editor = os.getenv("EDITOR") or "nvim"
editor_cmd = terminal .. " -e " .. editor
discord = "discord"
launcher = "rofi -show drun"

-- Weather API
openweathermap_key = "" -- API Key
openweathermap_city_id = "" -- City ID
weather_units = "metric" -- Unit

-- Global Vars
screen_width = awful.screen.focused().geometry.width
screen_height = awful.screen.focused().geometry.height

-- Autostart
local autostart = require("configuration.autostart")

-- Import Configuration
require("configuration")

-- Import Daemons and Widgets
require("signal")
require("ui")

-- Garbage Collector Settings
collectgarbage("setpause", 110)
collectgarbage("setstepmul", 1000)

-- EOF ------------------------------------------------------------------------
