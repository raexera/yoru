local filesystem = require("gears.filesystem")
local config_dir = filesystem.get_configuration_dir()
local utils_dir = config_dir .. "utilities/"

return {
	-- List of binaries/shell scripts that will execute for a certain task
	utils = {
		-- Fullscreen screenshot
		full_screenshot = utils_dir .. "screensht full",
		-- Area screenshot
		area_screenshot = utils_dir .. "screensht area",
		-- Color Picker
		color_picker = utils_dir .. "xcolor-pick",
	},
}
