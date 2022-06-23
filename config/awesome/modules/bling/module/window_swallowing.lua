local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")

local helpers = require(tostring(...):match(".*bling") .. ".helpers")

-- It might actually swallow too much, that's why there is a filter option by classname
-- without the don't-swallow-list it would also swallow for example
-- file pickers or new firefox windows spawned by an already existing one

local window_swallowing_activated = false

-- you might want to add or remove applications here
local parent_filter_list = beautiful.parent_filter_list
    or beautiful.dont_swallow_classname_list
    or { "firefox", "Gimp", "Google-chrome" }
local child_filter_list = beautiful.child_filter_list
    or beautiful.dont_swallow_classname_list or { }

-- for boolean values the or chain way to set the values breaks with 2 vars
-- and always defaults to true so i had to do this to se the right value...
local swallowing_filter = true
local filter_vars = { beautiful.swallowing_filter, beautiful.dont_swallow_filter_activated }
for _, var in pairs(filter_vars) do
    swallowing_filter = var
end

-- check if element exist in table
-- returns true if it is
local function is_in_table(element, table)
    local res = false
    for _, value in pairs(table) do
        if element:match(value) then
            res = true
            break
        end
    end
    return res
end

-- if the swallowing filter is active checks the child and parent classes
-- against their filters
local function check_swallow(parent, child)
    local res = true
    if swallowing_filter then
        local prnt = not is_in_table(parent, parent_filter_list)
        local chld = not is_in_table(child, child_filter_list)
        res = ( prnt and chld )
    end
    return res
end

-- async function to get the parent's pid
-- recieves a child process pid and a callback function
-- parent_pid in format "init(1)---ancestorA(pidA)---ancestorB(pidB)...---process(pid)"
function get_parent_pid(child_ppid, callback)
    local ppid_cmd = string.format("pstree -A -p -s %s", child_ppid)
    awful.spawn.easy_async(ppid_cmd, function(stdout, stderr, reason, exit_code)
        -- primitive error checking
        if stderr and stderr ~= "" then
            callback(stderr)
            return
        end
        local ppid = stdout
        callback(nil, ppid)
    end)
end


-- the function that will be connected to / disconnected from the spawn client signal
local function manage_clientspawn(c)
    -- get the last focused window to check if it is a parent window
    local parent_client = awful.client.focus.history.get(c.screen, 1)
    if not parent_client then
        return
    elseif parent_client.type == "dialog" or parent_client.type == "splash" then
        return
    end

    get_parent_pid(c.pid, function(err, ppid)
        if err then
            return
        end
        parent_pid = ppid
    if
        -- will search for "(parent_client.pid)" inside the parent_pid string
        ( tostring(parent_pid):find("("..tostring(parent_client.pid)..")") )
        and check_swallow(parent_client.class, c.class)
    then
        c:connect_signal("unmanage", function()
            if parent_client then
                helpers.client.turn_on(parent_client)
                helpers.client.sync(parent_client, c)
            end
        end)

        helpers.client.sync(c, parent_client)
        helpers.client.turn_off(parent_client)
    end
    end)
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
