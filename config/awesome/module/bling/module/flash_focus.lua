local gears = require("gears")
local beautiful = require("beautiful")

local op = beautiful.flash_focus_start_opacity or 0.6
local stp = beautiful.flash_focus_step or 0.01

local flashfocus = function(c)
    if c then
        c.opacity = op
        local q = op
        local g = gears.timer({
            timeout = stp,
            call_now = false,
            autostart = true,
        })

        g:connect_signal("timeout", function()
            if not c.valid then
                return
            end
            if q >= 1 then
                c.opacity = 1
                g:stop()
            else
                c.opacity = q
                q = q + stp
            end
        end)
    end

    -- Bring the focused client to the top
    if c then
        c:raise()
    end
end

local enable = function()
    client.connect_signal("focus", flashfocus)
end
local disable = function()
    client.disconnect_signal("focus", flashfocus)
end

return { enable = enable, disable = disable, flashfocus = flashfocus }
