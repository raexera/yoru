local wibox = require("wibox")
local beautiful = require("beautiful")
local awful = require("awful")
local gears = require("gears")

local chel = require("module.dock_helpers").color
local rubato = require("module.rubato")

local dpi = beautiful.xresources.apply_dpi

local function init(s, h, o, shape, pinneds)
	--local function init(args)
	--[[	if args.screen == nil then return end
--	local s		= args.screen
--	local h		= args.height or dpi(50)
--	local o		= args.offset or 0
--	local shape	= args.shape or gears.shape.rectangle
--	local pinneds	= args.pinneds or nil]]

	-- tasklist creation {{{
	local tasklist = awful.widget.tasklist({
		screen = s,
		source = function()
			local ret = {}
			for _, t in ipairs(s.tags) do
				gears.table.merge(ret, t:clients())
			end
			return ret
		end, --sorts clients in order of their tags
		filter = awful.widget.tasklist.filter.alltags,
		forced_height = h,
		style = {
			shape = shape,
		},
		layout = {
			layout = wibox.layout.fixed.horizontal,
		},
		widget_template = {
			{
				{
					nil,
					{
						{
							awful.widget.clienticon,
							widget = wibox.container.place,
							halign = "center",
							valign = "center",
						},
						widget = wibox.container.margin,
						margins = h / 10,
					},
					{
						{
							wibox.widget.base.make_widget(),
							forced_height = h / 10,
							forced_width = h / 10,
							id = "status",
							bg = beautiful.dock_focused_bg,
							shape = shape,
							widget = wibox.container.background,
						},
						widget = wibox.container.place, --so the bg widget doesnt get stretched
					},
					layout = wibox.layout.align.vertical,
				},
				id = "bg",
				widget = wibox.container.background,
				bg = beautiful.dock_bg,
				shape = shape,
			},
			widget = wibox.container.margin,
			margins = h / 10,
			forced_height = h,
			forced_width = h,
			create_callback = function(self, c, _, _)
				local function hover(p, t) --so gc can collect all the timed objects that are flying around
					local on_hover = rubato.timed({
						intro = 0.02,
						outro = 0.02,
						duration = 0.2,
						rate = 30,
						pos = p,
						subscribed = function(pos)
							self:get_children_by_id("bg")[1].bg = chel.col_shift(beautiful.dock_bg, pos)
						end,
					})
					on_hover.target = t
				end
				self:connect_signal("mouse::enter", function()
					hover(0, 20)
				end)
				self:connect_signal("mouse::leave", function()
					hover(20, 0)
				end)
				self:add_button(awful.button({
					modifiers = {},
					button = 1,
					on_press = function()
						if not c.active then
							c:activate({
								context = "through_dock",
								switch_to_tag = true,
							})
						else
							c.minimized = true
						end
					end,
				}))
			end,
			update_callback = function(self, c, _, _) --praying to the gc that this is getting cleared properly, didnt show problems in testing
				collectgarbage("collect")
				local status_w = rubato.timed({
					intro = 0.02,
					outro = 0.02,
					duration = 0.1,
					rate = 30,
					pos = self:get_children_by_id("status")[1].forced_width,
					subscribed = function(pos)
						self:get_children_by_id("status")[1].forced_width = pos
					end,
				})
				local bg_col = beautiful.dock_focused_bg
				local bg_focus_col = beautiful.dock_accent
				local sh_r, sh_g, sh_b, _ = chel.col_diff(bg_col, bg_focus_col)

				local status_c = rubato.timed({
					intro = 0.04,
					outro = 0.04,
					duration = 0.2,
					rate = 30,
					pos = 0,
					subscribed = function(pos)
						self:get_children_by_id("status")[1].bg = chel.col_shift(
							bg_col,
							math.floor(pos * (255 * sh_r)),
							math.floor((sh_g * 255) * pos),
							math.floor((sh_b * 255) * pos)
						)
					end,
				})
				--this here sets width and colors depending on the status of the client a widget in the tasklist represents
				if c.active then
					status_w.target = h / 2
					status_c.target = 1
				elseif c.minimized then
					status_w.target = h / 10
					status_c.target = 0
				else
					status_w.target = h / 3
					status_c.target = 0
				end
			end,
		},
	})

	-- }}}
	-- the funny desktop starters {{{
	local pinned_apps = pinneds and { layout = wibox.layout.fixed.horizontal } or nil
	if pinneds then
		for _, p in ipairs(pinneds) do
			pinned_apps[#pinned_apps + 1] = wibox.widget({
				{
					{
						nil,
						{
							{
								{
									widget = wibox.widget.imagebox,
									image = p.icon,
									resize = true,
								},
								margins = dpi(5),
								widget = wibox.container.margin,
							},
							widget = wibox.container.place,
							halign = "center",
							valign = "center",
						},
						{
							{
								wibox.widget.base.make_widget(),
								forced_height = h / 10,
								forced_width = h / 10,
								id = "status",
								shape = shape,
								widget = wibox.container.background,
							},
							widget = wibox.container.place, --so the bg widget doesnt get stretched
							halign = "center",
						},
						layout = wibox.layout.align.vertical,
					},
					widget = wibox.container.background,
					shape = shape,
					id = "bg",
					buttons = awful.button({}, 1, function()
						awful.spawn.easy_async(p.start_cmd)
					end),
				},
				widget = wibox.container.margin,
				margins = h / 10,
				forced_width = h,
				forced_height = h,
			})
			local self = pinned_apps[#pinned_apps]
			local function hover(po, t) --so gc can collect all the timed objects that are flying around
				local on_hover = rubato.timed({
					intro = 0.02,
					outro = 0.02,
					duration = 0.2,
					rate = 30,
					pos = po,
					subscribed = function(pos)
						self:get_children_by_id("bg")[1].bg = chel.col_shift(beautiful.dock_bg, pos)
					end,
				})
				on_hover.target = t
			end
			self:connect_signal("mouse::enter", function()
				hover(0, 20)
			end)
			self:connect_signal("mouse::leave", function()
				hover(20, 0)
			end)
			self:add_button(
				awful.button({ --this is very hacky. Please do NOT COPY if you are looking for suggestions on how to implement this
					modifiers = {},
					button = 1,
					on_press = function() end,
				})
			)
		end
	end
	-- }}}
	local dock_box = awful.popup({
		ontop = true,
		screen = s,
		x = s.geometry.x + s.geometry.width / 2,
		y = s.geometry.y + s.geometry.height - (h + o),
		shape = shape,
		widget = {
			{
				{
					{
						pinned_apps,
						tasklist,
						layout = wibox.layout.fixed.horizontal,
					},
					widget = wibox.container.margin,
					margin = dpi(5),
				},
				widget = wibox.container.background,
				bg = beautiful.dock_bg,
				shape = shape,
			},
			widget = wibox.container.place,
			halign = "center",
		},
	})

	dock_box:connect_signal("property::width", function() --for centered placement, wanted to keep the offset
		dock_box.x = s.geometry.x + s.geometry.width / 2 - dock_box.width / 2
	end)

	local autohideanim = rubato.timed({
		intro = 0.3,
		outro = 0.1,
		duration = 0.4,
		pos = 0,
		rate = 60,
		easing = rubato.quadratic,
		subscribed = function(pos)
			dock_box.y = s.geometry.y + s.geometry.height - ((pos * h) + o)
			dock_box.opacity = pos
		end,
	})
	local autohidetimer = gears.timer({
		timeout = 1,
		single_shot = true,
		callback = function()
			autohideanim.target = 0
		end,
	})
	dock_box:connect_signal("mouse::leave", function()
		autohidetimer:again()
	end)
	dock_box:connect_signal("mouse::enter", function()
		autohideanim.target = 1
		autohidetimer:stop()
	end)
	return dock_box
end

return {
	init = init,
}
