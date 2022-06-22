local color_libary = require("modules.color")
local tonumber = tonumber
local string = string
local math = math
local type = type
local floor = math.floor
local max = math.max
local min = math.min
local pow = math.pow
local random = math.random
local abs = math.abs
local format = string.format

local _color = {}

local function round(x, p)
	local power = 10 ^ (p or 0)
	return (x * power + 0.5 - (x * power + 0.5) % 1) / power
end

-- Returns a value that is clipped to interval edges if it falls outside the interval
local function clip(num, min_num, max_num)
	return max(min(num, max_num), min_num)
end

-- Converts the given hex color to rgba
function _color.hex_to_rgb(color)
	color = color:gsub("#", "")
	return {
		r = tonumber("0x" .. color:sub(1, 2)),
		g = tonumber("0x" .. color:sub(3, 4)),
		b = tonumber("0x" .. color:sub(5, 6)),
		a = #color == 8 and tonumber("0x" .. color:sub(7, 8)) or 255,
	}
end

-- Converts the given rgba color to hex
function _color.rgb_to_hex(color)
	local r = clip(color.r or color[1], 0, 255)
	local g = clip(color.g or color[2], 0, 255)
	local b = clip(color.b or color[3], 0, 255)
	local a = clip(color.a or color[4] or 255, 0, 255)
	return "#" .. format("%02x%02x%02x%02x", floor(r), floor(g), floor(b), floor(a))
end

-- Converts the given hex color to hsv
function _color.hex_to_hsv(color)
	local color = _color.hex_to_rgb(color)
	local C_max = max(color.r, color.g, color.b)
	local C_min = min(color.r, color.g, color.b)
	local delta = C_max - C_min
	local H, S, V
	if delta == 0 then
		H = 0
	elseif C_max == color.r then
		H = 60 * (((color.g - color.b) / delta) % 6)
	elseif C_max == color.g then
		H = 60 * (((color.b - color.r) / delta) + 2)
	elseif C_max == color.b then
		H = 60 * (((color.r - color.g) / delta) + 4)
	end
	if C_max == 0 then
		S = 0
	else
		S = delta / C_max
	end
	V = C_max

	return { h = H, s = S * 100, v = V * 100 }
end

--- Try to guess if a color is dark or light.
function _color.is_dark(color)
	color = color_libary.color({ hex = color })

	return color.l <= 0.4
end

--- Check if a color is opaque.
function _color.is_opaque(color)
	color = color_libary.color({ hex = color })

	return color.a == 0
end

-- Calculates the relative luminance of the given color
function _color.relative_luminance(color)
	local function from_sRGB(u)
		return u <= 0.0031308 and 25 * u / 323 or pow(((200 * u + 11) / 211), 12 / 5)
	end

	color = color_libary.color({ hex = color })

	return 0.2126 * from_sRGB(color.r) + 0.7152 * from_sRGB(color.g) + 0.0722 * from_sRGB(color.b)
end

-- Calculates the contrast ratio between the two given colors
function _color.contrast_ratio(fg, bg)
	return (_color.relative_luminance(fg) + 0.05) / (_color.relative_luminance(bg) + 0.05)
end

-- Returns true if the contrast between the two given colors is suitable
function _color.is_contrast_acceptable(fg, bg)
	return _color.contrast_ratio(fg, bg) >= 7 and true
end

-- Returns a bright-ish, saturated-ish, color of random hue
function _color.rand_hex(lb_angle, ub_angle)
	return color_libary.color({
		h = random(lb_angle or 0, ub_angle or 360),
		s = 70,
		v = 90,
	}).hex
end

-- Rotates the hue of the given hex color by the specified angle (in degrees)
function _color.rotate_hue(color, angle)
	color = color_libary.color({ hex = color })

	angle = clip(angle or 0, 0, 360)
	color.h = (color.h + angle) % 360

	return color.hex
end

function _color.button_color(color, amount)
	color = color_libary.color({ hex = color })

	if _color.is_dark(color.hex) then
		color = color + string.format("%fl", amount)
	else
		color = color - string.format("%fl", amount)
	end

	return color.hex
end

function _color.lighten(color, amount)
	amount = amount or 0

	color = color_libary.color({ hex = color })
	color.l = color.l + amount

	return color.hex
end

function _color.darken(color, amount)
	amount = amount or 0

	color = color_libary.color({ hex = color })
	color.l = color.l - amount

	return color.hex
end

-- Pywal like functions
function _color.pywal_blend(color1, color2)
	color1 = color_libary.color({ hex = color1 })
	color2 = color_libary.color({ hex = color2 })

	return color_libary.color({
		r = round(0.5 * color1.r + 0.5 * color2.r),
		g = round(0.5 * color1.g + 0.5 * color2.g),
		b = round(0.5 * color1.b + 0.5 * color2.b),
	}).hex
end

function _color.pywal_saturate_color(color, amount)
	color = color_libary.color({ hex = color })

	color.s = clip(amount, 0, 1)

	return color.hex
end

function _color.pywal_alter_brightness(color, amount, sat)
	sat = sat or 0

	color = color_libary.color({ hex = color })

	color.l = clip(color.l + amount, 0, 1)
	color.s = clip(color.s + sat, 0, 1)

	return color.hex
end

function _color.pywal_lighten(color, amount)
	color = color_libary.color({ hex = color })

	color.r = round(color.r + (255 - color.r) * amount)
	color.g = round(color.g + (255 - color.g) * amount)
	color.b = round(color.b + (255 - color.b) * amount)

	return color.hex
end

function _color.pywal_darken(color, amount)
	color = color_libary.color({ hex = color })

	color.r = round(color.r * (1 - amount))
	color.g = round(color.g * (1 - amount))
	color.b = round(color.b * (1 - amount))

	return color.hex
end

return _color
