-------------------------------------------
-- @author https://github.com/Kasper24
-- @copyright 2021-2022 Kasper24
-------------------------------------------

local wibox = require("wibox")
local beautiful = require("beautiful")
local helpers = require("helpers")
local dpi = beautiful.xresources.apply_dpi
local setmetatable = setmetatable

local container = { mt = {} }

local function new(args)
	args = args or {}

	args.direction = args.direction or nil
	args.forced_width = args.forced_width or nil
	args.forced_height = args.forced_height or nil
	args.constraint_strategy = args.constraint_strategy or nil
	args.constraint_width = args.constraint_width or nil
	args.constraint_height = args.constraint_height or nil
	args.margins = args.margins or dpi(0)
	args.paddings = args.paddings or dpi(0)
	args.halign = args.halign or nil
	args.valign = args.valign or nil
	args.child = args.child or nil

	args.bg = args.bg or beautiful.black
	args.shape = args.shape or helpers.ui.rrect(beautiful.border_radius)
	args.border_width = args.border_width or dpi(0)
	args.border_color = args.border_color or beautiful.transparent

	local widget = wibox.widget({
		widget = wibox.container.rotate,
		direction = args.direction,
		{
			widget = wibox.container.constraint,
			id = "constraint_role",
			strategy = args.constraint_strategy,
			width = args.constraint_width,
			height = args.constraint_height,
			{
				widget = wibox.container.margin,
				id = "margin_role",
				margins = args.margins,
				{
					widget = wibox.container.background,
					id = "background_role",
					forced_width = args.forced_width,
					forced_height = args.forced_height,
					shape = args.shape,
					bg = args.bg,
					border_width = args.border_width,
					border_color = args.border_color,
					{
						widget = wibox.container.place,
						id = "place_role",
						halign = args.halign,
						valign = args.valign,
						{
							widget = wibox.container.margin,
							id = "padding_role",
							margins = args.paddings,
							args.child,
						},
					},
				},
			},
		},
	})

	return widget
end

function container.mt:__call(...)
	return new(...)
end

return setmetatable(container, container.mt)
