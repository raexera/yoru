-- Icons directory
local dir = os.getenv("HOME") .. "/.config/awesome/theme/assets/icons/"

return {
	-- notifs
	notification = dir .. "notification.svg",
	notification_bell = dir .. "notification_bell.svg",

	-- system
	ram = dir .. "ram.svg",
	cpu = dir .. "cpu.svg",
	temp = dir .. "temp.svg",
	disk = dir .. "disk.svg",
}
