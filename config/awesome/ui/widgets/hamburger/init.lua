local wibox = require("wibox")
local rubato = require("module.rubato")
local awful = require("awful")
local gears = require("gears")

local function get_draw_function(pos)
	return function(_, _, cr, _, height)
		cr:set_source_rgb(1.0, 1.0, 1.0)
		cr:set_line_width(0.1 * height)

		--top, middle, bottom, left, right, radius, radius/2 pi*2
		local t, m, b, l, r, ra, ra2, pi2
		t = 0.3 * height
		m = 0.5 * height
		b = 0.7 * height
		l = 0.25 * height
		r = 0.75 * height
		ra = 0.05 * height
		ra2 = ra / 2
		pi2 = math.pi * 2

		if pos <= 0.5 then
			local tpos = t + (m - t) * pos
			local bpos = b - (b - m) * pos

			pos = pos * 2

			cr:arc(l, tpos, ra, 0, pi2)
			cr:arc(r, tpos, ra, 0, pi2)
			cr:fill()

			cr:arc(l, m, ra, 0, pi2)
			cr:arc(r, m, ra, 0, pi2)
			cr:fill()

			cr:arc(l, bpos, ra, 0, pi2)
			cr:arc(r, bpos, ra, 0, pi2)
			cr:fill()

			cr:move_to(l + ra2, tpos)
			cr:line_to(r - ra2, tpos)

			cr:move_to(l + ra2, m)
			cr:line_to(r - ra2, m)

			cr:move_to(l + ra2, bpos)
			cr:line_to(r - ra2, bpos)

			cr:stroke()
		else
			pos = (pos - 0.5) * 2

			cr:move_to(l, m - (m - l) * pos)
			cr:line_to(r, m + (r - m) * pos)

			cr:move_to(l, m + (r - m) * pos)
			cr:line_to(r, m - (m - l) * pos)

			cr:stroke()
		end
	end
end

local function hamburger(other_button)
	local timed

	local w = wibox.widget({

		draw = get_draw_function(0),
		fit = function(_, _, _, height)
			return height, height
		end,
		buttons = gears.table.join(
			-- switch state
			awful.button({}, 1, function()
				timed.target = (timed.target + 1) % 2
			end),
			other_button
		),
		widget = wibox.widget.make_base_widget,
	})

	timed = rubato.timed({
		duration = 0.4,
		intro = 0.3,
		prop_intro = true,
		rate = 30,
		subscribed = function(pos)
			w.draw = get_draw_function(pos)
			w:emit_signal("widget::redraw_needed")
		end,
	})

	return w
end

return hamburger
