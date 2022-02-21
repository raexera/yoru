local awful = require("awful")
local beautiful = require("beautiful")
local ruled = require("ruled")

ruled.client.connect_signal("request::rules", function()

    -- Global
    ruled.client.append_rule {
        id = "global",
        rule = {},
        properties = {
            focus = awful.client.focus.filter,
            raise = true,
            size_hints_honor = false,
            screen = awful.screen.preferred,
            placement = awful.placement.no_overlap+awful.placement.no_offscreen
        }
    }

    -- tasklist order
    ruled.client.append_rule {
        id = "tasklist_order",
        rule = {},
        properties = {},
        callback = awful.client.setslave
    }

    -- Float em
    ruled.client.append_rule {
        id = "floating",
        rule_any = {
            class = {"Arandr", "Blueman-manager", "Sxiv", "fzfmenu"},
            role = {
                "pop-up" -- e.g. Google Chrome's (detached) Developer Tools.
            },
            name = {"Friends List", "Steam - News"},
            instance = {"spad", "discord", "music"}
        },
        properties = {floating = true, placement = awful.placement.centered}
    }

    -- Borders
    ruled.client.append_rule {
        id = "borders",
        rule_any = {type = {"normal", "dialog"}},
        except_any = {
            role = {"Popup"},
            type = {"splash"},
            name = {"^discord.com is sharing your screen.$"}
        },
        properties = {
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal
        }
    }

    -- Center Placement
    ruled.client.append_rule {
        id = "center_placement",
        rule_any = {
            type = {"dialog"},
            class = {"Steam", "discord", "markdown_input", "scratchpad"},
            instance = {"markdown_input", "scratchpad"},
            role = {"GtkFileChooserDialog", "conversation"}
        },
        properties = {placement = awful.placement.center}
    }

    -- Titlebar rules
    ruled.client.append_rule {
        id = "titlebars",
        rule_any = {type = {"normal", "dialog"}},
        except_any = {
            class = {"Steam", "zoom", "jetbrains-studio", "chat", "Org.gnome.Nautilus", "Firefox", "Google-chrome", "Brave-browser"},
            type = {"splash"},
            instance = {"onboard"},
            name = {"^discord.com is sharing your screen.$"}
        },
        properties = {titlebars_enabled = true}
    }
end)

