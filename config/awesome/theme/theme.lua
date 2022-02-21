-- Standard awesome library
local gears = require("gears")
local gfs = require("gears.filesystem")

-- Theme handling library
local themes_path = gfs.get_themes_dir()
local theme = dofile(themes_path .. "default/theme.lua")
local theme_assets = require("beautiful.theme_assets")
local xresources = require("beautiful.xresources")
local xrdb = xresources.get_current_theme()
local dpi = xresources.apply_dpi
local helpers = require("helpers")


-- Theme
----------

-- Load ~/.Xresources colors
theme.xbackground = xrdb.background 
theme.xforeground = xrdb.foreground 
theme.xcolor0 = xrdb.color0 
theme.xcolor1 = xrdb.color1 
theme.xcolor2 = xrdb.color2 
theme.xcolor3 = xrdb.color3 
theme.xcolor4 = xrdb.color4 
theme.xcolor5 = xrdb.color5 
theme.xcolor6 = xrdb.color6 
theme.xcolor7 = xrdb.color7 
theme.xcolor8 = xrdb.color8 
theme.xcolor9 = xrdb.color9 
theme.xcolor10 = xrdb.color10 
theme.xcolor11 = xrdb.color11 
theme.xcolor12 = xrdb.color12 
theme.xcolor13 = xrdb.color13 
theme.xcolor14 = xrdb.color14 
theme.xcolor15 = xrdb.color15 
theme.darker_bg = "#0a1419"
theme.lighter_bg = "#162026"
theme.dash_fg = "#666c79"

-- Titlebar
local icon_path = gfs.get_configuration_dir() .. "assets/icons/"
local titlebar_icon_dir = icon_path .. "titlebar/"

-- PFP
theme.pfp = gears.surface.load_uncached(gfs.get_configuration_dir() .. "assets/images/pfp.png")

-- Wallpaper
theme.wallpaper = gears.surface.load_uncached(gfs.get_configuration_dir() .. "assets/images/bg.png")

-- Awesome Logo
theme.awesome_logo = gears.surface.load_uncached(gfs.get_configuration_dir() .. "assets/icons/awesome.png")

-- Notifications icon
theme.notification_icon = gears.surface.load_uncached(gfs.get_configuration_dir() .. "assets/icons/notification.png")

-- Fonts
theme.font_name = "Iosevka "
theme.font = theme.font_name .. "8"
theme.icon_font_name = "Material Icons "
theme.icon_font = theme.icon_font_name .. "18"
theme.font_taglist = theme.icon_font_name .. "13"

-- Background Colors
theme.bg_dark = theme.darker_bg
theme.bg_normal = theme.xbackground
theme.bg_focus = theme.xcolor0
theme.bg_urgent = theme.xcolor8
theme.bg_minimize = theme.xcolor8

-- Foreground Colors
theme.fg_normal = theme.xforeground
theme.fg_focus = theme.xcolor4
theme.fg_urgent = theme.xcolor3
theme.fg_minimize = theme.xcolor8
theme.button_close = theme.xcolor1

-- Borders
theme.border_width = dpi(0)
theme.oof_border_width = dpi(0)
theme.border_normal = theme.xbackground
theme.border_focus = theme.xbackground
theme.border_radius = dpi(3)
theme.client_radius = dpi(3)
theme.widget_border_width = dpi(3)
theme.widget_border_color = theme.lighter_bg

-- Taglist
-- Generate taglist squares:
local taglist_square_size = dpi(0)
theme.taglist_squares_sel = theme_assets.taglist_squares_sel(taglist_square_size, theme.fg_normal)
theme.taglist_squares_unsel = theme_assets.taglist_squares_unsel(taglist_square_size, theme.fg_normal)
theme.taglist_font = theme.font_taglist
theme.taglist_bg = theme.wibar_bg
theme.taglist_bg_focus = theme.lighter_bg
theme.taglist_fg_focus = theme.xcolor3
theme.taglist_bg_urgent = theme.wibar_bg
theme.taglist_fg_urgent = theme.xcolor6
theme.taglist_bg_occupied = theme.wibar_bg
theme.taglist_fg_occupied = theme.xcolor6
theme.taglist_bg_empty = theme.wibar_bg
theme.taglist_fg_empty = theme.xcolor8
theme.taglist_bg_volatile = transparent
theme.taglist_fg_volatile = theme.xcolor11
theme.taglist_disable_icon = true

theme.taglist_shape_focus = helpers.rrect(theme.border_radius)
theme.taglist_shape_empty = helpers.rrect(theme.border_radius)
theme.taglist_shape = helpers.rrect(theme.border_radius)
theme.taglist_shape_urgent = helpers.rrect(theme.border_radius)
theme.taglist_shape_volatile = helpers.rrect(theme.border_radius)


-- Tasklist
theme.tasklist_font = theme.font
theme.tasklist_plain_task_name = true
theme.tasklist_bg_focus = theme.lighter_bg
theme.tasklist_fg_focus = theme.xcolor6
theme.tasklist_bg_minimize = theme.xcolor0 .. 55
theme.tasklist_fg_minimize = theme.xforeground .. 55
theme.tasklist_bg_normal = theme.darker_bg
theme.tasklist_fg_normal = theme.xforeground
theme.tasklist_disable_task_name = false
theme.tasklist_disable_icon = true
theme.tasklist_bg_urgent = theme.xcolor0
theme.tasklist_fg_urgent = theme.xcolor1
theme.tasklist_align = "center"

-- Titlebars
theme.titlebars_enabled = true
theme.titlebar_bg_focus = theme.darker_bg
theme.titlebar_bg_normal = theme.darker_bg
theme.titlebar_fg_focus = theme.xbackground
theme.titlebar_fg_normal = theme.xbackground
theme.titlebar_size = dpi(30)
theme.titlebar_position = "left"

theme.titlebar_close_button_normal = titlebar_icon_dir .. "default.svg"
theme.titlebar_close_button_focus  = titlebar_icon_dir .. "close.svg"
theme.titlebar_minimize_button_normal = titlebar_icon_dir .. "default.svg"
theme.titlebar_minimize_button_focus  = titlebar_icon_dir .. "minimize.svg"
theme.titlebar_maximized_button_normal_inactive = titlebar_icon_dir .. "default.svg"
theme.titlebar_maximized_button_focus_inactive  = titlebar_icon_dir .. "maximized.svg"
theme.titlebar_maximized_button_normal_active = titlebar_icon_dir .. "default.svg"
theme.titlebar_maximized_button_focus_active  = titlebar_icon_dir .. "maximized.svg"


-- Edge snap
theme.snap_bg = theme.xcolor8
theme.snap_shape = helpers.rrect(0)

-- Prompts
theme.prompt_bg = transparent
theme.prompt_fg = theme.xforeground

-- Dashboard
theme.dash_width = dpi(300)
theme.dash_box_bg = theme.lighter_bg
theme.dash_box_fg = theme.dash_fg

-- Tooltips
theme.tooltip_bg = theme.xbackground
theme.tooltip_fg = theme.xforeground
theme.tooltip_font = theme.font_name .. "10"
theme.tooltip_border_width = 0
theme.tooltip_opacity = 1
theme.tooltip_align = "top"

-- Menu
theme.menu_font = theme.font
theme.menu_bg_focus = theme.lighter_bg
theme.menu_fg_focus = theme.xforeground
theme.menu_bg_normal = theme.xbackground
theme.menu_fg_normal = theme.xforeground
theme.menu_submenu_icon = gears.filesystem.get_configuration_dir() .. "assets/icons/submenu.png"
theme.menu_height = dpi(20)
theme.menu_width = dpi(130)
theme.menu_border_color = theme.xcolor8
theme.menu_border_width = theme.border_width / 2

-- Hotkeys Pop Up
theme.hotkeys_font = theme.font
theme.hotkeys_border_color = theme.lighter_bg
theme.hotkeys_group_margin = dpi(40)
theme.hotkeys_shape = helpers.rrect(5)

-- Layout List
theme.layoutlist_border_color = theme.lighter_bg
theme.layoutlist_border_width = theme.border_width
theme.layoutlist_shape_selected = helpers.rrect(3)
theme.layoutlist_bg_selected = theme.lighter_bg

-- Recolor Layout icons:
theme = theme_assets.recolor_layout(theme, theme.xforeground)

-- Gaps
theme.useless_gap = dpi(5)

-- Exit Screen
theme.exit_screen_fg = theme.xforeground
theme.exit_screen_bg = theme.xbackground

-- Wibar
theme.wibar_height = (dpi(42) + theme.widget_border_width) * 0
theme.wibar_width = dpi(42) + theme.widget_border_width
theme.wibar_margin = dpi(15)
theme.wibar_spacing = dpi(15)
theme.wibar_bg = theme.xbackground
theme.wibar_bg_secondary = theme.lighter_bg
theme.wibar_position = "left"

-- Tabs
theme.mstab_bar_height = dpi(60)
theme.mstab_bar_padding = dpi(0)
theme.mstab_border_radius = dpi(6)
theme.tabbar_disable = true
theme.tabbar_style = "modern"
theme.tabbar_bg_focus = theme.xbackground
theme.tabbar_bg_normal = theme.xcolor0
theme.tabbar_fg_focus = theme.xcolor0
theme.tabbar_fg_normal = theme.xcolor15
theme.tabbar_position = "bottom"
theme.tabbar_AA_radius = 0
theme.tabbar_size = 40
theme.mstab_bar_ontop = true

-- Notifications
theme.notification_spacing = 19
theme.notification_border_radius = dpi(6)
theme.notification_border_width = dpi(0)

-- Swallowing
theme.dont_swallow_classname_list = {
    "firefox", "gimp", "Google-chrome", "Thunar"
}

-- Layout Machi
theme.machi_switcher_border_color = theme.lighter_bg
theme.machi_switcher_border_opacity = 0.25
theme.machi_editor_border_color = theme.lighter_bg
theme.machi_editor_border_opacity = 0.25
theme.machi_editor_active_opacity = 0.25

-- Tag Preview
theme.tag_preview_widget_border_radius = theme.border_radius
theme.tag_preview_client_border_radius = theme.border_radius
theme.tag_preview_client_opacity = 0.1
theme.tag_preview_client_bg = theme.xbackground
theme.tag_preview_client_border_color = theme.lighter_bg
theme.tag_preview_client_border_width = theme.widget_border_width
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
