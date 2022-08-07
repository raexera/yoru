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
local stats_text = wibox.widget({
	font = beautiful.font_name .. "Medium 10",
	markup = helpers.ui.colorize_text("Stats", "#666c79"),
	valign = "center",
	widget = wibox.widget.textbox,
})

local stats_tooltip = wibox.widget({
	visible = false,
	top_only = true,
	layout = wibox.layout.stack,
})

local tooltip_counter = 0
local function create_tooltip(w)
	local tooltip = wibox.widget({
		font = beautiful.font_name .. "Medium 10",
		align = "right",
		valign = "center",
		widget = wibox.widget.textbox,
	})

	tooltip_counter = tooltip_counter + 1
	local index = tooltip_counter

	stats_tooltip:insert(index, tooltip)

	w:connect_signal("mouse::enter", function()
		-- Raise tooltip to the top of the stack
		stats_tooltip:set(1, tooltip)
		stats_tooltip.visible = true
	end)
	w:connect_signal("mouse::leave", function()
		stats_tooltip.visible = false
	end)

	return tooltip
end

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

local function cpu()
	local stats = wibox.widget({
		widget = wibox.container.arcchart,
		max_value = 100,
		min_value = 0,
		value = 50,
		thickness = dpi(20),
		rounded_edge = true,
		bg = "#85afc3",
		colors = { "#c1ebff" },
		start_angle = math.pi + math.pi / 2,
	})

	local tooltip = create_tooltip(stats)

	watch(
		[[sh -c "
		vmstat 1 2 | tail -1 | awk '{printf \"%d\", $15}'
		"]],
		5,
		function(_, stdout)
			local cpu_idle = stdout
			cpu_idle = string.gsub(cpu_idle, "^%s*(.-)%s*$", "%1")

			local cpu_value = 100 - tonumber(cpu_idle)

			stats:set_value(cpu_value)
			tooltip:set_markup_silently(helpers.ui.colorize_text(cpu_value .. "%", "#c1ebff"))

			collectgarbage("collect")
		end
	)

	return stats
end

local function temperature()
	local stats = wibox.widget({
		widget = wibox.container.arcchart,
		max_value = 100,
		min_value = 0,
		value = 50,
		thickness = dpi(20),
		rounded_edge = true,
		bg = "#6791c3",
		colors = { "#a3cdff" },
		start_angle = math.pi + math.pi / 2,
		cpu(),
	})

	local tooltip = create_tooltip(stats)

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
			]], 15, function(_, stdout)
				local temp = stdout:match("(%d+)")
				local temp_value = (temp / 1000) / max_temp * 100

				stats:set_value(temp_value)
				tooltip:set_markup_silently(helpers.ui.colorize_text(temp_value .. "°C", "#a3cdff"))
				collectgarbage("collect")
			end)
		end
	)

	return stats
end

local function ram()
	local stats = wibox.widget({
		widget = wibox.container.arcchart,
		max_value = 100,
		min_value = 0,
		value = 50,
		thickness = dpi(20),
		rounded_edge = true,
		bg = "#4973ab",
		colors = { "#85afe7" },
		start_angle = math.pi + math.pi / 2,
		temperature(),
	})

	local tooltip = create_tooltip(stats)

	watch(
		[[sh -c "
		free -m | grep 'Mem:' | awk '{printf \"%d@@%d@\", $7, $2}'
		"]],
		20,
		function(_, stdout)
			local available = stdout:match("(.*)@@")
			local total = stdout:match("@@(.*)@")
			local used = tonumber(total) - tonumber(available)

			local used_ram_percentage = (used / total) * 100

			stats:set_value(used_ram_percentage)
			tooltip:set_markup_silently(helpers.ui.colorize_text(string.format("%.1f", used / 1000) .. "G", "#85afe7"))
			collectgarbage("collect")
		end
	)

	return stats
end

local function hdd()
	local stats = wibox.widget({
		widget = wibox.container.arcchart,
		max_value = 100,
		min_value = 0,
		value = 50,
		thickness = dpi(20),
		rounded_edge = true,
		bg = "#2b558d",
		colors = { "#6791c9" },
		start_angle = math.pi + math.pi / 2,
		ram(),
	})

	local tooltip = create_tooltip(stats)

	watch([[bash -c "df -h /home|grep '^/' | awk '{print $5}'"]], 180, function(_, stdout)
		local space_consumed = stdout:match("(%d+)")

		stats:set_value(tonumber(space_consumed))
		tooltip:set_markup_silently(helpers.ui.colorize_text(space_consumed .. "%", "#6791c9"))
		collectgarbage("collect")
	end)

	return stats
end

local stats = wibox.widget({
	{
		stats_text,
		nil,
		stats_tooltip,
		expand = "none",
		layout = wibox.layout.align.horizontal,
	},
	{
		nil,
		{
			nil,
			{
				{
					hdd(),
					reflection = { horizontal = true, vertical = false },
					widget = wibox.container.mirror,
				},
				margins = dpi(10),
				widget = wibox.container.margin,
			},
			layout = wibox.layout.fixed.vertical,
		},
		expand = "none",
		layout = wibox.layout.align.horizontal,
	},
	spacing = dpi(10),
	layout = wibox.layout.fixed.vertical,
})

return create_boxed_widget(stats, dpi(200), dpi(300), beautiful.widget_bg)
