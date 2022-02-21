--- Linear easing (in quotes).
local linear = {
	F = 0.5,
	easing = function(t) return t end
}

--- Sublinear (?) easing.
local zero = {
	F = 1,
	easing = function() return 1 end
}

--- Quadratic easing.
local quadratic = {
	F = 1/3,
	easing = function(t) return t * t end
}

--bouncy constants
local b_cs = {
	c1 = 6 * math.pi - 3 * math.sqrt(3) * math.log(2),
	c2 = math.sqrt(3) * math.pi,
	c3 = 6 * math.sqrt(3) * math.log(2),
	c4 = 6 * math.pi - 6147 * math.sqrt(3) * math.log(2),
	c5 = 46 * math.pi / 6
}

--the bouncy one as seen in the readme
local bouncy = {
	F = (20 * math.pi - (10 * math.log(2) - 2049) * math.sqrt(3)) /
		(20 * math.pi - 20490 * math.sqrt(3) * math.log(2)),
	easing = function(t)
		--short circuit
		if t == 0 then return 0 end
		if t == 1 then return 1 end

		local c1 = (20 * t * math.pi) / 3 - b_cs.c5
		local c2 = math.pow(2, 10 * t + 1)
		return (b_cs.c1 + b_cs.c2 * c2 * math.cos(c1) + b_cs.c3 * c2 * math.sin(c1)) / b_cs.c4
	end
}

return {
	linear = linear,
	zero = zero,
	quadratic = quadratic,
	bouncy = bouncy
}
