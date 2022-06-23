-------------------------------------------
-- @author https://github.com/Kasper24
-- @copyright 2021-2022 Kasper24
-------------------------------------------

local gtable = require("gears.table")
local twidget = require("ui.widgets.text")
local ewidget = require("ui.widgets.button.elevated")
local beautiful = require("beautiful")
local animation = require("modules.animation")
local helpers = require("helpers")
local setmetatable = setmetatable
local math = math

local text_button = { mt = {} }

function text_button:set_font(font)
	self._private.text:set_font(font)
end

function text_button:set_bold(bold)
	self._private.text:set_bold(bold)
end

function text_button:set_size(font, size)
	self._private.text:set_size(font, size)
end

function text_button:set_color(color)
	self._private.text:set_color(color)
end

function text_button:set_text(text)
	self._private.text:set_text(text)
end

local function effect(widget, text_bg)
	if text_bg ~= nil then
		widget.text_animation:set(helpers.color.hex_to_rgb(text_bg))
	end
end

local function button(args, type)
	args = args or {}

	args.color = args.text_normal_bg
	local text_widget = twidget(args)

	args.child = text_widget
	local widget = type == "normal" and ewidget.normal(args) or ewidget.state(args)

	gtable.crush(widget, text_button, true)
	widget._private.text = text_widget

	widget.text_animation = animation:new({
		pos = helpers.color.hex_to_rgb(args.text_normal_bg),
		easing = animation.easing.linear,
		duration = 0.2,
		update = function(self, pos)
			text_widget:set_color(helpers.color.rgb_to_hex(pos))
		end,
	})

	widget.size_animation = animation:new({
		pos = args.size,
		easing = animation.easing.linear,
		duration = 0.2,
		update = function(self, pos)
			text_widget:set_size(pos)
		end,
	})

	return widget, text_widget
end

function text_button.state(args)
	args = args or {}

	args.text_normal_bg = args.text_normal_bg or beautiful.random_accent_color()
	args.text_hover_bg = args.text_hover_bg or helpers.color.button_color(args.text_normal_bg, 0.1)
	args.text_press_bg = args.text_press_bg or helpers.color.button_color(args.text_normal_bg, 0.2)

	args.text_on_normal_bg = args.text_on_normal_bg or args.text_normal_bg
	args.text_on_hover_bg = args.text_on_hover_bg or helpers.color.button_color(args.text_on_normal_bg, 0.1)
	args.text_on_press_bg = args.text_on_press_bg or helpers.color.button_color(args.text_on_normal_bg, 0.2)

	args.animate_size = args.animate_size == nil and true or args.animate_size

	local widget, text_widget = button(args, "state")

	function text_widget:on_hover(widget, state)
		if state == true then
			effect(widget, args.text_on_hover_bg)
		else
			effect(widget, args.text_hover_bg)
		end
	end

	function text_widget:on_leave(widget, state)
		if state == true then
			effect(widget, args.text_on_normal_bg)
		else
			effect(widget, args.text_normal_bg)
		end
	end

	function text_widget:on_turn_on()
		effect(widget, args.text_on_normal_bg)
	end

	if args.on_by_default == true then
		text_widget:on_turn_on()
	end

	function text_widget:on_turn_off()
		effect(widget, args.text_normal_bg)
	end

	function text_widget:on_press()
		if args.animate_size == true then
			widget.size_animation:set(math.max(12, args.size - 20))
		end
	end

	function text_widget:on_release()
		if args.animate_size == true then
			if widget.size_animation.state == true then
				widget.size_animation.ended:subscribe(function()
					widget.size_animation:set(args.size)
					widget.size_animation.ended:unsubscribe()
				end)
			else
				widget.size_animation:set(args.size)
			end
		end
	end

	return widget
end

function text_button.normal(args)
	args = args or {}

	args.text_normal_bg = args.text_normal_bg or beautiful.random_accent_color()
	args.text_hover_bg = args.text_hover_bg or helpers.color.button_color(args.text_normal_bg, 0.1)
	args.text_press_bg = args.text_press_bg or helpers.color.button_color(args.text_normal_bg, 0.2)

	args.animate_size = args.animate_size == nil and true or args.animate_size

	local widget, text_widget = button(args, "normal")

	function text_widget:on_hover()
		effect(widget, args.text_hover_bg)
	end

	function text_widget:on_leave()
		effect(widget, args.text_normal_bg)
	end

	function text_widget:on_press()
		effect(widget, args.text_press_bg)
		if args.animate_size == true then
			widget.size_animation:set(math.max(12, args.size - 20))
		end
	end

	function text_widget:on_release()
		effect(widget, args.text_normal_bg)
		if args.animate_size == true then
			if widget.size_animation.state == true then
				widget.size_animation.ended:subscribe(function()
					widget.size_animation:set(args.size)
					widget.size_animation.ended:unsubscribe()
				end)
			else
				widget.size_animation:set(args.size)
			end
		end
	end

	return widget
end

return setmetatable(text_button, text_button.mt)
