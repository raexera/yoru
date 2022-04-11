-- Standard awesome library
local awful = require("awful")
local gears = require("gears")

-- Widget library
local wibox = require("wibox")

-- Theme handling library
local beautiful = require("beautiful")

-- Rubato
local rubato = require("module.rubato")

-- Helpers
local helpers = require("helpers")

-- Get screen geometry
local screen_width = awful.screen.focused().geometry.width
local screen_height = awful.screen.focused().geometry.height


-- Helpers
-------------

local wrap_widget = function(widget)
    return {
        widget,
        margins = dpi(6),
        widget = wibox.container.margin
    }
end


-- Wibar
-----------

awful.screen.connect_for_each_screen(function(s)

    -- Launcher
    -------------

    local awesome_icon = wibox.widget {
        {
            widget = wibox.widget.imagebox,
            image = beautiful.awesome_logo,
            resize = true
        },
        margins = dpi(4),
        widget = wibox.container.margin
    }

    helpers.add_hover_cursor(awesome_icon, "hand2")


    -- Battery
    -------------

    local charge_icon = wibox.widget{
        bg = beautiful.xcolor8,
        widget = wibox.container.background,
        visible = false
    }

    local batt = wibox.widget{
        charge_icon,
        max_value = 100,
        value = 50,
        thickness = dpi(4),
        padding = dpi(2),
        start_angle = math.pi * 3 / 2,
        color = {beautiful.xcolor2},
        bg = beautiful.xcolor2 .. "55",
        widget = wibox.container.arcchart
    }

    local batt_last_value = 100
    local batt_low_value = 40
    local batt_critical_value = 20
    awesome.connect_signal("signal::battery", function(value)
        batt.value = value
        batt_last_value = value
        local color

        if charge_icon.visible then
            color = beautiful.xcolor6
        elseif value <= batt_critical_value then
            color = beautiful.xcolor1
        elseif value <= batt_low_value then
            color = beautiful.xcolor3
        else
            color = beautiful.xcolor2
        end

        batt.colors = {color}
        batt.bg = color .. "44"
    end)

    awesome.connect_signal("signal::charger", function(state)
        local color
        if state then
            charge_icon.visible = true
            color = beautiful.xcolor6
        elseif batt_last_value <= batt_critical_value then
            charge_icon.visible = false
            color = beautiful.xcolor1
        elseif batt_last_value <=  batt_low_value then
            charge_icon.visible = false
            color = beautiful.xcolor3
        else
            charge_icon.visible = false
            color = beautiful.xcolor2
        end

        batt.colors = {color}
        batt.bg = color .. "44"
    end)


    -- Time
    ----------

    local hour = wibox.widget{
        font = beautiful.font_name .. "bold 14",
        format = "%H",
        align = "center",
        valign = "center",
        widget = wibox.widget.textclock
    }

    local min = wibox.widget{
        font = beautiful.font_name .. "bold 14",
        format = "%M",
        align = "center",
        valign = "center",
        widget = wibox.widget.textclock
    }

    local clock = wibox.widget{
        {
            {
                hour,
                min,
                spacing = dpi(5),
                layout = wibox.layout.fixed.vertical
            },
            top = dpi(5),
            bottom = dpi(5),
            widget = wibox.container.margin
        },
        bg = beautiful.wibar_widget_bg,
        shape = helpers.rrect(beautiful.widget_radius),
        widget = wibox.container.background
    }


    -- Stats
    -----------

    local stats = wibox.widget{
        {
            wrap_widget(batt),
            clock,
            spacing = dpi(5),
            layout = wibox.layout.fixed.vertical
        },
        bg = beautiful.wibar_widget_alt_bg,
        shape = helpers.rrect(beautiful.widget_radius),
        widget = wibox.container.background
    }

    stats:connect_signal("mouse::enter", function()
        stats.bg = beautiful.xcolor8
        stats_tooltip_show()
    end)

    stats:connect_signal("mouse::leave", function()
        stats.bg = beautiful.wibar_widget_alt_bg
        stats_tooltip_hide()
    end)


    -- Notification center
    -------------------------

    notif_center = wibox({
        type = "dock",
        screen = s,
        height = screen_height - dpi(50),
        width = dpi(300),
        bg = beautiful.transparent,
        ontop = true,
        visible = false
    })
    notif_center.y = dpi(25)

    -- Rubato
    local slide = rubato.timed{
        pos = dpi(-300),
        rate = 60,
        intro = 0.2,
        duration = 0.6,
        easing = rubato.quadratic,
        awestore_compat = true,
        subscribed = function(pos)
            notif_center.x = pos
        end
    }

    local notif_center_status = false

    slide.ended:subscribe(function()
        if notif_center_status then
            notif_center.visible = false
        end
    end)

    -- Make toogle button
    local notif_center_show = function()
        notif_center.visible = true
        slide:set(dpi(100))
        notif_center_status = false
    end

    local notif_center_hide = function()
        slide:set(dpi(-375))
        notif_center_status = true
    end

    notif_center_toggle = function()
        if notif_center.visible then
            notif_center_hide()
        else
            notif_center_show()
        end
    end

    -- notif_center setup
    s.notif_center = require('ui.widgets.notif-center')(s)

    notif_center:setup {
        {
            s.notif_center,
            margins = dpi(15),
            widget = wibox.container.margin
        },
        bg = beautiful.xbackground,
        shape = helpers.rrect(beautiful.notif_center_radius),
        widget = wibox.container.background
    }

    local notif_center_button = wibox.widget{
        markup = helpers.colorize_text("", beautiful.accent),
        font = beautiful.font_name .. "18",
        align = "center",
        valign = "center",
        widget = wibox.widget.textbox
    }

    notif_center_button:connect_signal("mouse::enter", function()
        notif_center_button.markup = helpers.colorize_text(notif_center_button.text, beautiful.accent .. 55)
    end)

    notif_center_button:connect_signal("mouse::leave", function()
        notif_center_button.markup = helpers.colorize_text(notif_center_button.text, beautiful.accent)
    end)

    notif_center_button:buttons(gears.table.join(
        awful.button({}, 1, function()
            notif_center_toggle()
        end)
    ))
    helpers.add_hover_cursor(notif_center_button, "hand2")


-- Setup wibar
-----------------

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()

    -- Layoutbox
    local layoutbox_buttons = gears.table.join(
    -- Left click
    awful.button({}, 1, function (c)
        awful.layout.inc(1)
    end),

    -- Right click
    awful.button({}, 3, function (c) 
        awful.layout.inc(-1) 
    end),

    -- Scrolling
    awful.button({}, 4, function ()
        awful.layout.inc(-1)
    end),
    awful.button({}, 5, function ()
        awful.layout.inc(1)
    end)
    )

    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(layoutbox_buttons)

    local layoutbox = wibox.widget{
        s.mylayoutbox,
        margins = {bottom = dpi(7), left = dpi(8), right = dpi(8)},
        widget = wibox.container.margin
    }

    helpers.add_hover_cursor(layoutbox, "hand2")

    -- Create a system tray widget
    s.systray = wibox.widget.systray()
    s.traybox = wibox({ screen = s, width = dpi(200), height = dpi(50), bg = "#00000000", visible = false, ontop = true})
    s.traybox:setup {
        {
            {
                nil,
                s.systray,
                expand = "none",
                layout = wibox.layout.align.horizontal,
            },
            margins = dpi(15),
            widget = wibox.container.margin
        },
        bg = beautiful.wibar_bg,
        shape = helpers.rrect(beautiful.border_radius),
        widget = wibox.container.background
    }
    awful.placement.bottom_right(s.traybox, { margins = { bottom = dpi(25), right = dpi(25)} })
    s.traybox:buttons(gears.table.join(
        awful.button({ }, 2, function ()
            s.traybox.visible = false
        end)
    ))

    -- Create the wibar
    s.mywibar = awful.wibar({
        type = "dock",
        position = "left",
        screen = s,
        height = awful.screen.focused().geometry.height - dpi(50),
        width = beautiful.wibar_width,
        bg = beautiful.transparent,
        ontop = true,
        visible = true
    })

    awesome_icon:buttons(gears.table.join(
    awful.button({}, 1, function ()
        dashboard_toggle()
    end)
    ))

    -- Remove wibar on full screen
    local function remove_wibar(c)
        if c.fullscreen or c.maximized then
            c.screen.mywibar.visible = false
        else
            c.screen.mywibar.visible = true
        end
    end

    -- Remove wibar on full screen
    local function add_wibar(c)
        if c.fullscreen or c.maximized then
            c.screen.mywibar.visible = true
        end
    end

    client.connect_signal("property::fullscreen", remove_wibar)

    client.connect_signal("request::unmanage", add_wibar)

     -- Create the taglist widget
    s.mytaglist = require("ui.bar.pacman-taglist")(s)

    local taglist = wibox.widget{
        s.mytaglist,
        shape = beautiful.taglist_shape_focus,
        bg = beautiful.wibar_widget_alt_bg,
        widget = wibox.container.background
    }

    -- Add widgets to wibar
    s.mywibar:setup {
        {
            {
                layout = wibox.layout.align.vertical,
                expand = "none",
                { -- top
                    awesome_icon,
                    taglist,
                    spacing = dpi(10),
                    layout = wibox.layout.fixed.vertical
                },
                -- middle
                nil,
                { -- bottom
                    stats,
                    notif_center_button,
                    layoutbox,
                    spacing = dpi(8),
                    layout = wibox.layout.fixed.vertical
                }
            },
            margins = dpi(8),
            widget = wibox.container.margin
        },
        bg = beautiful.wibar_bg,
        shape = helpers.rrect(beautiful.border_radius),
        widget = wibox.container.background
    }

    -- wibar position
    s.mywibar.x = dpi(25)
end)

function tray_toggle()
    local s = awful.screen.focused()
    s.traybox.visible = not s.traybox.visible
end
