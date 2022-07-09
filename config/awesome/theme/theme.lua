--- ░▀█▀░█░█░█▀▀░█▄█░█▀▀
--- ░░█░░█▀█░█▀▀░█░█░█▀▀
--- ░░▀░░▀░▀░▀▀▀░▀░▀░▀▀▀

local gears = require("gears")
local gfs = require("gears.filesystem")
local themes_path = gfs.get_themes_dir()
local theme = dofile(themes_path .. "default/theme.lua")
local theme_assets = require("beautiful.theme_assets")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local helpers = require("helpers")
local icons = require("icons")

--- ░█▀█░█▀▀░█▀▀░▀█▀░█░█░█▀▀░▀█▀░▀█▀░█▀▀░░░█▀█░▀█▀░█▀▀░█░█░▀█▀
--- ░█▀█░█▀▀░▀▀█░░█░░█▀█░█▀▀░░█░░░█░░█░░░░░█░█░░█░░█░█░█▀█░░█░
--- ░▀░▀░▀▀▀░▀▀▀░░▀░░▀░▀░▀▀▀░░▀░░▀▀▀░▀▀▀░░░▀░▀░▀▀▀░▀▀▀░▀░▀░░▀░

--- Special
theme.xforeground = "#D9D7D6"
theme.darker_xbackground = "#000a0e"
theme.xbackground = "#061115"
theme.lighter_xbackground = "#0d181c"
theme.one_bg = "#131e22"
theme.one_bg2 = "#1c272b"
theme.one_bg3 = "#242f33"
theme.grey = "#313c40"
theme.grey_fg = "#3b464a"
theme.grey_fg2 = "#455054"
theme.light_grey = "#4f5a5e"
theme.transparent = "#00000000"

--- Black
theme.xcolor0 = "#1C252C"
theme.xcolor8 = "#484E5B"

--- Red
theme.xcolor1 = "#DF5B61"
theme.xcolor9 = "#F16269"

--- Green
theme.xcolor2 = "#78B892"
theme.xcolor10 = "#8CD7AA"

--- Yellow
theme.xcolor3 = "#DE8F78"
theme.xcolor11 = "#E9967E"

--- Blue
theme.xcolor4 = "#6791C9"
theme.xcolor12 = "#79AAEB"

--- Magenta
theme.xcolor5 = "#BC83E3"
theme.xcolor13 = "#C488EC"

--- Cyan
theme.xcolor6 = "#67AFC1"
theme.xcolor14 = "#7ACFE4"

--- White
theme.xcolor7 = "#D9D7D6"
theme.xcolor15 = "#E5E5E5"

--- ░█▀▀░█▀█░█▀█░▀█▀░█▀▀
--- ░█▀▀░█░█░█░█░░█░░▀▀█
--- ░▀░░░▀▀▀░▀░▀░░▀░░▀▀▀

--- Ui Fonts
theme.font_name = "Roboto "
theme.font = theme.font_name .. "Medium 10"

--- Icon Fonts
theme.icon_font = "Material Icons "

--- ░█▀▀░█▀█░█░░░█▀█░█▀▄░█▀▀
--- ░█░░░█░█░█░░░█░█░█▀▄░▀▀█
--- ░▀▀▀░▀▀▀░▀▀▀░▀▀▀░▀░▀░▀▀▀

--- Background Colors
theme.bg_normal = theme.xbackground
theme.bg_focus = theme.xbackground
theme.bg_urgent = theme.xbackground
theme.bg_minimize = theme.xbackground

--- Foreground Colors
theme.fg_normal = theme.xforeground
theme.fg_focus = theme.accent
theme.fg_urgent = theme.xcolor1
theme.fg_minimize = theme.xcolor0

--- Accent colors
function theme.random_accent_color()
	local accents = {
		theme.xcolor9,
		theme.xcolor10,
		theme.xcolor11,
		theme.xcolor12,
		theme.xcolor13,
		theme.xcolor14,
	}

	local i = math.random(1, #accents)
	return accents[i]
end

theme.accent = theme.xcolor4

--- UI events
theme.leave_event = transparent
theme.enter_event = "#ffffff" .. "10"
theme.press_event = "#ffffff" .. "15"
theme.release_event = "#ffffff" .. "10"

--- Widgets
theme.widget_bg = "#162026"

--- Titlebars
theme.titlebar_enabled = true
theme.titlebar_bg = theme.xbackground
theme.titlebar_fg = theme.xforeground

--- Wibar
theme.wibar_bg = "#0B161A"
theme.wibar_height = dpi(40)

--- Music
theme.music_bg = theme.xbackground
theme.music_bg_accent = theme.darker_xbackground
theme.music_accent = theme.lighter_xbackground

--- ░█░█░▀█▀░░░█▀▀░█░░░█▀▀░█▄█░█▀▀░█▀█░▀█▀░█▀▀
--- ░█░█░░█░░░░█▀▀░█░░░█▀▀░█░█░█▀▀░█░█░░█░░▀▀█
--- ░▀▀▀░▀▀▀░░░▀▀▀░▀▀▀░▀▀▀░▀░▀░▀▀▀░▀░▀░░▀░░▀▀▀

--- Wallpapers
theme.wallpaper = gears.surface.load_uncached(gfs.get_configuration_dir() .. "theme/assets/montereyNight.png")
--- theme.wallpaper = gears.surface.load_uncached(gfs.get_configuration_dir() .. "theme/assets/paperlikeXcanoopsy.png")

--- Image Assets
theme.pfp = gears.surface.load_uncached(gfs.get_configuration_dir() .. "theme/assets/pfp.png")
theme.music = gears.surface.load_uncached(gfs.get_configuration_dir() .. "theme/assets/music.png")

--- Layout
--- You can use your own layout icons like this:
theme.layout_floating = icons.floating
theme.layout_max = icons.max
theme.layout_tile = icons.tile
theme.layout_dwindle = icons.dwindle
theme.layout_centered = icons.centered
theme.layout_mstab = icons.mstab
theme.layout_equalarea = icons.equalarea
theme.layout_machi = icons.machi

--- Icon Theme
--- Define the icon theme for application icons. If not set then the icons
--- from /usr/share/icons and /usr/share/icons/hicolor will be used.
theme.icon_theme = "WhiteSur-dark"

--- Borders
theme.border_width = 0
theme.oof_border_width = 0
theme.border_color_marked = theme.titlebar_bg
theme.border_color_active = theme.titlebar_bg
theme.border_color_normal = theme.titlebar_bg
theme.border_color_new = theme.titlebar_bg
theme.border_color_urgent = theme.titlebar_bg
theme.border_color_floating = theme.titlebar_bg
theme.border_color_maximized = theme.titlebar_bg
theme.border_color_fullscreen = theme.titlebar_bg

--- Corner Radius
theme.border_radius = 12

--- Edge snap
theme.snap_bg = theme.xcolor8
theme.snap_shape = helpers.ui.rrect(0)

--- Main Menu
theme.main_menu_bg = theme.lighter_xbackground

--- Tooltip
theme.tooltip_bg = theme.lighter_xbackground
theme.tooltip_fg = theme.xforeground
theme.tooltip_font = theme.font_name .. "Regular 10"

--- Hotkeys Pop Up
theme.hotkeys_bg = theme.xbackground
theme.hotkeys_fg = theme.xforeground
theme.hotkeys_modifiers_fg = theme.xforeground
theme.hotkeys_font = theme.font_name .. "Medium 12"
theme.hotkeys_description_font = theme.font_name .. "Regular 10"
theme.hotkeys_shape = helpers.ui.rrect(theme.border_radius)
theme.hotkeys_group_margin = dpi(50)

--- Tag list
local taglist_square_size = dpi(0)
theme.taglist_squares_sel = theme_assets.taglist_squares_sel(taglist_square_size, theme.fg_normal)
theme.taglist_squares_unsel = theme_assets.taglist_squares_unsel(taglist_square_size, theme.fg_normal)

--- Tag preview
theme.tag_preview_widget_margin = dpi(10)
theme.tag_preview_widget_border_radius = theme.border_radius
theme.tag_preview_client_border_radius = theme.border_radius / 2
theme.tag_preview_client_opacity = 1
theme.tag_preview_client_bg = theme.wibar_bg
theme.tag_preview_client_border_color = theme.wibar_bg
theme.tag_preview_client_border_width = 0
theme.tag_preview_widget_bg = theme.wibar_bg
theme.tag_preview_widget_border_color = theme.wibar_bg
theme.tag_preview_widget_border_width = 0

--- Layout List
theme.layoutlist_shape_selected = helpers.ui.rrect(theme.border_radius)
theme.layoutlist_bg_selected = theme.widget_bg

--- Gaps
theme.useless_gap = dpi(2)

--- Systray
theme.systray_icon_size = dpi(20)
theme.systray_icon_spacing = dpi(10)
theme.bg_systray = theme.wibar_bg
--- theme.systray_max_rows = 2

--- Tabs
theme.mstab_bar_height = dpi(60)
theme.mstab_bar_padding = dpi(0)
theme.mstab_border_radius = dpi(6)
theme.mstab_bar_disable = true
theme.tabbar_disable = true
theme.tabbar_style = "modern"
theme.tabbar_bg_focus = theme.xbackground
theme.tabbar_bg_normal = theme.xcolor0
theme.tabbar_fg_focus = theme.xcolor0
theme.tabbar_fg_normal = theme.xcolor15
theme.tabbar_position = "bottom"
theme.tabbar_AA_radius = 0
theme.tabbar_size = 0
theme.mstab_bar_ontop = true

--- Notifications
theme.notification_spacing = dpi(4)
theme.notification_bg = theme.xbackground
theme.notification_bg_alt = theme.lighter_xbackground

--- Notif center
theme.notif_center_notifs_bg = theme.one_bg2
theme.notif_center_notifs_bg_alt = theme.one_bg3

--- Swallowing
theme.dont_swallow_classname_list = {
	"firefox",
	"gimp",
	"Google-chrome",
	"Thunar",
}

--- Layout Machi
theme.machi_switcher_border_color = theme.lighter_xbackground
theme.machi_switcher_border_opacity = 0.25
theme.machi_editor_border_color = theme.lighter_xbackground
theme.machi_editor_border_opacity = 0.25
theme.machi_editor_active_opacity = 0.25

return theme
