-- Standard awesome library
local awful = require("awful")
local gears = require("gears")

-- Widget library
local wibox = require("wibox")

-- Theme handling library
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

-- Helpers
local helpers = require("helpers")


-- Bar
--------

local function boxed_widget(widget)
    local boxed = wibox.widget{
        {
            widget,
            top = dpi(8),
            bottom = dpi(5),
            widget = wibox.container.margin
        },
        bg = beautiful.xcolor0,
        shape = helpers.rrect(dpi(4)),
        widget = wibox.container.background
    }
    return boxed
end

local function boxed_widget2(widget)
    local boxed = wibox.widget{
        {
            widget,
            top = dpi(4),
            bottom = dpi(4),
            left = dpi(2),
            right = dpi(2),
            widget = wibox.container.margin
        },
        bg = beautiful.lighter_bg,
        shape = helpers.rrect(dpi(4)),
        widget = wibox.container.background
    }
    return boxed
end

local wrap_widget = function(w)
    return {
        w,
        left = dpi(3),
        right = dpi(3),
        widget = wibox.container.margin
    }
end

local wrap_widget2 = function(w)
    return {
        w,
        left = dpi(2),
        right = dpi(2),
        widget = wibox.container.margin
    }
end

screen.connect_signal("request::desktop_decoration", function(s)

    -- Launcher
    local awesome_icon = wibox.widget {
        {
            {
                widget = wibox.widget.imagebox,
                image = beautiful.awesome_logo,
                resize = true
            },
            margins = dpi(4),
            widget = wibox.container.margin
        },
        shape = helpers.rrect(beautiful.border_radius),
        bg = beautiful.wibar_bg,
        widget = wibox.container.background
    }

    awesome_icon:buttons(gears.table.join(
        awful.button({}, 1, function ()
            awful.spawn(launcher)
        end)
    ))

    -- Tasklist
    local tasklist_buttons = gears.table.join(
                                awful.button({}, 1, function(c)
            if c == client.focus then
                c.minimized = true
            else
                c:emit_signal("request::activate", "tasklist", {raise = true})
            end
        end), awful.button({}, 3, function()
            awful.menu.client_list({theme = {width = 250}})
        end), awful.button({}, 4, function() awful.client.focus.byidx(1) end),
                                awful.button({}, 5, function()
            awful.client.focus.byidx(-1)
        end))

    -- Battery
    local charge_icon = wibox.widget{
        bg = beautiful.xcolor8,
        widget = wibox.container.background,
        visible = false
    }

    local batt = wibox.widget{
        charge_icon,
        color = {beautiful.xcolor2},
        bg = beautiful.xcolor8 .. "88",
        value = 50,
        min_value = 0,
        max_value = 100,
        thickness = dpi(4),
        padding = dpi(2),
        -- rounded_edge = true,
        start_angle = math.pi * 3 / 2,
        widget = wibox.container.arcchart
    }

    awesome.connect_signal("signal::battery", function(value) 
        local fill_color = beautiful.xcolor2

        if value >= 11 and value <= 30 then
            fill_color = beautiful.xcolor3
        elseif value <= 10 then
            fill_color = beautiful.xcolor1
        end

        batt.colors = {fill_color}
        batt.value = value
    end)

    awesome.connect_signal("signal::charger", function(state)
        if state then
            charge_icon.visible = true
        else
            charge_icon.visible = false
        end
    end)

    -- Time
    local time_hour = wibox.widget{
        font = beautiful.font_name .. "bold 12",
        format = "%H",
        align = "center",
        valign = "center",
        widget = wibox.widget.textclock
    }

    local time_min = wibox.widget{
        font = beautiful.font_name .. "bold 12",
        format = "%M",
        align = "center",
        valign = "center",
        widget = wibox.widget.textclock
    }

    local time = wibox.widget{
        time_hour,
        time_min,
        spacing = dpi(5),
        layout = wibox.layout.fixed.vertical
    }

    -- Notification center
    local notifs = wibox.widget{
        markup = "",
        font = beautiful.font_name .. "16",
        align = "center",
        valign = "center",
        widget = wibox.widget.textbox
    }
    notifs.markup = helpers.colorize_text(notifs.text, beautiful.xcolor3)

    notifs:buttons(gears.table.join(
        awful.button({}, 1, function()
            notifs_toggle()
        end)
    ))

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()

    -- Create layoutbox widget
    s.mylayoutbox = awful.widget.layoutbox(s)
    
    local layoutbox = wibox.widget{
        s.mylayoutbox,
        right = dpi(9),
        left = dpi(9),
        top = dpi(6),
        bottom = dpi(6),
        widget = wibox.container.margin
    }

    -- Create the wibox
    s.mywibox = wibox({
        -- position = beautiful.wibar_position,
        screen = s,
        type = "dock",
        ontop = true,
        x = 0,
        y = 0,
        width = beautiful.wibar_width,
        height = screen_height,
        visible = true
    })

    s.mywibox:struts{left = beautiful.wibar_width}

    -- Remove wibar on full screen
    local function remove_wibar(c)
        if c.fullscreen or c.maximized then
            c.screen.mywibox.visible = false
        else
            c.screen.mywibox.visible = true
        end
    end

    -- Remove wibar on full screen
    local function add_wibar(c)
        if c.fullscreen or c.maximized then
            c.screen.mywibox.visible = true
        end
    end

    client.connect_signal("property::fullscreen", remove_wibar)

    client.connect_signal("request::unmanage", add_wibar)

    -- Create the taglist widget
    s.mytaglist = require("ui.widgets.pacman_taglist")(s)

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen = s,
        filter = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons,
        bg = beautiful.wibar_bg,
        style = {
            bg = beautiful.xcolor0,
            shape = helpers.rrect(beautiful.border_radius)
        },
        layout = {spacing = dpi(10), layout = wibox.layout.fixed.vertical},
        widget_template = {
            {
                awful.widget.clienticon,
                margins = dpi(6),
                layout = wibox.container.margin
            },
            id = "background_role",
            widget = wibox.container.background,
            create_callback = function(self, c, index, clients)
                self:connect_signal('mouse::enter', function()
                    self.bg_temp = self.bg
                    self.bg = beautiful.xcolor0
                    awesome.emit_signal("bling::task_preview::visibility", s,
                                        true, c)
                end)
                self:connect_signal('mouse::leave', function()
                    self.bg = self.bg_temp
                    awesome.emit_signal("bling::task_preview::visibility", s,
                                        false, c)
                end)
            end
        }
    }

    -- Add widgets to the wibox
    s.mywibox.widget = wibox.widget {
        {
            layout = wibox.layout.align.vertical,
            expand = "none",
            {
                layout = wibox.layout.fixed.vertical,
                helpers.horizontal_pad(4),
                -- function to add padding
                {
                    {
                        awesome_icon,
                        margins = dpi(3),
                        widget = wibox.container.margin
                    },
                    margins = 3,
                    widget = wibox.container.margin
                },
                wrap_widget({
                    s.mytasklist,
                    left = dpi(2),
                    right = dpi(2),
                    widget = wibox.container.margin
                }),
                s.mypromptbox
            },
            {
                boxed_widget({
                wrap_widget({
                    s.mytaglist,
                    top = dpi(30),
                    bottom = dpi(30),
                    widget = wibox.container.margin
                }),
                    widget = wibox.container.constraint
            }),
            left = dpi(5),
            right = dpi(5),
            widget = wibox.container.margin
            },
            {
                {
                    {
                        {
                            boxed_widget({
                            wrap_widget({
                                wrap_widget2(batt), 
                                boxed_widget2(time), 
                                spacing = dpi(10), 
                                layout = wibox.layout.fixed.vertical
                            }),
                            left = dpi(2),
                            right = dpi(2),
                            widget = wibox.container.margin
                            }),
                            bottom = dpi(12),
                            widget = wibox.container.margin
                        },
                            boxed_widget({
                                notifs, 
                                layoutbox, 
                                spacing = dpi(3), 
                                layout = wibox.layout.fixed.vertical
                            }),
                            helpers.horizontal_pad(4),
                            layout = wibox.layout.fixed.vertical
                    },
                    bottom = dpi(10),
                    widget = wibox.container.margin
                },
                left = dpi(5),
                right = dpi(5),
                widget = wibox.container.margin
            }
        },
            widget = wibox.container.background,
            bg = beautiful.wibar_bg
        }
end)

-- EOF ------------------------------------------------------------------------
