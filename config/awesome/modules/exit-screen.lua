local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local helpers = require("helpers")
local lock_screen = require("modules.lockscreen")
lock_screen.init()

--- Minimalist Exit Screen
--- ~~~~~~~~~~~~~~~~~~~~~~

--- Icons
local icon_font = "icomoon bold 45"
local poweroff_text_icon = ""
local reboot_text_icon = ""
local suspend_text_icon = ""
local exit_text_icon = ""
local lock_text_icon = ""

local button_bg = beautiful.black
local button_size = dpi(120)

--- Commands
local poweroff_command = function()
	awful.spawn.with_shell("systemctl poweroff")
	awesome.emit_signal("module::exit_screen:hide")
end

local reboot_command = function()
	awful.spawn.with_shell("systemctl reboot")
	awesome.emit_signal("module::exit_screen:hide")
end

local suspend_command = function()
	awesome.emit_signal("module::exit_screen:hide")
	lock_screen_show()
	awful.spawn.with_shell("systemctl suspend")
end

local exit_command = function()
	awesome.quit()
end

local lock_command = function()
	awesome.emit_signal("module::exit_screen:hide")
	lock_screen_show()
end

local create_button = function(symbol, hover_color, text, command)
	local icon = wibox.widget({
		forced_height = button_size,
		forced_width = button_size,
		align = "center",
		valign = "center",
		font = icon_font,
		markup = helpers.ui.colorize_text(symbol, beautiful.lighter_black),
		widget = wibox.widget.textbox(),
	})

	local button = wibox.widget({
		{
			nil,
			icon,
			expand = "none",
			layout = wibox.layout.align.horizontal,
		},
		forced_height = button_size,
		forced_width = button_size,
		border_width = dpi(8),
		border_color = beautiful.lighter_black,
		shape = helpers.ui.rrect(beautiful.border_radius * 2),
		bg = button_bg,
		widget = wibox.container.background,
	})

	button:buttons(gears.table.join(awful.button({}, 1, function()
		command()
	end)))

	button:connect_signal("mouse::enter", function()
		icon.markup = helpers.ui.colorize_text(icon.text, hover_color)
		button.border_color = hover_color
	end)
	button:connect_signal("mouse::leave", function()
		icon.markup = helpers.ui.colorize_text(icon.text, beautiful.lighter_black)
		button.border_color = beautiful.lighter_black
	end)

	helpers.ui.add_hover_cursor(button, "hand1")

	return button
end

--- Create the buttons
local poweroff = create_button(poweroff_text_icon, beautiful.color1, "Poweroff", poweroff_command)
local reboot = create_button(reboot_text_icon, beautiful.color2, "Reboot", reboot_command)
local suspend = create_button(suspend_text_icon, beautiful.color3, "Suspend", suspend_command)
local exit = create_button(exit_text_icon, beautiful.color4, "Exit", exit_command)
local lock = create_button(lock_text_icon, beautiful.color5, "Lock", lock_command)

local create_exit_screen = function(s)
	s.exit_screen = wibox({
		screen = s,
		type = "splash",
		visible = false,
		ontop = true,
		bg = beautiful.transparent,
		fg = beautiful.fg_normal,
		height = s.geometry.height,
		width = s.geometry.width,
		x = s.geometry.x,
		y = s.geometry.y,
	})

	s.exit_screen:buttons(gears.table.join(
		awful.button({}, 2, function()
			awesome.emit_signal("module::exit_screen:hide")
		end),
		awful.button({}, 3, function()
			awesome.emit_signal("module::exit_screen:hide")
		end)
	))

	s.exit_screen:setup({
		nil,
		{
			nil,
			{
				poweroff,
				reboot,
				suspend,
				exit,
				lock,
				spacing = dpi(50),
				layout = wibox.layout.fixed.horizontal,
			},
			expand = "none",
			layout = wibox.layout.align.horizontal,
		},
		expand = "none",
		layout = wibox.layout.align.vertical,
	})
end

screen.connect_signal("request::desktop_decoration", function(s)
	create_exit_screen(s)
end)

screen.connect_signal("removed", function(s)
	create_exit_screen(s)
end)

local exit_screen_grabber = awful.keygrabber({
	auto_start = true,
	stop_event = "release",
	keypressed_callback = function(self, mod, key, command)
		if key == "s" then
			suspend_command()
		elseif key == "e" then
			exit_command()
		elseif key == "l" then
			lock_command()
		elseif key == "p" then
			poweroff_command()
		elseif key == "r" then
			reboot_command()
		elseif key == "Escape" or key == "q" or key == "x" then
			awesome.emit_signal("module::exit_screen:hide")
		end
	end,
})

awesome.connect_signal("module::exit_screen:show", function()
	for s in screen do
		s.exit_screen.visible = false
	end
	awful.screen.focused().exit_screen.visible = true
	exit_screen_grabber:start()
end)

awesome.connect_signal("module::exit_screen:hide", function()
	exit_screen_grabber:stop()
	for s in screen do
		s.exit_screen.visible = false
	end
end)
