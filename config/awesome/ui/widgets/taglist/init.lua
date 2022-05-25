local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local wibox = require("wibox")
local helpers = require("helpers")
local rubato = require("module.rubato")
local color = require("module.color")

rubato.set_def_rate(60)

--- useful color constants
local ia_rgb = color.color({ hex = beautiful.xcolor8, disable_hsl = true }) --inactive color
local a_rgb = color.color({ hex = beautiful.accent, disable_hsl = true }) --active color
local u_rgb = color.color({ hex = beautiful.xcolor1, disable_hsl = true }) --urgent color
local s_rgb = color.color({ hex = beautiful.xforeground, disable_hsl = true }) --slidey color

-- Calculate the diff in colors for some stuff later on
local diff = {}
diff.r = ia_rgb.r - a_rgb.r
diff.g = ia_rgb.g - a_rgb.g
diff.b = ia_rgb.b - a_rgb.b

--- Draws a circle
local function draw_circle(cr, height)
	cr:arc(height / 2, height / 2, dpi(6), 0, math.pi * 2)
	cr:fill()
end

--- Draws the slidey thing
local function draw_slidey_thing(cr, height, xpos)
	cr:arc(xpos, height / 2, dpi(6), 0, math.pi * 2)
	cr:fill()
end

--- Creates the taglist widgets.
local function create_taglist_widgets(s, slidey_thing)
	local l = { layout = wibox.layout.fixed.horizontal }

	for _, t in pairs(s.tags) do
		-- Create the widget and instantiate its base values
		local w = wibox.widget.base.make_widget()
		function w:fit(_, _, height)
			return height, height
		end
		function w:draw(_, cr, _, height)
			cr:set_source_rgb(ia_rgb.r / 255, ia_rgb.g / 255, ia_rgb.b / 255)
			draw_circle(cr, height)
		end
		w.buttons = awful.button({}, 1, function()
			t:view_only()
		end)

		--difference in color
		local d = { ar = 0, ag = 0, ab = 0, ur = 0, ug = 0, ub = 0, dim = 0 }

		-- All the interpolators
		local active_timed = rubato.timed({
			intro = 0.075,
			duration = 0.2,
		})

		local urgent_timed = rubato.timed({
			intro = 0.075,
			duration = 0.2,
		})

		local hover_timed = rubato.timed({
			intro = 0.075,
			duration = 0.2,
		})

		--- Updates RGB for the taglist (to allow for hover)
		local function update_rgb(rgb)
			local r = (rgb.r + d.ar + d.ur) * d.dim
			local g = (rgb.g + d.ag + d.ug) * d.dim
			local b = (rgb.b + d.ab + d.ub) * d.dim
			function w:draw(_, cr, _, height)
				cr:set_source_rgb(r / 255, g / 255, b / 255)
				draw_circle(cr, height)
			end
			w:emit_signal("widget::redraw_needed")
		end

		active_timed:subscribe(function(pos)
			d.ar = -pos * diff.r
			d.ag = -pos * diff.g
			d.ab = -pos * diff.b
			update_rgb(ia_rgb)
		end)

		urgent_timed:subscribe(function(pos)
			d.ur = (u_rgb.r - a_rgb.r - d.ar) * pos
			d.ug = (u_rgb.g - a_rgb.g - d.ag) * pos
			d.ub = (u_rgb.b - a_rgb.b - d.ab) * pos
			update_rgb(ia_rgb)
		end)

		hover_timed:subscribe(function(pos)
			d.dim = 1 - 0.1 * pos
			update_rgb(ia_rgb)
		end)

		client.connect_signal("tagged", function()
			if not (#t:clients() == 0) then
				active_timed.target = 1
			else
				active_timed.target = 0
			end
		end)

		client.connect_signal("untagged", function()
			if not (#t:clients() == 0) then
				active_timed.target = 1
			else
				active_timed.target = 0
			end
		end)

		t:connect_signal("property::urgent", function()
			if awful.tag.getproperty(t, "urgent") then
				urgent_timed.target = 1
			else
				urgent_timed.target = 0
			end
		end)

		w:connect_signal("mouse::enter", function()
			--look, I know this isn't by any means idiomatic, but it's either this or
			--have a signal for every single one of the taglist widgets, which I really
			--don't want to do. So random variable put in tag it is.
			t.is_being_hovered = true
			hover_timed.target = 1
			if s.selected_tag == t then
				slidey_thing:hover(1)
			end
		end)

		w:connect_signal("mouse::leave", function()
			t.is_being_hovered = false
			hover_timed.target = 0
			if s.selected_tag == t then
				slidey_thing:hover(0)
			end
		end)

		table.insert(l, w)
	end

	return l
end

--- Updates the position of the slidey thing
local function update_slidey_thing(w, dim, pos)
	function w:draw(_, cr, _, height)
		cr:set_source_rgb(s_rgb.r * dim / 255, s_rgb.g * dim / 255, s_rgb.b * dim / 255)
		draw_slidey_thing(cr, height, height / 2 + (pos - 1) * height)
	end
	w:emit_signal("widget::redraw_needed")
end

--- Creates the slidey thing in the workspace switcher.
local function create_slidey_thing(s)
	local w = wibox.widget({
		fit = function(self, cocntext, width, height)
			return height, height
		end,

		draw = function(self, context, cr, width, height)
			cr:set_source_rgba(0.6, 0.6, 1, 0.3)
			draw_slidey_thing(cr, height, height / 2 + dpi(10))
		end,

		layout = wibox.widget.base.make_widget,
	})

	-- Bouncy easing if I so please
	local timed = rubato.timed({
		duration = 0.85,
		intro = 0.25,
		outro = 0.65,
		inter = 0.2,
		prop_intro = true,
		pos = index,
		easing = rubato.easing.linear,
		easing_outro = rubato.easing.bouncy,
		easing_inter = rubato.easing.quadratic,
		override_dt = false,
	})

	local timed = rubato.timed({
		duration = 0.3,
		intro = 0.1,
		inter = 0.2,
		pos = index,
		easing = rubato.linear,
		override_dt = false,
	})
	--[[local timed = rubato.timed {
		intro = 0.05,
		duration = 0.15,
		rate = 100,
	}]]

	local hover_timed = rubato.timed({
		intro = 0.075,
		duration = 0.2,
	})

	local ti = {}
	for k, v in ipairs(s.tags) do
		ti[v] = k
	end

	local pos, dim

	timed:subscribe(function(_pos)
		pos = _pos
		update_slidey_thing(w, dim, pos)
	end)

	hover_timed:subscribe(function(_pos)
		dim = 1 - 0.15 * _pos
		update_slidey_thing(w, dim, pos)
	end)

	s:connect_signal("tag::history::update", function()
		if ti[s.selected_tag] == w.index then
			return
		end

		timed.target = ti[s.selected_tag]
		index = ti[s.selected_tag]

		hover_timed.target = s.selected_tag.is_being_hovered and 1 or 0
	end)

	function w:hover(value)
		hover_timed.target = value
	end

	return w
end

local above_taglist = { layout = wibox.layout.fixed.horizontal }

--make clickable overlay
--TODO: make slidey thing work with these
function get_taglist(s)
	for _, t in pairs(s.tags) do
		table.insert(
			above_taglist,
			wibox.widget({
				fit = function(_, _, _, height)
					return height
				end,
				buttons = awful.button({}, 1, function()
					t:view_only()
				end),
				widget = wibox.widget.base.make_widget,
			})
		)
	end

	--- Create the slidey thing beforehand as to pass it into the taglist widgets
	local slidey_thing = create_slidey_thing(s)

	local taglist = wibox.widget({
		{
			{
				{
					create_taglist_widgets(s, slidey_thing),
					slidey_thing,
					above_taglist,
					layout = wibox.layout.stack,
				},
				left = dpi(10),
				right = dpi(10),
				layout = wibox.container.margin,
			},
			bg = beautiful.widget_bg,
			shape = function(cr, width, height)
				return gears.shape.rounded_rect(cr, width, height, dpi(3))
			end,
			shape_clip = true,
			layout = wibox.container.background,
		},
		margins = dpi(6),
		layout = wibox.container.margin,
	})

	return taglist
end

return get_taglist
