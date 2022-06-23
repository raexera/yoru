local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local capi = { client = client, mouse = mouse }

local _client = {}

-- Resize client or factor
local floating_resize_amount = dpi(20)
local tiling_resize_factor = 0.05
function _client.resize_client(c, direction)
	if c and c.floating or awful.layout.get(capi.mouse.screen) == awful.layout.suit.floating then
		if direction == "up" then
			c:relative_move(0, 0, 0, -floating_resize_amount)
		elseif direction == "down" then
			c:relative_move(0, 0, 0, floating_resize_amount)
		elseif direction == "left" then
			c:relative_move(0, 0, -floating_resize_amount, 0)
		elseif direction == "right" then
			c:relative_move(0, 0, floating_resize_amount, 0)
		end
	elseif awful.layout.get(capi.mouse.screen) ~= awful.layout.suit.floating then
		if direction == "up" then
			awful.client.incwfact(-tiling_resize_factor)
		elseif direction == "down" then
			awful.client.incwfact(tiling_resize_factor)
		elseif direction == "left" then
			awful.tag.incmwfact(-tiling_resize_factor)
		elseif direction == "right" then
			awful.tag.incmwfact(tiling_resize_factor)
		end
	end
end

-- Move client to screen edge, respecting the screen workarea
function _client.move_to_edge(c, direction)
	local workarea = awful.screen.focused().workarea
	if direction == "up" then
		c:geometry({ nil, y = workarea.y + beautiful.useless_gap * 2, nil, nil })
	elseif direction == "down" then
		c:geometry({
			nil,
			y = workarea.height
				+ workarea.y
				- c:geometry().height
				- beautiful.useless_gap * 2
				- beautiful.border_width * 2,
			nil,
			nil,
		})
	elseif direction == "left" then
		c:geometry({ x = workarea.x + beautiful.useless_gap * 2, nil, nil, nil })
	elseif direction == "right" then
		c:geometry({
			x = workarea.width
				+ workarea.x
				- c:geometry().width
				- beautiful.useless_gap * 2
				- beautiful.border_width * 2,
			nil,
			nil,
			nil,
		})
	end
end

-- Move client DWIM (Do What I Mean)
-- Move to edge if the client / layout is floating
-- Swap by index if maximized
-- Else swap client by direction
function _client.move_client(c, direction)
	if c.floating or (awful.layout.get(capi.mouse.screen) == awful.layout.suit.floating) then
		_client.move_to_edge(c, direction)
	elseif awful.layout.get(capi.mouse.screen) == awful.layout.suit.max then
		if direction == "up" or direction == "left" then
			awful.client.swap.byidx(-1, c)
		elseif direction == "down" or direction == "right" then
			awful.client.swap.byidx(1, c)
		end
	else
		awful.client.swap.bydirection(direction, c, nil)
	end
end

function _client.centered_client_placement(c)
	return gears.timer.delayed_call(function()
		awful.placement.centered(c, { honor_padding = true, honor_workarea = true })
	end)
end

-- Resize gaps on the fly
_client.resize_gaps = function(amt)
	local t = awful.screen.focused().selected_tag
	t.gap = t.gap + tonumber(amt)
	awful.layout.arrange(awful.screen.focused())
end

-- Resize padding on the fly
_client.resize_padding = function(amt)
	local s = awful.screen.focused()
	local l = s.padding.left
	local r = s.padding.right
	local t = s.padding.top
	local b = s.padding.bottom
	s.padding = {
		left = l + amt,
		right = r + amt,
		top = t + amt,
		bottom = b + amt,
	}
	awful.layout.arrange(awful.screen.focused())
end

return _client
