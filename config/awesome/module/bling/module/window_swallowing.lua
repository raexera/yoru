local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")

local helpers = require(tostring(...):match(".*bling") .. ".helpers")

-- It might actually swallow too much, that's why there is a filter option by classname
-- without the don't-swallow-list it would also swallow for example
-- file pickers or new firefox windows spawned by an already existing one

local window_swallowing_activated = false

-- you might want to add or remove applications here
local dont_swallow_classname_list = beautiful.dont_swallow_classname_list
    or { "firefox", "Gimp", "Google-chrome" }
local activate_dont_swallow_filter = beautiful.dont_swallow_filter_activated
    or true

-- checks if client classname matches with any entry of the dont-swallow-list
local function check_if_swallow(c)
    if not activate_dont_swallow_filter then
        return true
    end
    for _, classname in ipairs(dont_swallow_classname_list) do
        if classname == c.class then
            return false
        end
    end
    return true
end

-- the function that will be connected to / disconnected from the spawn client signal
local function manage_clientspawn(c)
    -- get the last focused window to check if it is a parent window
    local parent_client = awful.client.focus.history.get(c.screen, 1)
    if not parent_client then
        return
    end

    -- io.popen is normally discouraged. Should probably be changed
    local handle = io.popen(
        [[pstree -T -p -a -s ]]
            .. tostring(c.pid)
            .. [[ | sed '2q;d' | grep -o '[0-9]*$' | tr -d '\n']]
    )
    local parent_pid = handle:read("*a")
    handle:close()

    if
        (tostring(parent_pid) == tostring(parent_client.pid))
        and check_if_swallow(c)
    then
        c:connect_signal("unmanage", function()
            helpers.client.turn_on(parent_client)
            helpers.client.sync(parent_client, c)
        end)

        helpers.client.sync(c, parent_client)
        helpers.client.turn_off(parent_client)
    end
end

-- without the following functions that module would be autoloaded by require("bling")
-- a toggle window swallowing hotkey is also possible that way

local function start()
    client.connect_signal("manage", manage_clientspawn)
    window_swallowing_activated = true
end

local function stop()
    client.disconnect_signal("manage", manage_clientspawn)
    window_swallowing_activated = false
end

local function toggle()
    if window_swallowing_activated then
        stop()
    else
        start()
    end
end

return {
    start = start,
    stop = stop,
    toggle = toggle,
}
