-- Icons directory
local gfs = require("gears.filesystem")
local dir = gfs.get_configuration_dir() .. "icons/"

return {
	-- notifications
	notification = dir .. "notification.svg",
	notification_bell = dir .. "notification_bell.svg",

	-- system
	ram = dir .. "ram.svg",
	cpu = dir .. "cpu.svg",
	temp = dir .. "temp.svg",
	disk = dir .. "disk.svg",
}
