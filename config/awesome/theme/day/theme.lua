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

-- Beautiful Day Theme
--------------------------

-- colorscheme
local color_palette = {
	rosewater = "#DC907F",
	flamingo = "#DD7878",
	pink = "#EC83D0",
	mauve = "#822FEE",
	red = "#BB0D33",
	maroon = "#E63B4A",
	peach = "#FE640B",
	yellow = "#E49320",
	green = "#40A02B",
	teal = "#179299",
	sky = "#04A5E5",
	blue = "#1D65F5",
	sapphire = "#209FB5",
	lavender = "#7287FD",
	white = "#575279",
	gray2 = "#6C6789",
	gray1 = "#817C98",
	gray0 = "#9691A8",
	black0 = "#D0CDD4",
	black1 = "#ECEBEB",
	black2 = "#FBF8F4",
	black3 = "#E1DCE0",
	black4 = "#BEBAC6",
	black5 = "#AAA6B7",
}

theme.xbackground = color_palette.black2
theme.xforeground = color_palette.white
theme.xcolor0 = color_palette.gray0
theme.xcolor1 = color_palette.red
theme.xcolor2 = color_palette.green
theme.xcolor3 = color_palette.yellow
theme.xcolor4 = color_palette.blue
theme.xcolor5 = color_palette.mauve
theme.xcolor6 = color_palette.pink
theme.xcolor7 = color_palette.white
theme.xcolor8 = color_palette.gray1
theme.xcolor9 = color_palette.maroon
theme.xcolor10 = color_palette.teal
theme.xcolor11 = color_palette.peach
theme.xcolor12 = color_palette.sky
theme.xcolor13 = color_palette.lavender
theme.xcolor14 = color_palette.flamingo
theme.xcolor15 = color_palette.white
theme.darker_bg = color_palette.black1
theme.lighter_bg = color_palette.black3
theme.dashboard_fg = color_palette.gray2
theme.transparent = "#00000000"

-- PFP
theme.pfp = gears.surface.load_uncached(gfs.get_configuration_dir() .. "theme/assets/pfp.png")

-- Awesome Logo
theme.awesome_logo = gears.surface.load_uncached(gfs.get_configuration_dir() .. "theme/assets/icons/awesome_logo.svg")

-- Fonts
theme.font_name = "Iosevka Nerd Font Mono "
theme.font = theme.font_name .. "8"
theme.icon_font_name = "Material Design Icons Desktop "
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
theme.accent = theme.xcolor6
theme.hover_effect = theme.accent .. "44"

-- Foreground Colors
theme.fg_normal = theme.xforeground
theme.fg_focus = theme.xforeground
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

-- Pop up notifications
theme.pop_size = dpi(190)
theme.pop_bg = theme.xbackground
theme.pop_vol_color = theme.accent
theme.pop_brightness_color = theme.accent
theme.pop_bar_bg = theme.accent .. "44"
theme.pop_fg = theme.xforeground
theme.pop_border_radius = theme.border_radius

-- Tooltip
theme.tooltip_bg = theme.darker_bg
theme.tooltip_widget_bg = theme.xbackground
theme.tooltip_height = dpi(245)
theme.tooltip_width = dpi(200)
theme.tooltip_gap = dpi(10)
theme.tooltip_box_margin = dpi(10)
theme.tooltip_border_radius = theme.border_radius
theme.tooltip_box_border_radius = theme.widget_radius

-- Edge snap
theme.snap_bg = theme.xcolor8
theme.snap_shape = helpers.rrect(0)

-- Prompts
theme.prompt_bg = theme.transparent
theme.prompt_fg = theme.xforeground

-- Dashboard
theme.dashboard_bg = theme.darker_bg
theme.dashboard_box_bg = theme.xbackground
theme.dashboard_box_fg = theme.dashboard_fg

-- Control center
theme.control_center_radius = dpi(20)
theme.control_center_widget_radius = theme.border_radius
theme.control_center_bg = theme.darker_bg
theme.control_center_widget_bg = theme.xbackground
theme.control_center_button_bg = theme.lighter_bg

-- Playerctl
theme.playerctl_ignore = { "firefox", "qutebrowser", "chromium", "brave" }
theme.playerctl_player = { "spotify", "mpd", "%any" }
theme.playerctl_update_on_activity = true
theme.playerctl_position_update_interval = 1

-- Mainmenu
theme.menu_font = theme.font_name .. "medium 10"
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
theme.hotkeys_font = theme.font_name .. "11"
theme.hotkeys_description_font = theme.font_name .. "9"
theme.hotkeys_shape = helpers.rrect(theme.border_radius)
theme.hotkeys_group_margin = dpi(40)

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
theme.wibar_widget_bg = theme.xbackground

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
theme.notif_center_notifs_bg = theme.xbackground
theme.notif_center_notifs_bg_accent = theme.darker_bg
theme.notif_center_notifs_accent = theme.lighter_bg

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
theme.tag_preview_client_border_radius = dpi(6)
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
theme.task_preview_widget_border_radius = dpi(10)
theme.task_preview_widget_bg = theme.xbackground
theme.task_preview_widget_border_color = theme.widget_border_color
theme.task_preview_widget_border_width = theme.widget_border_width * 0
theme.task_preview_widget_margin = dpi(15)

theme.fade_duration = 250

return theme
