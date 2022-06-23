-------------------------------------------
-- @author https://github.com/Kasper24
-- @copyright 2021-2022 Kasper24
-------------------------------------------

local gtable = require("gears.table")
local wibox = require("wibox")
local ewidget = require("ui.widgets.button.elevated")
local animation = require("modules.animation")
local setmetatable = setmetatable

local image_button = { mt = {} }

function image_button:set_image(image)
	self._private.image:set_image(image)
end

local function button(args, type)
	args = args or {}

	args.image_width = args.image_width or nil
	args.image_height = args.image_height or nil
	args.image_halign = args.image_halign or "center"
	args.image_valign = args.image_valign or "center"
	args.horizontal_fit_policy = args.horizontal_fit_policy or "auto"
	args.vertical_fit_policy = args.vertical_fit_policy or "auto"
	args.image = args.image or nil

	local image_widget = wibox.widget({
		widget = wibox.widget.imagebox,
		forced_width = args.image_width,
		forced_height = args.image_height,
		halign = args.image_halign,
		valign = args.image_valign,
		horizontal_fit_policy = args.horizontal_fit_policy,
		vertical_fit_policy = args.vertical_fit_policy,
		resize = true,
		image = args.image,
	})

	args.child = image_widget
	local widget = type == "normal" and ewidget.normal(args) or ewidget.state(args)

	gtable.crush(widget, image_button, true)
	widget._private.image = image_widget

	widget.size_animation = animation:new({
		pos = 50,
		easing = animation.easing.linear,
		duration = 0.2,
		update = function(self, pos)
			image_widget.forced_width = pos
			image_widget.forced_height = pos
		end,
	})

	return widget, image_widget
end

function image_button.state(args)
	args = args or {}

	local widget, image_widget = button(args, "state")

	function image_widget:on_press()
		widget.size_animation:set(20)
	end

	function image_widget:on_release()
		if widget.size_animation.state == true then
			widget.size_animation.ended:subscribe(function()
				widget.size_animation:set(50)
				widget.size_animation.ended:unsubscribe()
			end)
		else
			widget.size_animation:set(50)
		end
	end

	return widget
end

function image_button.normal(args)
	args = args or {}

	local widget, text_widget = button(args, "normal")

	function text_widget:on_press()
		widget.size_animation:set(20)
	end

	function text_widget:on_release()
		if widget.size_animation.state == true then
			widget.size_animation.ended:subscribe(function()
				widget.size_animation:set(50)
				widget.size_animation.ended:unsubscribe()
			end)
		else
			widget.size_animation:set(50)
		end
	end

	return widget
end

return setmetatable(image_button, image_button.mt)
