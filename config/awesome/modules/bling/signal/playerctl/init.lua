local awful = require("awful")
local gtimer = require("gears.timer")
local beautiful = require("beautiful")
local naughty = require("naughty")

-- Use CLI backend as default as it is supported on most if not all systems
local backend_config = beautiful.playerctl_backend or "playerctl_cli"
local backends = {
    playerctl_cli = require(... .. ".playerctl_cli"),
    playerctl_lib = require(... .. ".playerctl_lib"),
}

local backend = nil

local function enable_wrapper(args)
    local open = naughty.action { name = "Open" }

    open:connect_signal("invoked", function()
        awful.spawn("xdg-open https://blingcorp.github.io/bling/#/signals/pctl")
    end)

    gtimer.delayed_call(function()
        naughty.notify({
            title = "Bling Error",
            text = "Global signals are deprecated! Please take a look at the playerctl documentation.",
            app_name = "Bling Error",
            app_icon = "system-error",
            actions = { open }
        })
    end)

    backend_config = (args and args.backend) or backend_config
    backend = backends[backend_config](args)
    return backend
end

local function disable_wrapper()
    backend:disable()
end

return {
    lib = backends.playerctl_lib,
    cli = backends.playerctl_cli,
    enable = enable_wrapper,
    disable = disable_wrapper
}