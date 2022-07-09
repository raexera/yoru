--- Icons directory
local gfs = require("gears.filesystem")
local dir = gfs.get_configuration_dir() .. "icons/"

return {
	--- layouts
	floating = dir .. "layouts/floating.png",
	max = dir .. "layouts/max.png",
	tile = dir .. "layouts/tile.png",
	dwindle = dir .. "layouts/dwindle.png",
	centered = dir .. "layouts/centered.png",
	mstab = dir .. "layouts/mstab.png",
	equalarea = dir .. "layouts/equalarea.png",
	machi = dir .. "layouts/machi.png",

	--- notifications
	notification = dir .. "notification.svg",
	notification_bell = dir .. "notification_bell.svg",

	--- system UI
	volume = dir .. "volume.svg",
	brightness = dir .. "brightness.svg",
	ram = dir .. "ram.svg",
	cpu = dir .. "cpu.svg",
	temp = dir .. "temp.svg",
	disk = dir .. "disk.svg",
	battery = dir .. "battery.svg",
	battery_low = dir .. "battery-low.svg",
	charging = dir .. "charging.svg",
	web_browser = dir .. "firefox.svg",
	awesome_logo = dir .. "awesome-logo.svg",
}
