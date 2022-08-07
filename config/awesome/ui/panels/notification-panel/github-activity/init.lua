local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local gfs = require("gears.filesystem")
local widgets = require("ui.widgets")
local helpers = require("helpers")
local github_daemon = require("signal.github")
local collectgarbage = collectgarbage
local setmetatable = setmetatable
local tostring = tostring
local string = string
local ipairs = ipairs
local os = os

local widget_dir = gfs.get_configuration_dir() .. "ui/panels/notification-panel/github-activity"
local icons_dir = widget_dir .. "/icons/"

--- Github Activity Widget
--- ~~~~~~~~~~~~~~~~~~~~~~

local github = { mt = {} }

local function generate_action_string(event)
	local action_string = event.type
	local icon = "repo.svg"
	local link = "http://github.com/" .. event.repo.name

	if event.type == "PullRequestEvent" then
		action_string = event.payload.action .. " a pull request in"
		link = event.pr_url
		icon = "git-pull-request.svg"
	elseif event.type == "IssuesEvent" then
		action_string = event.payload.action .. " an issue in"
		link = event.issue_url
		icon = "alert-circle.svg"
	elseif event.type == "IssueCommentEvent" then
		action_string = event.payload.action == "created" and "commented in issue" or event.action .. " a comment in"
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

local function widget()
	local missing_credentials_text = wibox.widget({
		widget = wibox.container.place,
		halign = "center",
		valign = "center",
		widgets.text({
			halign = "center",
			size = 25,
			color = beautiful.color1,
			text = "Missing Credentials",
		}),
	})

	local error_icon = wibox.widget({
		widget = wibox.container.place,
		halign = "center",
		valign = "center",
		{
			widgets.text({
				halign = "center",
				size = 125,
				color = beautiful.color3,
				font = "Material Icons Round ",
				text = "",
			}),
			widgets.text({
				halign = "center",
				color = beautiful.color3,
				text = "Error",
				bold = true,
			}),
			layout = wibox.layout.fixed.vertical,
		},
	})

	local scrollbox = wibox.widget({
		layout = require("modules.overflow").vertical,
		spacing = dpi(10),
		scrollbar_widget = {
			widget = wibox.widget.separator,
			shape = helpers.ui.rrect(beautiful.border_radius),
		},
		scrollbar_width = dpi(10),
		step = 50,
	})

	return missing_credentials_text, error_icon, scrollbox
end

local function spacer_vertical(amount)
	return wibox.widget({
		layout = wibox.layout.fixed.vertical,
		forced_height = amount,
	})
end

local function github_activity()
	local missing_credentials_text, error_icon, scrollbox = widget()

	local github_activity_widget = wibox.widget({
		layout = wibox.layout.stack,
		top_only = true,
		missing_credentials_text,
		error_icon,
		scrollbox,
	})

	github_daemon:connect_signal("events::error", function()
		github_activity_widget:raise_widget(error_icon)
	end)

	github_daemon:connect_signal("missing_credentials", function()
		github_activity_widget:raise_widget(missing_credentials_text)
	end)

	github_daemon:connect_signal("events", function(self, events, path_to_avatars)
		scrollbox:reset()
		collectgarbage("collect")
		github_activity_widget:raise_widget(scrollbox)

		for index, event in ipairs(events) do
			local action_and_link = generate_action_string(event)

			local avatar = widgets.button.elevated.normal({
				paddings = dpi(5),
				normal_bg = beautiful.wibar_bg,
				child = {
					widget = wibox.widget.imagebox,
					forced_width = dpi(40),
					forced_height = dpi(40),
					clip_shape = helpers.ui.rrect(beautiful.border_radius),
					image = path_to_avatars .. event.actor.id,
				},
				on_release = function()
					awful.spawn("xdg-open http://github.com/" .. event.actor.login, false)
				end,
			})

			local repo_info = widgets.button.elevated.normal({
				paddings = dpi(5),
				normal_bg = beautiful.wibar_bg,
				halign = "left",
				child = {
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
							font = beautiful.font_name .. "Regular 11",
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
							markup = helpers.misc.to_time_ago(
								os.difftime(os.time(os.date("!*t")), helpers.misc.parse_date(event.created_at))
							),
							font = beautiful.font_name .. "Regular 11",
							widget = wibox.widget.textbox,
						},
						spacing = dpi(5),
						layout = wibox.layout.fixed.horizontal,
					},
					layout = wibox.layout.align.vertical,
				},
				on_release = function()
					awful.spawn("xdg-open " .. action_and_link.link, false)
				end,
			})

			local content = wibox.widget({
				avatar,
				repo_info,
				spacing = dpi(5),
				layout = wibox.layout.fixed.horizontal,
			})

			scrollbox:add(content)

			if index == #events then
				scrollbox:add(spacer_vertical(20))
			end
		end
	end)

	return github_activity_widget
end

function github.mt:__call()
	return github_activity()
end

return setmetatable(github, github.mt)
