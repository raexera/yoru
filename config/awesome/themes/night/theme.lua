-- Standard awesome library
local gears = require("gears")
local gfs = require("gears.filesystem")

-- Theme handling library
local themes_path = gfs.get_themes_dir()
local theme = dofile(themes_path .. "default/theme.lua")
local theme_assets = require("beautiful.theme_assets")
local xresources = require("beautiful.xresources")
local xrdb = xresources.get_current_theme()

-- Helpers
local helpers = require("helpers")

-- Aesthetic Night Theme
---------------------------

-- Night Colorscheme
theme.xbackground = "#061115"
theme.xforeground = "#D9D7D6"
theme.xcolor0 = "#1C252C"
theme.xcolor1 = "#DF5B61"
theme.xcolor2 = "#78B892"
theme.xcolor3 = "#DE8F78"
theme.xcolor4 = "#6791C9"
theme.xcolor5 = "#BC83E3"
theme.xcolor6 = "#67AFC1"
theme.xcolor7 = "#D9D7D6"
theme.xcolor8 = "#484E5B"
theme.xcolor9 = "#F16269"
theme.xcolor10 = "#8CD7AA"
theme.xcolor11 = "#E9967E"
theme.xcolor12 = "#79AAEB"
theme.xcolor13 = "#C488EC"
theme.xcolor14 = "#7ACFE4"
theme.xcolor15 = "#E5E5E5"
theme.darker_bg = "#0A1419"
theme.lighter_bg = "#162026"
theme.dashboard_fg = "#666C79"
theme.transparent = "#00000000"

-- Wallpaper
theme.wallpaper = gfs.get_configuration_dir() .. "themes/assets/night.png"

-- PFP
theme.pfp = gears.surface.load_uncached(gfs.get_configuration_dir() .. "themes/assets/pfp.png")

-- Awesome Logo
theme.awesome_logo = gears.surface.load_uncached(gfs.get_configuration_dir() .. "icons/awesome_logo.svg")

-- Fonts
theme.font_name = "Iosevka "
theme.font = theme.font_name .. "Regular 8"
theme.icon_font_name = "Material Icons "
theme.icon_font = theme.icon_font_name .. "18"
theme.font_taglist = theme.icon_font_name .. "16"
theme.prompt_font = theme.font_name .. "Bold 10"

-- Background Colors
theme.bg_dark = theme.darker_bg
theme.bg_normal = theme.xbackground
theme.bg_focus = theme.xbackground
theme.bg_urgent = theme.xbackground
theme.bg_minimize = theme.xbackground
theme.bg_secondary = theme.darker_bg
theme.bg_accent = theme.lighter_bg

-- Accent colors
theme.accent = theme.xcolor4
theme.hover_effect = theme.accent .. "44"

-- Foreground Colors
theme.fg_normal = theme.xforeground
theme.fg_focus = theme.accent
theme.fg_urgent = theme.xcolor1
theme.fg_minimize = theme.xcolor0

-- Borders
theme.border_width = dpi(0)
theme.oof_border_width = dpi(0)
theme.border_normal = theme.darker_bg
theme.border_focus = theme.darker_bg
theme.widget_border_width = dpi(2)
theme.widget_border_color = theme.darker_bg

-- Radius
theme.border_radius = dpi(10)
theme.client_radius = theme.border_radius
theme.dashboard_radius = theme.border_radius
theme.widget_radius = theme.border_radius

-- Titlebars
theme.titlebar_enabled = true
theme.titlebar_bg = theme.xbackground
theme.titlebar_fg = theme.xforeground

-- Music
theme.music_bg = theme.xbackground
theme.music_bg_accent = theme.darker_bg
theme.music_accent = theme.lighter_bg

-- Pop up
theme.pop_size = dpi(190)
theme.pop_bg = theme.xbackground
theme.pop_vol_color = theme.accent
theme.pop_brightness_color = theme.accent
theme.pop_bar_bg = theme.accent .. "44"
theme.pop_fg = theme.xforeground
theme.pop_border_radius = theme.border_radius

-- Tooltip
theme.tooltip_bg = theme.darker_bg
theme.tooltip_widget_bg = theme.lighter_bg
theme.tooltip_height = dpi(270)
theme.tooltip_width = dpi(230)
theme.tooltip_border_radius = theme.border_radius
theme.tooltip_box_border_radius = theme.widget_radius

-- Battery Indicator
theme.battery_happy_color = theme.xcolor2
theme.battery_sad_color = theme.xcolor1
theme.battery_ok_color = theme.xcolor3
theme.battery_charging_color = theme.accent

-- Edge snap
theme.snap_bg = theme.xcolor8
theme.snap_shape = helpers.rrect(0)

-- Prompts
theme.prompt_bg = theme.transparent
theme.prompt_fg = theme.xforeground

-- Central Panel
theme.central_panel_bg = theme.darker_bg
theme.central_panel_radius = theme.border_radius

-- Dashboard
theme.dashboard_box_bg = theme.lighter_bg
theme.dashboard_box_fg = theme.dashboard_fg

-- Control center
theme.control_center_widget_radius = theme.border_radius
theme.control_center_widget_bg = theme.lighter_bg
theme.control_center_button_bg = theme.xbackground

-- Playerctl
theme.playerctl_ignore = { "firefox", "qutebrowser", "chromium", "brave" }
theme.playerctl_player = { "spotify", "mpd", "%any" }
theme.playerctl_update_on_activity = true
theme.playerctl_position_update_interval = 1

-- Mainmenu
theme.menu_font = theme.font_name .. "Medium 10"
theme.menu_height = dpi(30)
theme.menu_width = dpi(150)
theme.menu_bg_normal = theme.xbackground
theme.menu_bg_focus = theme.lighter_bg
theme.menu_fg_normal = theme.xforeground
theme.menu_fg_focus = theme.accent
theme.menu_border_width = dpi(0)
theme.menu_border_color = theme.xcolor0
theme.menu_submenu = "»  "
theme.menu_submenu_icon = nil

-- Hotkeys Pop Up
theme.hotkeys_bg = theme.xbackground
theme.hotkeys_fg = theme.xforeground
theme.hotkeys_modifiers_fg = theme.xforeground
theme.hotkeys_font = theme.font_name .. "Regular 11"
theme.hotkeys_description_font = theme.font_name .. "Regular 9"
theme.hotkeys_shape = helpers.rrect(theme.border_radius)
theme.hotkeys_group_margin = dpi(35)

-- Layout List
theme.layoutlist_border_color = theme.lighter_bg
theme.layoutlist_border_width = theme.border_width
theme.layoutlist_shape_selected = helpers.rrect(dpi(10))
theme.layoutlist_bg_selected = theme.lighter_bg

-- Recolor Layout icons:
theme = theme_assets.recolor_layout(theme, theme.xforeground)

-- Gaps
theme.useless_gap = dpi(5)

-- Wibar
theme.wibar_bg = theme.darker_bg
theme.wibar_widget_bg = theme.lighter_bg

-- Dock
theme.dock_bg = theme.wibar_bg
theme.dock_focused_bg = theme.lighter_bg
theme.dock_accent = theme.accent

-- Systray
theme.systray_icon_spacing = dpi(15)
theme.bg_systray = theme.wibar_bg
theme.systray_icon_size = dpi(15)
theme.systray_max_rows = 2

-- Tabs
theme.mstab_bar_height = dpi(60)
theme.mstab_bar_padding = dpi(0)
theme.mstab_border_radius = theme.border_radius
theme.tabbar_disable = true
theme.tabbar_style = "modern"
theme.tabbar_bg_focus = theme.lighter_bg
theme.tabbar_bg_normal = theme.darker_bg
theme.tabbar_fg_focus = theme.xforeground
theme.tabbar_fg_normal = theme.xcolor0
theme.tabbar_position = "bottom"
theme.tabbar_AA_radius = 0
theme.tabbar_size = 40
theme.mstab_bar_ontop = true

-- Notifications
theme.notification_spacing = dpi(20)
theme.notification_border_radius = theme.border_radius
theme.notification_border_width = dpi(0)

-- Notif center
theme.notif_center_radius = theme.border_radius
theme.notif_center_box_radius = theme.notif_center_radius / 2
theme.notif_center_notifs_bg = theme.lighter_bg
theme.notif_center_notifs_accent = theme.xcolor0

-- Swallowing
theme.dont_swallow_classname_list = {
	"firefox",
	"gimp",
	"Google-chrome",
	"Thunar",
}

-- Layout Machi
theme.machi_switcher_border_color = theme.darker_bg
theme.machi_switcher_border_opacity = 0.25
theme.machi_editor_border_color = theme.darker_bg
theme.machi_editor_border_opacity = 0.25
theme.machi_editor_active_opacity = 0.25

-- Tag Preview
theme.tag_preview_client_border_radius = dpi(5)
theme.tag_preview_client_opacity = 0.1
theme.tag_preview_client_bg = theme.xbackground
theme.tag_preview_client_border_color = theme.darker_bg
theme.tag_preview_client_border_width = theme.widget_border_width

theme.tag_preview_widget_border_radius = theme.border_radius
theme.tag_preview_widget_bg = theme.xbackground
theme.tag_preview_widget_border_color = theme.widget_border_color
theme.tag_preview_widget_border_width = theme.widget_border_width * 0
theme.tag_preview_widget_margin = dpi(10)

-- Task Preview
theme.task_preview_widget_border_radius = theme.border_radius
theme.task_preview_widget_bg = theme.xbackground
theme.task_preview_widget_border_color = theme.widget_border_color
theme.task_preview_widget_border_width = theme.widget_border_width * 0
theme.task_preview_widget_margin = dpi(15)

theme.fade_duration = 250

return theme
