local awful = require("awful")
local bling = require("modules.bling")
local machi = require("modules.layout-machi")

--- Custom Layouts
local mstab = bling.layout.mstab
local centered = bling.layout.centered
local equal = bling.layout.equalarea
local deck = bling.layout.deck

machi.editor.nested_layouts = {
	["0"] = deck,
	["1"] = awful.layout.suit.spiral,
	["2"] = awful.layout.suit.fair,
	["3"] = awful.layout.suit.fair.horizontal,
}

--- Set the layouts
tag.connect_signal("request::default_layouts", function()
	awful.layout.append_default_layouts({
		awful.layout.suit.spiral.dwindle,
		awful.layout.suit.tile,
		awful.layout.suit.floating,
		awful.layout.suit.max,
		centered,
		mstab,
		equal,
		machi.default_layout,
	})
end)
