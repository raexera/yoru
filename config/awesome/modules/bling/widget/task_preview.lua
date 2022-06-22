--
-- Provides:
-- bling::task_preview::visibility
--      s   (screen)
--      v   (boolean)
--      c   (client)
--
local awful = require("awful")
local wibox = require("wibox")
local helpers = require(tostring(...):match(".*bling") .. ".helpers")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local cairo = require("lgi").cairo

-- TODO: rename structure to something better?
local function draw_widget(
    c,
    widget_template,
    screen_radius,
    widget_bg,
    widget_border_color,
    widget_border_width,
    margin,
    widget_width,
    widget_height
)
    if not pcall(function()
        return type(c.content)
    end) then
        return
    end

    local content = nil
    if c.active then
        content = gears.surface(c.content)
    elseif c.prev_content then
        content = gears.surface(c.prev_content)
    end

    local img = nil
    if content ~= nil then
        local cr = cairo.Context(content)
        local x, y, w, h = cr:clip_extents()
        img = cairo.ImageSurface.create(cairo.Format.ARGB32, w - x, h - y)
        cr = cairo.Context(img)
        cr:set_source_surface(content, 0, 0)
        cr.operator = cairo.Operator.SOURCE
        cr:paint()
    end

    local widget = wibox.widget({
        (widget_template or {
            {
                {
                    {
                        {
                            id = "icon_role",
                            resize = true,
                            forced_height = dpi(20),
                            forced_width = dpi(20),
                            widget = wibox.widget.imagebox,
                        },
                        {
                            {
                                id = "name_role",
                                align = "center",
                                widget = wibox.widget.textbox,
                            },
                            left = dpi(4),
                            right = dpi(4),
                            widget = wibox.container.margin,
                        },
                        layout = wibox.layout.align.horizontal,
                    },
                    {
                        {
                            {
                                id = "image_role",
                                resize = true,
                                clip_shape = helpers.shape.rrect(screen_radius),
                                widget = wibox.widget.imagebox,
                            },
                            valign = "center",
                            halign = "center",
                            widget = wibox.container.place,
                        },
                        top = margin * 0.25,
                        widget = wibox.container.margin,
                    },
                    fill_space = true,
                    layout = wibox.layout.fixed.vertical,
                },
                margins = margin,
                widget = wibox.container.margin,
            },
            bg = widget_bg,
            shape_border_width = widget_border_width,
            shape_border_color = widget_border_color,
            shape = helpers.shape.rrect(screen_radius),
            widget = wibox.container.background,
        }),
        width = widget_width,
        height = widget_height,
        widget = wibox.container.constraint,
    })

    -- TODO: have something like a create callback here?

    for _, w in ipairs(widget:get_children_by_id("image_role")) do
        w.image = img -- TODO: copy it with gears.surface.xxx or something
    end

    for _, w in ipairs(widget:get_children_by_id("name_role")) do
        w.text = c.name
    end

    for _, w in ipairs(widget:get_children_by_id("icon_role")) do
        w.image = c.icon -- TODO: detect clienticon
    end

    return widget
end

local enable = function(opts)
    local opts = opts or {}

    local widget_x = opts.x or dpi(20)
    local widget_y = opts.y or dpi(20)
    local widget_height = opts.height or dpi(200)
    local widget_width = opts.width or dpi(200)
    local placement_fn = opts.placement_fn or nil

    local margin = beautiful.task_preview_widget_margin or dpi(0)
    local screen_radius = beautiful.task_preview_widget_border_radius or dpi(0)
    local widget_bg = beautiful.task_preview_widget_bg or "#000000"
    local widget_border_color = beautiful.task_preview_widget_border_color
        or "#ffffff"
    local widget_border_width = beautiful.task_preview_widget_border_width
        or dpi(3)

    local task_preview_box = awful.popup({
        type = "dropdown_menu",
        visible = false,
        ontop = true,
        placement = placement_fn,
        widget = wibox.container.background, -- A dummy widget to make awful.popup not scream
        input_passthrough = true,
        bg = "#00000000",
    })

    tag.connect_signal("property::selected", function(t)
        -- Awesome switches up tags on startup really fast it seems, probably depends on what rules you have set
        -- which can cause the c.content to not show the correct image
        gears.timer
        {
            timeout = 0.1,
            call_now  = false,
            autostart = true,
            single_shot = true,
            callback = function()
                if t.selected == true then
                    for _, c in ipairs(t:clients()) do
                        c.prev_content = gears.surface.duplicate_surface(c.content)
                    end
                end
            end
        }
    end)

    awesome.connect_signal("bling::task_preview::visibility", function(s, v, c)
        if v then
            -- Update task preview contents
            task_preview_box.widget = draw_widget(
                c,
                opts.structure,
                screen_radius,
                widget_bg,
                widget_border_color,
                widget_border_width,
                margin,
                widget_width,
                widget_height
            )
        else
            task_preview_box.widget = nil
            collectgarbage("collect")
        end

        if not placement_fn then
            task_preview_box.x = s.geometry.x + widget_x
            task_preview_box.y = s.geometry.y + widget_y
        end

        task_preview_box.visible = v
    end)
end

return { enable = enable, draw_widget = draw_widget }
