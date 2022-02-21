-- Standard awesome library
local gears = require("gears")
local awful = require("awful")

-- Theme handling library
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

-- Notification library
local naughty = require("naughty")

-- Widget library
local wibox = require("wibox")

-- rubato
local rubato = require("module.rubato")

-- Helpers
local helpers = require("helpers")


-- Notification center
------------------------

-- Header
local notif_header = wibox.widget {
    markup = '<b>Notifications</b>',
    font = beautiful.font_name .. "12",
    align = 'center',
    valign = 'center',
    widget = wibox.widget.textbox
}

-- Clear button
local clear = wibox.widget {
    markup = "",
    font = beautiful.icon_font_name .. "14",
    align = "center",
    valign = "center",
    widget = wibox.widget.textbox
}

clear:buttons(gears.table.join(
    awful.button({}, 1, function()
        _G.reset_notif_container()
    end)
))

helpers.add_hover_cursor(clear, "hand1")

-- Empty notifs
local empty = wibox.widget {
    {
        {
            expand = 'none',
            layout = wibox.layout.align.horizontal,
            nil,
            {
                markup = "",
                font = beautiful.icon_font_name .. "28",
                align = "center",
                valign = "center",
                widget = wibox.widget.textbox
            },
            nil
        },
        {
            markup = 'You have no notifs!',
            font = beautiful.font_name .. '10',
            align = 'center',
            valign = 'center',
            widget = wibox.widget.textbox
        },
        layout = wibox.layout.fixed.vertical,
        spacing = dpi(5)
    },
    top = dpi(75),
    widget = wibox.container.margin
}

-- Mouse scroll
local notif_container = wibox.layout.fixed.vertical()
notif_container.spacing = dpi(15)
notif_container.forced_width = beautiful.notifs_width or dpi(270)

local remove_notif_empty = true

reset_notif_container = function()
    notif_container:reset(notif_container)
    notif_container:insert(1, empty)
    remove_notif_empty = true
end

remove_notif = function(box)
    notif_container:remove_widgets(box)

    if #notif_container.children == 0 then
        notif_container:insert(1, empty)
        remove_notif_empty = true
    end
end

local create_notif = function(icon, n, width)
    local time = os.date("%H:%M")
    local box = {}

    local dismiss = wibox.widget {
        markup = "",
        font = beautiful.icon_font_name .. "9",
        align = "center",
        valign = "center",
        widget = wibox.widget.textbox
    }

    dismiss:buttons(gears.table.join(
        awful.button({}, 1, function()
            _G.remove_notif(box)
        end)
    ))

    helpers.add_hover_cursor(dismiss, "hand1")

    box = wibox.widget {
        {
            {
                {
                    {
                        {
                            {
                                image = icon,
                                resize = true,
                                clip_shape = helpers.rrect(dpi(2)),
                                halign = "center",
                                valign = "center",
                                widget = wibox.widget.imagebox
                            },
                            strategy = 'exact',
                            height = 40,
                            width = 40,
                            widget = wibox.container.constraint
                        },
                        layout = wibox.layout.align.vertical
                    },
                    left = dpi(14),
                    right = dpi(4),
                    top = dpi(12),
                    bottom = dpi(12),
                    widget = wibox.container.margin
                },
                {
                    {
                        nil,
                        {
                            {
                                {
                                    step_function = wibox.container.scroll
                                        .step_functions
                                        .waiting_nonlinear_back_and_forth,
                                    speed = 50,
                                    {
                                        markup = "<b>" .. n.title .. "</b>",
                                        font = beautiful.font_name .. "10",
                                        align = "left",
                                        -- visible = title_visible,
                                        widget = wibox.widget.textbox
                                    },
                                    forced_width = dpi(140),
                                    widget = wibox.container.scroll.horizontal
                                },
                                {
                                    {
                                        dismiss,
                                        halign = "right",
                                        widget = wibox.container.place
                                    },
                                    left = dpi(10),
                                    widget = wibox.container.margin
                                },
                                layout = wibox.layout.fixed.horizontal
                            },
                            {
                                {
                                    step_function = wibox.container.scroll
                                        .step_functions
                                        .waiting_nonlinear_back_and_forth,
                                    speed = 50,
                                    {
                                        markup = n.message,
                                        align = "left",
                                        font = beautiful.font_name .. "9",
                                        widget = wibox.widget.textbox
                                    },
                                    forced_width = dpi(125),
                                    widget = wibox.container.scroll.horizontal
                                },
                                {
                                    {
                                        markup = time,
                                        align = "right",
                                        valign = "bottom",
                                        font = beautiful.font,
                                        widget = wibox.widget.textbox
                                    },
                                    left = dpi(10),
                                    widget = wibox.container.margin
                                },
                                layout = wibox.layout.fixed.horizontal
                            },
                            layout = wibox.layout.fixed.vertical
                        },
                        nil,
                        expand = "none",
                        layout = wibox.layout.align.vertical
                    },
                    margins = dpi(8),
                    widget = wibox.container.margin
                },
                layout = wibox.layout.align.horizontal
            },
            top = dpi(2),
            bottom = dpi(2),
            widget = wibox.container.margin
        },
        bg = beautiful.xcolor0,
        shape = helpers.rrect(dpi(2)),
        widget = wibox.container.background
    }

    return box
end

notif_container:buttons(gears.table.join(
    awful.button({}, 4, nil, function()
        if #notif_container.children == 1 then return end
        notif_container:insert(1, notif_container.children[#notif_container.children])
        notif_container:remove(#notif_container.children)
    end),

    awful.button({}, 5, nil, function()
        if #notif_container.children == 1 then return end
        notif_container:insert(#notif_container.children + 1, notif_container.children[1])
        notif_container:remove(1)
    end)
))

notif_container:insert(1, empty)

naughty.connect_signal("request::display", function(n)

    if #notif_container.children == 1 and remove_notif_empty then
        notif_container:reset(notif_container)
        remove_notif_empty = false
    end

    local notif_color = beautiful.groups_bg
    if n.urgency == 'critical' then
        notif_color = beautiful.xcolor1 .. '66'
    end
    local appicon = n.icon or n.app_icon
    if not appicon then appicon = beautiful.notification_icon end

    notif_container:insert(1, create_notif(appicon, n, width))
end)

local notif_center =  wibox.widget {
    {
        {
            notif_header,
            nil,
            clear,
            expand = "none",
            spacing = dpi(10),
            layout = wibox.layout.align.horizontal
        },
        left = dpi(5),
        right = dpi(5),
        layout = wibox.container.margin
    },
    notif_container,

    spacing = dpi(10),
    layout = wibox.layout.fixed.vertical
}

notifs = wibox({
    type = "dock",
    screen = screen.primary,
    height = beautiful.notifs_height or dpi(310),
    width = beautiful.notifs_width or dpi(270),
    shape = helpers.rrect(dpi(8)),
    ontop = true,
    visible = false
})

awful.placement.bottom_left(
    notifs,
    {
        honor_workarea = true,
        margins = {
            bottom = 50,
            left = beautiful.wibar_width + 11
        }
    })

local slide = rubato.timed{
    pos = dpi(10),
    rate = 60,
    intro = 0.025,
    duration = 0.5,
    easing = rubato.quadratic,
    awestore_compat = true,
    subscribed = function(pos) notifs.y = pos end
}

local notifs_status = false

slide.ended:subscribe(function()
    if notifs_status then
        notifs.visible = false
    end
end)

notifs_show = function()
    notifs.visible = true
    slide:set(dpi(445))
    notifs_status = false
end

notifs_hide = function()
    slide:set(dpi(10))
    notifs_status = true
end

notifs_toggle = function()
    if notifs.visible then
        notifs_hide()
    else
        notifs_show()
    end
end

notifs:setup {
    notif_center,
	margins = dpi(15),
	widget = wibox.container.margin
}
