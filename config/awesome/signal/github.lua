local aspawn = require("awful.spawn")
local gobject = require("gears.object")
local gtable = require("gears.table")
local gtimer = require("gears.timer")
local json = require("modules.json")
local helpers = require("helpers")
local user_vars = require("user_variables")
local string = string
local ipairs = ipairs

local github = {}
local instance = nil

local UPDATE_INTERVAL = 60 * 60 * 1 -- 1 hour
local PATH = helpers.filesystem.get_cache_dir("github")

function github:get_username()
	return self._private.username
end

function github:check_username(callback)
	local username_file = PATH .. "username.txt"

	local function continue()
		helpers.filesystem.read_file(username_file, function (username)
			if username ~= nil and username ~= self:get_username() then
				aspawn("rm -rf " .. PATH)
				helpers.filesystem.make_directory(PATH, function ()
					helpers.filesystem.save_file(username_file, self._private.username, function ()
						callback(true)
					end)
				end)
			end

			callback(false)
		end)
	end

	helpers.filesystem.is_file_readable(username_file, function (is_readable)
		if not is_readable then
			helpers.filesystem.save_file(username_file, self._private.username, continue)
		end
		continue()
	end)
end

local function github_events(self)
	local link = "https://api.github.com/users/%s/received_events"
	local path = PATH .. "events/"
	local avatars_path = path .. "avatars/"
	local DATA_PATH = path .. "data.json"

	local old_data = nil

	helpers.filesystem.remote_watch(
		DATA_PATH,
		string.format(link, self._private.username),
		UPDATE_INTERVAL,
		function(content)
			if content == nil or content == false then
				self:emit_signal("events::error")
				return
			end

			local data = json.decode(content)

			if data == nil then
				self:emit_signal("events::error")
				return
			end

			for index, event in ipairs(data) do
				if old_data ~= nil and old_data[event.id] == nil then
					self:emit_signal("new_event", event)
				end

				local is_downloading = false
				local path_to_avatar = avatars_path .. event.actor.id
				helpers.filesystem.is_file_readable(path_to_avatar, function(result)
					if result == false then
						is_downloading = true
						helpers.filesystem.save_uri(path_to_avatar, event.actor.avatar_url, function()
							is_downloading = false
							if index == #data then
								self:emit_signal("events", data, avatars_path)
							end
						end)
					elseif index == #data and is_downloading == false then
						self:emit_signal("events", data, avatars_path)
					end
				end)
			end
		end,
		function(old_content)
			local data = json.decode(old_content)
			if data ~= nil then
				old_data = {}
				for _, event in ipairs(data) do
					old_data[event.id] = event.id
				end
			end
		end
	)
end

local function github_prs(self)
	local path = PATH .. "created_prs/"
	local avatars_path = path .. "avatars/"
	local DATA_PATH = path .. "data.json"

	local link = "https://api.github.com/search/issues?q=author%3A" .. self._private.username .. "+type%3Apr"

	local old_data = nil

	helpers.filesystem.remote_watch(DATA_PATH, link, UPDATE_INTERVAL, function(content)
		if content == nil or content == false then
			self:emit_signal("prs::error")
			return
		end

		local data = json.decode(content)
		if data == nil then
			self:emit_signal("prs::error")
			return
		end

		for index, pr in ipairs(data.items) do
			if old_data ~= nil and old_data[pr.id] == nil then
				self:emit_signal("new_pr", pr)
			end

			local is_downloading = false
			local path_to_avatar = avatars_path .. pr.user.id
			helpers.filesystem.is_file_readable(path_to_avatar, function(result)
				if result == false then
					is_downloading = true
					helpers.filesystem.save_uri(path_to_avatar, pr.user.avatar_url, function()
						is_downloading = false
						if index == #data.items then
							self:emit_signal("prs", data.items, avatars_path)
						end
					end)
				elseif index == #data.items and is_downloading == false then
					self:emit_signal("prs", data.items, avatars_path)
				end
			end)
		end
	end, function(old_content)
		local data = json.decode(old_content)
		if data ~= nil then
			old_data = {}
			for _, pr in ipairs(data.items) do
				old_data[pr.id] = pr.id
			end
		end
	end)
end

local function github_contributions(self)
	local link = "https://github-contributions.vercel.app/api/v1/%s"
	local path = PATH .. "contributions/"
	local DATA_PATH = path .. "data.json"

	helpers.filesystem.remote_watch(
		DATA_PATH,
		string.format(link, self._private.username),
		UPDATE_INTERVAL,
		function(content)
			self:emit_signal("contributions", content)
		end
	)
end

function github:refresh()
	github_events(self)
	github_prs(self)
	github_contributions(self)
end

local function new()
	local ret = gobject({})
	gtable.crush(ret, github, true)

	ret._private = {}
	ret._private.username = user_vars.widget.github.username

	ret:check_username(function (_)
		if ret._private.username ~= nil then
			ret:refresh()
		else
			gtimer.delayed_call(function ()
				ret:emit_signal("missing_credentials")
			end)
		end
	end)

	return ret
end

if not instance then
	instance = new()
end
return instance
