COLOR_DIR = (...):match("(.-)[^%.]+$").."color."

return {
	color = require(COLOR_DIR.."color"),
	utils = require(COLOR_DIR.."utils"),
	transition = require(COLOR_DIR.."transition"),
}
