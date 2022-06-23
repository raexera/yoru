local color = require(COLOR_DIR.."color")

--0 is rgb
--1 is hsl
--2 is hsl but backwards

local transition = {
	RGB = 0,
	HSL = 1,
	HSLR = 2,
}

setmetatable(transition, {__call = function(self, col1, col2, method)
	if method == self.RGB then return function(t) return color {
		r = math.min(math.max(col1.r + t * (col2.r - col1.r), 0), 255),
		g = math.min(math.max(col1.g + t * (col2.g - col1.g), 0), 255),
		b = math.min(math.max(col1.b + t * (col2.b - col1.b), 0), 255) }
	end
	else return function(t) return color {
		h = math.max(col1.h + t * (col2.h - (method == self.HSLR and 360 or 0) - col1.h), 0) % 360,
		s = math.min(math.max(col1.s + t * (col2.s - col1.s), 0), 1),
		l = math.min(math.max(col1.l + t * (col2.l - col1.l), 0), 1) }
	end end
end})

return transition
