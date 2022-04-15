local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local helpers = require("helpers")

-- Taglist
-------------

local get_taglist = function(s)
	-- Taglist buttons
	local taglist_buttons = gears.table.join(
		awful.button({}, 1, function(t)
			t:view_only()
		end),
		awful.button({ modkey }, 1, function(t)
			if client.focus then
				client.focus:move_to_tag(t)
			end
		end),
		awful.button({}, 3, awful.tag.viewtoggle),
		awful.button({ modkey }, 3, function(t)
			if client.focus then
				client.focus:toggle_tag(t)
			end
		end),
		awful.button({}, 4, function(t)
			awful.tag.viewnext(t.screen)
		end),
		awful.button({}, 5, function(t)
			awful.tag.viewprev(t.screen)
		end)
	)

	-- Function to update the tags
	local update_tags = function(self, tag)
		local textbox = self:get_children_by_id("index_role")[1]
		if tag.selected then
			textbox.markup = helpers.colorize_text("󰮯", beautiful.taglist_icon_focused)
		elseif #tag:clients() == 0 then
			textbox.markup = helpers.colorize_text("󰽢", beautiful.taglist_icon_empty)
		else
			textbox.markup = helpers.colorize_text("󰊠", beautiful.taglist_icon_occupied)
		end
	end

	local taglist = awful.widget.taglist({
		screen = s,
		filter = awful.widget.taglist.filter.all,
		style = {
			shape = helpers.rrect(beautiful.border_radius),
		},
		layout = { spacing = 0, layout = wibox.layout.fixed.vertical },
		widget_template = {
			{
				{
					id = "index_role",
					align = "center",
					font = beautiful.font_taglist,
					widget = wibox.widget.textbox,
				},
				id = "margin_role",
				margins = {
					top = dpi(8),
					bottom = dpi(8),
					left = dpi(6),
					right = dpi(6),
				},
				widget = wibox.container.margin,
			},
			id = "background_role",
			widget = wibox.container.background,
			create_callback = function(self, c3, index, objects)
				update_tags(self, c3)
				self:connect_signal("mouse::enter", function()
					if #c3:clients() > 0 then
						awesome.emit_signal("bling::tag_preview::update", c3)
						awesome.emit_signal("bling::tag_preview::visibility", s, true)
					end
				end)
				self:connect_signal("mouse::leave", function()
					awesome.emit_signal("bling::tag_preview::visibility", s, false)
				end)
			end,
			update_callback = function(self, c3, index, objects)
				update_tags(self, c3)
			end,
		},
		buttons = taglist_buttons,
	})

	return taglist
end

return get_taglist
