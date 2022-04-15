-- Standard awesome library
local gears = require("gears")
local awful = require("awful")

-- Theme handling library
local beautiful = require("beautiful")

-- Widget library
local wibox = require("wibox")

-- Helpers
local helpers = require("helpers")

-- Media Keys
---------------

--playerctl
local playerctl = require("module.bling").signal.playerctl.lib()

-- Helpers
local create_media_button = function(symbol, color, command, playpause)
	local icon = wibox.widget({
		markup = helpers.colorize_text(symbol, color),
		font = beautiful.icon_font_name .. "16",
		align = "center",
		valign = "center",
		widget = wibox.widget.textbox(),
	})

	playerctl:connect_signal("playback_status", function(_, playing, __)
		if playpause then
			if playing then
				icon:set_markup_silently(helpers.colorize_text("󰏦", color))
			else
				icon:set_markup_silently(helpers.colorize_text("󰐍", color))
			end
		end
	end)

	icon:buttons(gears.table.join(awful.button({}, 1, function()
		command()
	end)))

	icon:connect_signal("mouse::enter", function()
		icon.markup = helpers.colorize_text(icon.text, beautiful.xcolor15)
	end)

	icon:connect_signal("mouse::leave", function()
		icon.markup = helpers.colorize_text(icon.text, color)
	end)

	return icon
end

-- Widget
local media_play_command = function()
	playerctl:play_pause()
end
local media_prev_command = function()
	playerctl:previous()
end
local media_next_command = function()
	playerctl:next()
end

local media_play = create_media_button("󰐍", beautiful.xforeground, media_play_command, true)
local media_prev = create_media_button("󰒮", beautiful.xforeground, media_prev_command, false)
local media_next = create_media_button("󰒭", beautiful.xforeground, media_next_command, false)

local media = wibox.widget({
	{
		{
			{
				media_prev,
				media_play,
				media_next,
				expand = "none",
				layout = wibox.layout.align.vertical,
			},
			margins = dpi(9),
			widget = wibox.container.margin,
		},
		bg = beautiful.dashboard_box_bg,
		shape = helpers.rrect(5),
		forced_width = dpi(40),
		forced_height = dpi(120),
		widget = wibox.container.background,
	},
	margins = dpi(10),
	widget = wibox.container.margin,
})

return media
