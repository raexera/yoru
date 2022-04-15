local awful = require("awful")

require("module.bling")
require("module.rubato")
require("module.layout-machi")
require("module.better-resize")
require("module.exit-screen")
require("module.savefloats")
require("module.window_switcher").enable(awful.screen.focused())
