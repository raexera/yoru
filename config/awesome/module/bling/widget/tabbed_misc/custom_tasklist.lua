local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = require("beautiful.xresources").apply_dpi

local function tabobj_support(self, c, index, clients)
 	-- Self is the background widget in this context
	if not c.bling_tabbed and #c.bling_tabbed.clients > 1 then
		return
	end

	local group = c.bling_tabbed
	
	-- TODO: Allow customization here
	local layout_v = wibox.widget {
		vertical_spacing = dpi(2),
		horizontal_spacing = dpi(2),
		layout = wibox.layout.grid.horizontal,
		forced_num_rows = 2,
		forced_num_cols = 2,
		homogeneous = true
	}

	local wrapper = wibox.widget({
		layout_v,
		id = "click_role",
		widget = wibox.container.margin,
		margins = dpi(5),
	})

	-- To get the ball rolling.
	for idx, c in ipairs(group.clients) do
		if not (c and c.icon) then goto skip end

		-- Add to the last layout
		layout_v:add(wibox.widget {
			{
				widget = awful.widget.clienticon,
				client = c
			},
			widget = wibox.container.constraint,
			width = dpi(24),
			height = dpi(24)
		})
		::skip::
	end
	self.widget = wrapper
end

return tabobj_support
