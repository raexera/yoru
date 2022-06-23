local this_package = ... and (...):match("(.-)[^%.]+$") or ""
local machi_engine = require(this_package.."engine")
local beautiful = require("beautiful")
local awful = require("awful")
local wibox = require("wibox")
local naughty = require("naughty")
local gears = require("gears")
local gfs = require("gears.filesystem")
local lgi = require("lgi")
local dpi = require("beautiful.xresources").apply_dpi

local ERROR = 2
local WARNING = 1
local INFO = 0
local DEBUG = -1

local module = {
    log_level = WARNING,
    nested_layouts = {
        ["0"] = awful.layout.suit.tile,
        ["1"] = awful.layout.suit.spiral,
        ["2"] = awful.layout.suit.fair,
        ["3"] = awful.layout.suit.fair.horizontal,
    },
}

local function log(level, msg)
    if level > module.log_level then
        print(msg)
    end
end

local function with_alpha(col, alpha)
    local r, g, b
    _, r, g, b, _ = col:get_rgba()
    return lgi.cairo.SolidPattern.create_rgba(r, g, b, alpha)
end

local function max(a, b)
    if a < b then return b else return a end
end

local function is_tiling(c)
    return
        not (c.tomb_floating or c.floating or c.maximized_horizontal or c.maximized_vertical or c.maximized or c.fullscreen)
end

local function set_tiling(c)
    c.floating = false
    c.maximized = false
    c.maximized_vertical = false
    c.maximized_horizontal = false
    c.fullscreen = false
end

local function _area_tostring(wa)
    return "{x:" .. tostring(wa.x) .. ",y:" .. tostring(wa.y) .. ",w:" .. tostring(wa.width) .. ",h:" .. tostring(wa.height) .. "}"
end

local function shrink_area_with_gap(a, gap)
    return {
        x = a.x + gap,
        y = a.y + gap,
        width = a.width - gap * 2,
        height = a.height - gap * 2,
    }
end

function module.restore_data(data)
    if data.history_file then
        local file, err = io.open(data.history_file, "r")
        if err then
            log(INFO, "cannot read history from " .. data.history_file)
        else
            data.cmds = {}
            data.last_cmd = {}
            local last_layout_name
            for line in file:lines() do
                if line:sub(1, 1) == "+" then
                    last_layout_name = line:sub(2, #line)
                else
                    if last_layout_name ~= nil then
                        log(DEBUG, "restore last cmd " .. line .. " for " .. last_layout_name)
                        data.last_cmd[last_layout_name] = line
                        last_layout_name = nil
                    else
                        log(DEBUG, "restore cmd " .. line)
                        data.cmds[#data.cmds + 1] = line
                    end
                end
            end
            file:close()
        end
    end

    return data
end

function module.create(data)
    if data == nil then
        data = module.restore_data({
                history_file = gfs.get_cache_dir() .. "/history_machi",
                history_save_max = 100,
        })
    end

    data.cmds = data.cmds or {}
    data.last_cmd = data.last_cmd or {}
    data.minimum_size = data.minimum_size or 100


    local function add_cmd(instance_name, cmd)
        -- remove duplicated entries
        local j = 1
        for i = 1, #data.cmds do
            if data.cmds[i] ~= cmd then
                data.cmds[j] = data.cmds[i]
                j = j + 1
            end
        end
        for i = #data.cmds, j, -1 do
            table.remove(data.cmds, i)
        end

        data.cmds[#data.cmds + 1] = cmd
        data.last_cmd[instance_name] = cmd
        if data.history_file then
            local file, err = io.open(data.history_file, "w")
            if err then
                log(ERROR, "cannot save history to " .. data.history_file)
            else
                for i = max(1, #data.cmds - data.history_save_max + 1), #data.cmds do
                    log(DEBUG, "save cmd " .. data.cmds[i])
                    file:write(data.cmds[i] .. "\n")
                end
                for name, cmd in pairs(data.last_cmd) do
                    log(DEBUG, "save last cmd " .. cmd .. " for " .. name)
                    file:write("+" .. name .. "\n" .. cmd .. "\n")
                end
            end
            file:close()
        end

        return true
    end


    local function start_interactive(screen, embed_args)
        local info_size = dpi(60)
        -- colors are in rgba
        local border_color = with_alpha(
            gears.color(beautiful.machi_editor_border_color or beautiful.border_focus),
            beautiful.machi_editor_border_opacity or 0.75)
        local active_color = with_alpha(
            gears.color(beautiful.machi_editor_active_color or beautiful.bg_focus),
            beautiful.machi_editor_active_opacity or 0.5)
        local open_color = with_alpha(
            gears.color(beautiful.machi_editor_open_color or beautiful.bg_normal),
            beautiful.machi_editor_open_opacity or 0.5)
        local closed_color = open_color

        if to_save == nil then
            to_save = true
        end

        screen = screen or awful.screen.focused()
        local tag = screen.selected_tag
        local gap = tag.gap or 0
        local layout = tag.layout

        if layout.machi_set_cmd == nil then
            naughty.notify({
                    text = "The layout to edit is not machi",
                    timeout = 3,
            })
            return
        end

        local cmd_index = #data.cmds + 1
        data.cmds[cmd_index] = ""

        local start_x = screen.workarea.x
        local start_y = screen.workarea.y

        local kg
        local infobox = wibox({
                screen = screen,
                x = screen.workarea.x,
                y = screen.workarea.y,
                width = screen.workarea.width,
                height = screen.workarea.height,
                bg = "#ffffff00",
                opacity = 1,
                ontop = true,
                type = "dock",
        })
        infobox.visible = true

        workarea = embed_args and embed_args.workarea or screen.workarea

        local closed_areas
        local open_areas
        local pending_op
        local current_cmd
        local to_exit
        local to_apply

        local key_translate_tab = {
            ["Return"] = ".",
            [" "] = "-",
        }

        local function set_cmd(cmd)
            local new_closed_areas, new_open_areas, new_pending_op = machi_engine.areas_from_command(
                cmd,
                {
                    x = workarea.x + gap,
                    y = workarea.y + gap,
                    width =  workarea.width - gap * 2,
                    height = workarea.height - gap * 2
                },
                gap * 2 + data.minimum_size)
            if new_closed_areas then
                closed_areas, open_areas, pending_op =
                    new_closed_areas, new_open_areas, new_pending_op
                current_cmd = cmd

                if embed_args then
                    current_info =
                        embed_args.cmd_prefix.."["..current_cmd.."]"..embed_args.cmd_suffix
                else
                    current_info = cmd
                end

                if #open_areas == 0 and not pending_op then
                    current_info = current_info .. "\n(enter to apply)"
                end
                return true
            else
                return false
            end
        end

        local function handle_key(key)
            if key_translate_tab[key] ~= nil then
                key = key_translate_tab[key]
            end

            return set_cmd(current_cmd..key)
        end


        local function cleanup()
            infobox.visible = false
        end

        local function draw_info(context, cr, width, height)
            cr:set_source_rgba(0, 0, 0, 0)
            cr:rectangle(0, 0, width, height)
            cr:fill()

            local msg, ext

            for i, a in ipairs(closed_areas) do
                if a.habitable then
                    local sa = shrink_area_with_gap(a, gap)
                    local to_highlight = false
                    if pending_op ~= nil then
                        to_highlight = a.group_id == op_count
                    end
                    cr:rectangle(sa.x - start_x, sa.y - start_y, sa.width, sa.height)
                    cr:clip()
                    if to_highlight then
                        cr:set_source(active_color)
                    else
                        cr:set_source(closed_color)
                    end
                    cr:rectangle(sa.x - start_x, sa.y - start_y, sa.width, sa.height)
                    cr:fill()
                    cr:set_source(border_color)
                    cr:rectangle(sa.x - start_x, sa.y - start_y, sa.width, sa.height)
                    cr:set_line_width(10.0)
                    cr:stroke()
                    cr:reset_clip()
                end
            end

            for i, a in ipairs(open_areas) do
                local sa = shrink_area_with_gap(a, gap)
                local to_highlight = false
                if not pending_op then
                    to_highlight = i == #open_areas
                else
                    to_highlight = a.group_id == op_count
                end
                cr:rectangle(sa.x - start_x, sa.y - start_y, sa.width, sa.height)
                cr:clip()
                if i == #open_areas then
                    cr:set_source(active_color)
                else
                    cr:set_source(open_color)
                end
                cr:rectangle(sa.x - start_x, sa.y - start_y, sa.width, sa.height)
                cr:fill()

                cr:set_source(border_color)
                cr:rectangle(sa.x - start_x, sa.y - start_y, sa.width, sa.height)
                cr:set_line_width(10.0)
                if to_highlight then
                    cr:stroke()
                else
                    cr:set_dash({5, 5}, 0)
                    cr:stroke()
                    cr:set_dash({}, 0)
                end
                cr:reset_clip()
            end

            local pl = lgi.Pango.Layout.create(cr)
            pl:set_font_description(beautiful.get_merged_font(beautiful.font, info_size))
            pl:set_alignment("CENTER")
            pl:set_text(current_info)
            local w, h = pl:get_size()
            w = w / lgi.Pango.SCALE
            h = h / lgi.Pango.SCALE
            local ext = { width = w, height = h, x_bearing = 0, y_bearing = 0 }
            cr:move_to(width / 2 - ext.width / 2 - ext.x_bearing, height / 2 - ext.height / 2 - ext.y_bearing)
            cr:set_source_rgba(1, 1, 1, 1)
            cr:show_layout(pl)
            cr:fill()
            cr:move_to(width / 2 - ext.width / 2 - ext.x_bearing, height / 2 - ext.height / 2 - ext.y_bearing)
            cr:set_source_rgba(0, 0, 0, 1)
            cr:set_line_width(2.0)
            cr:layout_path(pl)
            cr:stroke()
        end

        local function refresh()
            log(DEBUG, "closed areas:")
            for i, a in ipairs(closed_areas) do
                log(DEBUG, "  " .. _area_tostring(a))
            end
            log(DEBUG, "open areas:")
            for i, a in ipairs(open_areas) do
                log(DEBUG, "  " .. _area_tostring(a))
            end
            infobox.bgimage = draw_info
        end

        local function get_final_cmd()
            local final_cmd = current_cmd
            if embed_args then
                final_cmd = embed_args.cmd_prefix ..
                    machi_engine.areas_to_command(closed_areas, true) ..
                    embed_args.cmd_suffix
            end
            return final_cmd
        end

        log(DEBUG, "interactive layout editing starts")

        set_cmd("")
        refresh()

        kg = awful.keygrabber.run(
            function (mod, key, event)
                if event == "release" then
                    return
                end

                local ok, err = pcall(
                    function ()
                        if key == "BackSpace" then
                            local alt = false
                            for _, m in ipairs(mod) do
                                if m == "Shift" then
                                    alt = true
                                    break
                                end
                            end
                            if alt then
                                if embed_args then
                                    set_cmd(embed_args.original_cmd or "")
                                else
                                    local _cd, _td, areas = layout.machi_get_instance_data(screen, tag)
                                    set_cmd(machi_engine.areas_to_command(areas))
                                end
                            else
                                set_cmd(current_cmd:sub(1, #current_cmd - 1))
                            end
                        elseif key == "Escape" then
                            table.remove(data.cmds, #data.cmds)
                            to_exit = true
                        elseif key == "Up" or key == "Down" then
                            if current_cmd ~= data.cmds[cmd_index] then
                                data.cmds[#data.cmds] = current_cmd
                            end

                            if key == "Up" and cmd_index > 1 then
                                cmd_index = cmd_index - 1
                            elseif key == "Down" and cmd_index < #data.cmds then
                                cmd_index = cmd_index + 1
                            end

                            log(DEBUG, "restore history #" .. tostring(cmd_index) .. ":" .. data.cmds[cmd_index])
                            set_cmd(data.cmds[cmd_index])
                        elseif #open_areas > 0 or pending_op then
                            handle_key(key)
                        else
                            if key == "Return" then
                                local alt = false
                                for _, m in ipairs(mod) do
                                    if m == "Shift" then
                                        alt = true
                                        break
                                    end
                                end

                                local instance_name, persistent = layout.machi_get_instance_info(tag)
                                if not alt and persistent then
                                    table.remove(data.cmds, #data.cmds)
                                    add_cmd(instance_name, get_final_cmd())
                                    current_info = "Saved!"
                                else
                                    current_info = "Applied!"
                                end

                                to_exit = true
                                to_apply = true
                            end
                        end

                        refresh()

                        if to_exit then
                            log(DEBUG, "interactive layout editing ends")
                            if to_apply then
                                layout.machi_set_cmd(get_final_cmd(), tag)
                                awful.layout.arrange(screen)
                                gears.timer{
                                    timeout = 1,
                                    autostart = true,
                                    singleshot = true,
                                    callback = cleanup,
                                }
                            else
                                cleanup()
                            end
                        end
                end)

                if not ok then
                    log(ERROR, "Getting error in keygrabber: " .. err)
                    to_exit = true
                    cleanup()
                end

                if to_exit then
                    awful.keygrabber.stop(kg)
                end
            end
        )
    end

    local function run_cmd(cmd, screen, tag)
        local gap = tag.gap
        local areas, closed = machi_engine.areas_from_command(
            cmd,
            {
                x = screen.workarea.x + gap,
                y = screen.workarea.y + gap,
                width = screen.workarea.width - gap * 2,
                height = screen.workarea.height - gap * 2
            },
            gap * 2 + data.minimum_size)
        if not areas or #closed > 0 then
            return nil
        end
        for _, a in ipairs(areas) do
            a.x = a.x + gap
            a.y = a.y + gap
            a.width = a.width - gap * 2
            a.height = a.height - gap * 2
        end
        return areas
    end

    local function get_last_cmd(name)
        return data.last_cmd[name]
    end

    function adjust_shares(c, axis, adj)
        if not c:isvisible() or c.floating or c.immobilized then
            return
        end
        local screen = c.screen
        local tag = screen.selected_tag
        local layout = tag.layout
        if not layout.machi_get_instance_data then return end
        local cd, _td, areas = layout.machi_get_instance_data(screen, tag)
        local key_shares = axis.."_shares"
        local key_spare = axis.."_spare"
        local key_parent_shares = "parent_"..axis.."_shares"

        if not cd[c] or not cd[c].area then
            return
        end

        if adj < 0 then
            if axis == "x" and c.width + adj < data.minimum_size then
                adj = data.minimum_size - c.width
            elseif axis == "y" and c.height + adj < data.minimum_size then
                adj = data.minimum_size - c.height
            end
        end

        local function adjust(parent_id, shares, adj)
            -- The propagation part is questionable. But it is not critical anyway..
            if type(shares) ~= "table" then
                local old = areas[parent_id].split[key_shares][shares][2] or 0
                areas[parent_id].split[key_shares][shares][2] = old + adj
            else
                local acc = 0
                for i = 1, #shares do
                    local old = areas[parent_id].split[key_shares][shares[i]][2] or 0
                    local adj_split = i == #shares and adj - acc or math.floor(adj * i / #shares - acc + 0.5)
                    areas[parent_id].split[key_shares][shares[i]][2] = old + adj_split
                    acc = acc + adj_split
                end
            end
            if adj <= 0 then
                return #areas[parent_id].split[key_shares] > 1
            else
                return areas[parent_id].split[key_spare] >= adj
            end
        end

        local area = cd[c].area
        while areas[area].parent_id do
            if adjust(areas[area].parent_id, areas[area][key_parent_shares], adj) then
                break
            end
            area = areas[area].parent_id
        end

        layout.machi_set_cmd(machi_engine.areas_to_command(areas), tag, true)
        awful.layout.arrange(screen)
    end

    function adjust_x_shares(c, adj)
        adjust_shares(c, "x", adj)
    end

    function adjust_y_shares(c, adj)
        adjust_shares(c, "y", adj)
    end

    return {
        start_interactive = start_interactive,
        run_cmd = run_cmd,
        get_last_cmd = get_last_cmd,
        adjust_x_shares = adjust_x_shares,
        adjust_y_shares = adjust_y_shares,
    }
end

module.default_editor = module.create()

return module
