## 🔍 Task Preview <!-- {docsify-ignore} -->

This is a popup widget that will show a preview of the specified client. It is supposed to mimic the small popup that Windows has when hovering over the application icon.

![](https://user-images.githubusercontent.com/33443763/124705653-d7b98b80-deaa-11eb-8091-42bbe62365be.png)

*image by [javacafe](https://github.com/JavaCafe01)*

### Usage

To enable:

```lua
bling.widget.task_preview.enable {
    x = 20,                    -- The x-coord of the popup
    y = 20,                    -- The y-coord of the popup
    height = 200,              -- The height of the popup
    width = 200,               -- The width of the popup
    placement_fn = function(c) -- Place the widget using awful.placement (this overrides x & y)
        awful.placement.bottom(c, {
            margins = {
                bottom = 30
            }
        })
    end
}
```

To allow for more customization, there is also a `widget_structure` property (as seen in some default awesome widgets) which is optional. An example is as follows -
```lua
bling.widget.task_preview.enable {
    x = 20,                    -- The x-coord of the popup
    y = 20,                    -- The y-coord of the popup
    height = 200,              -- The height of the popup
    width = 200,               -- The width of the popup
    placement_fn = function(c) -- Place the widget using awful.placement (this overrides x & y)
        awful.placement.bottom(c, {
            margins = {
                bottom = 30
            }
        })
    end,
    -- Your widget will automatically conform to the given size due to a constraint container.
    widget_structure = {
        {
            {
                {
                    id = 'icon_role',
                    widget = awful.widget.clienticon, -- The client icon
                },
                {
                    id = 'name_role', -- The client name / title
                    widget = wibox.widget.textbox,
                },
                layout = wibox.layout.flex.horizontal
            },
            widget = wibox.container.margin,
            margins = 5
        },
        {
            id = 'image_role', -- The client preview
            resize = true,
            valign = 'center',
            halign = 'center',
            widget = wibox.widget.imagebox,
        },
        layout = wibox.layout.fixed.vertical
    }
}
```

Here are the signals available:

```lua
-- bling::task_preview::visibility  -- first line is the signal
--     s   (screen)                 -- indented lines are function parameters
--     v   (boolean)
--     c   (client)
```

By default, the widget is not visible. You must implement when it will update and when it will show.

### Example Implementation

We can trigger the widget to show the specific client when hovering over it in the tasklist. The code shown below is the example icon only tasklist from the [AwesomeWM docs](https://awesomewm.org/doc/api/classes/awful.widget.tasklist.html). Basically, we are going to toggle the widget through the tasklist's `create_callback`. (The bling addons are commented)
```lua
s.mytasklist = awful.widget.tasklist {
    screen   = s,
    filter   = awful.widget.tasklist.filter.currenttags,
    buttons  = tasklist_buttons,
    layout   = {
        spacing_widget = {
            {
                forced_width  = 5,
                forced_height = 24,
                thickness     = 1,
                color         = '#777777',
                widget        = wibox.widget.separator
            },
            valign = 'center',
            halign = 'center',
            widget = wibox.container.place,
        },
        spacing = 1,
        layout  = wibox.layout.fixed.horizontal
    },
    -- Notice that there is *NO* wibox.wibox prefix, it is a template,
    -- not a widget instance.
    widget_template = {
        {
            wibox.widget.base.make_widget(),
            forced_height = 5,
            id            = 'background_role',
            widget        = wibox.container.background,
        },
        {
            {
                id     = 'clienticon',
                widget = awful.widget.clienticon,
            },
            margins = 5,
            widget  = wibox.container.margin
        },
        nil,
        create_callback = function(self, c, index, objects) --luacheck: no unused args
            self:get_children_by_id('clienticon')[1].client = c

            -- BLING: Toggle the popup on hover and disable it off hover
            self:connect_signal('mouse::enter', function()
                    awesome.emit_signal("bling::task_preview::visibility", s,
                                        true, c)
                end)
                self:connect_signal('mouse::leave', function()
                    awesome.emit_signal("bling::task_preview::visibility", s,
                                        false, c)
                end)
        end,
        layout = wibox.layout.align.vertical,
    },
}
```

### Theme Variables
```lua
theme.task_preview_widget_border_radius = 0        -- Border radius of the widget (With AA)
theme.task_preview_widget_bg = "#000000"           -- The bg color of the widget
theme.task_preview_widget_border_color = "#ffffff" -- The border color of the widget
theme.task_preview_widget_border_width = 3         -- The border width of the widget
theme.task_preview_widget_margin = 0               -- The margin of the widget
```

NOTE: I recommend to only use the widget border radius theme variable when not using shadows with a compositor, as anti-aliased rounding with the outer widgets made with AwesomeWM rely on the actual bg being transparent. If you want rounding with shadows on the widget, use a compositor like [jonaburg's fork](https://github.com/jonaburg/picom).
