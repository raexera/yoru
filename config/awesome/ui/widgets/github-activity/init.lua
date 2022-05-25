-- Github Activity widget stolen from streetturtle/

local awful = require("awful")
local wibox = require("wibox")
local json = require("module.json")
local spawn = require("awful.spawn")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local gfs = require("gears.filesystem")
local config = require("configuration.config")
local clickable_container = require("ui.widgets.clickable-container")

local home = os.getenv("HOME")
local widget_dir = gfs.get_configuration_dir() .. "ui/widgets/github-activity"
local icons_dir = widget_dir .. "/icons/"
local cache_dir = home .. "/.cache/awesomewm/github-activity-widget"

local get_events_cmd = [[sh -c "cat %s/activity.json | jq '.[:%d] | [.[] ]]
	.. [[| {type: .type, actor: .actor, repo: .repo, action: .payload.action, issue_url: .payload.issue.html_url, ]]
	.. [[pr_url: .payload.pull_request.html_url, created_at: .created_at}]'"]]
local download_avatar_cmd = [[sh -c "curl -n --create-dirs -o  %s/avatars/%s %s"]]
local update_events_cmd = [[sh -c "curl -s --show-error https://api.github.com/users/%s/received_events ]]
	.. [[> %s/activity.json"]]

local function parse_date(date_str)
	local pattern = "(%d+)%-(%d+)%-(%d+)T(%d+):(%d+):(%d+)%Z"
	local y, m, d, h, min, sec, _ = date_str:match(pattern)
	return os.time({ year = y, month = m, day = d, hour = h, min = min, sec = sec })
end

local function to_time_ago(seconds)
	local days = seconds / 86400
	if days > 1 then
		days = math.floor(days + 0.5)
		return days .. (days == 1 and " day" or " days") .. " ago"
	end

	local hours = (seconds % 86400) / 3600
	if hours > 1 then
		hours = math.floor(hours + 0.5)
		return hours .. (hours == 1 and " hour" or " hours") .. " ago"
	end

	local minutes = ((seconds % 86400) % 3600) / 60
	if minutes > 1 then
		minutes = math.floor(minutes + 0.5)
		return minutes .. (minutes == 1 and " minute" or " minutes") .. " ago"
	end
end

local popup = awful.popup({
	type = "dock",
	ontop = true,
	visible = false,
	width = dpi(350),
	maximum_width = dpi(350),
	offset = { y = dpi(10) },
	shape = function(cr, w, h)
		gears.shape.rounded_rect(cr, w, h, beautiful.control_center_widget_radius)
	end,
	widget = {},
})

local function generate_action_string(event)
	local action_string = event.type
	local icon = "repo.svg"
	local link = "http://github.com/" .. event.repo.name

	if event.type == "PullRequestEvent" then
		action_string = event.action .. " a pull request in"
		link = event.pr_url
		icon = "git-pull-request.svg"
	elseif event.type == "IssuesEvent" then
		action_string = event.action .. " an issue in"
		link = event.issue_url
		icon = "alert-circle.svg"
	elseif event.type == "IssueCommentEvent" then
		action_string = event.action == "created" and "commented in issue" or event.action .. " a comment in"
		link = event.issue_url
		icon = "message-square.svg"
	elseif event.type == "WatchEvent" then
		action_string = "starred"
		icon = "star.svg"
	elseif event.type == "ForkEvent" then
		action_string = "forked"
		icon = "git-branch.svg"
	elseif event.type == "CreateEvent" then
		action_string = "created"
	end

	return { action_string = action_string, link = link, icon = icon }
end

local github_widget = wibox.widget({
	{
		{
			id = "icon",
			text = "",
			align = "center",
			valign = "center",
			font = "icomoon 18",
			widget = wibox.widget.textbox,
		},
		id = "m",
		margins = dpi(8),
		layout = wibox.container.margin,
	},
	widget = require("ui.widgets.clickable-container"),
})

local github_activity = {
	layout = wibox.layout.fixed.vertical,
}

if not gfs.dir_readable(cache_dir) then
	gfs.make_directories(cache_dir)
end

local username = config.widget.github.username
local number_of_events = config.widget.github.number_of_events

local rebuild_widget = function(stdout, stderr, _, _)
	if stderr ~= "" then
		return
	end

	local current_time = os.time(os.date("!*t"))

	local events = json.decode(stdout)

	for i = 0, #github_activity do
		github_activity[i] = nil
	end
	for _, event in ipairs(events) do
		local path_to_avatar = cache_dir .. "/avatars/" .. event.actor.id

		local avatar_img = wibox.widget({
			resize = true,
			forced_width = dpi(40),
			forced_height = dpi(40),
			widget = wibox.widget.imagebox,
		})

		if not gfs.file_readable(path_to_avatar) then
			-- download it first
			spawn.easy_async(
				string.format(download_avatar_cmd, cache_dir, event.actor.id, event.actor.avatar_url),
				function()
					avatar_img:set_image(path_to_avatar)
				end
			)
		else
			avatar_img:set_image(path_to_avatar)
		end

		local action_and_link = generate_action_string(event)

		local avatar = wibox.widget({
			{
				avatar_img,
				margins = dpi(4),
				layout = wibox.container.margin,
			},
			widget = clickable_container,
		})
		avatar:add_button(awful.button({}, 1, function()
			spawn.with_shell("xdg-open http://github.com/" .. event.actor.login)
			popup.visible = false
		end))

		local repo_info = wibox.widget({
			{
				step_function = wibox.container.scroll.step_functions.waiting_nonlinear_back_and_forth,
				fps = 60,
				speed = 75,
				{
					markup = "<b> "
						.. event.actor.display_login
						.. "</b> "
						.. action_and_link.action_string
						.. " <b>"
						.. event.repo.name
						.. "</b>",
					widget = wibox.widget.textbox,
				},
				forced_width = dpi(300),
				widget = wibox.container.scroll.horizontal,
			},
			{
				{
					{
						image = icons_dir .. action_and_link.icon,
						resize = true,
						forced_height = dpi(16),
						forced_width = dpi(16),
						widget = wibox.widget.imagebox,
					},
					valign = "center",
					layout = wibox.container.place,
				},
				{
					markup = to_time_ago(os.difftime(current_time, parse_date(event.created_at))),
					widget = wibox.widget.textbox,
				},
				spacing = dpi(4),
				layout = wibox.layout.fixed.horizontal,
			},
			layout = wibox.layout.align.vertical,
		})
		repo_info:add_button(awful.button({}, 1, function()
			spawn.with_shell("xdg-open " .. action_and_link.link)
			popup.visible = false
		end))

		local activity = wibox.widget({
			{
				{
					avatar,
					repo_info,
					spacing = dpi(5),
					layout = wibox.layout.fixed.horizontal,
				},
				margins = dpi(10),
				layout = wibox.container.margin,
			},
			bg = beautiful.wibar_bg,
			widget = wibox.container.background,
		})

		local old_cursor, old_wibox

		activity:connect_signal("mouse::enter", function(c)
			c:set_bg(beautiful.widget_bg)
			local w = mouse.current_wibox
			if w then
				old_cursor, old_wibox = w.cursor, w
				w.cursor = "hand1"
			end
		end)

		activity:connect_signal("mouse::leave", function(c)
			c:set_bg(beautiful.wibar_bg)
			if old_wibox then
				old_wibox.cursor = old_cursor
				old_wibox = nil
			end
		end)

		table.insert(github_activity, activity)
	end

	popup:setup(github_activity)
end

github_widget:add_button(awful.button({}, 1, function()
	if popup.visible then
		popup.visible = not popup.visible
	else
		spawn.easy_async(string.format(get_events_cmd, cache_dir, number_of_events), function(stdout, stderr)
			rebuild_widget(stdout, stderr)
			popup:move_next_to(mouse.current_widget_geometry)
		end)
	end
end))

-- Calls GitHub event API and stores response in "cache" file
gears.timer({
	timeout = 600,
	call_now = true,
	autostart = true,
	callback = function()
		spawn.easy_async(string.format(update_events_cmd, username, cache_dir), function(_, stderr)
			if stderr ~= "" then
				return
			end
		end)
	end,
})

return github_widget
