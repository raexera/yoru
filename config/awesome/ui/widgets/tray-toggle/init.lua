local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local clickable_container = require("ui.widgets.clickable-container")

local widget = wibox.widget({
	text = "",
	align = "center",
	valign = "center",
	font = beautiful.icon_font .. "Round 16",
	widget = wibox.widget.textbox,
})

local widget_button = wibox.widget({
	{
		widget,
		margins = dpi(8),
		widget = wibox.container.margin,
	},
	widget = clickable_container,
})

widget_button:buttons(gears.table.join(awful.button({}, 1, nil, function()
	awesome.emit_signal("widget::systray:toggle")
end)))

-- Listen to signal
awesome.connect_signal("widget::systray:toggle", function()
	if screen.primary.systray then
		if not screen.primary.systray.visible then
			widget:set_text("")
		else
			widget:set_text("")
		end

		screen.primary.systray.visible = not screen.primary.systray.visible
	end
end)

-- Update icon on start-up
if screen.primary.systray then
	if screen.primary.systray.visible then
		widget:set_text("")
	end
end

-- Show only the tray button in the primary screen
return awful.widget.only_on_screen(widget_button, "primary")
