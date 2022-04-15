local awful = require("awful")
local watch = awful.widget.watch
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local active_color = beautiful.accent

local temp_arc = wibox.widget({
	max_value = 100,
	value = 20,
	thickness = dpi(8),
	start_angle = 4.3,
	rounded_edge = true,
	bg = active_color .. "44",
	paddings = dpi(10),
	colors = { active_color },
	widget = wibox.container.arcchart,
})

local max_temp = 80

awful.spawn.easy_async_with_shell(
	[[
	temp_path=null
	for i in /sys/class/hwmon/hwmon*/temp*_input;
	do
		temp_path="$(echo "$(<$(dirname $i)/name): $(cat ${i%_*}_label 2>/dev/null ||
			echo $(basename ${i%_*})) $(readlink -f $i)");"

		label="$(echo $temp_path | awk '{print $2}')"

		if [ "$label" = "Package" ];
		then
			echo ${temp_path} | awk '{print $5}' | tr -d ';\n'
			exit;
		fi
	done
	]],
	function(stdout)
		local temp_path = stdout:gsub("%\n", "")
		if temp_path == "" or not temp_path then
			temp_path = "/sys/class/thermal/thermal_zone0/temp"
		end

		watch([[
			sh -c "cat ]] .. temp_path .. [["
			]], 10, function(_, stdout)
			local temp = stdout:match("(%d+)")
			temp_arc:set_value((temp / 1000) / max_temp * 100)
			collectgarbage("collect")
		end)
	end
)

return temp_arc
