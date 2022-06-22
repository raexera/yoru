local math = math

local mylayout = {}

mylayout.name = "vertical"

function mylayout.arrange(p)
    local area = p.workarea
    local t = p.tag or screen[p.screen].selected_tag
    local mwfact = t.master_width_factor
    local nmaster = math.min(t.master_count, #p.clients)
    local nslaves = #p.clients - nmaster

    local master_area_width = area.width * mwfact
    local slave_area_width = area.width - master_area_width

    -- Special case: no slaves
    if nslaves == 0 then
        master_area_width = area.width
        slave_area_width = 0
    end

    -- Special case: no masters
    if nmaster == 0 then
        master_area_width = 0
        slave_area_width = area.width
    end

    -- iterate through masters
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

    -- itearte through slaves
    for idx = 1, nslaves do
        local c = p.clients[idx + nmaster]
        local g = {
            x = area.x
                + master_area_width
                + (idx - 1) * (slave_area_width / nslaves),
            y = area.y,
            width = slave_area_width / nslaves,
            height = area.height,
        }
        p.geometries[c] = g
    end
end

return mylayout
