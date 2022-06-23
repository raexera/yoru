## 📑 Tabbed <!-- {docsify-ignore} -->

Tabbed implements a tab container. There are also different themes for the tabs.

### Usage

You should bind these functions to keys in order to use the tabbed module effectively:
```lua
bling.module.tabbed.pick()                 -- picks a client with your cursor to add to the tabbing group
bling.module.tabbed.pop()                  -- removes the focused client from the tabbing group
bling.module.tabbed.iter()            	   -- iterates through the currently focused tabbing group
bling.module.tabbed.pick_with_dmenu()      -- picks a client with a dmenu application (defaults to rofi, other options can be set with a string parameter like "dmenu")
bling.module.tabbed.pick_by_direction(dir) -- picks a client based on direction ("up", "down", "left" or "right")
```

### Theme Variables

```lua
-- For tabbed only
theme.tabbed_spawn_in_tab = false  -- whether a new client should spawn into the focused tabbing container

-- For tabbar in general
theme.tabbar_ontop  = false
theme.tabbar_radius = 0                -- border radius of the tabbar
theme.tabbar_style = "default"         -- style of the tabbar ("default", "boxes" or "modern")
theme.tabbar_font = "Sans 11"          -- font of the tabbar
theme.tabbar_size = 40                 -- size of the tabbar
theme.tabbar_position = "top"          -- position of the tabbar
theme.tabbar_bg_normal = "#000000"     -- background color of the focused client on the tabbar
theme.tabbar_fg_normal = "#ffffff"     -- foreground color of the focused client on the tabbar
theme.tabbar_bg_focus  = "#1A2026"     -- background color of unfocused clients on the tabbar
theme.tabbar_fg_focus  = "#ff0000"     -- foreground color of unfocused clients on the tabbar
theme.tabbar_bg_focus_inactive = nil   -- background color of the focused client on the tabbar when inactive
theme.tabbar_fg_focus_inactive = nil   -- foreground color of the focused client on the tabbar when inactive
theme.tabbar_bg_normal_inactive = nil  -- background color of unfocused clients on the tabbar when inactive
theme.tabbar_fg_normal_inactive = nil  -- foreground color of unfocused clients on the tabbar when inactive
theme.tabbar_disable = false           -- disable the tab bar entirely

-- the following variables are currently only for the "modern" tabbar style
theme.tabbar_color_close = "#f9929b" -- chnges the color of the close button
theme.tabbar_color_min   = "#fbdf90" -- chnges the color of the minimize button
theme.tabbar_color_float = "#ccaced" -- chnges the color of the float button
```

### Preview

Modern theme:

<img src="https://imgur.com/omowmIQ.png" width="600"/>

*screenshot by [JavaCafe01](https://github.com/JavaCafe01)*

### Signals
The tabbed module emits a few signals for the purpose of integration,
```lua
-- bling::tabbed::update -- triggered whenever a tabbed object is updated
--             tabobj -- the object that caused the update
-- bling::tabbed::client_added -- triggered whenever a new client is added to a tab group
--             tabobj -- the object that the client was added to
--             client -- the client that added
-- bling::tabbed::client_removed -- triggered whenever a client is removed from a tab group
--             tabobj -- the object that the client was removed from
--             client -- the client that was removed
-- bling::tabbed::changed_focus -- triggered whenever a tab group's focus is changed
--             tabobj -- the modified tab group
```
