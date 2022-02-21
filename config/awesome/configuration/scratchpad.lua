local bling = require("module.bling")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local rubato = require("module.rubato")

local music_anim = {
    x = rubato.timed {
        pos = -970,
        rate = 120,
        easing = rubato.quadratic,
        intro = 0.1,
        duration = 0.3,
        awestore_compat = true
    }
}

local music_scratch = bling.module.scratchpad:new{
    command = music,
    rule = {instance = "music"},
    sticky = false,
    autoclose = false,
    floating = true,
    geometry = {x = dpi(10), y = dpi(580), height = dpi(460), width = dpi(960)},
    reapply = true,
    rubato = music_anim
}

awesome.connect_signal("scratch::music", function() music_scratch:toggle() end)

local chat_anim = {
    y = rubato.timed {
        pos = 1090,
        rate = 120,
        easing = rubato.quadratic,
        intro = 0.1,
        duration = 0.3,
        awestore_compat = true
    }
}

local chat_scratch = bling.module.scratchpad:new{
    command = "Discord",
    rule = {
        -- class = "chat"
        class = "discord"
    },
    sticky = false,
    autoclose = false,
    floating = true,
    geometry = {x = dpi(460), y = dpi(90), height = dpi(900), width = dpi(1000)},
    reapply = true,
    rubato = chat_anim
}

awesome.connect_signal("scratch::chat", function() chat_scratch:toggle() end)
