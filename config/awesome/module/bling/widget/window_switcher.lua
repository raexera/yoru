local cairo = require("lgi").cairo
local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local helpers = require(tostring(...):match(".*bling") .. ".helpers")
local dpi = beautiful.xresources.apply_dpi

local window_switcher_first_client -- The client that was focused when the window_switcher was activated
local window_switcher_minimized_clients = {} -- The clients that were minimized when the window switcher was activated
local window_switcher_grabber

local get_num_clients = function()
    local minimized_clients_in_tag = 0
    local matcher = function(c)
        return awful.rules.match(
            c,
            {
                minimized = true,
                skip_taskbar = false,
                hidden = false,
                first_tag = awful.screen.focused().selected_tag,
            }
        )
    end
    for c in awful.client.iterate(matcher) do
        minimized_clients_in_tag = minimized_clients_in_tag + 1
    end
    return minimized_clients_in_tag + #awful.screen.focused().clients
end

local window_switcher_hide = function(window_switcher_box)
    -- Add currently focused client to history
    if client.focus then
        local window_switcher_last_client = client.focus
        awful.client.focus.history.add(window_switcher_last_client)
        -- Raise client that was focused originally
        -- Then raise last focused client
        if
            window_switcher_first_client and window_switcher_first_client.valid
        then
            window_switcher_first_client:raise()
            window_switcher_last_client:raise()
        end
    end

    -- Minimize originally minimized clients
    local s = awful.screen.focused()
    for _, c in pairs(window_switcher_minimized_clients) do
        if c and c.valid and not (client.focus and client.focus == c) then
            c.minimized = true
        end
    end
    -- Reset helper table
    window_switcher_minimized_clients = {}

    -- Resume recording focus history
    awful.client.focus.history.enable_tracking()
    -- Stop and hide window_switcher
    awful.keygrabber.stop(window_switcher_grabber)
    window_switcher_box.visible = false
    window_switcher_box.widget = nil
    collectgarbage("collect")
end

local function draw_widget(
    type,
    background,
    border_width,
    border_radius,
    border_color,
    clients_spacing,
    client_icon_horizontal_spacing,
    client_width,
    client_height,
    client_margins,
    thumbnail_margins,
    thumbnail_scale,
    name_margins,
    name_valign,
    name_forced_width,
    name_font,
    name_normal_color,
    name_focus_color,
    icon_valign,
    icon_width,
    mouse_keys
)
    local tasklist_widget = type == "thumbnail"
            and awful.widget.tasklist({
                screen = awful.screen.focused(),
                filter = awful.widget.tasklist.filter.currenttags,
                buttons = mouse_keys,
                style = {
                    font = name_font,
                    fg_normal = name_normal_color,
                    fg_focus = name_focus_color,
                },
                layout = {
                    layout = wibox.layout.flex.horizontal,
                    spacing = clients_spacing,
                },
                widget_template = {
                    widget = wibox.container.background,
                    id = "bg_role",
                    forced_width = client_width,
                    forced_height = client_height,
                    create_callback = function(self, c, _, __)
                        local content = gears.surface(c.content)
                        local cr = cairo.Context(content)
                        local x, y, w, h = cr:clip_extents()
                        local img = cairo.ImageSurface.create(
                            cairo.Format.ARGB32,
                            w - x,
                            h - y
                        )
                        cr = cairo.Context(img)
                        cr:set_source_surface(content, 0, 0)
                        cr.operator = cairo.Operator.SOURCE
                        cr:paint()
                        self:get_children_by_id("thumbnail")[1].image =
                            gears.surface.load(
                                img
                            )
                    end,
                    {
                        {
                            {
                                horizontal_fit_policy = thumbnail_scale == true
                                        and "fit"
                                    or "auto",
                                vertical_fit_policy = thumbnail_scale == true
                                        and "fit"
                                    or "auto",
                                id = "thumbnail",
                                widget = wibox.widget.imagebox,
                            },
                            margins = thumbnail_margins,
                            widget = wibox.container.margin,
                        },
                        {
                            {
                                {
                                    id = "icon_role",
                                    widget = wibox.widget.imagebox,
                                },
                                forced_width = icon_width,
                                valign = icon_valign,
                                widget = wibox.container.place,
                            },
                            {
                                {
                                    forced_width = name_forced_width,
                                    valign = name_valign,
                                    id = "text_role",
                                    widget = wibox.widget.textbox,
                                },
                                margins = name_margins,
                                widget = wibox.container.margin,
                            },
                            spacing = client_icon_horizontal_spacing,
                            layout = wibox.layout.fixed.horizontal,
                        },
                        layout = wibox.layout.flex.vertical,
                    },
                },
            })
        or awful.widget.tasklist({
            screen = awful.screen.focused(),
            filter = awful.widget.tasklist.filter.currenttags,
            buttons = mouse_keys,
            style = {
                font = name_font,
                fg_normal = name_normal_color,
                fg_focus = name_focus_color,
            },
            layout = {
                layout = wibox.layout.fixed.vertical,
                spacing = clients_spacing,
            },
            widget_template = {
                widget = wibox.container.background,
                id = "bg_role",
                forced_width = client_width,
                forced_height = client_height,
                {
                    {
                        {
                            id = "icon_role",
                            widget = wibox.widget.imagebox,
                        },
                        forced_width = icon_width,
                        valign = icon_valign,
                        widget = wibox.container.place,
                    },
                    {
                        {
                            forced_width = name_forced_width,
                            valign = name_valign,
                            id = "text_role",
                            widget = wibox.widget.textbox,
                        },
                        margins = name_margins,
                        widget = wibox.container.margin,
                    },
                    spacing = client_icon_horizontal_spacing,
                    layout = wibox.layout.fixed.horizontal,
                },
            },
        })

    return wibox.widget({
        {
            tasklist_widget,
            margins = client_margins,
            widget = wibox.container.margin,
        },
        shape_border_width = border_width,
        shape_border_color = border_color,
        bg = background,
        shape = helpers.shape.rrect(border_radius),
        widget = wibox.container.background,
    })
end

local enable = function(opts)
    local opts = opts or {}

    local type = opts.type or "thumbnail"
    local background = beautiful.window_switcher_widget_bg or "#000000"
    local border_width = beautiful.window_switcher_widget_border_width or dpi(3)
    local border_radius = beautiful.window_switcher_widget_border_radius
        or dpi(0)
    local border_color = beautiful.window_switcher_widget_border_color
        or "#ffffff"
    local clients_spacing = beautiful.window_switcher_clients_spacing or dpi(20)
    local client_icon_horizontal_spacing = beautiful.window_switcher_client_icon_horizontal_spacing
        or dpi(5)
    local client_width = beautiful.window_switcher_client_width
        or dpi(type == "thumbnail" and 150 or 500)
    local client_height = beautiful.window_switcher_client_height
        or dpi(type == "thumbnail" and 250 or 50)
    local client_margins = beautiful.window_switcher_client_margins or dpi(10)
    local thumbnail_margins = beautiful.window_switcher_thumbnail_margins
        or dpi(5)
    local thumbnail_scale = beautiful.thumbnail_scale or false
    local name_margins = beautiful.window_switcher_name_margins or dpi(10)
    local name_valign = beautiful.window_switcher_name_valign or "center"
    local name_forced_width = beautiful.window_switcher_name_forced_width
        or dpi(type == "thumbnail" and 200 or 550)
    local name_font = beautiful.window_switcher_name_font or beautiful.font
    local name_normal_color = beautiful.window_switcher_name_normal_color
        or "#FFFFFF"
    local name_focus_color = beautiful.window_switcher_name_focus_color
        or "#FF0000"
    local icon_valign = beautiful.window_switcher_icon_valign or "center"
    local icon_width = beautiful.window_switcher_icon_width or dpi(40)

    local hide_window_switcher_key = opts.hide_window_switcher_key or "Escape"

    local select_client_key = opts.select_client_key or 1
    local minimize_key = opts.minimize_key or "n"
    local unminimize_key = opts.unminimize_key or "N"
    local kill_client_key = opts.kill_client_key or "q"

    local cycle_key = opts.cycle_key or "Tab"

    local previous_key = opts.previous_key or "Left"
    local next_key = opts.next_key or "Right"

    local vim_previous_key = opts.vim_previous_key or "h"
    local vim_next_key = opts.vim_next_key or "l"

    local scroll_previous_key = opts.scroll_previous_key or 4
    local scroll_next_key = opts.scroll_next_key or 5

    local window_switcher_box = awful.popup({
        bg = "#00000000",
        visible = false,
        ontop = true,
        placement = awful.placement.centered,
        screen = awful.screen.focused(),
        widget = wibox.container.background, -- A dummy widget to make awful.popup not scream
        widget = {
            {
                draw_widget(),
                margins = client_margins,
                widget = wibox.container.margin,
            },
            shape_border_width = border_width,
            shape_border_color = border_color,
            bg = background,
            shape = helpers.shape.rrect(border_radius),
            widget = wibox.container.background,
        },
    })

    local mouse_keys = gears.table.join(
        awful.button({
            modifiers = { "Any" },
            button = select_client_key,
            on_press = function(c)
                client.focus = c
            end,
        }),

        awful.button({
            modifiers = { "Any" },
            button = scroll_previous_key,
            on_press = function()
                awful.client.focus.byidx(-1)
            end,
        }),

        awful.button({
            modifiers = { "Any" },
            button = scroll_next_key,
            on_press = function()
                awful.client.focus.byidx(1)
            end,
        })
    )

    local keyboard_keys = {
        [hide_window_switcher_key] = function()
            window_switcher_hide(window_switcher_box)
        end,

        [minimize_key] = function()
            if client.focus then
                client.focus.minimized = true
            end
        end,
        [unminimize_key] = function()
            if awful.client.restore() then
                client.focus = awful.client.restore()
            end
        end,
        [kill_client_key] = function()
            if client.focus then
                client.focus:kill()
            end
        end,

        [cycle_key] = function()
            awful.client.focus.byidx(1)
        end,

        [previous_key] = function()
            awful.client.focus.byidx(1)
        end,
        [next_key] = function()
            awful.client.focus.byidx(-1)
        end,

        [vim_previous_key] = function()
            awful.client.focus.byidx(1)
        end,
        [vim_next_key] = function()
            awful.client.focus.byidx(-1)
        end,
    }

    window_switcher_box:connect_signal("property::width", function()
        if window_switcher_box.visible and get_num_clients() == 0 then
            window_switcher_hide(window_switcher_box)
        end
    end)

    window_switcher_box:connect_signal("property::height", function()
        if window_switcher_box.visible and get_num_clients() == 0 then
            window_switcher_hide(window_switcher_box)
        end
    end)

    awesome.connect_signal("bling::window_switcher::turn_on", function()
        local number_of_clients = get_num_clients()
        if number_of_clients == 0 then
            return
        end

        -- Store client that is focused in a variable
        window_switcher_first_client = client.focus

        -- Stop recording focus history
        awful.client.focus.history.disable_tracking()

        -- Go to previously focused client (in the tag)
        awful.client.focus.history.previous()

        -- Track minimized clients
        -- Unminimize them
        -- Lower them so that they are always below other
        -- originally unminimized windows
        local clients = awful.screen.focused().selected_tag:clients()
        for _, c in pairs(clients) do
            if c.minimized then
                table.insert(window_switcher_minimized_clients, c)
                c.minimized = false
                c:lower()
            end
        end

        -- Start the keygrabber
        window_switcher_grabber = awful.keygrabber.run(function(_, key, event)
            if event == "release" then
                -- Hide if the modifier was released
                -- We try to match Super or Alt or Control since we do not know which keybind is
                -- used to activate the window switcher (the keybind is set by the user in keys.lua)
                if
                    key:match("Super")
                    or key:match("Alt")
                    or key:match("Control")
                then
                    window_switcher_hide(window_switcher_box)
                end
                -- Do nothing
                return
            end

            -- Run function attached to key, if it exists
            if keyboard_keys[key] then
                keyboard_keys[key]()
            end
        end)

        window_switcher_box.widget = draw_widget(
            type,
            background,
            border_width,
            border_radius,
            border_color,
            clients_spacing,
            client_icon_horizontal_spacing,
            client_width,
            client_height,
            client_margins,
            thumbnail_margins,
            thumbnail_scale,
            name_margins,
            name_valign,
            name_forced_width,
            name_font,
            name_normal_color,
            name_focus_color,
            icon_valign,
            icon_width,
            mouse_keys
        )
        window_switcher_box.visible = true
    end)
end

return { enable = enable }
