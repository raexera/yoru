-- Standard Awesome Library
local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")

-- Bling
local bling = require("module.bling")
bling.module.flash_focus.enable()

-- Autostart
awful.spawn.with_shell("~/.config/awesome/configuration/autorun.sh")

-- Default Applications
terminal = "alacritty"
browser = "firefox"
filemanager = "thunar"
vscode = "code"
editor = os.getenv("EDITOR") or "nvim"
editor_cmd = terminal .. " -e " .. editor
discord = "discord"
launcher = "rofi -show drun"

-- Weather API
openweathermap_key = "eaf60d2e3c3652df3ca54365b46c236e"
openweathermap_city_id = "1650357"
weather_units = "metric"

-- Global Vars
screen_width = awful.screen.focused().geometry.width
screen_height = awful.screen.focused().geometry.height

-- Default modkey.
modkey = "Mod4"
altkey = "Mod1"
shift = "Shift"
ctrl = "Control"

-- Set Wallpaper
gears.wallpaper.maximized(beautiful.wallpaper, s, false, nil)

-- bling.module.tiled_wallpaper("", s, {
--         fg = beautiful.xcolor8,
--         bg = beautiful.xbackground,
--         offset_y = 20,
--         offset_x = 20,
--         font = "Iosevka",
--         font_size = 13,
--         padding = 100,
--         zickzack = true
-- })

-- Get Bling Config
require("configuration.bling")

-- Get Keybinds
require("configuration.keys")

-- Get Rules
require("configuration.ruled")

-- Layouts and Window Stuff
require("configuration.window")

-- Scratchpad
require("configuration.scratchpad")
