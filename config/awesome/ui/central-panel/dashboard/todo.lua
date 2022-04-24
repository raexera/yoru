-- Standard awesome library
local awful = require("awful")

-- Theme handling library
local beautiful = require("beautiful")

-- Widget library
local wibox = require("wibox")

-- Helpers
local helpers = require("helpers")

-- Todo
---------

local todo_text = wibox.widget({
	font = beautiful.font_name .. "medium 8",
	markup = helpers.colorize_text("Todo", beautiful.dashboard_box_fg),
	valign = "center",
	widget = wibox.widget.textbox,
})

local todo_badge = wibox.widget({
	font = beautiful.font_name .. "medium 8",
	markup = helpers.colorize_text("0", beautiful.xcolor1),
	valign = "center",
	widget = wibox.widget.textbox,
})

local todo_stat_color = beautiful.xcolor8
local todo_stat = wibox.widget({
	colors = { todo_stat_color },
	bg = todo_stat_color .. "44",
	value = 5,
	min_value = 0,
	max_value = 8,
	thickness = dpi(8),
	rounded_edge = true,
	start_angle = math.pi * 3 / 2,
	widget = wibox.container.arcchart,
})

local todo_done = wibox.widget({
	font = beautiful.font_name .. "bold 14",
	markup = "0",
	valign = "bottom",
	widget = wibox.widget.textbox,
})

local todo_total = wibox.widget({
	font = beautiful.font_name .. "bold 8",
	markup = helpers.colorize_text("/0", beautiful.xcolor8),
	valign = "bottom",
	widget = wibox.widget.textbox,
})

local todo = wibox.widget({
	{
		todo_text,
		nil,
		todo_badge,
		expand = "none",
		layout = wibox.layout.align.horizontal,
	},
	{
		{
			{
				todo_stat,
				reflection = { horizontal = true },
				widget = wibox.container.mirror,
			},
			{
				nil,
				{
					nil,
					{
						todo_done,
						todo_total,
						spacing = dpi(1),
						layout = wibox.layout.fixed.horizontal,
					},
					expand = "none",
					layout = wibox.layout.align.vertical,
				},
				expand = "none",
				layout = wibox.layout.align.horizontal,
			},
			layout = wibox.layout.stack,
		},
		margins = dpi(10),
		widget = wibox.container.margin,
	},
	layout = wibox.layout.fixed.vertical,
})

awesome.connect_signal("signal::todo", function(total, done, undone)
	todo_badge.markup = helpers.colorize_text("-" .. undone, beautiful.xcolor1)

	todo_total.markup = helpers.colorize_text("/" .. total, beautiful.xcolor8)

	if total == 0 then
		todo_badge.visible = false
		total = 1
	else
		todo_badge.visible = true
	end

	todo_done.markup = done
	todo_stat.max_value = total
	todo_stat.value = done
end)

return todo
