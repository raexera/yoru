local awful = require("awful")
local watch = awful.widget.watch
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local apps = require("configuration.apps")
local clickable_container = require("ui.widgets.clickable-container")

local return_button = function()
	local widget = wibox.widget({
		{
			id = "icon",
			text = "",
			align = "center",
			valign = "center",
			font = beautiful.icon_font .. "Round 19",
			widget = wibox.widget.textbox,
		},
		layout = wibox.layout.align.horizontal,
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
		awful.spawn(apps.default.network_manager, false)
	end)))

	watch(
		[[sh -c "
		nmcli g | tail -n 1 | awk '{ print $1 }'
		"]],
		5,
		function(_, stdout)
			local net_ssid = stdout
			net_ssid = string.gsub(net_ssid, "^%s*(.-)%s*$", "%1")

			if not net_ssid:match("disconnected") then
				local getstrength = [[
					awk '/^\s*w/ { print  int($3 * 100 / 70) }' /proc/net/wireless
					]]
				awful.spawn.easy_async_with_shell(getstrength, function(stdout)
					if not tonumber(stdout) then
						return
					end
					local strength = tonumber(stdout)
					if strength <= 20 then
						widget.icon:set_text("")
					elseif strength <= 40 then
						widget.icon:set_text("")
					elseif strength <= 60 then
						widget.icon:set_text("")
					elseif strength <= 80 then
						widget.icon:set_text("")
					else
						widget.icon:set_text("")
					end
				end)
			else
				widget.icon:set_text("")
			end
		end
	)

	return widget_button
end

return return_button
