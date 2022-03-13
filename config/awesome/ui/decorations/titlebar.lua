local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local bling = require("module.bling")
local helpers = require("helpers")

-- Shape buttons
local function create_title_button(c, color_focus, color_unfocus, shp)
    local tb = wibox.widget {
        forced_width = dpi(20),
        forced_height = dpi(20),
        bg = color_focus .. 90,
        shape = shp,
        border_color = beautiful.border_color,
        widget = wibox.container.background
    }

    local function update()
        if client.focus == c then
            tb.bg = color_focus
        else
            tb.bg = color_unfocus
        end
    end
    update()

    c:connect_signal("focus", update)
    c:connect_signal("unfocus", update)

    tb:connect_signal("mouse::enter", function() tb.bg = color_focus .. 55 end)
    tb:connect_signal("mouse::leave", function() tb.bg = color_focus end)

    tb.visible = true
    return tb
end

-- Text buttons
local function create_text_title_button(c, symbol, font, color_focus, color_unfocus)
    local tb = wibox.widget {
        align = "center",
        valign = "center",
        font = font,
        -- Initialize with the "unfocused" color
        markup = symbol,
        -- Increase the width of the textbox in order to make it easier to click. It does not affect the size of the symbol itself.
        forced_width = dpi(20),
        widget = wibox.widget.textbox
    }

    local function update()
        if client.focus == c then
            tb.markup = helpers.colorize_text(symbol, color_focus)
        else
            tb.markup = helpers.colorize_text(symbol, color_unfocus)
        end
    end
    update()

    c:connect_signal("focus", update)
    c:connect_signal("unfocus", update)

    tb:connect_signal("mouse::enter", function() tb.markup = helpers.colorize_text(symbol, color_focus .. 55) end)
    tb:connect_signal("mouse::leave", function() tb.markup = helpers.colorize_text(symbol, color_focus) end)

    tb.visible = true
    return tb
end

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar

    local buttons = gears.table.join(awful.button({}, 1, function()
        c:emit_signal("request::activate", "titlebar", {raise = true})
        if c.maximized == true then c.maximized = false end
        awful.mouse.client.move(c)
    end), awful.button({}, 3, function()
        c:emit_signal("request::activate", "titlebar", {raise = true})
        awful.mouse.client.resize(c)
    end))
    local borderbuttons = gears.table.join( awful.button({}, 3, function()
        c:emit_signal("request::activate", "titlebar", {raise = true})
        awful.mouse.client.resize(c)
    end), awful.button({}, 1, function()
        c:emit_signal("request::activate", "titlebar", {raise = true})
        awful.mouse.client.resize(c)
    end))

    -- Shapes

        local circle = function(width, height)
            return function(cr) gears.shape.circle(cr, width, height) end
        end

    -- Buttons

        local love = create_text_title_button(c, "", "Material Icons 11", beautiful.xcolor1, beautiful.titlebar_unfocused)
        love:connect_signal("button::press", function() c:kill() end)

        local float = create_title_button(c, beautiful.xcolor4, beautiful.titlebar_unfocused, circle(dpi(11), dpi(11)))
        float:connect_signal("button::press", function() awful.client.floating.toggle(c) end)

        local max = create_title_button(c, beautiful.xcolor5, beautiful.titlebar_unfocused, circle(dpi(11), dpi(11)))
        max:connect_signal("button::press", function() c.maximized = not c.maximized end)

    local wrap_widget = function(w)
        return {
            w,
            top = dpi(20),
            widget = wibox.container.margin
        }
    end

    local wrap_text_widget = function(w)
        return {
            w,
            top = dpi(5),
            right = dpi(5),
            widget = wibox.container.margin
        }
    end

    -- Titlebar setup

    awful.titlebar(c, {
        position = "top",
        size = beautiful.titlebar_size,
        bg = "#00000000",
    }):setup{
            {   -- left
                wrap_text_widget({
                    love,
                    left = dpi(25),
                    widget = wibox.container.margin
                }),
                wrap_widget(float),
                wrap_widget(max),
                buttons = buttons,
                layout = wibox.layout.fixed.horizontal,
            },
            {   -- middle
                awful.titlebar.widget.titlewidget(c),
                layout  = wibox.layout.fixed.horizontal
            },
            {   -- right
                layout  = wibox.layout.fixed.horizontal
            },
        bg = beautiful.darker_bg,
        shape = helpers.prrect(beautiful.border_radius, true, true, false, false),
        widget = wibox.container.background
    }

    awful.titlebar(c, {
        position = "bottom",
        size = dpi(24),
        bg = "#00000000"
    }):setup{
        bg = beautiful.darker_bg,
        shape = helpers.prrect(beautiful.border_radius, false, false, true, true),
        widget = wibox.container.background
    }
end)

