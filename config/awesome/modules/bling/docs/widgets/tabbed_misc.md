## 🧱 Tabbed Miscellaneous <!-- {docsify-ignore} -->

This comprises a few widgets to better represent tabbed groups (from the tabbed module) in your desktop.
The widgets currently included are:
- Titlebar Indicator
- Tasklist

![Preview Image](https://i.imgur.com/ZeYSrxY.png)

## Titlebar Indicator

### Usage

To use the task list indicator:
**NOTE:** Options can be set as theme vars under the table `theme.bling_tabbed_misc_titlebar_indicator` 

```lua
bling.widget.tabbed_misc.titlebar_indicator(client, {
    layout = wibox.layout.fixed.vertical,
    layout_spacing = dpi(5), -- Set spacing in between items
    icon_size = dpi(24), -- Set icon size
    icon_margin = 0, -- Set icon margin
    fg_color = "#cccccc", -- Normal color for text
    fg_color_focus = "#ffffff", -- Color for focused text
    bg_color_focus = "#282828", -- Color for the focused items
    bg_color = "#1d2021", -- Color for normal / unfocused items
    icon_shape = gears.shape.circle -- Set icon shape,
})
```

a widget_template option is also available:
```lua
bling.widget.tabbed_misc.titlebar_indicator(client, {
    widget_template = {
        {
            widget = awful.widget.clienticon,
            id = 'icon_role'
        },
        widget = wibox.container.margin,
        margins = 2,
        id = 'bg_role',
        update_callback = function(self, client, group)
            if client == group.clients[group.focused_idx] then
                self.margins = 5
            end
        end
    }
})
```

### Example Implementation

You normally embed the widget in your titlebar...
```lua
awful.titlebar(c).widget = {
        { -- Left
            bling.widget.tabbed_misc.titlebar_indicator(c),
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal
        },
        layout = wibox.layout.align.horizontal
    }
```

## Tasklist
The module exports a function that can be added to your tasklist as a `update_callback`

### Usage
```lua
awful.widget.tasklist({
     screen = s,
     filter = awful.widget.tasklist.filter.currenttags,
     layout = {
         spacing = dpi(10),
         layout = wibox.layout.fixed.vertical,
     },
     style = {
         bg_normal = "#00000000",
     },
     widget_template = {
         {
             {
                  widget = wibox.widget.imagebox,
                  id = "icon_role",
                  align = "center",
                  valign = "center",
              },
              width = dpi(24),
              height = dpi(24),
              widget = wibox.container.constraint,
          },
          widget = wibox.container.background, -- IT MUST BE A CONTAINER WIDGET AS THAT IS WHAT THE FUNCTION EXPECTS
          update_callback = require("bling.widget.tabbed_misc").custom_tasklist,
          id = "background_role",
    },
})
```

If you need to do something else, it can be used like so
```lua
update_callback = function(self, client, index, clients)
    require("bling.widget.tabbed_misc").custom_tasklist(self, client, index, clients)
    require("naughty").notify({ text = "Tasklist was updated" })
end
```
