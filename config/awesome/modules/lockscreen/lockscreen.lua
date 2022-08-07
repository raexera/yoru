local gears = require("gears")
local awful = require("awful")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local wibox = require("wibox")
local helpers = require("helpers")
local lock_screen = require("modules.lockscreen")

--- Word Clock Lock Screen
--- ~~~~~~~~~~~~~~~~~~~~~~

local lock_screen_symbol = ""
local lock_screen_fail_symbol = ""
local lock_animation_icon = wibox.widget({
	--- Set forced size to prevent flickering when the icon rotates
	forced_height = dpi(80),
	forced_width = dpi(80),
	font = beautiful.icon_font .. "Outlined 40",
	align = "center",
	valign = "center",
	widget = wibox.widget.textbox(lock_screen_symbol),
})

local some_textbox = wibox.widget.textbox()

lock_screen_box = wibox({ visible = false, ontop = true, type = "splash", screen = screen.primary })
awful.placement.maximize(lock_screen_box)

lock_screen_box.bg = beautiful.transparent
lock_screen_box.fg = beautiful.white

--- Add lockscreen to each screen
awful.screen.connect_for_each_screen(function(s)
	if s == screen.primary then
		s.mylockscreen = lock_screen_box
	else
		s.mylockscreen = helpers.ui.screen_mask(
			s,
			beautiful.lock_screen_bg or beautiful.exit_screen_bg or beautiful.black
		)
	end
end)

local function set_visibility(v)
	for s in screen do
		s.mylockscreen.visible = v
	end
end

--- Word Clock
--- ~~~~~~~~~
local char =
	"I T L I S A S A M P M A C Q U A R T E R D C T W E N T Y F I V E X H A L F S T E N F T O P A S T E R U N I N E O N E S I X T H R E E F O U R F I V E T W O E I G H T E L E V E N S E V E N T W E L V E T E N S E O C L O C K"

local pos_map = {
	["it"] = { 1, 2 },
	["is"] = { 4, 5 },
	["a"] = { 12, 12 },
	["quarter"] = { 14, 20 },
	["twenty"] = { 23, 28 },
	["five"] = { 29, 32 },
	["half"] = { 34, 37 },
	["ten"] = { 39, 41 },
	["past"] = { 45, 48 },
	["to"] = { 43, 44 },
	["1"] = { 56, 58 },
	["2"] = { 75, 77 },
	["3"] = { 62, 66 },
	["4"] = { 67, 70 },
	["5"] = { 71, 74 },
	["6"] = { 59, 61 },
	["7"] = { 89, 93 },
	["8"] = { 78, 82 },
	["9"] = { 52, 55 },
	["10"] = { 100, 102 },
	["11"] = { 83, 88 },
	["12"] = { 94, 99 },
	["oclock"] = { 105, 110 },
}

local char_map = {
	["it"] = {},
	["is"] = {},
	["a"] = {},
	["quarter"] = {},
	["twenty"] = {},
	["five"] = {},
	["half"] = {},
	["ten"] = {},
	["past"] = {},
	["to"] = {},
	["1"] = {},
	["2"] = {},
	["3"] = {},
	["4"] = {},
	["5"] = {},
	["6"] = {},
	["7"] = {},
	["8"] = {},
	["9"] = {},
	["10"] = {},
	["11"] = {},
	["12"] = {},
	["oclock"] = {},
}

local reset_map = { 4, 12, 14, 23, 29, 34, 39, 43, 45, 52, 56, 59, 62, 67, 71, 75, 78, 83, 89, 94, 100, 105 }

function split_str(s, delimiter)
	result = {}
	for match in (s .. delimiter):gmatch("(.-)" .. delimiter) do
		table.insert(result, match)
	end

	return result
end

local time_char = split_str(char, " ")

local time = wibox.widget({
	forced_num_cols = 11,
	spacing = dpi(6),
	layout = wibox.layout.grid,
})

local function create_text_widget(index, w)
	local text_widget = wibox.widget({
		id = "t" .. index,
		markup = w,
		font = beautiful.font_name .. "Bold 24",
		align = "center",
		valign = "center",
		forced_width = dpi(36),
		forced_height = dpi(36),
		widget = wibox.widget.textbox,
	})

	time:add(text_widget)

	return text_widget
end

local var_count = 0
for i, m in pairs(time_char) do
	local text = helpers.ui.colorize_text(m, "#ffffff" .. "10")

	var_count = var_count + 1
	local create_dummy_text = true

	for j, k in pairs(pos_map) do
		if i >= pos_map[j][1] and i <= pos_map[j][2] then
			char_map[j][var_count] = create_text_widget(i, text)
			create_dummy_text = false
		end

		for _, n in pairs(reset_map) do
			if i == n then
				var_count = 1
			end
		end
	end

	if create_dummy_text then
		create_text_widget(i, text)
	end
end

local function activate_word(w)
	for i, m in pairs(char_map[w]) do
		local text = m.text
		m.markup = helpers.ui.colorize_text(text, beautiful.white)
	end
end

local function deactivate_word(w)
	for i, m in pairs(char_map[w]) do
		local text = m.text
		m.markup = helpers.ui.colorize_text(text, "#ffffff" .. "10")
	end
end

local function reset_time()
	for j, k in pairs(char_map) do
		deactivate_word(j)
	end

	activate_word("it")
	activate_word("is")
end

gears.timer({
	timeout = 1,
	call_now = true,
	autostart = true,
	callback = function()
		local time = os.date("%I" .. ":%M")
		local h, m = time:match("(%d+):(%d+)")
		local min = tonumber(m)
		local hour = tonumber(h)

		reset_time()

		if min >= 0 and min <= 2 or min >= 58 and min <= 59 then
			activate_word("oclock")
		elseif min >= 3 and min <= 7 or min >= 53 and min <= 57 then
			activate_word("five")
		elseif min >= 8 and min <= 12 or min >= 48 and min <= 52 then
			activate_word("ten")
		elseif min >= 13 and min <= 17 or min >= 43 and min <= 47 then
			activate_word("a")
			activate_word("quarter")
		elseif min >= 18 and min <= 22 or min >= 38 and min <= 42 then
			activate_word("twenty")
		elseif min >= 23 and min <= 27 or min >= 33 and min <= 37 then
			activate_word("twenty")
			activate_word("five")
		elseif min >= 28 and min <= 32 then
			activate_word("half")
		end

		if min >= 3 and min <= 32 then
			activate_word("past")
		elseif min >= 33 and min <= 57 then
			activate_word("to")
		end

		local hh

		if min >= 0 and min <= 30 then
			hh = hour
		else
			hh = hour + 1
		end

		if hh > 12 then
			hh = hh - 12
		end

		activate_word(tostring(hh))
	end,
})

--- Lock animation
local lock_animation_widget_rotate = wibox.container.rotate()

local arc = function()
	return function(cr, width, height)
		gears.shape.arc(cr, width, height, 5, 0, math.pi / 2, true, true)
	end
end

local lock_animation_arc = wibox.widget({
	shape = arc(),
	bg = "#00000000",
	forced_width = dpi(100),
	forced_height = dpi(100),
	widget = wibox.container.background,
})

local lock_animation = {
	{
		lock_animation_arc,
		widget = lock_animation_widget_rotate,
	},
	lock_animation_icon,
	layout = wibox.layout.stack,
}

--- Lock helper functions
local characters_entered = 0
local function reset()
	characters_entered = 0
	lock_animation_icon.markup = lock_screen_symbol
	lock_animation_widget_rotate.direction = "north"
	lock_animation_arc.bg = "#00000000"
end

local function fail()
	characters_entered = 0
	lock_animation_icon.markup = lock_screen_fail_symbol
	lock_animation_widget_rotate.direction = "north"
	lock_animation_arc.bg = "#00000000"
end

local animation_colors = {
	--- Rainbow sequence
	beautiful.color1,
	beautiful.color5,
	beautiful.color4,
	beautiful.color6,
	beautiful.color2,
	beautiful.color3,
}

local animation_directions = { "north", "west", "south", "east" }

--- Function that "animates" every key press
local function key_animation(char_inserted)
	local color
	local direction = animation_directions[(characters_entered % 4) + 1]
	if char_inserted then
		color = animation_colors[(characters_entered % 6) + 1]
		lock_animation_icon.markup = lock_screen_symbol
	else
		if characters_entered == 0 then
			reset()
		else
			color = beautiful.color7 .. "55"
		end
	end

	lock_animation_arc.bg = color
	lock_animation_widget_rotate.direction = direction
end

--- Get input from user
local function grab_password()
	awful.prompt.run({
		hooks = {
			--- Custom escape behaviour: Do not cancel input with Escape
			--- Instead, this will just clear any input received so far.
			{
				{},
				"Escape",
				function(_)
					reset()
					grab_password()
				end,
			},
			--- Fix for Control+Delete crashing the keygrabber
			{
				{ "Control" },
				"Delete",
				function()
					reset()
					grab_password()
				end,
			},
		},
		keypressed_callback = function(mod, key, cmd)
			--- Only count single character keys (thus preventing "Shift", "Escape", etc from triggering the animation)
			if #key == 1 then
				characters_entered = characters_entered + 1
				key_animation(true)
			elseif key == "BackSpace" then
				if characters_entered > 0 then
					characters_entered = characters_entered - 1
				end
				key_animation(false)
			end
		end,
		exe_callback = function(input)
			--- Check input
			if lock_screen.authenticate(input) then
				--- YAY
				reset()
				set_visibility(false)
			else
				--- NAY
				fail()
				grab_password()
			end
		end,
		textbox = some_textbox,
	})
end

function lock_screen_show()
	set_visibility(true)
	grab_password()
end

lock_screen_box:setup({
	--- Horizontal centering
	nil,
	{
		--- Vertical centering
		nil,
		{
			helpers.ui.vertical_pad(dpi(20)),
			time,
			lock_animation,
			spacing = dpi(60),
			layout = wibox.layout.fixed.vertical,
		},
		expand = "none",
		layout = wibox.layout.align.vertical,
	},
	expand = "none",
	layout = wibox.layout.align.horizontal,
})
