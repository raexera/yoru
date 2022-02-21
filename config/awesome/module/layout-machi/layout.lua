local this_package = ... and (...):match("(.-)[^%.]+$") or ""
local machi_editor = require(this_package.."editor")
local awful = require("awful")
local gobject = require("gears.object")
local capi = {
    screen = screen
}

local ERROR = 2
local WARNING = 1
local INFO = 0
local DEBUG = -1

local module = {
    log_level = WARNING,
    global_default_cmd = "w66.",
    allow_shrinking_by_mouse_moving = false,
}

local function log(level, msg)
    if level > module.log_level then
        print(msg)
    end
end

local function min(a, b)
    if a < b then return a else return b end
end

local function max(a, b)
    if a < b then return b else return a end
end

local function get_screen(s)
    return s and capi.screen[s]
end

awful.mouse.resize.add_enter_callback(
    function (c)
        c.full_width_before_move = c.width + c.border_width * 2
        c.full_height_before_move = c.height + c.border_width * 2
    end, 'mouse.move')

--- find the best area for the area-like object
-- @param c       area-like object - table with properties x, y, width, and height
-- @param areas   array of area objects
-- @return the index of the best area
local function find_area(c, areas)
    local choice = 1
    local choice_value = nil
    local c_area = c.width * c.height
    for i, a in ipairs(areas) do
        if a.habitable then
            local x_cap = max(0, min(c.x + c.width, a.x + a.width) - max(c.x, a.x))
            local y_cap = max(0, min(c.y + c.height, a.y + a.height) - max(c.y, a.y))
            local cap = x_cap * y_cap
            -- -- a cap b / a cup b
            -- local cup = c_area + a.width * a.height - cap
            -- if cup > 0 then
            --    local itx_ratio = cap / cup
            --    if choice_value == nil or choice_value < itx_ratio then
            --       choice_value = itx_ratio
            --       choice = i
            --    end
            -- end
            -- a cap b
            if choice_value == nil or choice_value < cap then
                choice = i
                choice_value = cap
            end
        end
    end
    return choice
end

local function distance(x1, y1, x2, y2)
    -- use d1
    return math.abs(x1 - x2) + math.abs(y1 - y2)
end

local function find_lu(c, areas, rd)
    local lu = nil
    for i, a in ipairs(areas) do
        if a.habitable then
            if rd == nil or (a.x < areas[rd].x + areas[rd].width and a.y < areas[rd].y + areas[rd].height) then
                if lu == nil or distance(c.x, c.y, a.x, a.y) < distance(c.x, c.y, areas[lu].x, areas[lu].y) then
                    lu = i
                end
            end
        end
    end
    return lu
end

local function find_rd(c, border_width, areas, lu)
    local x, y
    x = c.x + c.width + (border_width or 0) * 2
    y = c.y + c.height + (border_width or 0) * 2
    local rd = nil
    for i, a in ipairs(areas) do
        if a.habitable then
            if lu == nil or (a.x + a.width > areas[lu].x and a.y + a.height > areas[lu].y) then
                if rd == nil or distance(x, y, a.x + a.width, a.y + a.height) < distance(x, y, areas[rd].x + areas[rd].width, areas[rd].y + areas[rd].height) then
                    rd = i
                end
            end
        end
    end
    return rd
end

function module.set_geometry(c, area_lu, area_rd, useless_gap, border_width)
    -- We try to negate the gap of outer layer
    if area_lu ~= nil then
        c.x = area_lu.x - useless_gap
        c.y = area_lu.y - useless_gap
    end

    if area_rd ~= nil then
        c.width = area_rd.x + area_rd.width - c.x + useless_gap - border_width * 2
        c.height = area_rd.y + area_rd.height - c.y + useless_gap - border_width * 2
    end
end

-- TODO: the string need to be updated when its screen geometry changed.
local function get_machi_tag_string(tag)
    if tag.machi_tag_string == nil then
        tag.machi_tag_string =
            tostring(tag.screen.geometry.width) .. "x" .. tostring(tag.screen.geometry.height) .. "+" ..
            tostring(tag.screen.geometry.x) .. "+" .. tostring(tag.screen.geometry.y) .. '+' .. tag.name
    end
    return tag.machi_tag_string
end

function module.create(args_or_name, editor, default_cmd)
    local args
    if type(args_or_name) == "string" then
        args = {
            name = args_or_name
        }
    elseif type(args_or_name) == "function" then
        args = {
            name_func = args_or_name
        }
    elseif type(args_or_name) == "table" then
        args = args_or_name
    else
        return nil
    end
    if args.name == nil and args.name_func == nil then
        local prefix = args.icon_name and (args.icon_name.."-") or ""
        args.name_func = function (tag)
            return prefix..get_machi_tag_string(tag)
        end
    end
    args.editor = args.editor or editor or machi_editor.default_editor
    args.default_cmd = args.default_cmd or default_cmd or global_default_cmd
    args.persistent = args.persistent == nil or args.persistent

    local layout = {}
    local instances = {}

    local function get_instance_info(tag)
        return (args.name_func and args.name_func(tag) or args.name), args.persistent
    end

    local function get_instance_(tag)
        local name, persistent = get_instance_info(tag)
        if instances[name] == nil then
            instances[name] = {
                layout = layout,
                cmd = persistent and args.editor.get_last_cmd(name) or nil,
                areas_cache = {},
                tag_data = {},
                client_data = setmetatable({}, {__mode="k"}),
            }
            if instances[name].cmd == nil then
                instances[name].cmd = args.default_cmd
            end
        end
        return instances[name]
    end

    local function get_instance_data(screen, tag)
        local workarea = screen.workarea
        local instance = get_instance_(tag)
        local cmd = instance.cmd or module.global_default_cmd
        if cmd == nil then return end

        local key = tostring(workarea.width) .. "x" .. tostring(workarea.height) .. "+" .. tostring(workarea.x) .. "+" .. tostring(workarea.y)
        if instance.areas_cache[key] == nil then
            instance.areas_cache[key] = args.editor.run_cmd(cmd, screen, tag)
            if instance.areas_cache[key] == nil then
                return
            end
        end
        return instance.client_data, instance.tag_data, instance.areas_cache[key], instance, args.new_placement_cb
    end

    local function set_cmd(cmd, tag, keep_instance_data)
        local instance = get_instance_(tag)
        if instance.cmd ~= cmd then
            instance.cmd = cmd
            instance.areas_cache = {}
            for _, tag in pairs(instance.tag_data) do
                tag:emit_signal("property::layout")
            end
            if not keep_instance_data then
                instance.tag_data = {}
                instance.client_data = setmetatable({}, {__mode="k"})
            end
        end
    end

    local clean_up
    local tag_data = setmetatable({}, {__mode = "k"})

    clean_up = function (tag)
        local screen = tag.screen
        local _cd, _td, _areas, instance, _new_placement_cb = get_instance_data(screen, tag)

        if tag_data[tag].regsitered then
            tag_data[tag].regsitered = false
            tag:disconnect_signal("property::layout", clean_up)
            tag:connect_signal("property::selected", clean_up)
            for _, tag in pairs(instance.tag_data) do
                tag:emit_signal("property::layout")
            end
        end
    end

    clean_up_on_selected_change = function (tag)
        if not tag.selected then clean_up(tag) end
    end

    local function arrange(p)
        local useless_gap = p.useless_gap
        local screen = get_screen(p.screen)
        local wa = screen.workarea -- get the real workarea without the gap (instead of p.workarea)
        local cls = p.clients
        local tag = p.tag or screen.selected_tag
        local cd, td, areas, instance, new_placement_cb = get_instance_data(screen, tag)

        if not tag_data[tag] then tag_data[tag] = {} end
        if not tag_data[tag].registered then
            tag_data[tag].regsitered = true
            tag:connect_signal("property::layout", clean_up)
            tag:connect_signal("property::selected", clean_up)
        end

        if areas == nil then return end
        local nested_clients = {}

        local function place_client_in_area(c, area)
            if machi_editor.nested_layouts[areas[area].layout] ~= nil then
                local clients = nested_clients[area]
                if clients == nil then clients = {}; nested_clients[area] = clients end
                clients[#clients + 1] = c
            else
                p.geometries[c] = {}
                module.set_geometry(p.geometries[c], areas[area], areas[area], useless_gap, 0)
            end
        end

        -- Make clients calling new_placement_cb appear in the end.
        local j = 0
        for i = 1, #cls do
            cd[cls[i]] = cd[cls[i]] or {}
            if cd[cls[i]].placement then
                j = j + 1
                cls[j], cls[i] = cls[i], cls[j]
            end
        end

        for i, c in ipairs(cls) do
            if c.floating or c.immobilized then
                log(DEBUG, "Ignore client " .. tostring(c))
            else
                local geo = {
                    x = c.x,
                    y = c.y,
                    width = c.width + c.border_width * 2,
                    height = c.height + c.border_width * 2,
                }

                if not cd[c].placement and new_placement_cb then
                    cd[c].placement = true
                    new_placement_cb(c, instance, areas, geo)
                end

                local in_draft = cd[c].draft
                if cd[c].draft ~= nil then
                    in_draft = cd[c].draft
                elseif cd[c].lu then
                    in_draft = true
                elseif cd[c].area then
                    in_draft = false
                else
                    in_draft = nil
                end

                local skip = false

                if in_draft ~= false then
                    if cd[c].lu ~= nil and cd[c].rd ~= nil and
                        cd[c].lu <= #areas and cd[c].rd <= #areas and
                        areas[cd[c].lu].habitable and areas[cd[c].rd].habitable
                    then
                        if areas[cd[c].lu].x == geo.x and
                            areas[cd[c].lu].y == geo.y and
                            areas[cd[c].rd].x + areas[cd[c].rd].width == geo.x + geo.width and
                            areas[cd[c].rd].y + areas[cd[c].rd].height == geo.y + geo.height
                        then
                            skip = true
                        end
                    end

                    local lu = nil
                    local rd = nil
                    if not skip then
                        log(DEBUG, "Compute areas for " .. (c.name or ("<untitled:" .. tostring(c) .. ">")))
                        lu = find_lu(geo, areas)
                        if lu ~= nil then
                            geo.x = areas[lu].x
                            geo.y = areas[lu].y
                            rd = find_rd(geo, 0, areas, lu)
                        end
                    end

                    if lu ~= nil and rd ~= nil then
                        if lu == rd and cd[c].lu == nil then
                            cd[c].area = lu
                            place_client_in_area(c, lu)
                        else
                            cd[c].lu = lu
                            cd[c].rd = rd
                            cd[c].area = nil
                            p.geometries[c] = {}
                            module.set_geometry(p.geometries[c], areas[lu], areas[rd], useless_gap, 0)
                        end
                    end
                else
                    if cd[c].area ~= nil and
                        cd[c].area <= #areas and
                        areas[cd[c].area].habitable and
                        areas[cd[c].area].layout == nil and
                        areas[cd[c].area].x == geo.x and
                        areas[cd[c].area].y == geo.y and
                        areas[cd[c].area].width == geo.width and
                        areas[cd[c].area].height == geo.height
                    then
                        skip = true
                    else
                        log(DEBUG, "Compute areas for " .. (c.name or ("<untitled:" .. tostring(c) .. ">")))
                        local area = find_area(geo, areas)
                        cd[c].area, cd[c].lu, cd[c].rd = area, nil, nil
                        place_client_in_area(c, area)
                    end
                end

                if skip then
                    if geo.x ~= c.x or geo.y ~= c.y or
                        geo.width ~= c.width + c.border_width * 2 or
                        geo.height ~= c.height + c.border_width * 2 then
                        p.geometries[c] = {}
                        module.set_geometry(p.geometries[c], geo, geo, useless_gap, 0)
                    end
                end
            end
        end

        local arranged_area = {}
        local function arrange_nested_layout(area, clients)
            local nested_layout = machi_editor.nested_layouts[areas[area].layout]
            if not nested_layout then return end
            if td[area] == nil then
                local tag = gobject{}
                td[area] = tag
                -- TODO: Make the default more flexible.
                tag.layout = nested_layout
                tag.column_count = 1
                tag.master_count = 1
                tag.master_fill_policy = "expand"
                tag.gap = 0
                tag.master_width_factor = 0.5
                tag._private = {
                    awful_tag_properties = {
                    },
                }
            end
            local nested_params = {
                tag = td[area],
                screen = p.screen,
                clients = clients,
                padding = 0,
                geometry = {
                    x = areas[area].x,
                    y = areas[area].y,
                    width = areas[area].width,
                    height = areas[area].height,
                },
                -- Not sure how useless_gap adjustment works here. It seems to work anyway.
                workarea = {
                    x = areas[area].x - useless_gap,
                    y = areas[area].y - useless_gap,
                    width = areas[area].width + useless_gap * 2,
                    height = areas[area].height + useless_gap * 2,
                },
                useless_gap = useless_gap,
                geometries = {},
            }
            nested_layout.arrange(nested_params)
            for _, c in ipairs(clients) do
                p.geometries[c] = {
                    x = nested_params.geometries[c].x,
                    y = nested_params.geometries[c].y,
                    width = nested_params.geometries[c].width,
                    height = nested_params.geometries[c].height,
                }
            end
        end
        for area, clients in pairs(nested_clients) do
            arranged_area[area] = true
            arrange_nested_layout(area, clients)
        end
        -- Also rearrange empty nested layouts.
        -- TODO Iterate through only if the area has a nested layout
        for area, data in pairs(areas) do
            if not arranged_area[area] and areas[area].layout then
                arrange_nested_layout(area, {})
            end
        end
    end

    local function resize_handler (c, context, h)
        local tag = c.screen.selected_tag
        local instance = get_instance_(tag)
        local cd = instance.client_data
        local cd, td, areas, _placement_cb = get_instance_data(c.screen, tag)

        if areas == nil then return end

        if context == "mouse.move" then
            local in_draft = cd[c].draft
            if cd[c].draft ~= nil then
                in_draft = cd[c].draft
            elseif cd[c].lu then
                in_draft = true
            elseif cd[c].area then
                in_draft = false
            else
                log(ERROR, "Assuming in_draft for unhandled client "..tostring(c))
                in_draft = true
            end
            if in_draft then
                local lu = find_lu(h, areas)
                local rd = nil
                if lu ~= nil then
                    -- Use the initial width and height since it may change in undesired way.
                    local hh = {}
                    hh.x = areas[lu].x
                    hh.y = areas[lu].y
                    hh.width = c.full_width_before_move
                    hh.height = c.full_height_before_move
                    rd = find_rd(hh, 0, areas, lu)

                    if rd ~= nil and not module.allowing_shrinking_by_mouse_moving and
                        (areas[rd].x + areas[rd].width - areas[lu].x < c.full_width_before_move or
                         areas[rd].y + areas[rd].height - areas[lu].y < c.full_height_before_move) then
                        hh.x = areas[rd].x + areas[rd].width - c.full_width_before_move
                        hh.y = areas[rd].y + areas[rd].height - c.full_height_before_move
                        lu = find_lu(hh, areas, rd)
                    end

                    if lu ~= nil and rd ~= nil then
                        cd[c].lu = lu
                        cd[c].rd = rd
                        cd[c].area = nil
                        module.set_geometry(c, areas[lu], areas[rd], 0, c.border_width)
                    end
                end
            else
                local center_x = h.x + h.width / 2
                local center_y = h.y + h.height / 2

                local choice = nil
                local choice_value = nil

                for i, a in ipairs(areas) do
                    if a.habitable then
                        local ac_x = a.x + a.width / 2
                        local ac_y = a.y + a.height / 2
                        local dis = (ac_x - center_x) * (ac_x - center_x) + (ac_y - center_y) * (ac_y - center_y)
                        if choice_value == nil or choice_value > dis then
                            choice = i
                            choice_value = dis
                        end
                    end
                end

                if choice and cd[c].area ~= choice then
                    cd[c].lu = nil
                    cd[c].rd = nil
                    cd[c].area = choice
                    module.set_geometry(c, areas[choice], areas[choice], 0, c.border_width)
                end
            end
        elseif cd[c].draft ~= false then
            local lu = find_lu(h, areas)
            local rd = nil
            if lu ~= nil then
                local hh = {}
                hh.x = h.x
                hh.y = h.y
                hh.width = h.width
                hh.height = h.height
                rd = find_rd(hh, c.border_width, areas, lu)
            end

            if lu ~= nil and rd ~= nil then
                if lu == rd and cd[c].draft ~= true then
                    cd[c].lu = nil
                    cd[c].rd = nil
                    cd[c].area = lu
                    awful.layout.arrange(c.screen)
                else
                    cd[c].lu = lu
                    cd[c].rd = rd
                    cd[c].area = nil
                    module.set_geometry(c, areas[lu], areas[rd], 0, c.border_width)
                end
            end
        end
    end

    layout.name = args.icon_name or "machi"
    layout.arrange = arrange
    layout.resize_handler = resize_handler
    layout.machi_editor = args.editor
    layout.machi_get_instance_info = get_instance_info
    layout.machi_get_instance_data = get_instance_data
    layout.machi_set_cmd = set_cmd
    return layout
end

module.placement = {}

local function empty_then_maybe_fair(c, instance, areas, geometry, do_fair)
    local area_client_count = {}
    for _, oc in ipairs(c.screen.tiled_clients) do
        local cd = instance.client_data[oc]
        if cd and cd.placement and cd.area then
            area_client_count[cd.area] = (area_client_count[cd.area] or 0) + 1
        end
    end
    local choice_client_count = nil
    local choice_spare_score = nil
    local choice = nil
    for i = 1, #areas do
        local a = areas[i]
        if a.habitable then
            -- +1 for the new client
            local client_count = (area_client_count[i] or 0) + 1
            local spare_score = a.width * a.height / client_count
            if choice == nil or (choice_client_count > 1 and client_count == 1) then
                choice_client_count = client_count
                choice_spare_score = spare_score
                choice = i
            elseif (choice_client_count > 1) == (client_count > 1) and  choice_spare_score < spare_score then
                choice_client_count = client_count
                choice_spare_score = spare_score
                choice = i
            end
        end
    end
    if choice_client_count > 1 and not do_fair then
        return
    end
    instance.client_data[c].lu = nil
    instance.client_data[c].rd = nil
    instance.client_data[c].area = choice
    geometry.x = areas[choice].x
    geometry.y = areas[choice].y
    geometry.width = areas[choice].width
    geometry.height = areas[choice].height
end

function module.placement.empty(c, instance, areas, geometry)
    empty_then_maybe_fair(c, instance, areas, geometry, false)
end

function module.placement.empty_then_fair(c, instance, areas, geometry)
    empty_then_maybe_fair(c, instance, areas, geometry, true)
end

return module
