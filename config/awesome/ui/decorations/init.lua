local awful = require("awful")
local beautiful = require("beautiful")
local helpers = require("helpers")
local gears = require("gears")
local wibox = require("wibox")

--- Disable popup tooltip on titlebar button hover
awful.titlebar.enable_tooltip = false

local decorations = {}

function decorations.hide(c)
	if not c.custom_decoration or not (c.custom_decoration["top"] and c.custom_decoration["bottom"]) then
		awful.titlebar.hide(c, "top")
		awful.titlebar.hide(c, "bottom")
	end
end

function decorations.show(c)
	if not c.custom_decoration or not (c.custom_decoration["top"] and c.custom_decoration["bottom"]) then
		awful.titlebar.show(c, "top")
		awful.titlebar.show(c, "bottom")
	end
end

function decorations.cycle(c)
	if not c.custom_decoration or not (c.custom_decoration["top"] and c.custom_decoration["bottom"]) then
		awful.titlebar.toggle(c, "top")
		awful.titlebar.toggle(c, "bottom")
	end
end

--- Helper function to be used by decoration themes to enable client rounding
function decorations.enable_rounding()
	--- Apply rounded corners to clients if needed
	if beautiful.border_radius and beautiful.border_radius > 0 then
		client.connect_signal("manage", function(c, startup)
			if not c.fullscreen and not c.maximized then
				c.shape = helpers.ui.rrect(beautiful.border_radius)
			end
		end)

		--- Fullscreen and maximized clients should not have rounded corners
		local function no_round_corners(c)
			if c.fullscreen or c.maximized then
				c.shape = gears.shape.rectangle
			else
				c.shape = helpers.ui.rrect(beautiful.border_radius)
			end
		end

		client.connect_signal("property::fullscreen", no_round_corners)
		client.connect_signal("property::maximized", no_round_corners)

		beautiful.snap_shape = helpers.ui.rrect(beautiful.border_radius * 2)
	else
		beautiful.snap_shape = gears.shape.rectangle
	end
end

local button_commands = {
	["close"] = {
		fun = function(c)
			c:kill()
		end,
		track_property = nil,
	},
	["maximize"] = {
		fun = function(c)
			c.maximized = not c.maximized
			c:raise()
		end,
		track_property = "maximized",
	},
	["minimize"] = {
		fun = function(c)
			c.minimized = true
		end,
	},
	["sticky"] = {
		fun = function(c)
			c.sticky = not c.sticky
			c:raise()
		end,
		track_property = "sticky",
	},
	["ontop"] = {
		fun = function(c)
			c.ontop = not c.ontop
			c:raise()
		end,
		track_property = "ontop",
	},
	["floating"] = {
		fun = function(c)
			c.floating = not c.floating
			c:raise()
		end,
		track_property = "floating",
	},
}

decorations.button = function(c, shape, color, unfocused_color, hover_color, size, margin, cmd)
	local button = wibox.widget({
		bg = (client.focus and c == client.focus) and color or unfocused_color,
		shape = shape,
		widget = wibox.container.background(),
	})

	--- Instead of adding spacing between the buttons, we add margins
	--- around them. That way it is more forgiving to click them
	--- (especially if they are very small)
	local button_widget = wibox.widget({
		widget = wibox.container.place,
		{
			widget = wibox.container.margin,
			margins = margin,
			{
				button,
				widget = wibox.container.constraint,
				height = size,
				width = size,
				strategy = "exact",
			},
		},
	})

	button_widget:buttons(gears.table.join(awful.button({}, 1, function()
		button_commands[cmd].fun(c)
	end)))

	local p = button_commands[cmd].track_property
	--- Track client property if needed
	if p then
		c:connect_signal("property::" .. p, function()
			button.bg = c[p] and color .. "40" or color
		end)
		c:connect_signal("focus", function()
			button.bg = c[p] and color .. "40" or color
		end)
		button_widget:connect_signal("mouse::leave", function()
			if c == client.focus then
				button.bg = c[p] and color .. "40" or color
			else
				button.bg = unfocused_color
			end
		end)
	else
		button_widget:connect_signal("mouse::leave", function()
			if c == client.focus then
				button.bg = color
			else
				button.bg = unfocused_color
			end
		end)
		c:connect_signal("focus", function()
			button.bg = color
		end)
	end
	button_widget:connect_signal("mouse::enter", function()
		button.bg = hover_color
	end)
	c:connect_signal("unfocus", function()
		button.bg = unfocused_color
	end)

	return button_widget
end

function decorations.init()
	require("ui.decorations.titlebar")
	require("ui.decorations.music")
end

return decorations
