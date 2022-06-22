package = "bling"
version = "dev-1"

source = {
   url = "git://github.com/BlingCorp/bling",
   branch = "master",
}

description = {
   summary = "Utilities for the AwesomeWM",
   detailed = [[
    This module extends the Awesome window manager with alternative layouts,
    flash focus, tabbing, a simple tiling wallpaper generator, a declarative
    wallpaper setter, window swallowing and a playerctl signal.
   ]],
   homepage = "https://github.com/BlingCorp/bling",
   license = "MIT",
}

dependencies = {
   "lua >= 5.1",
}

build = {
   type = "builtin",
   modules = {
       ["bling"] = "init.lua",
       ["bling.helpers"] = "helpers/init.lua",
       ["bling.helpers.client"] = "helpers/client.lua",
       ["bling.helpers.color"] = "helpers/color.lua",
       ["bling.helpers.filesystem"] = "helpers/filesystem.lua",
       ["bling.helpers.shape"] = "helpers/shape.lua",
       ["bling.helpers.time"] = "helpers/time.lua",
       ["bling.layout"] = "layout/init.lua",
       ["bling.layout.centered"] = "layout/centered.lua",
       ["bling.layout.deck"] = "layout/deck.lua",
       ["bling.layout.equalarea"] = "layout/equalarea.lua",
       ["bling.layout.horizontal"] = "layout/horizontal.lua",
       ["bling.layout.mstab"] = "layout/mstab.lua",
       ["bling.layout.vertical"] = "layout/vertical.lua",
       ["bling.module"] = "module/init.lua",
       ["bling.module.flash_focus"] = "module/flash_focus.lua",
       ["bling.module.scratchpad"] = "module/scratchpad.lua",
       ["bling.module.tabbed"] = "module/tabbed.lua",
       ["bling.module.tiled_wallpaper"] = "module/tiled_wallpaper.lua",
       ["bling.module.wallpaper"] = "module/wallpaper.lua",
       ["bling.module.window_swallowing"] = "module/window_swallowing.lua",
       ["bling.signal"] = "signal/init.lua",
       ["bling.signal.playerctl"] = "signal/playerctl/init.lua",
       ["bling.signal.playerctl.playerctl_cli"] = "signal/playerctl/playerctl_cli.lua",
       ["bling.signal.playerctl.playerctl_lib"] = "signal/playerctl/playerctl_lib.lua",
       ["bling.widget"] = "widget/init.lua",
       ["bling.widget.tabbar.boxes"] = "widget/tabbar/boxes.lua",
       ["bling.widget.tabbar.default"] = "widget/tabbar/default.lua",
       ["bling.widget.tabbar.modern"] = "widget/tabbar/modern.lua",
       ["bling.widget.tabbed_misc"] = "widget/tabbed_misc/init.lua",
       ["bling.widget.tabbed_misc.custom_tasklist"] = "widget/tabbed_misc/custom_tasklist.lua",
       ["bling.widget.tabbed_misc.titlebar_indicator"] = "widget/tabbed_misc/titlebar_indicator.lua",
       ["bling.widget.tag_preview"] = "widget/tag_preview.lua",
       ["bling.widget.task_preview"] = "widget/task_preview.lua",
       ["bling.widget.window_switcher"] = "widget/window_switcher.lua",
   },
}
