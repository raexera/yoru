local capi = {
    client = client,
    mouse = mouse,
    screen = screen,
    mousegrabber = mousegrabber
}
local awful = require("awful")

local function mouse_resize_handler(m, c)
    awful.client.incwfact(0, c) -- needed to fix normalization at start
    local start = m(capi.mouse.coords())
    local x, y = start.x, start.y
    local wa = m(c.screen.workarea)
    local idx = awful.client.idx(c)
    local c_above, c_below
    local idx_above, idx_below
    local wfact_above, wfact_below
    local jump_to = {x = x, y = y}
    local move_mwfact = false

    do
        local g = m(c:geometry())

        local v_border = 0.2 * g.height

        if idx.idx > 1 and y >= g.y and y <= g.y + v_border then
            -- we are near the top edge of the window
            c_above = awful.client.next(-1, c)
            c_below = c
            jump_to.y = g.y
            idx_above = idx.idx - 1
            idx_below = idx.idx
        elseif idx.idx < (idx.num) and y >= g.y + g.height - v_border then
            -- we are near the bottom edge of the window
            c_above = c
            c_below = awful.client.next(1, c)
            idx_above = idx.idx
            idx_below = idx.idx + 1
            jump_to.y = g.y + g.height
        end

        local mw_split = wa.x + wa.width *
                             c.screen.selected_tag.master_width_factor

        if math.abs(mw_split - x) > wa.width / 6 then
            move_mwfact = false
        else
            move_mwfact = true
            jump_to.x = mw_split
        end
    end

    if idx_above then
        local t = c.screen.selected_tag
        local data = t.windowfact or {}
        local colfact = data[idx.col] or {}
        wfact_above = colfact[idx_above] or 1
        wfact_below = colfact[idx_below] or 1
    end

    if idx_above and move_mwfact then
        cursor = "cross"
    elseif idx_above then
        cursor = m({y = "sb_v_double_arrow", x = "sb_h_double_arrow"}).y
    elseif move_mwfact then
        cursor = m({y = "sb_v_double_arrow", x = "sb_h_double_arrow"}).x
    else
        return false
    end

    capi.mouse.coords(m(jump_to))

    capi.mousegrabber.run(function(_mouse)
        if not c.valid then return false end

        local pressed = false
        for _, v in ipairs(_mouse.buttons) do
            if v then
                pressed = true
                break
            end
        end

        _mouse = m(_mouse)

        if pressed then
            if move_mwfact then
                c.screen.selected_tag.master_width_factor =
                    math.min(math.max((_mouse.x - wa.x) / wa.width, 0.01), 0.99)
            end

            if idx_above then
                local factor_delta = (_mouse.y - jump_to.y) / wa.height

                if factor_delta < 0 then
                    factor_delta = math.max(factor_delta, -(wfact_above - 0.05))
                else
                    factor_delta = math.min(factor_delta, wfact_below - 0.05)
                end

                local t = c.screen.selected_tag
                local data = t.windowfact or {}
                local colfact = data[idx.col] or {}
                colfact[idx_above] = wfact_above + factor_delta
                colfact[idx_below] = wfact_below - factor_delta
                awful.client.incwfact(0, c_above) -- just in case
            end
            return true
        else
            return false
        end
    end, cursor)

    return true
end

awful.layout.suit.tile.mouse_resize_handler =
    function(c) return mouse_resize_handler(function(x) return x end, c) end
awful.layout.suit.tile.bottom.mouse_resize_handler =
    function(c)
        return mouse_resize_handler(function(q)
            return {x = q.y, y = q.x, width = q.height, height = q.width}
        end, c)
    end

-- local old_coords = mouse.coords

-- mouse.coords = function(...)
--    if select(1, ...) and not(select(1, ...).blah) then
--       print("set mouse!!!")
--       print(debug.traceback())

--    end
--    return old_coords(...)
-- end
