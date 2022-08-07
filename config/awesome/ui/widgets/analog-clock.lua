local gears = require("gears")
local wibox = require("wibox")
local math = require("math")
local beautiful = require("beautiful")
local cairo = require("lgi").cairo

--- Analog clock
--- ~~~~~~~~~~~~

local function create_minute_pointer(minute)
	local img = cairo.ImageSurface(cairo.Format.ARGB32, 1000, 1000)
	local cr = cairo.Context(img)
	local angle = (minute / 60) * 2 * math.pi
	cr:translate(500, 500)
	cr:rotate(angle)
	cr:translate(-500, -500)
	cr:set_source(gears.color(beautiful.white))
	cr:rectangle(485, 100, 30, 420)
	cr:fill()
	return img
end

local function create_hour_pointer(hour)
	local img = cairo.ImageSurface(cairo.Format.ARGB32, 1000, 1000)
	local cr = cairo.Context(img)
	local angle = ((hour % 12) / 12) * 2 * math.pi
	cr:translate(500, 500)
	cr:rotate(angle)
	cr:translate(-500, -500)
	cr:set_source(gears.color(beautiful.accent))
	cr:rectangle(480, 200, 40, 320)
	cr:fill()
	return img
end

local minute_pointer = create_minute_pointer(37)
local hour_pointer = create_hour_pointer(17)

local minute_pointer_img = wibox.widget.imagebox()
local hour_pointer_img = wibox.widget.imagebox()

local analog_clock = wibox.widget({
	{ -- circle
		wibox.widget.textbox(""),
		shape = function(cr, width, height)
			gears.shape.circle(cr, width, height, height / 2)
		end,
		shape_border_width = 4,
		shape_border_color = beautiful.accent,
		bg = "alpha",
		widget = wibox.container.background,
	},
	minute_pointer_img,
	hour_pointer_img,
	layout = wibox.layout.stack,
})

local minute = 0
local hour = 0

gears.timer({
	timeout = 30,
	call_now = true,
	autostart = true,
	callback = function()
		minute = os.date("%M")
		hour = os.date("%H")
		minute_pointer = create_minute_pointer(minute)
		hour_pointer = create_hour_pointer(hour + (minute / 60))
		minute_pointer_img.image = minute_pointer
		hour_pointer_img.image = hour_pointer
	end,
})

return analog_clock
