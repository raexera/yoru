-- area {
--   x, y, width, height
--   parent_id
--   parent_cid
--   parent_x_shares
--   parent_y_shares
--   habitable
--   hole (unique)
-- }
--
-- split {
--   method
--   x_shares
--   y_shares
--   children
-- }
--
-- share {weight, adjustment, dynamic, minimum}
local in_module = ...

-- Split a length by `measures`, such that each split respect the
-- weight [1], adjustment (user [2] + engine [3]) without breaking the minimum size [4].
--
-- The split algorithm has a worst case of O(n^2) where n = #shares,
-- which should be fine for practical usage of screen partitions.
-- Using geometric algorithm this can be optimized to O(n log n), but
-- I don't think it is worth.

-- Returns two values:
--   1. the (accumulative) result if it is possible to give every share its minimum size, otherwise nil.
--   2. any spare space to adjust without capping any share.
local function fair_split(length, shares)
    local ret = {}
    local normalized_adj = nil
    local sum_weight
    local sum_adj
    local remaining = #shares
    local spare = nil
    local need_recompute
    repeat
        need_recompute = false
        sum_weight = 0
        sum_adj = 0
        for i = 1, #shares do
            if ret[i] == nil then
                sum_weight = sum_weight + shares[i][1]
                if normalized_adj then
                    sum_adj = sum_adj + normalized_adj[i]
                end
            end
        end

        if normalized_adj == nil then
            normalized_adj = {}
            for i = 1, #shares do
                if sum_weight > shares[i][1] then
                    normalized_adj[i] = ((shares[i][2] or 0) + (shares[i][3] or 0)) * sum_weight / (sum_weight - shares[i][1])
                else
                    normalized_adj[i] = 0
                end
                sum_adj = sum_adj + normalized_adj[i]
            end

            for i = 1, #shares do
                local required = (shares[i][4] - normalized_adj[i]) * sum_weight / shares[i][1] + sum_adj
                if spare == nil or spare > length - required then
                    spare = length - required
                end
            end
        end

        local capped_length = 0
        for i = 1, #shares do
            if ret[i] == nil then
                local split = (length - sum_adj) * shares[i][1] / sum_weight + normalized_adj[i]
                if split < shares[i][4] then
                    ret[i] = shares[i][4]
                    capped_length = capped_length + shares[i][4]
                    need_recompute = true
                end
            end
        end

        length = length - capped_length
    until not need_recompute

    if #shares == 1 or spare < 0 then
        spare = 0
    end

    if remaining == 0 then
        return nil, spare
    end

    local acc_weight = 0
    local acc_adj = 0
    local acc_ret = 0
    for i = 1, #shares do
        if ret[i] == nil then
            acc_weight = acc_weight + shares[i][1]
            acc_adj = acc_adj + normalized_adj[i]
            ret[i] = remaining == 1 and length - acc_ret or math.floor((length - sum_adj) / sum_weight * acc_weight + acc_adj - acc_ret + 0.5)
            acc_ret = acc_ret + ret[i]
            remaining = remaining - 1
        end
    end

    ret[0] = 0
    for i = 1, #shares do
        ret[i] = ret[i - 1] + ret[i]
    end

    return ret, spare
end

-- Static data

-- Command character info
-- 3 for taking the arg string and an open area
-- 2 for taking an open area
-- 1 for taking nothing
-- 0 for args
local ch_info = {
    ["h"] = 3, ["H"] = 3,
    ["v"] = 3, ["V"] = 3,
    ["w"] = 3, ["W"] = 3,
    ["d"] = 3, ["D"] = 3,
    ["s"] = 3,
    ["t"] = 3,
    ["c"] = 3,
    ["x"] = 3,
    ["-"] = 2,
    ["/"] = 2,
    ["."] = 1,
    [";"] = 1,
    ["0"] = 0, ["1"] = 0, ["2"] = 0, ["3"] = 0, ["4"] = 0,
    ["5"] = 0, ["6"] = 0, ["7"] = 0, ["8"] = 0, ["9"] = 0,
    ["_"] = 0, [","] = 0,
}

local function parse_arg_str(arg_str, default)
    local ret = {}
    local current = {}
    if #arg_str == 0 then return ret end
    local index = 1
    local split_mode = arg_str:find("[,_]") ~= nil

    local p = index
    while index <= #arg_str do
        local ch = arg_str:sub(index, index)
        if split_mode then
            if ch == "_" then
                local r = tonumber(arg_str:sub(p, index - 1))
                if r == nil then
                    current[#current + 1] = default
                else
                    current[#current + 1] = r
                end
                p = index + 1
            elseif ch == "," then
                local r = tonumber(arg_str:sub(p, index - 1))
                if r == nil then
                    current[#current + 1] = default
                else
                    current[#current + 1] = r
                end
                ret[#ret + 1] = current
                current = {}
                p = index + 1
            end
        else
            local r = tonumber(ch)
            if r == nil then
                ret[#ret + 1] = {default}
            else
                ret[#ret + 1] = {r}
            end
        end
        index = index + 1
    end

    if split_mode then
        local r = tonumber(arg_str:sub(p, index - 1))
        if r == nil then
            current[#current + 1] = default
        else
            current[#current + 1] = r
        end
        ret[#ret + 1] = current
    end

    return ret
end

if not in_module then
    print("Testing parse_arg_str")
    local x = parse_arg_str("1234", 0)
    assert(#x == 4)
    assert(#x[1] == 1 and x[1][1] == 1)
    assert(#x[2] == 1 and x[2][1] == 2)
    assert(#x[3] == 1 and x[3][1] == 3)
    assert(#x[4] == 1 and x[4][1] == 4)
    local x = parse_arg_str("12_34_,", -1)
    assert(#x == 2)
    assert(#x[1] == 3 and x[1][1] == 12 and x[1][2] == 34 and x[1][3] == -1)
    assert(#x[2] == 1 and x[2][1] == -1)
    local x = parse_arg_str("12_34,56_,78_90_", -1)
    assert(#x == 3)
    assert(#x[1] == 2 and x[1][1] == 12 and x[1][2] == 34)
    assert(#x[2] == 2 and x[2][1] == 56 and x[2][2] == -1)
    assert(#x[3] == 3 and x[3][1] == 78 and x[3][2] == 90 and x[3][3] == -1)
    print("Passed.")
end

local max_split = 1000
local max_areas = 10000
local default_expansion = 2

-- Execute a (partial) command, returns:
--   1. Closed areas: areas that will not be further partitioned by further input.
--   2. Open areas: areas that can be further partitioned.
--   3. Pending: if the command can take more argument into the last command.
local function areas_from_command(command, workarea, minimum)
    local pending_op = nil
    local arg_str = ""
    local closed_areas = {}
    local open_areas
    local root = {
        expansion = default_expansion,
        x = workarea.x,
        y = workarea.y,
        width = workarea.width,
        height = workarea.height,
        bl = true,
        br = true,
        bu = true,
        bd = true,
    }

    local function close_area()
        local a = open_areas[#open_areas]
        table.remove(open_areas, #open_areas)
        local i = #closed_areas + 1
        closed_areas[i] = a
        a.id = i
        a.habitable = true
        return a, i
    end

    local function push_open_areas(areas)
        for i = #areas, 1, -1 do
            open_areas[#open_areas + 1] = areas[i]
        end
    end

    local function handle_op(method)
        local l = method:lower()
        local alt = method ~= l
        method = l

        if method == "h" or method == "v" then

            local args = parse_arg_str(arg_str, 0)
            if #args == 0 then
                args = {{1}, {1}}
            elseif #args == 1 then
                args[2] = {1}
            end

            local total = 0
            local shares = { }
            for i = 1, #args do
                local arg
                if not alt then
                    arg = args[i]
                else
                    arg = args[#args - i + 1]
                end
                if arg[2] == 0 and arg[3] then arg[2], arg[3] = -arg[3], nil end
                shares[i] = arg
            end

            if #shares > max_split then
                return nil
            end

            local a, area_index = close_area()
            a.habitable = false
            a.split = {
                method = method,
                x_shares = method == "h" and shares or {{1}},
                y_shares = method == "v" and shares or {{1}},
                children = {}
            }
            local children = a.split.children

            if method == "h" then
                for i = 1, #a.split.x_shares do
                    local child = {
                        parent_id = area_index,
                        parent_cid = #children + 1,
                        parent_x_shares = #children + 1,
                        parent_y_shares = 1,
                        expansion = a.expansion - 1,

                        bl = i == 1 and a.bl or false,
                        br = i == #a.split.x_shares and a.br or false,
                        bu = a.bu,
                        bd = a.bd,
                    }
                    children[#children + 1] = child
                end
            else
                for i = 1, #a.split.y_shares do
                    local child = {
                        parent_id = area_index,
                        parent_cid = #children + 1,
                        parent_x_shares = 1,
                        parent_y_shares = #children + 1,
                        expansion = a.expansion - 1,

                        bl = a.bl,
                        br = a.br,
                        bu = i == 1 and a.bu or false,
                        bd = i == #a.split.y_shares and a.bd or false,
                    }
                    children[#children + 1] = child
                end
            end

            push_open_areas(children)

        elseif method == "w" or method == "d" then

            local args = parse_arg_str(arg_str, 0)

            local x_shares = {}
            local y_shares = {}
            local m_start = #args + 1

            if method == "w" then
                if #args == 0 then
                    args = {{1}, {1}}
                elseif #args == 1 then
                    args[2] = {1}
                end

                local x_shares_count, y_shares_count
                if alt then
                    x_shares_count = args[2][1]
                    y_shares_count = args[1][1]
                else
                    x_shares_count = args[1][1]
                    y_shares_count = args[2][1]
                end
                if x_shares_count < 1 then x_shares_count = 1 end
                if y_shares_count < 1 then y_shares_count = 1 end

                if x_shares_count * y_shares_count > max_split then
                    return nil
                end

                for i = 1, x_shares_count do x_shares[i] = {1} end
                for i = 1, y_shares_count do y_shares[i] = {1} end

                m_start = 3
            else
                local current = x_shares
                for i = 1, #args do
                    if not alt then
                        arg = args[i]
                    else
                        arg = args[#args - i + 1]
                    end
                    if arg[1] == 0 then
                        if current == x_shares then current = y_shares else
                            m_start = i + 1
                            break
                        end
                    else
                        if arg[2] == 0 and arg[3] then arg[2], arg[3] = -arg[3], nil end
                        current[#current + 1] = arg
                    end
                end

                if #x_shares == 0 then
                    x_shares = {{1}}
                end

                if #y_shares == 0 then
                    y_shares = {{1}}
                end

                if #x_shares * #y_shares > max_split then
                    return nil
                end
            end

            local a, area_index = close_area()
            a.habitable = false
            a.split = {
                method = method,
                x_shares = x_shares,
                y_shares = y_shares,
                children = {},
            }
            local children = {}

            for y_index = 1, #a.split.y_shares do
                for x_index = 1, #a.split.x_shares do
                    local r = {
                        parent_id = area_index,
                        -- parent_cid will be filled later.
                        parent_x_shares = x_index,
                        parent_y_shares = y_index,
                        expansion = a.expansion - 1
                    }
                    if x_index == 1 then r.bl = a.bl else r.bl = false end
                    if x_index == #a.split.x_shares then r.br = a.br else r.br = false end
                    if y_index == 1 then r.bu = a.bu else r.bu = false end
                    if y_index == #a.split.y_shares then r.bd = a.bd else r.bd = false end
                    children[#children + 1] = r
                end
            end

            local merged_children = {}
            local start_index = 1
            for i = m_start, #args - 1, 2 do
                -- find the first index that is not merged
                while start_index <= #children and children[start_index] == false do
                    start_index = start_index + 1
                end
                if start_index > #children or children[start_index] == false then
                    break
                end
                local x = (start_index - 1) % #x_shares
                local y = math.floor((start_index - 1) / #x_shares)
                local w = args[i][1]
                local h = args[i + 1][1]
                if w < 1 then w = 1 end
                if h == nil or h < 1 then h = 1 end
                if alt then
                    local tmp = w
                    w = h
                    h = tmp
                end
                if x + w > #x_shares then w = #x_shares - x end
                if y + h > #y_shares then h = #y_shares - y end
                local end_index = start_index
                for ty = y, y + h - 1 do
                    local succ = true
                    for tx = x, x + w - 1 do
                        if children[ty * #x_shares + tx + 1] == false then
                            succ = false
                            break
                        elseif ty == y then
                            end_index = ty * #x_shares + tx + 1
                        end
                    end

                    if not succ then
                        break
                    elseif ty > y then
                        end_index = ty * #x_shares + x + w
                    end
                end

                local function generate_range(s, e)
                    local r = {} for i = s, e do r[#r+1] = i end return r
                end

                local r = {
                    bu = children[start_index].bu, bl = children[start_index].bl,
                    bd = children[end_index].bd, br = children[end_index].br,

                    parent_id = area_index,
                    -- parent_cid will be filled later.
                    parent_x_shares = generate_range(children[start_index].parent_x_shares, children[end_index].parent_x_shares),
                    parent_y_shares = generate_range(children[start_index].parent_y_shares, children[end_index].parent_y_shares),
                    expansion = a.expansion - 1
                }
                merged_children[#merged_children + 1] = r

                for ty = y, y + h - 1 do
                    local succ = true
                    for tx = x, x + w - 1 do
                        local index = ty * #x_shares + tx + 1
                        if index <= end_index then
                            children[index] = false
                        else
                            break
                        end
                    end
                end
            end

            for i = 1, #merged_children do
                a.split.children[#a.split.children + 1] = merged_children[i]
                a.split.children[#a.split.children].parent_cid = #a.split.children
            end

            -- clean up children, remove all `false'
            for i = 1, #children do
                if children[i] ~= false then
                    a.split.children[#a.split.children + 1] = children[i]
                    a.split.children[#a.split.children].parent_cid = #a.split.children
                end
            end

            push_open_areas(a.split.children)

        elseif method == "s" then

            if #open_areas > 0 then
                local times = arg_str == "" and 1 or tonumber(arg_str)
                local t = {}
                local c = #open_areas
                local p = open_areas[c].parent_id
                while c > 0 and open_areas[c].parent_id == p do
                    t[#t + 1] = open_areas[c]
                    open_areas[c] = nil
                    c = c - 1
                end
                for i = #t, 1, -1 do
                    open_areas[c + 1] = t[(i + times - 1) % #t + 1]
                    c = c + 1
                end
            end

        elseif method == "t" then

            if #open_areas > 0 then
                open_areas[#open_areas].expansion = tonumber(arg_str) or default_expansion
            end

        elseif method == "x" then

            local a = close_area()
            a.layout = arg_str

        elseif method == "-" then

            close_area()

        elseif method == "." then

            while #open_areas > 0 do
                close_area()
            end

        elseif method == "c" then

            local limit = tonumber(arg_str)
            if limit == nil or limit > #open_areas then
                limit = #open_areas
            end
            local p = open_areas[#open_areas].parent_id
            while limit > 0 and open_areas[#open_areas].parent_id == p do
                close_area()
                limit = limit - 1
            end

        elseif method == "/" then

            close_area().habitable = false

        elseif method == ";" then

            -- nothing

        end

        if #open_areas + #closed_areas > max_areas then
            return nil
        end

        while #open_areas > 0 and open_areas[#open_areas].expansion <= 0 do
            close_area()
        end

        arg_str = ""
        return true
    end

    open_areas = {root}

    for i = 1, #command do
        local ch = command:sub(i, i)
        local t = ch_info[ch]
        local r = true
        if t == nil then
            return nil
        elseif t == 3 then
            if pending_op ~= nil then
                r = handle_op(pending_op)
                pending_op = nil
            end
            if #open_areas == 0 then return nil end
            if arg_str == "" then
                pending_op = ch
            else
                r = handle_op(ch)
            end
        elseif t == 2 or t == 1 then
            if pending_op ~= nil then
                handle_op(pending_op)
                pending_op = nil
            end
            if #open_areas == 0 and t == 2 then return nil end
            r = handle_op(ch)
        elseif t == 0 then
            arg_str = arg_str..ch
        end

        if not r then return nil end
    end

    if pending_op ~= nil then
        if not handle_op(pending_op) then
            return nil
        end
    end

    if #closed_areas == 0 then
        return closed_areas, open_areas, pending_op ~= nil
    end

    local old_closed_areas = closed_areas
    closed_areas = {}
    local function reorder_and_fill_adj_min(old_id)
        local a = old_closed_areas[old_id]
        closed_areas[#closed_areas + 1] = a
        a.id = #closed_areas

        if a.split then
            for i = 1, #a.split.x_shares do
                a.split.x_shares[i][3] = 0
                a.split.x_shares[i][4] = minimum
            end

            for i = 1, #a.split.y_shares do
                a.split.y_shares[i][3] = 0
                a.split.y_shares[i][4] = minimum
            end

            for _, c in ipairs(a.split.children) do
                if c.id then
                    reorder_and_fill_adj_min(c.id)
                end

                local x_minimum, y_minimum
                if c.split then
                    x_minimum, y_minimum = c.x_minimum, c.y_minimum
                else
                    x_minimum, y_minimum =
                        minimum, minimum
                end

                if type(c.parent_x_shares) == "table" then
                    local x_minimum_split = math.ceil(x_minimum / #c.parent_x_shares)
                    for i = 1, #c.parent_x_shares do
                        if a.split.x_shares[c.parent_x_shares[i]][4] < x_minimum_split then
                            a.split.x_shares[c.parent_x_shares[i]][4] = x_minimum_split
                        end
                    end
                else
                    if a.split.x_shares[c.parent_x_shares][4] < x_minimum then
                        a.split.x_shares[c.parent_x_shares][4] = x_minimum
                    end
                end

                if type(c.parent_y_shares) == "table" then
                    local y_minimum_split = math.ceil(y_minimum / #c.parent_y_shares)
                    for i = 1, #c.parent_y_shares do
                        if a.split.y_shares[c.parent_y_shares[i]][4] < y_minimum_split then
                            a.split.y_shares[c.parent_y_shares[i]][4] = y_minimum_split
                        end
                    end
                else
                    if a.split.y_shares[c.parent_y_shares][4] < y_minimum then
                        a.split.y_shares[c.parent_y_shares][4] = y_minimum
                    end
                end
            end

            a.x_minimum = 0
            a.x_total_weight = 0
            for i = 1, #a.split.x_shares do
                a.x_minimum = a.x_minimum + a.split.x_shares[i][4]
                a.x_total_weight = a.x_total_weight + (a.split.x_shares[i][2] or 0)
            end
            a.y_minimum = 0
            a.y_total_weight = 0
            for i = 1, #a.split.y_shares do
                a.y_minimum = a.y_minimum + a.split.y_shares[i][4]
                a.y_total_weight = a.y_total_weight + (a.split.y_shares[i][2] or 0)
            end
        end
    end
    reorder_and_fill_adj_min(1)

    -- For debugging
    -- for i = 1, #closed_areas do
    --     print(i, closed_areas[i].parent_id, closed_areas[i].parent_x_shares, closed_areas[i].parent_y_shares)
    --     if closed_areas[i].split then
    --         print("/", closed_areas[i].split.method, #closed_areas[i].split.x_shares, #closed_areas[i].split.y_shares)
    --         for j = 1, #closed_areas[i].split.children do
    --             print("->", closed_areas[i].split.children[j].id)
    --         end
    --     end
    -- end

    local orig_width = root.width
    if root.x_minimum and root.width < root.x_minimum then
        root.width = root.x_minimum
    end
    local orig_height = root.height
    if root.y_minimum and root.height < root.y_minimum then
        root.height = root.y_minimum
    end

    function split(id)
        local a = closed_areas[id]
        if a.split then
            local x_shares, y_shares
            x_shares, a.split.x_spare = fair_split(a.width, a.split.x_shares)
            y_shares, a.split.y_spare = fair_split(a.height, a.split.y_shares)

            for _, c in ipairs(a.split.children) do

                if type(c.parent_x_shares) == "table" then
                    c.x = a.x + x_shares[c.parent_x_shares[1] - 1]
                    c.width = 0
                    for i = 1, #c.parent_x_shares do
                        c.width = c.width + x_shares[c.parent_x_shares[i]] - x_shares[c.parent_x_shares[i] - 1]
                    end
                else
                    c.x = a.x + x_shares[c.parent_x_shares - 1]
                    c.width = x_shares[c.parent_x_shares] - x_shares[c.parent_x_shares - 1]
                end

                if type(c.parent_y_shares) == "table" then
                    c.y = a.y + y_shares[c.parent_y_shares[1] - 1]
                    c.height = 0
                    for i = 1, #c.parent_y_shares do
                        c.height = c.height + y_shares[c.parent_y_shares[i]] - y_shares[c.parent_y_shares[i] - 1]
                    end
                else
                    c.y = a.y + y_shares[c.parent_y_shares - 1]
                    c.height = y_shares[c.parent_y_shares] - y_shares[c.parent_y_shares - 1]
                end

                if c.id then
                    split(c.id)
                end
            end
        end
    end
    split(1)

    for i = 1, #closed_areas do
        if closed_areas[i].x + closed_areas[i].width > root.x + orig_width or
            closed_areas[i].y + closed_areas[i].height > root.y + orig_height
        then
            closed_areas[i].habitable = false
        end
    end

    for i = 1, #open_areas do
        if open_areas[i].x + open_areas[i].width > root.x + orig_width or
            open_areas[i].y + open_areas[i].height > root.y + orig_height
        then
            open_areas[i].habitable = false
        end
    end

    return closed_areas, open_areas, pending_op ~= nil
end

local function areas_to_command(areas, to_embed, root_area)
    root_area = root_area or 1
    if #areas < root_area then return nil end

    local function shares_to_arg_str(shares)
        local arg_str = ""
        for _, share in ipairs(shares) do
            if #arg_str > 0 then arg_str = arg_str.."," end
            arg_str = arg_str..tostring(share[1])
            if not share[2] or share[2] == 0 then
                -- nothing
            elseif share[2] > 0 then
                arg_str = arg_str.."_"..tostring(share[2])
            else
                arg_str = arg_str.."__"..tostring(-share[2])
            end
        end
        return arg_str
    end

    local function get_command(area_id)
        local r
        local handled_options = {}
        local a = areas[area_id]

        if a.hole then
            return "|"
        end

        if a.split then
            for i = 1, #a.split.children do
                if a.split.children[i].hole then
                    a.expansion = default_expansion + 1
                    break
                end
            end

            local method = a.split.method
            if method == "h" then
                r = shares_to_arg_str(a.split.x_shares)
                r = "h"..r
            elseif method == "v" then
                r = shares_to_arg_str(a.split.y_shares)
                r = "v"..r
            elseif method == "d" or method == "w" then
                local simple = true
                for _, s in ipairs(a.split.x_shares) do
                    if s[1] ~= 1 or s[2] then simple = false break end
                end
                if simple then
                    for _, s in ipairs(a.split.y_shares) do
                        if s[1] ~= 1 or s[2] then simple = false break end
                    end
                end
                if method == "w" and simple then
                    r = tostring(#a.split.x_shares)..","..tostring(#a.split.y_shares)
                else
                    r = shares_to_arg_str(a.split.x_shares)..",,"..shares_to_arg_str(a.split.y_shares)
                    method = "d"
                end
                local m = ""
                for _, c in ipairs(a.split.children) do
                    if type(c.parent_x_shares) == "table" then
                        if #m > 0 then m = m.."," end
                        m = m..tostring(c.parent_x_shares[#c.parent_x_shares] - c.parent_x_shares[1] + 1)..","..
                            tostring(c.parent_y_shares[#c.parent_y_shares] - c.parent_y_shares[1] + 1)
                    end
                end
                if method == "d" and r == "1,,1" then
                    r = ""
                end
                r = method..r..(#m == 0 and m or (method == "w" and "," or ",,"))..m
            end
            local acc_dashes = 0
            if a.expansion > 1 then
                for _, c in ipairs(a.split.children) do
                    local cr = get_command(c.id)
                    if cr == "-" then
                        acc_dashes = acc_dashes + 1
                    else
                        if acc_dashes == 0 then
                        elseif acc_dashes == 1 then
                            r = r.."-"
                        else
                            r = r.."c"..tonumber(acc_dashes)
                        end
                        acc_dashes = 0
                        r = r..cr
                    end
                end
                if acc_dashes > 0 then
                    r = r.."c"
                end
            end

            if area_id ~= root_area then
                if a.expansion ~= areas[a.parent_id].expansion - 1 then
                    r = "t"..tostring(a.expansion)..r
                end
            else
                if a.expansion ~= default_expansion then
                    r = "t"..tostring(a.expansion)..r
                end
            end
        elseif a.disabled then
            r = "/"
        elseif a.layout then
            r = "x"..a.layout
        else
            r = "-"
        end

        return r
    end

    local r = get_command(root_area)
    if not to_embed then
        if r == "-" then
            r = "."
        else
            -- The last . may be redundant, but it makes sure no pending op.
            r = r:gsub("[\\c]+$", "").."."
        end
    end
    return r
end

if not in_module then
    print("Testing areas/command processing")
    local function check_transcoded_command(command, expectation)
        local areas, open_areas = areas_from_command(command, {x = 0, y = 0, width = 100, height = 100}, 0)
        if #open_areas > 0 then
            print("Found open areas after command "..command)
            assert(false)
        end
        local transcoded = areas_to_command(areas)
        if transcoded ~= expectation then
            print("Mismatched transcoding for "..command..": got "..transcoded..", expected "..expectation)
            assert(false)
        end
    end
    check_transcoded_command(".", ".")
    check_transcoded_command("3t.", ".")
    check_transcoded_command("121h.", "h1,2,1.")
    check_transcoded_command("1_10,2,1h1s131v.", "h1_10,2,1-v1,3,1.")
    check_transcoded_command("332111w.", "w3,3,2,1,1,1.")
    check_transcoded_command("1310111d.", "d1,3,1,,1,1,1.")
    check_transcoded_command("dw66.", "dw6,6.")
    check_transcoded_command(";dw66.", "dw6,6.")
    check_transcoded_command("101dw66.", "dw6,6.")
    check_transcoded_command("3tdw66.", "t3dw6,6.")
    print("Passed.")
end

return {
    areas_from_command = areas_from_command,
    areas_to_command = areas_to_command,
}
