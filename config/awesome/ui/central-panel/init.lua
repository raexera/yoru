-- Standard awesome library
local gears = require("gears")
local awful = require("awful")

-- Theme handling library
local beautiful = require("beautiful")

-- Widget library
local wibox = require("wibox")

-- rubato
local rubato = require("module.rubato")

-- Helpers
local helpers = require("helpers")

-- Aesthetic Dashboard
-------------------------
local panel_visible = false

awful.screen.connect_for_each_screen(function(s)
	-- Dashboard and animations init
	local separator = wibox.widget({
		orientation = "horizontal",
		opacity = 0.0,
		forced_height = 15,
		widget = wibox.widget.separator,
	})

	central_panel = wibox({
		type = "dock",
		screen = s,
		height = dpi(670),
		width = dpi(620),
		bg = beautiful.transparent,
		ontop = true,
		visible = false,
	})

	awful.placement.centered(central_panel, { honor_workarea = true, margins = beautiful.useless_gap * 5 })

	-- Rubato
	local slide = rubato.timed({
		pos = dpi(-s.geometry.height),
		rate = 60,
		duration = 0.25,
		intro = 0.125,
		easing = rubato.quadratic,
		awestore_compat = true,
		subscribed = function(pos)
			central_panel.y = pos
		end,
	})

	local central_panel_status = false

	slide.ended:subscribe(function()
		if central_panel_status then
			central_panel.visible = false
		end
	end)

	-- Make toogle button
	local central_panel_show = function()
		central_panel.visible = true
		slide:set(dpi(80))
		central_panel_status = false

		central_panel:emit_signal("opened")
	end

	local central_panel_hide = function()
		slide:set(-s.geometry.height)
		central_panel_status = true

		central_panel:emit_signal("closed")
	end

	function central_panel:toggle()
		self.opened = not self.opened
		if self.opened then
			central_panel_hide()
		else
			central_panel_show()
		end
	end

	function central_panel:switch_pane(mode)
		if mode == "dashboard_mode" then
			-- Update Content
			central_panel:get_children_by_id("settings_id")[1].visible = false
			central_panel:get_children_by_id("dashboard_id")[1].visible = true
		elseif mode == "settings_mode" then
			-- Update Content
			central_panel:get_children_by_id("dashboard_id")[1].visible = false
			central_panel:get_children_by_id("settings_id")[1].visible = true
		end
	end

	central_panel:setup({
		{
			{
				expand = "none",
				layout = wibox.layout.fixed.vertical,
				{
					layout = wibox.layout.align.horizontal,
					expand = "none",
					nil,
					require("ui.widgets.central-panel-switch"),
					nil,
				},
				separator,
				{
					layout = wibox.layout.stack,
					{
						id = "dashboard_id",
						visible = true,
						layout = wibox.layout.fixed.vertical,
						{
							layout = wibox.layout.flex.horizontal,
							spacing = 10,
							spacing_widget = wibox.widget.separator({
								span_ratio = 0.80,
								color = beautiful.lighter_bg,
							}),
							require("ui.central-panel.dashboard")(s),
							require("ui.central-panel.notif-center")(s),
						},
					},
					{
						id = "settings_id",
						visible = false,
						layout = wibox.layout.fixed.vertical,
						{
							layout = wibox.layout.fixed.vertical,
							require("ui.central-panel.settings")(s),
						},
					},
				},
			},
			margins = dpi(10),
			widget = wibox.container.margin,
		},
		bg = beautiful.dashboard_bg,
		shape = helpers.rrect(beautiful.notif_center_radius),
		widget = wibox.container.background,
	})
end)
