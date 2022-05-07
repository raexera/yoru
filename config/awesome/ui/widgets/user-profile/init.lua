local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local create_profile = function()
	local profile_imagebox = wibox.widget({
		{
			id = "icon",
			image = beautiful.pfp,
			widget = wibox.widget.imagebox,
			resize = true,
			clip_shape = gears.shape.circle,
		},
		layout = wibox.layout.fixed.horizontal,
	})

	local profile_name = wibox.widget({
		font = beautiful.font_name .. "Bold 16",
		markup = "User",
		align = "left",
		valign = "center",
		widget = wibox.widget.textbox,
	})

	awful.spawn.easy_async_with_shell(
		[[
		sh -c '
		fullname="$(getent passwd `whoami` | cut -d ':' -f 5 | cut -d ',' -f 1 | tr -d "\n")"
		if [ -z "$fullname" ];
		then
			printf "$(whoami)@$(hostname)"
		else
			printf "$fullname"
		fi
		'
		]],
		function(stdout)
			local stdout = stdout:gsub("%\n", "")
			profile_name:set_markup(stdout)
		end
	)

	local user_profile = wibox.widget({
		layout = wibox.layout.fixed.horizontal,
		spacing = dpi(20),
		{
			{
				profile_imagebox,
				border_width = dpi(2),
				border_color = beautiful.central_panel_bg,
				shape = gears.shape.circle,
				widget = wibox.container.background,
			},
			left = dpi(10),
			widget = wibox.container.margin,
		},
		profile_name,
	})

	return user_profile
end

return create_profile
