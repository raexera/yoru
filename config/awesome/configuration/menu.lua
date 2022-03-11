-- Standard Awesome Library
local awful = require("awful")
local hotkeys_popup = require("awful.hotkeys_popup")
local beautiful = require("beautiful")

-- Create a launcher widget and a main menu
awful.screen.connect_for_each_screen(function(s)

    -- Submenu
    awesomemenu = {
        {"Hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end},
        {"Restart", awesome.restart},
        {"Quit", function() awesome.quit() end}
    }

    -- Powermenu
    powermenu = {
        {"Power OFF", function() awful.spawn.with_shell("systemctl poweroff") end},
        {"Reboot", function() awful.spawn.with_shell("systemctl reboot") end},
        {"Suspend", function() 
            lock_screen_show()
            awful.spawn.with_shell("systemctl suspend")  
        end},
        {"Lock Screen", function() lock_screen_show() end}
    }

    -- Mainmenu
    mymainmenu = awful.menu({
        items = {
            {"Terminal", terminal, beautiful.awesome_logo},
            {"Code Editor", vscode},
            {"File Manager", filemanager},
            {"Web Browser", browser},
            {"Discord", discord},
            {"AwesomeWM", awesomemenu},
            {"Power Menu", powermenu}
        }
    })

end)

