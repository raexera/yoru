local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local profile_imagebox = wibox.widget({
	{
		id = "icon",
		image = beautiful.pfp,
		widget = wibox.widget.imagebox,
		resize = true,
		clip_shape = function(cr, width, height)
			gears.shape.rounded_rect(cr, width, height, dpi(9))
		end,
	},
	layout = wibox.layout.align.horizontal,
})

local profile_imagebox_container = wibox.widget({
	profile_imagebox,
	margins = dpi(15),
	widget = wibox.container.margin,
})

profile_imagebox:buttons(gears.table.join(awful.button({}, 1, nil, function()
	awful.spawn.single_instance("mugshot")
end)))

local profile_name = wibox.widget({
	font = beautiful.font_name .. "Regular 10",
	markup = "User",
	align = "left",
	valign = "center",
	widget = wibox.widget.textbox,
})

local distro_name = wibox.widget({
	font = beautiful.font_name .. "Regular 10",
	markup = "GNU/Linux",
	align = "left",
	valign = "center",
	widget = wibox.widget.textbox,
})

local kernel_version = wibox.widget({
	font = beautiful.font_name .. "Regular 10",
	markup = "Linux",
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

awful.spawn.easy_async_with_shell(
	[[
		cat /etc/os-release | awk 'NR==1'| awk -F '"' '{print $2}'
		]],
	function(stdout)
		local distroname = stdout:gsub("%\n", "")
		distro_name:set_markup(distroname)
	end
)

awful.spawn.easy_async_with_shell("uname -r", function(stdout)
	local kname = stdout:gsub("%\n", "")
	kernel_version:set_markup(kname)
end)

local user_profile = wibox.widget({
	layout = wibox.layout.fixed.horizontal,
	spacing = dpi(10),
	{
		layout = wibox.layout.align.vertical,
		expand = "none",
		nil,
		profile_imagebox_container,
		nil,
	},
	{
		layout = wibox.layout.align.vertical,
		expand = "none",
		nil,
		{
			layout = wibox.layout.fixed.vertical,
			profile_name,
			distro_name,
			kernel_version,
		},
		nil,
	},
})

return user_profile
