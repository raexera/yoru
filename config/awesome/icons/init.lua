-- Icons directory
local gfs = require("gears.filesystem")
local dir = gfs.get_configuration_dir() .. "icons/"

return {
	-- notifications
	notification = dir .. "notification.svg",
	notification_bell = dir .. "notification_bell.svg",

	-- system UI
	ram = dir .. "ram.svg",
	cpu = dir .. "cpu.svg",
	temp = dir .. "temp.svg",
	disk = dir .. "disk.svg",
	power = dir .. "power.svg",
	memory = dir .. "memory.svg",

	--- Previous and Next icon
	previous = dir .. "go-previous.svg",
	next = dir .. "go-next.svg",
	-- OSD
	volume = dir .. "volume.svg",
	brightness = dir .. "brightness.svg",

	-- layout
	floating = dir .. "floating.svg",
}
