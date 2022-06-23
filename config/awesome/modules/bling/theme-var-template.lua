--[[ Bling theme variables template

This file has all theme variables of the bling module.
Every variable has a small comment on what it does.
You might just want to copy that whole part into your theme.lua and start adjusting from there.

--]]
-- LuaFormatter off
-- window swallowing
theme.dont_swallow_classname_list = { "firefox", "Gimp" } -- list of class names that should not be swallowed
theme.dont_swallow_filter_activated = true -- whether the filter above should be active

-- flash focus
theme.flash_focus_start_opacity = 0.6 -- the starting opacity
theme.flash_focus_step = 0.01 -- the step of animation

-- playerctl signal
theme.playerctl_backend = "playerctl_cli" -- backend to use
theme.playerctl_ignore = {} -- list of players to be ignored
theme.playerctl_player = {} -- list of players to be used in priority order
theme.playerctl_update_on_activity = true -- whether to prioritize the most recently active players or not
theme.playerctl_position_update_interval = 1 -- the update interval for fetching the position from playerctl

-- tabbed
theme.tabbed_spawn_in_tab = false -- whether a new client should spawn into the focused tabbing container

-- tabbar general
theme.tabbar_disable = false -- disable the tab bar entirely
theme.tabbar_ontop = false
theme.tabbar_radius = 0 -- border radius of the tabbar
theme.tabbar_style = "default" -- style of the tabbar ("default", "boxes" or "modern")
theme.tabbar_font = "Sans 11" -- font of the tabbar
theme.tabbar_size = 40 -- size of the tabbar
theme.tabbar_position = "top" -- position of the tabbar
theme.tabbar_bg_normal = "#000000" -- background color of the focused client on the tabbar
theme.tabbar_fg_normal = "#ffffff" -- foreground color of the focused client on the tabbar
theme.tabbar_bg_focus = "#1A2026" -- background color of unfocused clients on the tabbar
theme.tabbar_fg_focus = "#ff0000" -- foreground color of unfocused clients on the tabbar
theme.tabbar_bg_focus_inactive = nil -- background color of the focused client on the tabbar when inactive
theme.tabbar_fg_focus_inactive = nil -- foreground color of the focused client on the tabbar when inactive
theme.tabbar_bg_normal_inactive = nil -- background color of unfocused clients on the tabbar when inactive
theme.tabbar_fg_normal_inactive = nil -- foreground color of unfocused clients on the tabbar when inactive

-- mstab
theme.mstab_bar_disable = false -- disable the tabbar
theme.mstab_bar_ontop = false -- whether you want to allow the bar to be ontop of clients
theme.mstab_dont_resize_slaves = false -- whether the tabbed stack windows should be smaller than the
-- currently focused stack window (set it to true if you use
-- transparent terminals. False if you use shadows on solid ones
theme.mstab_bar_padding = "default" -- how much padding there should be between clients and your tabbar
-- by default it will adjust based on your useless gaps.
-- If you want a custom value. Set it to the number of pixels (int)
theme.mstab_border_radius = 0 -- border radius of the tabbar
theme.mstab_bar_height = 40 -- height of the tabbar
theme.mstab_tabbar_position = "top" -- position of the tabbar (mstab currently does not support left,right)
theme.mstab_tabbar_style = "default" -- style of the tabbar ("default", "boxes" or "modern")
-- defaults to the tabbar_style so only change if you want a
-- different style for mstab and tabbed

-- the following variables are currently only for the "modern" tabbar style
theme.tabbar_color_close = "#f9929b" -- changes the color of the close button
theme.tabbar_color_min = "#fbdf90" -- changes the color of the minimize button
theme.tabbar_color_float = "#ccaced" -- changes the color of the float button

-- tag preview widget
theme.tag_preview_widget_border_radius = 0 -- Border radius of the widget (With AA)
theme.tag_preview_client_border_radius = 0 -- Border radius of each client in the widget (With AA)
theme.tag_preview_client_opacity = 0.5 -- Opacity of each client
theme.tag_preview_client_bg = "#000000" -- The bg color of each client
theme.tag_preview_client_border_color = "#ffffff" -- The border color of each client
theme.tag_preview_client_border_width = 3 -- The border width of each client
theme.tag_preview_widget_bg = "#000000" -- The bg color of the widget
theme.tag_preview_widget_border_color = "#ffffff" -- The border color of the widget
theme.tag_preview_widget_border_width = 3 -- The border width of the widget
theme.tag_preview_widget_margin = 0 -- The margin of the widget

-- task preview widget
theme.task_preview_widget_border_radius = 0 -- Border radius of the widget (With AA)
theme.task_preview_widget_bg = "#000000" -- The bg color of the widget
theme.task_preview_widget_border_color = "#ffffff" -- The border color of the widget
theme.task_preview_widget_border_width = 3 -- The border width of the widget
theme.task_preview_widget_margin = 0 -- The margin of the widget

-- window switcher
theme.window_switcher_widget_bg = "#000000" -- The bg color of the widget
theme.window_switcher_widget_border_width = 3 -- The border width of the widget
theme.window_switcher_widget_border_radius = 0 -- The border radius of the widget
theme.window_switcher_widget_border_color = "#ffffff" -- The border color of the widget
theme.window_switcher_clients_spacing = 20 -- The space between each client item
theme.window_switcher_client_icon_horizontal_spacing = 5 -- The space between client icon and text
theme.window_switcher_client_width = 150 -- The width of one client widget
theme.window_switcher_client_height = 250 -- The height of one client widget
theme.window_switcher_client_margins = 10 -- The margin between the content and the border of the widget
theme.window_switcher_thumbnail_margins = 10 -- The margin between one client thumbnail and the rest of the widget
theme.thumbnail_scale = false -- If set to true, the thumbnails fit policy will be set to "fit" instead of "auto"
theme.window_switcher_name_margins = 10 -- The margin of one clients title to the rest of the widget
theme.window_switcher_name_valign = "center" -- How to vertically align one clients title
theme.window_switcher_name_forced_width = 200 -- The width of one title
theme.window_switcher_name_font = "Sans 11" -- The font of all titles
theme.window_switcher_name_normal_color = "#ffffff" -- The color of one title if the client is unfocused
theme.window_switcher_name_focus_color = "#ff0000" -- The color of one title if the client is focused
theme.window_switcher_icon_valign = "center" -- How to vertically align the one icon
theme.window_switcher_icon_width = 40 -- The width of one icon

-- LuaFormatter on
