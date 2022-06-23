local awful = require("awful")
local watch = awful.widget.watch
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local wibox = require("wibox")
local helpers = require("helpers")
local icons = require("icons")

--- Stats Widget
--- ~~~~~~~~~~~~

local function create_boxed_widget(widget_to_be_boxed, width, height, bg_color)
	local box_container = wibox.container.background()
	box_container.bg = bg_color
	box_container.forced_height = height
	box_container.forced_width = width
	box_container.shape = helpers.ui.rrect(beautiful.border_radius)

	local boxed_widget = wibox.widget({
		--- Add margins
		{
			--- Add background color
			{
				--- The actual widget goes here
				widget_to_be_boxed,
				top = dpi(9),
				bottom = dpi(9),
				left = dpi(10),
				right = dpi(10),
				widget = wibox.container.margin,
			},
			widget = box_container,
		},
		margins = dpi(10),
		color = "#FF000000",
		widget = wibox.container.margin,
	})

	return boxed_widget
end

local function widget(img)
	local icon = wibox.widget({
		{
			image = img,
			resize = true,
			widget = wibox.widget.imagebox,
		},
		margins = dpi(25),
		widget = wibox.container.margin,
	})

	local widget = wibox.widget({
		widget = wibox.container.arcchart,
		max_value = 100,
		min_value = 0,
		value = 50,
		thickness = dpi(8),
		rounded_edge = true,
		bg = beautiful.grey,
		colors = { beautiful.accent },
		start_angle = math.pi * 3 / 2,
		icon,
	})

	return widget
end

local function cpu()
	local stats = widget(icons.cpu)

	local total_prev = 0
	local idle_prev = 0

	watch(
		[[bash -c "
		cat /proc/stat | grep '^cpu '
		"]],
		10,
		function(_, stdout)
			local user, nice, system, idle, iowait, irq, softirq, steal, guest, guest_nice = stdout:match(
				"(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s"
			)

			local total = user + nice + system + idle + iowait + irq + softirq + steal

			local diff_idle = idle - idle_prev
			local diff_total = total - total_prev
			local diff_usage = (1000 * (diff_total - diff_idle) / diff_total + 5) / 10

			stats:set_value(diff_usage)

			total_prev = total
			idle_prev = idle
			collectgarbage("collect")
		end
	)

	return stats
end

local function temperature()
	local stats = widget(icons.temp)

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
				stats:set_value((temp / 1000) / max_temp * 100)
				collectgarbage("collect")
			end)
		end
	)

	return stats
end

local function ram()
	local stats = widget(icons.ram)

	watch('bash -c "free | grep -z Mem.*Swap.*"', 10, function(_, stdout)
		local total, used, free, shared, buff_cache, available, total_swap, used_swap, free_swap = stdout:match(
			"(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*Swap:%s*(%d+)%s*(%d+)%s*(%d+)"
		)
		stats:set_value(used / total * 100)
		collectgarbage("collect")
	end)

	return stats
end

local function hdd()
	local stats = widget(icons.disk)

	watch([[bash -c "df -h /home|grep '^/' | awk '{print $5}'"]], 10, function(_, stdout)
		local space_consumed = stdout:match("(%d+)")
		stats:set_value(tonumber(space_consumed))
		collectgarbage("collect")
	end)

	return stats
end

local stats = wibox.widget({
	create_boxed_widget(cpu(), dpi(115), dpi(120), beautiful.one_bg3),
	create_boxed_widget(temperature(), dpi(115), dpi(120), beautiful.one_bg3),
	create_boxed_widget(ram(), dpi(115), dpi(120), beautiful.one_bg3),
	create_boxed_widget(hdd(), dpi(115), dpi(120), beautiful.one_bg3),
	forced_num_cols = 2,
	forced_num_rows = 2,
	layout = wibox.layout.grid,
})

return create_boxed_widget(stats, dpi(200), dpi(300), beautiful.widget_bg)
