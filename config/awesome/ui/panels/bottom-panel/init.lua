local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local helpers = require("helpers")
local widgets = require("ui.widgets")
local wbutton = require("ui.widgets.button")
local animation = require("modules.animation")

--- Modern Bottom Panel
--- ~~~~~~~~~~~~~~~~~~~

return function(s)
	--- Widgets
	--- ~~~~~~~~~~
	s.clock = require("ui.panels.bottom-panel.clock")(s)
	s.battery = require("ui.panels.bottom-panel.battery")()
	s.network = require("ui.panels.bottom-panel.network")()

	--- Animated tag list
	--- ~~~~~~~~~~~~~~~~~

	--- Taglist buttons
	local modkey = "Mod4"
	local taglist_buttons = gears.table.join(
		awful.button({}, 1, function(t)
			t:view_only()
		end),
		awful.button({ modkey }, 1, function(t)
			if client.focus then
				client.focus:move_to_tag(t)
			end
		end),
		awful.button({}, 3, awful.tag.viewtoggle),
		awful.button({ modkey }, 3, function(t)
			if client.focus then
				client.focus:toggle_tag(t)
			end
		end),
		awful.button({}, 4, function(t)
			awful.tag.viewnext(t.screen)
		end),
		awful.button({}, 5, function(t)
			awful.tag.viewprev(t.screen)
		end)
	)

	local function tag_list(s)
		local taglist = awful.widget.taglist({
			screen = s,
			filter = awful.widget.taglist.filter.all,
			layout = { layout = wibox.layout.fixed.horizontal },
			widget_template = {
				widget = wibox.container.margin,
				forced_width = dpi(40),
				forced_height = dpi(40),
				create_callback = function(self, c3, _)
					local indicator = wibox.widget({
						widget = wibox.container.place,
						valign = "center",
						{
							widget = wibox.container.background,
							forced_height = dpi(8),
							shape = gears.shape.rounded_bar,
						},
					})

					self.indicator_animation = animation:new({
						duration = 0.125,
						easing = animation.easing.linear,
						update = function(self, pos)
							indicator.children[1].forced_width = pos
						end,
					})

					self:set_widget(indicator)

					if c3.selected then
						self.widget.children[1].bg = beautiful.accent
						self.indicator_animation:set(dpi(32))
					elseif #c3:clients() == 0 then
						self.widget.children[1].bg = beautiful.color8
						self.indicator_animation:set(dpi(8))
					else
						self.widget.children[1].bg = beautiful.accent
						self.indicator_animation:set(dpi(16))
					end

					--- Tag preview
					self:connect_signal("mouse::enter", function()
						if #c3:clients() > 0 then
							awesome.emit_signal("bling::tag_preview::update", c3)
							awesome.emit_signal("bling::tag_preview::visibility", s, true)
						end
					end)

					self:connect_signal("mouse::leave", function()
						awesome.emit_signal("bling::tag_preview::visibility", s, false)
					end)
				end,
				update_callback = function(self, c3, _)
					if c3.selected then
						self.widget.children[1].bg = beautiful.accent
						self.indicator_animation:set(dpi(32))
					elseif #c3:clients() == 0 then
						self.widget.children[1].bg = beautiful.color8
						self.indicator_animation:set(dpi(8))
					else
						self.widget.children[1].bg = beautiful.accent
						self.indicator_animation:set(dpi(16))
					end
				end,
			},
			buttons = taglist_buttons,
		})

		local widget = widgets.button.elevated.state({
			normal_bg = beautiful.widget_bg,
			normal_shape = gears.shape.rounded_bar,
			child = {
				taglist,
				margins = { left = dpi(10), right = dpi(10) },
				widget = wibox.container.margin,
			},
			on_release = function()
				awesome.emit_signal("central_panel::toggle", s)
			end,
		})

		return wibox.widget({
			widget,
			margins = dpi(5),
			widget = wibox.container.margin,
		})
	end

	--- Systray
	--- ~~~~~~~
	local function system_tray()
		local mysystray = wibox.widget.systray()
		mysystray.base_size = beautiful.systray_icon_size

		local widget = wibox.widget({
			widget = wibox.container.constraint,
			strategy = "max",
			width = dpi(0),
			{
				widget = wibox.container.margin,
				margins = dpi(10),
				mysystray,
			},
		})

		local system_tray_animation = animation:new({
			easing = animation.easing.linear,
			duration = 0.125,
			update = function(self, pos)
				widget.width = pos
			end,
		})

		local arrow = wbutton.text.state({
			text_normal_bg = beautiful.accent,
			normal_bg = beautiful.wibar_bg,
			font = beautiful.icon_font .. "Round ",
			size = 18,
			text = "",
			on_turn_on = function(self)
				system_tray_animation:set(400)
				self:set_text("")
			end,
			on_turn_off = function(self)
				system_tray_animation:set(0)
				self:set_text("")
			end,
		})

		return wibox.widget({
			layout = wibox.layout.fixed.horizontal,
			arrow,
			widget,
		})
	end

	--- Notif panel
	--- ~~~~~~~~~~~
	local function notif_panel()
		local icon = wibox.widget({
			markup = helpers.ui.colorize_text("", beautiful.accent),
			align = "center",
			valign = "center",
			font = beautiful.icon_font .. "Round 18",
			widget = wibox.widget.textbox,
		})

		local widget = wbutton.elevated.state({
			child = icon,
			normal_bg = beautiful.wibar_bg,
			on_release = function()
				awesome.emit_signal("notification_panel::toggle", s)
			end,
		})

		return widget
	end

	--- Layoutbox
	--- ~~~~~~~~~
	local function layoutbox()
		local layoutbox_buttons = gears.table.join(
			--- Left click
			awful.button({}, 1, function(c)
				awful.layout.inc(1)
			end),

			--- Right click
			awful.button({}, 3, function(c)
				awful.layout.inc(-1)
			end),

			--- Scrolling
			awful.button({}, 4, function()
				awful.layout.inc(-1)
			end),
			awful.button({}, 5, function()
				awful.layout.inc(1)
			end)
		)

		s.mylayoutbox = awful.widget.layoutbox()
		s.mylayoutbox:buttons(layoutbox_buttons)

		local widget = wbutton.elevated.state({
			child = s.mylayoutbox,
			normal_bg = beautiful.wibar_bg,
		})

		return widget
	end

	--- Create the bottom_panel
	--- ~~~~~~~~~~~~~~~~~~~~~~~
	s.bottom_panel = awful.popup({
		screen = s,
		type = "dock",
		maximum_height = beautiful.wibar_height,
		minimum_width = s.geometry.width,
		maximum_width = s.geometry.width,
		placement = function(c)
			awful.placement.bottom(c)
		end,
		bg = beautiful.transparent,
		widget = {
			{
				{
					layout = wibox.layout.align.horizontal,
					expand = "none",
					s.clock,
					tag_list(s),
					{
						system_tray(),
						s.battery,
						s.network,
						notif_panel(),
						layoutbox(),
						layout = wibox.layout.fixed.horizontal,
					},
				},
				left = dpi(10),
				right = dpi(10),
				widget = wibox.container.margin,
			},
			bg = beautiful.wibar_bg,
			widget = wibox.container.background,
		},
	})

	s.bottom_panel:struts({
		bottom = s.bottom_panel.maximum_height,
	})

	--- Remove bottom_panel on full screen
	local function remove_bottom_panel(c)
		if c.fullscreen or c.maximized then
			c.screen.bottom_panel.visible = false
		else
			c.screen.bottom_panel.visible = true
		end
	end

	--- Remove bottom_panel on full screen
	local function add_bottom_panel(c)
		if c.fullscreen or c.maximized then
			c.screen.bottom_panel.visible = true
		end
	end

	--- Hide bar when a splash widget is visible
	awesome.connect_signal("widgets::splash::visibility", function(vis)
		screen.primary.bottom_panel.visible = not vis
	end)

	client.connect_signal("property::fullscreen", remove_bottom_panel)
	client.connect_signal("request::unmanage", add_bottom_panel)
end
