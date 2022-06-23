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

-- Okay look. It works. It's not terribly slow because computers can do math
-- quick. The other one decidedly does not work (thanks sagemath, I trusted
-- you...) so this will have to do. I may try to fix it up at some point, I may
-- just leave it be and laugh to myself whenever I see this. As they say, if
-- As they say, if you want something fixed that badly, make a pull request lol
local bouncy = {
	F = (20*math.sqrt(3)*math.pi-30*math.log(2)-6147) /
		(10*(2*math.sqrt(3)*math.pi-6147*math.log(2))),
	easing = function(t) return
(4096*math.pi*math.pow(2, 10*t-10)*math.cos(20/3*math.pi*t-43/6*math.pi)
+6144*math.pow(2, 10*t-10)*math.log(2)*math.sin(20/3*math.pi*t-43/6*math.pi)
+2*math.sqrt(3)*math.pi-3*math.log(2)) /
(2*math.pi*math.sqrt(3)-6147*math.log(2))
	end
}

return {
	linear = linear,
	zero = zero,
	quadratic = quadratic,
	bouncy = bouncy
}
