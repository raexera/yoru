local tonumber = tonumber
local string = string
local math = math
local floor = math.floor
local max = math.max
local min = math.min
local abs = math.abs
local format = string.format

local _color = {}

--- Try to guess if a color is dark or light.
--
-- @string color The color with hexadecimal HTML format `"#RRGGBB"`.
-- @treturn bool `true` if the color is dark, `false` if it is light.
function _color.is_dark(color)
    -- Try to determine if the color is dark or light
    local numeric_value = 0
    for s in color:gmatch("[a-fA-F0-9][a-fA-F0-9]") do
        numeric_value = numeric_value + tonumber("0x" .. s)
    end
    return (numeric_value < 383)
end

function _color.is_opaque(color)
    if type(color) == "string" then
        color = _color.hex_to_rgba(color)
    end

    return color.a < 0.01
end

--- Lighten a color.
--
-- @string color The color to lighten with hexadecimal HTML format `"#RRGGBB"`.
-- @int[opt=26] amount How much light from 0 to 255. Default is around 10%.
-- @treturn string The lighter color
function _color.lighten(color, amount)
    amount = amount or 26
    local c = {
        r = tonumber("0x" .. color:sub(2, 3)),
        g = tonumber("0x" .. color:sub(4, 5)),
        b = tonumber("0x" .. color:sub(6, 7)),
    }

    c.r = c.r + amount
    c.r = c.r < 0 and 0 or c.r
    c.r = c.r > 255 and 255 or c.r
    c.g = c.g + amount
    c.g = c.g < 0 and 0 or c.g
    c.g = c.g > 255 and 255 or c.g
    c.b = c.b + amount
    c.b = c.b < 0 and 0 or c.b
    c.b = c.b > 255 and 255 or c.b

    return string.format("#%02x%02x%02x", c.r, c.g, c.b)
end

--- Darken a color.
--
-- @string color The color to darken with hexadecimal HTML format `"#RRGGBB"`.
-- @int[opt=26] amount How much dark from 0 to 255. Default is around 10%.
-- @treturn string The darker color
function _color.darken(color, amount)
    amount = amount or 26
    return _color.lighten(color, -amount)
end

-- Returns a value that is clipped to interval edges if it falls outside the interval
function _color.clip(num, min_num, max_num)
    return max(min(num, max_num), min_num)
end

-- Converts the given hex color to rgba
function _color.hex_to_rgba(color)
    color = color:gsub("#", "")
    return { r = tonumber("0x" .. color:sub(1, 2)),
             g = tonumber("0x" .. color:sub(3, 4)),
             b = tonumber("0x" .. color:sub(5, 6)),
             a = #color == 8 and tonumber("0x" .. color:sub(7, 8)) or 255 }
end

-- Converts the given rgba color to hex
function _color.rgba_to_hex(color)
	local r = _color.clip(color.r or color[1], 0, 255)
	local g = _color.clip(color.g or color[2], 0, 255)
	local b = _color.clip(color.b or color[3], 0, 255)
	local a = _color.clip(color.a or color[4] or 255, 0, 255)
	return "#" .. format("%02x%02x%02x%02x",
			floor(r),
			floor(g),
			floor(b),
            floor(a))
end

-- Converts the given hex color to hsv
function _color.hex_to_hsv(color)
    local color = _color.hex2rgb(color)
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

    return { h = H,
             s = S * 100,
             v = V * 100 }
end

-- Converts the given hsv color to hex
function _color.hsv_to_hex(H, S, V)
    S = S / 100
    V = V / 100
    if H > 360 then H = 360 end
    if H < 0 then H = 0 end
    local C = V * S
    local X = C * (1 - abs(((H / 60) % 2) - 1))
    local m = V - C
    local r_, g_, b_ = 0, 0, 0
    if H >= 0 and H < 60 then
        r_, g_, b_ = C, X, 0
    elseif H >= 60 and H < 120 then
        r_, g_, b_ = X, C, 0
    elseif H >= 120 and H < 180 then
        r_, g_, b_ = 0, C, X
    elseif H >= 180 and H < 240 then
        r_, g_, b_ = 0, X, C
    elseif H >= 240 and H < 300 then
        r_, g_, b_ = X, 0, C
    elseif H >= 300 and H < 360 then
        r_, g_, b_ = C, 0, X
    end
    local r, g, b = (r_ + m) * 255, (g_ + m) * 255, (b_ + m) * 255
    return ("#%02x%02x%02x"):format(floor(r), floor(g), floor(b))
end

function _color.multiply(color, amount)
    return { _color.clip(color.r * amount, 0, 255),
             _color.clip(color.g * amount, 0, 255),
             _color.clip(color.b * amount, 0, 255),
             255 }
end

return _color
