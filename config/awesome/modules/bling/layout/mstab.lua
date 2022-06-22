local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")

local mylayout = {}

mylayout.name = "mstab"

local tabbar_disable = beautiful.mstab_bar_disable or false
local tabbar_ontop = beautiful.mstab_bar_ontop or false
local tabbar_padding = beautiful.mstab_bar_padding or "default"
local border_radius = beautiful.mstab_border_radius
    or beautiful.border_radius
    or 0
local tabbar_position = beautiful.mstab_tabbar_position
    or beautiful.tabbar_position
    or "top"

local bar_style = beautiful.mstab_tabbar_style
    or beautiful.tabbar_style
    or "default"
local bar = require(
    tostring(...):match(".*bling") .. ".widget.tabbar." .. bar_style
)
local tabbar_size = bar.size
    or beautiful.mstab_bar_height
    or beautiful.tabbar_size
    or 40
local dont_resize_slaves = beautiful.mstab_dont_resize_slaves or false

-- The top_idx is the idx of the slave clients (excluding all master clients)
-- that should be on top of all other slave clients ("the focused slave")
-- by creating a variable outside of the arrange function, this layout can "remember" that client
-- by creating it as a new property of every tag, this layout can be active on different tags and
-- still have different "focused slave clients"
for idx, tag in ipairs(root.tags()) do
    tag.top_idx = 1
end

-- Haven't found a signal that is emitted when a new tag is added. That should work though
-- since you can't use a layout on a tag that you haven't selected previously
tag.connect_signal("property::selected", function(t)
    if not t.top_idx then
        t.top_idx = 1
    end
end)

function update_tabbar(
    clients,
    t,
    top_idx,
    area,
    master_area_width,
    slave_area_width
)
    local s = t.screen

    -- create the list of clients for the tabbar
    local clientlist = bar.layout()
    for idx, c in ipairs(clients) do
        -- focus with right click, kill with mid click, minimize with left click
        local buttons = gears.table.join(
            awful.button({}, 1, function()
                c:raise()
                client.focus = c
            end),
            awful.button({}, 2, function()
                c:kill()
            end),
            awful.button({}, 3, function()
                c.minimized = true
            end)
        )
        local client_box = bar.create(c, (idx == top_idx), buttons)
        clientlist:add(client_box)
    end

    -- if no tabbar exists, create one
    if not s.tabbar then
        s.tabbar = wibox({
            ontop = tabbar_ontop,
            shape = function(cr, width, height)
                gears.shape.rounded_rect(cr, width, height, border_radius)
            end,
            bg = bar.bg_normal,
            visible = true,
        })

        -- Change visibility of the tab bar when layout, selected tag or number of clients (visible, master, slave) changes
        local function adjust_visibility()
            local name = awful.layout.getname( awful.layout.get( s ) )
            s.tabbar.visible = (name == mylayout.name)
        end

        tag.connect_signal("property::selected", adjust_visibility)
        tag.connect_signal("property::layout", adjust_visibility)
        tag.connect_signal("tagged", adjust_visibility)
        tag.connect_signal("untagged", adjust_visibility)
        tag.connect_signal("property::master_count", adjust_visibility)
        client.connect_signal("property::minimized", adjust_visibility)
    end

    -- update the tabbar size and position (to support gap size change on the fly)
    if tabbar_position == "top" then
        s.tabbar.x = area.x + master_area_width + t.gap
        s.tabbar.y = area.y + t.gap
        s.tabbar.width = slave_area_width - 2 * t.gap
        s.tabbar.height = tabbar_size
    elseif tabbar_position == "bottom" then
        s.tabbar.x = area.x + master_area_width + t.gap
        s.tabbar.y = area.y + area.height - tabbar_size - t.gap
        s.tabbar.width = slave_area_width - 2 * t.gap
        s.tabbar.height = tabbar_size
    elseif tabbar_position == "left" then
        s.tabbar.x = area.x + master_area_width + t.gap
        s.tabbar.y = area.y + t.gap
        s.tabbar.width = tabbar_size
        s.tabbar.height = area.height - 2 * t.gap
    elseif tabbar_position == "right" then
        s.tabbar.x = area.x
            + master_area_width
            + slave_area_width
            - tabbar_size
            - t.gap
        s.tabbar.y = area.y + t.gap
        s.tabbar.width = tabbar_size
        s.tabbar.height = area.height - 2 * t.gap
    end

    -- update clientlist
    s.tabbar:setup({ layout = wibox.layout.flex.horizontal, clientlist })
end

function mylayout.arrange(p)
    local area = p.workarea
    local t = p.tag or screen[p.screen].selected_tag
    local s = t.screen
    local mwfact = t.master_width_factor
    local nmaster = math.min(t.master_count, #p.clients)
    local nslaves = #p.clients - nmaster

    local master_area_width = area.width * mwfact
    local slave_area_width = area.width - master_area_width

    -- "default" means that it uses standard useless gap size
    if tabbar_padding == "default" then
        tabbar_padding = 2 * t.gap
    end

    -- Special case: No masters -> full screen slave width
    if nmaster == 0 then
        master_area_width = 1
        slave_area_width = area.width
    end

    -- Special case: One or zero slaves -> no tabbar (essentially tile right)
    if nslaves <= 1 then
        -- since update_tabbar isnt called that way we have to hide it manually
        if s.tabbar then
            s.tabbar.visible = false
        end
        -- otherwise just do tile right
        awful.layout.suit.tile.right.arrange(p)
        return
    end

    -- Iterate through masters
    for idx = 1, nmaster do
        local c = p.clients[idx]
        local g = {
            x = area.x,
            y = area.y + (idx - 1) * (area.height / nmaster),
            width = master_area_width,
            height = area.height / nmaster,
        }
        p.geometries[c] = g
    end

    local tabbar_size_change = 0
    local tabbar_width_change = 0
    local tabbar_y_change = 0
    local tabbar_x_change = 0
    if not tabbar_disable then
        if tabbar_position == "top" then
            tabbar_size_change = tabbar_size + tabbar_padding
            tabbar_y_change = tabbar_size + tabbar_padding
        elseif tabbar_position == "bottom" then
            tabbar_size_change = tabbar_size + tabbar_padding
        elseif tabbar_position == "left" then
            tabbar_width_change = tabbar_size + tabbar_padding
            tabbar_x_change = tabbar_size + tabbar_padding
        elseif tabbar_position == "right" then
            tabbar_width_change = tabbar_size + tabbar_padding
        end
    end

    -- Iterate through slaves
    -- (also creates a list of all slave clients for update_tabbar)
    local slave_clients = {}
    for idx = 1, nslaves do
        local c = p.clients[idx + nmaster]
        slave_clients[#slave_clients + 1] = c
        if c == client.focus then
            t.top_idx = #slave_clients
        end
        local g = {
            x = area.x + master_area_width + tabbar_x_change,
            y = area.y + tabbar_y_change,
            width = slave_area_width - tabbar_width_change,
            height = area.height - tabbar_size_change,
        }
        if not dont_resize_slaves and idx ~= t.top_idx then
            g = {
                x = area.x + master_area_width + slave_area_width / 4,
                y = area.y + tabbar_size + area.height / 4,
                width = slave_area_width / 2,
                height = area.height / 4 - tabbar_size,
            }
        end
        p.geometries[c] = g
    end

    if not tabbar_disable then
        update_tabbar(
            slave_clients,
            t,
            t.top_idx,
            area,
            master_area_width,
            slave_area_width
        )
    end
end

return mylayout
