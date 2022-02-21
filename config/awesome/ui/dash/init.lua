-- Standard awesome library
local gears = require("gears")
local awful = require("awful")

-- Theme handling library
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

-- Widget library
local wibox = require("wibox")

-- rubato
local rubato = require("module.rubato")

-- Helpers
local helpers = require("helpers")

-- Get screen geometry
local screen_width = awful.screen.focused().geometry.width
local screen_height = awful.screen.focused().geometry.height


-- dash
------------

-- Helpers
local function centered_widget(widget)
    local w = wibox.widget{
        nil,
        {
            nil,
            widget,
            expand = "none",
            layout = wibox.layout.align.vertical
        },
        expand = "none",
        layout = wibox.layout.align.horizontal
    }

    return w
end

local function create_boxed_widget(widget_to_be_boxed, width, height, bg_color)
    local box_container = wibox.container.background()
    box_container.bg = bg_color
    box_container.forced_height = height
    box_container.forced_width = width
    box_container.shape = helpers.rrect(dpi(5))

    local boxed_widget = wibox.widget {
        -- Add margins
        {
            -- Add background color
            {
                -- The actual widget goes here
                widget_to_be_boxed,
                top = dpi(9),
                bottom = dpi(9),
                left = dpi(10),
                right = dpi(10),
                widget = wibox.container.margin
            },
            widget = box_container,
        },
        margins = dpi(10),
        color = "#FF000000",
        widget = wibox.container.margin
    }

    return boxed_widget
end

-- Widget
local profile = require("ui.dash.profile")
local music = require("ui.dash.music")
local media = require("ui.dash.mediakeys")
local time = require("ui.dash.time")
local date = require("ui.dash.date")
local todo = require("ui.dash.todo")
local weather = require("ui.dash.weather")
local stats = require("ui.dash.stats")
local notifs = require("ui.dash.notifs")


local time_boxed = create_boxed_widget(centered_widget(time), dpi(260), dpi(95), beautiful.transparent)
local date_boxed = create_boxed_widget(date, dpi(120), dpi(50), beautiful.dash_box_bg)
local todo_boxed = create_boxed_widget(todo, dpi(120), dpi(120), beautiful.dash_box_bg)
local weather_boxed = create_boxed_widget(weather, dpi(120), dpi(120), beautiful.dash_box_bg)
local stats_boxed = create_boxed_widget(stats, dpi(120), dpi(190), beautiful.dash_box_bg)
local notifs_boxed = create_boxed_widget(notifs, dpi(260), dpi(155), beautiful.dash_box_bg)

-- Dashboard
dash = wibox({
    type = "dock",
    screen = screen.primary,
    height = screen_height,
    width = beautiful.dash_width or dpi(300),
    ontop = true,
    visible = false
})

awful.placement.left(dash)

dash:buttons(gears.table.join(
    -- Middle click - Hide dash
    awful.button({}, 2, function()
        dash_hide()
    end)
))

local slide = rubato.timed{
    pos = dpi(-300),
    rate = 60,
    intro = 0.3,
    duration = 0.8,
    easing = rubato.quadratic,
    awestore_compat = true,
    subscribed = function(pos) dash.x = pos end
}

local slide_strut = rubato.timed{
    pos = dpi(0),
    rate = 60,
    intro = 0.3,
    duration = 0.8,
    easing = rubato.quadratic,
    awestore_compat = true,
    subscribed = function(width) dash:struts{left = width, right = 0, top = 0, bottom = 0} end
}

local dash_status = false

slide.ended:subscribe(function()
    if dash_status then
        dash.visible = false
    end
end)

dash_show = function()
    dash.visible = true
    slide:set(0)
    slide_strut:set(300)
    dash_status = false
end

dash_hide = function()
    slide:set(-300)
    slide_strut:set(0)
    dash_status = true
end

dash_toggle = function()
    if dash.visible then
        dash_hide()
    else
        dash_show()
    end
end

dash:setup {
    {
        nil,
        {
            time_boxed,
            {
                {
                    profile,
                    stats_boxed,
                    layout = wibox.layout.fixed.vertical
                },
                {
                    date_boxed,
                    todo_boxed,
                    weather_boxed,
                    layout = wibox.layout.fixed.vertical
                },
                layout = wibox.layout.fixed.horizontal
            },
            {
                music,
                media,
                layout = wibox.layout.fixed.horizontal
            },
            notifs_boxed,
            layout = wibox.layout.fixed.vertical
        },
        expand = "none",
        layout = wibox.layout.align.horizontal
    },
    margins = dpi(10),
    widget = wibox.container.margin
}
