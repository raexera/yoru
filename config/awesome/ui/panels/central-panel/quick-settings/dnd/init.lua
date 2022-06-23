local awful = require("awful")
local gears = require("gears")
local naughty = require("naughty")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local config_dir = gears.filesystem.get_configuration_dir()
local widget_dir = config_dir .. "ui/panels/central-panel/quick-settings/dnd/"
local widgets = require("ui.widgets")

--- Do not Disturb Widget
--- ~~~~~~~~~~~~~~~~~~~~~

_G.dnd_state = false

local function button(icon)
	return widgets.button.text.state({
		forced_width = dpi(60),
		forced_height = dpi(60),
		normal_bg = beautiful.one_bg3,
		normal_shape = gears.shape.circle,
		on_normal_bg = beautiful.accent,
		text_normal_bg = beautiful.accent,
		text_on_normal_bg = beautiful.one_bg3,
		font = beautiful.icon_font .. "Round ",
		size = 17,
		text = icon,
	})
end

local widget = button("")

local update_widget = function()
	if dnd_state then
		widget:turn_on()
	else
		widget:turn_off()
	end
end

local check_dnd_status = function()
	awful.spawn.easy_async_with_shell("cat " .. widget_dir .. "dnd_status", function(stdout)
		local status = stdout

		if status:match("true") then
			dnd_state = true
		elseif status:match("false") then
			dnd_state = false
		else
			dnd_state = false
			awful.spawn.with_shell("echo 'false' > " .. widget_dir .. "dnd_status")
		end

		update_widget()
	end)
end

check_dnd_status()

local toggle_action = function()
	if dnd_state then
		dnd_state = false
	else
		dnd_state = true
	end
	awful.spawn.easy_async_with_shell("echo " .. tostring(dnd_state) .. " > " .. widget_dir .. "dnd_status", function()
		update_widget()
	end)
end

widget:buttons(gears.table.join(awful.button({}, 1, nil, function()
	toggle_action()
end)))

--- Create a notification sound
naughty.connect_signal("request::display", function(n)
	if not dnd_state then
		awful.spawn("canberra-gtk-play -i bell", false)
	end
end)

return widget
