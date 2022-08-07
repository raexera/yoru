-------------------------------------------
-- @author https://github.com/Kasper24
-- @copyright 2021-2022 Kasper24
-------------------------------------------

local gtable = require("gears.table")
local gstring = require("gears.string")
local wibox = require("wibox")
local beautiful = require("beautiful")
local helpers = require("helpers")
local setmetatable = setmetatable
local tostring = tostring
local string = string

local text = { mt = {} }

local function generate_markup(self)
	local bold_start = ""
	local bold_end = ""
	local italic_start = ""
	local italic_end = ""

	if self._private.bold == true then
		bold_start = "<b>"
		bold_end = "</b>"
	end
	if self._private.italic == true then
		italic_start = "<i>"
		italic_end = "</i>"
	end

	-- Need to unescape in a case the text was escaped by other code before
	self._private.text = gstring.xml_unescape(tostring(self._private.text))
	self._private.text = gstring.xml_escape(tostring(self._private.text))

	self.markup = bold_start
		.. italic_start
		.. helpers.ui.colorize_text(self._private.text, self._private.color)
		.. italic_end
		.. bold_end
end

function text:set_width(width)
	self.forced_width = width
end

function text:set_height(height)
	self.forced_height = height
end

function text:set_halign(halign)
	self.align = halign
end

function text:set_font(font)
	self._private.font = font
	self._private.layout:set_font_description(beautiful.get_font(font))
	self:emit_signal("widget::redraw_needed")
	self:emit_signal("widget::layout_changed")
	self:emit_signal("property::font", font)
end

function text:set_bold(bold)
	self._private.bold = bold
	generate_markup(self)
end

function text:set_italic(italic)
	self._private.italic = italic
	generate_markup(self)
end

function text:set_size(size)
	-- Remove the previous size from the font field
	local font = string.gsub(self._private.font, self._private.size, "")
	self._private.size = size
	self:set_font(font .. size)
end

function text:set_color(color)
	self._private.color = color
	generate_markup(self)
end

function text:set_text(text)
	self._private.text = text
	generate_markup(self)
end

local function new(args)
	args = args or {}

	args.width = args.width or nil
	args.height = args.height or nil
	args.halign = args.halign or nil
	args.valign = args.valign or nil
	args.font = args.font or beautiful.font_name or nil
	args.bold = args.bold ~= nil and args.bold or false
	args.italic = args.italic ~= nil and args.italic or false
	args.size = args.size or 20
	args.color = args.color or beautiful.white
	args.text = args.text ~= nil and args.text or ""

	local widget = wibox.widget({
		widget = wibox.widget.textbox,
		forced_width = args.width,
		forced_height = args.height,
		align = args.halign,
		valign = args.valign,
		font = args.font .. args.size,
	})

	gtable.crush(widget, text, true)

	widget._private.font = args.font
	widget._private.bold = args.bold
	widget._private.italic = args.italic
	widget._private.size = args.size
	widget._private.color = args.color
	widget._private.text = args.text

	generate_markup(widget)

	return widget
end

function text.mt:__call(...)
	return new(...)
end

return setmetatable(text, text.mt)
