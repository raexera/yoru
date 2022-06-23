local math = math
local screen = screen
local mylayout = {}
mylayout.name = "equalarea"

local function divide(p, g, low, high, cls, mwfact, mcount)
    if low == high then
        p.geometries[cls[low]] = g
    else
        local masters = math.max(0, math.min(mcount, high) - low + 1)
        local numblock = high - low + 1
        local slaves = numblock - masters
        local smalldiv
        if numblock > 5 and (numblock % 5) == 0 then
            smalldiv = math.floor(numblock / 5)
        else
            if (numblock % 3) == 0 then
                smalldiv = math.floor(numblock / 3)
            else
                smalldiv = math.floor(numblock / 2)
            end
        end
        local bigdiv = numblock - smalldiv
        local smallmasters = math.min(masters, smalldiv)
        local bigmasters = masters - smallmasters
        local smallg = {}
        local bigg = {}
        smallg.x = g.x
        smallg.y = g.y
        if g.width > (g.height * 1.3) then
            smallg.height = g.height
            bigg.height = g.height
            bigg.width = math.floor(
                g.width
                    * (bigmasters * (mwfact - 1) + bigdiv)
                    / (slaves + mwfact * masters)
            )
            smallg.width = g.width - bigg.width
            bigg.y = g.y
            bigg.x = g.x + smallg.width
        else
            smallg.width = g.width
            bigg.width = g.width
            bigg.height = math.floor(
                g.height
                    * (bigmasters * (mwfact - 1) + bigdiv)
                    / (slaves + mwfact * masters)
            )
            smallg.height = g.height - bigg.height
            bigg.x = g.x
            bigg.y = g.y + smallg.height
        end
        divide(p, smallg, low, high - bigdiv, cls, mwfact, mcount)
        divide(p, bigg, low + smalldiv, high, cls, mwfact, mcount)
    end
    return
end

function mylayout.arrange(p)
    local t = p.tag or screen[p.screen].selected_tag
    local wa = p.workarea
    local cls = p.clients

    if #cls == 0 then
        return
    end
    local mwfact = t.master_width_factor * 2
    local mcount = t.master_count
    local g = {}
    g.height = wa.height
    g.width = wa.width
    g.x = wa.x
    g.y = wa.y
    divide(p, g, 1, #cls, cls, mwfact, mcount)
end

return mylayout
