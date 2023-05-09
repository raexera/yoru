local lockScreen = require('modules.lockscreen')
lockScreen.init()

awesome.connect_signal("module::lock_screen:show", function()
    lock_screen_show()
end)