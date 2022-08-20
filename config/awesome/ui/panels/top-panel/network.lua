local awful = require("awful")
local watch = awful.widget.watch
local wibox = require("wibox")
local beautiful = require("beautiful")
local apps = require("configuration.apps")
local wbutton = require("ui.widgets.button")

--- Network Widget
--- ~~~~~~~~~~~~~~

return function()
	local network = wibox.widget({
		{
			id = "icon",
			text = "",
			align = "center",
			valign = "center",
			font = beautiful.icon_font .. "Round 18",
			widget = wibox.widget.textbox,
		},
		layout = wibox.layout.align.horizontal,
	})

	local widget = wbutton.elevated.state({
		child = network,
		normal_bg = beautiful.wibar_bg,
		on_release = function()
			awful.spawn(apps.default.network_manager, false)
		end,
	})

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
						network.icon:set_text("")
					elseif strength <= 40 then
						network.icon:set_text("")
					elseif strength <= 60 then
						network.icon:set_text("")
					elseif strength <= 80 then
						network.icon:set_text("")
					else
						network.icon:set_text("")
					end
				end)
			else
				network.icon:set_text("")
			end
		end
	)

	return widget
end
