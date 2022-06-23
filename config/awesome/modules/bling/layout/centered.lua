local awful = require("awful")
local math = math

local mylayout = {}

mylayout.name = "centered"

function mylayout.arrange(p)
    local area = p.workarea
    local t = p.tag or screen[p.screen].selected_tag
    local nmaster = math.min(t.master_count, #p.clients)
    local nslaves = #p.clients - nmaster

    local master_area_width = area.width * t.master_width_factor
    if t.master_count == 0 then master_area_width = 0 end
    local slave_width = 0.5 * (area.width - master_area_width)
    local master_area_x = area.x + slave_width


    -- Special case: few slaves -> make masters take more space - unless requested otherwise!
    if nslaves < 2 and t.master_fill_policy ~= "master_width_factor" then
        master_area_x = area.x

        if nslaves == 1 then
            slave_width = area.width - master_area_width
        else
            master_area_width = area.width
        end
    end


    -- iterate through masters
    for idx = 1, nmaster do
        local c = p.clients[idx]
        local g
        g = {
            x = master_area_x,
            y = area.y + (nmaster - idx) * (area.height / nmaster),
            width = master_area_width,
            height = area.height / nmaster,
        }
        p.geometries[c] = g
    end


    -- iterate through slaves
    local number_of_left_sided_slaves = math.floor(nslaves / 2)
    local number_of_right_sided_slaves = nslaves - number_of_left_sided_slaves
    local left_iterator = 0
    local right_iterator = 0

    for idx = 1, nslaves do
        local c = p.clients[idx + nmaster]
        local g
        if idx % 2 == 0 then
            g = {
                x = area.x,
                y = area.y
                    + left_iterator
                        * (area.height / number_of_left_sided_slaves),
                width = slave_width,
                height = area.height / number_of_left_sided_slaves,
            }
            left_iterator = left_iterator + 1
        else
            g = {
                x = master_area_x + master_area_width,
                y = area.y
                    + right_iterator
                        * (area.height / number_of_right_sided_slaves),
                width = slave_width,
                height = area.height / number_of_right_sided_slaves,
            }
            right_iterator = right_iterator + 1
        end
        p.geometries[c] = g
    end
end

return mylayout
