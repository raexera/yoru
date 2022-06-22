## 🔍 Tag Preview <!-- {docsify-ignore} -->

This is a popup widget that will show a preview of a specified tag that illustrates the position, size, content, and icon of all clients.

![](https://imgur.com/zFdvs4K.gif)

*gif by [javacafe](https://github.com/JavaCafe01)*

### Usage

To enable:

```lua
bling.widget.tag_preview.enable {
    show_client_content = false,  -- Whether or not to show the client content
    x = 10,                       -- The x-coord of the popup
    y = 10,                       -- The y-coord of the popup
    scale = 0.25,                 -- The scale of the previews compared to the screen
    honor_padding = false,        -- Honor padding when creating widget size
    honor_workarea = false,       -- Honor work area when creating widget size
    placement_fn = function(c)    -- Place the widget using awful.placement (this overrides x & y)
        awful.placement.top_left(c, {
            margins = {
                top = 30,
                left = 30
            }
        })
    end,
	background_widget = wibox.widget {	-- Set a background image (like a wallpaper) for the widget 
        image = beautiful.wallpaper,
        horizontal_fit_policy = "fit",
        vertical_fit_policy   = "fit",
        widget = wibox.widget.imagebox
    }
}
```

Here are the signals available:

```lua
-- bling::tag_preview::update -- first line is the signal
--     t   (tag)              -- indented lines are function parameters
-- bling::tag_preview::visibility
--     s   (screen)
--     v   (boolean)
```

By default, the widget is not visible. You must implement when it will update and when it will show.

### Example Implementation

We can trigger the widget to show the specific tag when hovering over it in the taglist. The code shown below is the example taglist from the [AwesomeWM docs](https://awesomewm.org/doc/api/classes/awful.widget.taglist.html). Basically, we are going to update the widget and toggle it through the taglist's `create_callback`. (The bling addons are commented)
```lua
s.mytaglist = awful.widget.taglist {
    screen  = s,
    filter  = awful.widget.taglist.filter.all,
    style   = {
        shape = gears.shape.powerline
    },
    layout   = {
        spacing = -12,
        spacing_widget = {
            color  = '#dddddd',
            shape  = gears.shape.powerline,
            widget = wibox.widget.separator,
        },
        layout  = wibox.layout.fixed.horizontal
    },
    widget_template = {
        {
            {
                {
                    {
                        {
                            id     = 'index_role',
                            widget = wibox.widget.textbox,
                        },
                        margins = 4,
                        widget  = wibox.container.margin,
                    },
                    bg     = '#dddddd',
                    shape  = gears.shape.circle,
                    widget = wibox.container.background,
                },
                {
                    {
                        id     = 'icon_role',
                        widget = wibox.widget.imagebox,
                    },
                    margins = 2,
                    widget  = wibox.container.margin,
                },
                {
                    id     = 'text_role',
                    widget = wibox.widget.textbox,
                },
                layout = wibox.layout.fixed.horizontal,
            },
            left  = 18,
            right = 18,
            widget = wibox.container.margin
        },
        id     = 'background_role',
        widget = wibox.container.background,
        -- Add support for hover colors and an index label
        create_callback = function(self, c3, index, objects) --luacheck: no unused args
            self:get_children_by_id('index_role')[1].markup = '<b> '..index..' </b>'
            self:connect_signal('mouse::enter', function()

                -- BLING: Only show widget when there are clients in the tag
                if #c3:clients() > 0 then
                    -- BLING: Update the widget with the new tag
                    awesome.emit_signal("bling::tag_preview::update", c3)
                    -- BLING: Show the widget
                    awesome.emit_signal("bling::tag_preview::visibility", s, true)
                end

                if self.bg ~= '#ff0000' then
                    self.backup     = self.bg
                    self.has_backup = true
                end
                self.bg = '#ff0000'
            end)
            self:connect_signal('mouse::leave', function()

                -- BLING: Turn the widget off
                awesome.emit_signal("bling::tag_preview::visibility", s, false)

                if self.has_backup then self.bg = self.backup end
            end)
        end,
        update_callback = function(self, c3, index, objects) --luacheck: no unused args
            self:get_children_by_id('index_role')[1].markup = '<b> '..index..' </b>'
        end,
    },
    buttons = taglist_buttons
}
```

### Theme Variables

```lua
theme.tag_preview_widget_border_radius = 0        -- Border radius of the widget (With AA)
theme.tag_preview_client_border_radius = 0        -- Border radius of each client in the widget (With AA)
theme.tag_preview_client_opacity = 0.5            -- Opacity of each client
theme.tag_preview_client_bg = "#000000"           -- The bg color of each client
theme.tag_preview_client_border_color = "#ffffff" -- The border color of each client
theme.tag_preview_client_border_width = 3         -- The border width of each client
theme.tag_preview_widget_bg = "#000000"           -- The bg color of the widget
theme.tag_preview_widget_border_color = "#ffffff" -- The border color of the widget
theme.tag_preview_widget_border_width = 3         -- The border width of the widget
theme.tag_preview_widget_margin = 0               -- The margin of the widget
```

NOTE: I recommend to only use the widget border radius theme variable when not using shadows with a compositor, as anti-aliased rounding with the outer widgets made with AwesomeWM rely on the actual bg being transparent. If you want rounding with shadows on the widget, use a compositor like [jonaburg's fork](https://github.com/jonaburg/picom).
