local gears = require("gears")
local beautiful = require("beautiful")
local naughty = require("naughty")
local icons = require("icons")

local display_high = true
local display_low = true
local display_charge = true

awesome.connect_signal("signal::battery", function(percentage, state)
	local value = percentage

	--- only display message if its not charging and low
	if value <= 15 and display_low and state == 2 then
		naughty.notification({
			title = "Battery Status",
			text = "Running low at " .. math.floor(value) .. "%",
			app_name = "AwesomeWM",
			image = gears.color.recolor_image(icons.battery_low, beautiful.color1),
		})
		display_low = false
	end

	--- only display message once if its fully charged and high
	if display_high and state == 4 and value > 90 then
		naughty.notification({
			title = "Battery Status",
			text = "Fully charged!",
			app_name = "AwesomeWM",
			image = gears.color.recolor_image(icons.battery, beautiful.color2),
		})
		display_high = false
	end

	--- only display once if charging
	if display_charge and state == 1 then
		naughty.notification({
			title = "Battery Status",
			text = "Charging",
			app_name = "AwesomeWM",
			image = gears.color.recolor_image(icons.charging, beautiful.color6),
		})
		display_charge = false
	end

	if value < 88 and value > 18 then
		display_low = true
		display_high = true
	end

	if state == 2 then
		display_charge = true
	end
end)
