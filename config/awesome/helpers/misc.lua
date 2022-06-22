local awful = require("awful")
local naughty = require("naughty")
local gears = require("gears")
local beautiful = require("beautiful")
local icons = require("icons")
local math = math
local os = os
local capi = { awesome = awesome, client = client }

local _misc = {}

-- Send key
function _misc.send_key(c, key)
	awful.spawn.with_shell("xdotool key --window " .. tostring(c.window) .. " " .. key)
end

--- Converts string representation of date (2020-06-02T11:25:27Z) to date
function _misc.parse_date(date_str)
	local pattern = "(%d+)%-(%d+)%-(%d+)T(%d+):(%d+):(%d+)%Z"
	local y, m, d, h, min, sec, _ = date_str:match(pattern)

	return os.time({ year = y, month = m, day = d, hour = h, min = min, sec = sec })
end

--- Converts seconds to "time ago" representation, like '1 hour ago'
function _misc.to_time_ago(seconds)
	local days = seconds / 86400
	if days >= 1 then
		days = math.floor(days)
		return days .. (days == 1 and " day" or " days") .. " ago"
	end

	local hours = (seconds % 86400) / 3600
	if hours >= 1 then
		hours = math.floor(hours)
		return hours .. (hours == 1 and " hour" or " hours") .. " ago"
	end

	local minutes = ((seconds % 86400) % 3600) / 60
	if minutes >= 1 then
		minutes = math.floor(minutes)
		return minutes .. (minutes == 1 and " minute" or " minutes") .. " ago"
	end

	return "Now"
end

function _misc.tag_back_and_forth(tag_index)
	local s = awful.screen.focused()
	local tag = s.tags[tag_index]
	if tag then
		if tag == s.selected_tag then
			awful.tag.history.restore()
		else
			tag:view_only()
		end

		local urgent_clients = function(c)
			return awful.rules.match(c, { urgent = true, first_tag = tag })
		end

		for c in awful.client.iterate(urgent_clients) do
			capi.client.focus = c
			c:raise()
		end
	end
end

function _misc.prompt(action, textbox, prompt, callback)
	if action == "run" then
		awful.prompt.run({
			prompt = prompt,
			-- prompt       = "<b>Run: </b>",
			textbox = textbox,
			font = beautiful.font_name .. "Regular 12",
			done_callback = callback,
			exe_callback = awful.spawn,
			completion_callback = awful.completion.shell,
			history_path = awful.util.get_cache_dir() .. "/history",
		})
	elseif action == "web_search" then
		awful.prompt.run({
			prompt = prompt,
			-- prompt       = '<b>Web search: </b>',
			textbox = textbox,
			font = beautiful.font_name .. "Regular 12",
			history_path = awful.util.get_cache_dir() .. "/history_web",
			done_callback = callback,
			exe_callback = function(input)
				if not input or #input == 0 then
					return
				end
				awful.spawn.with_shell("noglob " .. "xdg-open https://www.google.com/search?q=" .. "'" .. input .. "'")
				naughty.notify({
					title = "Searching the web for",
					text = input,
					icon = gears.color.recolor_image(icons.web_browser, beautiful.accent),
					urgency = "low",
				})
			end,
		})
	end
end

return _misc
