pcall(require, "luarocks.loader")
--[[
 _____ __ _ __ _____ _____ _____ _______ _____
|     |  | |  |  ___|  ___|     |       |  ___|
|  -  |  | |  |  ___|___  |  |  |  | |  |  ___|
|__|__|_______|_____|_____|_____|__|_|__|_____|

============== @author rxyhn ==================
======== https://github.com/rxyhn =============
--]]

-- 🎨 Themes
themes = {
	"day", -- [1] 🌕 Beautiful Light Colorscheme
	"night", -- [2] 🌑 Aesthetic Dark Colorscheme
}
theme = themes[1]
-- ============================================
-- 🌊 Default Applications
terminal = "alacritty"
editor = terminal .. " -e " .. "nvim"
vscode = "code"
browser = "firefox"
web_search_cmd = "xdg-open https://duckduckgo.com/?q="
file_manager = "nautilus"
music_client = terminal .. " --class music -e ncmpcpp"

-- 🌏 Weather API
openweathermap_key = "" -- API Key
openweathermap_city_id = "" -- City ID
weather_units = "metric"
-- ============================================
-- 📚 Library
local gfs = require("gears.filesystem")
local awful = require("awful")
local beautiful = require("beautiful")
dpi = beautiful.xresources.apply_dpi
-- ============================================
-- 🌟 Load theme
local theme_dir = gfs.get_configuration_dir() .. "themes/" .. theme .. "/"
beautiful.init(theme_dir .. "theme.lua")
-- ============================================
-- 🖥 Get screen geometry
screen_width = awful.screen.focused().geometry.width
screen_height = awful.screen.focused().geometry.height
-- ============================================
-- 🚀 Launch Autostart
awful.spawn.with_shell(gfs.get_configuration_dir() .. "configuration/autostart")
-- ============================================
-- 🤖 Import Configuration & module
require("configuration")
require("module")
-- ============================================
-- ✨ Import Daemons, UI & Widgets
require("signal")
require("ui")
-- ============================================
-- 🗑 Garbage Collector Settings
collectgarbage("setpause", 110)
collectgarbage("setstepmul", 1000)
