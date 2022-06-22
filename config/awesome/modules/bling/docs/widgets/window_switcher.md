## 🎨 Window Switcher <!-- {docsify-ignore} -->

A popup with client previews that allows you to switch clients similar to the alt-tab menu in MacOS, GNOME, and Windows.

![](https://user-images.githubusercontent.com/70270606/133311802-8aef1012-346f-4f4c-843d-10d9de54ffeb.png)

*image by [No37](https://github.com/Nooo37)*

### Usage

To enable:

```lua
bling.widget.window_switcher.enable {
    type = "thumbnail", -- set to anything other than "thumbnail" to disable client previews

    -- keybindings (the examples provided are also the default if kept unset)
    hide_window_switcher_key = "Escape", -- The key on which to close the popup
    minimize_key = "n",                  -- The key on which to minimize the selected client
    unminimize_key = "N",                -- The key on which to unminimize all clients
    kill_client_key = "q",               -- The key on which to close the selected client
    cycle_key = "Tab",                   -- The key on which to cycle through all clients
    previous_key = "Left",               -- The key on which to select the previous client
    next_key = "Right",                  -- The key on which to select the next client
    vim_previous_key = "h",              -- Alternative key on which to select the previous client
    vim_next_key = "l",                  -- Alternative key on which to select the next client

    cycleClientsByIdx = awful.client.focus.byidx,               -- The function to cycle the clients
    filterClients = awful.widget.tasklist.filter.currenttags,   -- The function to filter the viewed clients
}
```

To run the window swicher you have to emit this signal from within your configuration (usually using a keybind).

```lua
awesome.emit_signal("bling::window_switcher::turn_on")
```

For example:
```lua
 awful.key({Mod1}, "Tab", function()
     awesome.emit_signal("bling::window_switcher::turn_on")
 end, {description = "Window Switcher", group = "bling"})
```

### Theme Variables
```lua
theme.window_switcher_widget_bg = "#000000"              -- The bg color of the widget
theme.window_switcher_widget_border_width = 3            -- The border width of the widget
theme.window_switcher_widget_border_radius = 0           -- The border radius of the widget
theme.window_switcher_widget_border_color = "#ffffff"    -- The border color of the widget
theme.window_switcher_clients_spacing = 20               -- The space between each client item
theme.window_switcher_client_icon_horizontal_spacing = 5 -- The space between client icon and text
theme.window_switcher_client_width = 150                 -- The width of one client widget
theme.window_switcher_client_height = 250                -- The height of one client widget
theme.window_switcher_client_margins = 10                -- The margin between the content and the border of the widget
theme.window_switcher_thumbnail_margins = 10             -- The margin between one client thumbnail and the rest of the widget
theme.thumbnail_scale = false                            -- If set to true, the thumbnails fit policy will be set to "fit" instead of "auto"
theme.window_switcher_name_margins = 10                  -- The margin of one clients title to the rest of the widget
theme.window_switcher_name_valign = "center"             -- How to vertically align one clients title
theme.window_switcher_name_forced_width = 200            -- The width of one title
theme.window_switcher_name_font = "sans 11"              -- The font of all titles
theme.window_switcher_name_normal_color = "#ffffff"      -- The color of one title if the client is unfocused
theme.window_switcher_name_focus_color = "#ff0000"       -- The color of one title if the client is focused
theme.window_switcher_icon_valign = "center"             -- How to vertically align the one icon
theme.window_switcher_icon_width = 40                    -- The width of one icon
```
