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
    markup = "Notifications Center",
    font = beautiful.font_name .. "Bold 12",
    align = 'center',
    valign = 'center',
    widget = wibox.widget.textbox
}

-- Clear button
local clear = wibox.widget {
    markup = "",
    font = beautiful.icon_font_name .. "Round 16",
    align = "center",
    valign = "center",
    widget = wibox.widget.textbox
}

clear:buttons(gears.table.join(
    awful.button({}, 1, function()
        _G.reset_notif_container()
    end)
))

helpers.add_hover_cursor(clear, "hand2")

-- Empty notifs
local empty = wibox.widget {
    {
        {
            expand = 'none',
            layout = wibox.layout.align.horizontal,
            nil,
            {
                image = beautiful.notification_icon,
                forced_width = dpi(60),
                forced_height = dpi(60),
                halign = "center",
                valign = "center",
                widget = wibox.widget.imagebox
            },
            nil
        },
        {
            markup = 'You have no notifs!',
            font = beautiful.font_name .. 'medium 10',
            align = 'center',
            valign = 'center',
            widget = wibox.widget.textbox
        },
        layout = wibox.layout.fixed.vertical,
        spacing = dpi(10)
    },
    top = dpi(100),
    widget = wibox.container.margin
}

-- Mouse scroll
local notif_container = wibox.layout.fixed.vertical()
notif_container.spacing = dpi(15)
notif_container.forced_width = dpi(270)

local remove_notif_empty = true

reset_notif_container = function()
    notif_container:reset(notif_container)
    notif_container:insert(1, empty)
    remove_notif_empty = true
end

remove_notifbox = function(box)
        notif_container:remove_widgets(box)

    if #notif_container.children == 0 then
        notif_container:insert(1, empty)
        remove_notif_empty = true
    end
end

local return_date_time = function(format)
	return os.date(format)
end

local parse_to_seconds = function(time)
	local hourInSec = tonumber(string.sub(time, 1, 2)) * 3600
	local minInSec = tonumber(string.sub(time, 4, 5)) * 60
	local getSec = tonumber(string.sub(time, 7, 8))
	return (hourInSec + minInSec + getSec)
end

local create_notif = function(icon, n, width)

    --Time
	local time_of_pop = return_date_time('%H:%M:%S')
	local exact_time = return_date_time('%I:%M %p')
	local exact_date_time = return_date_time('%b %d, %I:%M %p')

	local timepop =  wibox.widget {
		id = 'time_pop',
		markup = nil,
		font = beautiful.font_name .. "medium 8",
        align = "center",
        valign = "center",
		visible = true,
		widget = wibox.widget.textbox
	}

	local time_of_popup = gears.timer {
		timeout   = 60,
		call_now  = true,
		autostart = true,
		callback  = function()

			local time_difference = nil

			time_difference = parse_to_seconds(return_date_time('%H:%M:%S')) - parse_to_seconds(time_of_pop)
			time_difference = tonumber(time_difference)

			if time_difference < 60 then
				timepop:set_markup('now')

			elseif time_difference >= 60 and time_difference < 3600 then
				local time_in_minutes = math.floor(time_difference / 60)
				timepop:set_markup(time_in_minutes .. 'm ago')

			elseif time_difference >= 3600 and time_difference < 86400 then
				timepop:set_markup(exact_time)

			elseif time_difference >= 86400 then
				timepop:set_markup(exact_date_time)
				return false

			end

			collectgarbage('collect')
		end
	}

    local box = {}

    -- Dismiss button
    local dismiss= wibox.widget {
        {
            {
                markup = helpers.colorize_text("", beautiful.xcolor1),
                font = beautiful.icon_font_name .. "Round 10",
                align = "center",
                valign = "center",
                widget = wibox.widget.textbox
            },
            margins = dpi(2),
            widget = wibox.container.margin
        },
    shape = gears.shape.circle,
    widget = wibox.container.background
    }

    dismiss:connect_signal("mouse::enter", function()
        dismiss.bg = beautiful.xcolor8
    end)

    dismiss:connect_signal("mouse::leave", function()
        dismiss.bg = beautiful.xcolor0
    end)

    dismiss:buttons(gears.table.join(
        awful.button({}, 1, function()
            _G.remove_notifbox(box)
        end)
    ))

    helpers.add_hover_cursor(dismiss, "hand2")


    -- Create notifs
    box = wibox.widget {
        {
            {
                {
                    {
                        image = icon,
                        resize = true,
                        clip_shape = helpers.rrect(dpi(6)),
                        halign = "center",
                        valign = "center",
                        widget = wibox.widget.imagebox
                    },
                    strategy = 'exact',
                    height = dpi(50),
                    width = dpi(50),
                    widget = wibox.container.constraint
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
                                        markup = n.title,
                                        font = beautiful.font_name .. "medium 10",
                                        align = "left",
                                        widget = wibox.widget.textbox
                                    },
                                    forced_width = dpi(140),
                                    widget = wibox.container.scroll.horizontal
                                },
                                nil,
                                {
                                    timepop,
                                    layout = wibox.layout.fixed.horizontal
                                },
                                expand = "none",
                                layout = wibox.layout.align.horizontal
                            },
                            {
                                {
                                    step_function = wibox.container.scroll
                                    .step_functions
                                    .waiting_nonlinear_back_and_forth,
                                    speed = 50,
                                    {
                                        markup = n.message,
                                        font = beautiful.font_name .. "medium 8",
                                        align = "left",
                                        widget = wibox.widget.textbox
                                    },
                                    forced_width = dpi(165),
                                    widget = wibox.container.scroll.horizontal
                                },
                                nil,
                                {
                                    dismiss,
                                    layout = wibox.layout.fixed.horizontal
                                },
                                expand = "none",
                                layout = wibox.layout.align.horizontal
                            },
                            spacing = dpi(2),
                            layout = wibox.layout.fixed.vertical
                        },
                        expand = "none",
                        layout = wibox.layout.align.vertical
                    },
                    left = dpi(12),
                    widget = wibox.container.margin
                },
                layout = wibox.layout.align.horizontal
            },
            margins = dpi(8),
            widget = wibox.container.margin
        },
        bg = beautiful.xcolor0,
        shape = helpers.rrect(dpi(6)),
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

-- Init widgets
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

    spacing = dpi(20),
    layout = wibox.layout.fixed.vertical
}

notifs = wibox({
    type = "dock",
    screen = screen.primary,
    height =  dpi(380),
    width = dpi(300),
    shape = helpers.rrect(beautiful.border_radius),
    ontop = true,
    visible = false
})
notifs.y = dpi(365)

-- Rubato
local slide = rubato.timed{
    pos = dpi(-300),
    rate = 60,
    intro = 0.3,
    duration = 0.8,
    easing = rubato.quadratic,
    awestore_compat = true,
    subscribed = function(pos) notifs.x = pos end
}

local notifs_status = false

slide.ended:subscribe(function()
    if notifs_status then
        notifs.visible = false
    end
end)

-- Make toogle button
notifs_show = function()
    notifs.visible = true
    slide:set(dpi(100))
    notifs_status = false
end

notifs_hide = function()
    slide:set(dpi(-375))
    notifs_status = true
end

notifs_toggle = function()
    if notifs.visible then
        notifs_hide()
    else
        notifs_show()
    end
end

-- notifs setup
notifs:setup {
    notif_center,
	margins = dpi(15),
	widget = wibox.container.margin
}
