local gears = require("gears")
local awful = require("awful")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local wibox = require("wibox")
local helpers = require("helpers")

--- Layout list
--- ~~~~~~~~~~~

screen.connect_signal("request::desktop_decoration", function(s)
	local layout_list = awful.widget.layoutlist({
		source = awful.widget.layoutlist.source.default_layouts, --- DOC_HIDE
		spacing = dpi(24),
		base_layout = wibox.widget({
			spacing = dpi(24),
			forced_num_cols = 4,
			layout = wibox.layout.grid.vertical,
		}),
		widget_template = {
			{
				{
					id = "icon_role",
					forced_height = dpi(68),
					forced_width = dpi(68),
					widget = wibox.widget.imagebox,
				},
				margins = dpi(24),
				widget = wibox.container.margin,
			},
			id = "background_role",
			forced_width = dpi(68),
			forced_height = dpi(68),
			widget = wibox.container.background,
		},
	})

	local layout_popup = awful.popup({
		widget = wibox.widget({
			{ layout_list, margins = dpi(24), widget = wibox.container.margin },
			bg = beautiful.black,
			shape = helpers.ui.rrect(beautiful.border_radius),
			widget = wibox.container.background,
		}),
		placement = awful.placement.centered,
		ontop = true,
		visible = false,
		bg = beautiful.black .. "00",
	})

	function gears.table.iterate_value(t, value, step_size, filter, start_at)
		local k = gears.table.hasitem(t, value, true, start_at)
		if not k then
			return
		end

		step_size = step_size or 1
		local new_key = gears.math.cycle(#t, k + step_size)

		if filter and not filter(t[new_key]) then
			for i = 1, #t do
				local k2 = gears.math.cycle(#t, new_key + i)
				if filter(t[k2]) then
					return t[k2], k2
				end
			end
			return
		end

		return t[new_key], new_key
	end

	awful.keygrabber({
		start_callback = function()
			layout_popup.visible = true
		end,
		stop_callback = function()
			layout_popup.visible = false
		end,
		export_keybindings = true,
		stop_event = "release",
		stop_key = { "Escape", "Super_L", "Super_R", "Mod4" },
		keybindings = {
			{
				{ mod, "Shift" },
				" ",
				function()
					awful.layout.set(
						gears.table.iterate_value(layout_list.layouts, layout_list.current_layout, -1),
						nil
					)
				end,
			},
			{
				{ mod },
				" ",
				function()
					awful.layout.set(gears.table.iterate_value(layout_list.layouts, layout_list.current_layout, 1), nil)
				end,
			},
		},
	})
end)
