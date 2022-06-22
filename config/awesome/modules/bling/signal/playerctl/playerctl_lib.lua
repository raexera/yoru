-- Playerctl signals
--
-- Provides:
-- metadata
--      title (string)
--      artist  (string)
--      album_path (string)
--      album (string)
--      new (bool)
--      player_name (string)
-- position
--      interval_sec (number)
--      length_sec (number)
--      player_name (string)
-- playback_status
--      playing (boolean)
--      player_name (string)
-- seeked
--      position (number)
--      player_name (string)
-- volume
--      volume (number)
--      player_name (string)
-- loop_status
--      loop_status (string)
--      player_name (string)
-- shuffle
--      shuffle (boolean)
--      player_name (string)
-- exit
--      player_name (string)
-- no_players
--      (No parameters)

local awful = require("awful")
local gobject = require("gears.object")
local gtable = require("gears.table")
local gtimer = require("gears.timer")
local gstring = require("gears.string")
local beautiful = require("beautiful")
local helpers = require(tostring(...):match(".*bling") .. ".helpers")
local setmetatable = setmetatable
local ipairs = ipairs
local pairs = pairs
local type = type
local capi = { awesome = awesome }

local playerctl = { mt = {} }

function playerctl:disable()
    -- Restore default settings
    self.ignore = {}
    self.priority = {}
    self.update_on_activity = true
    self.interval = 1
    self.debounce_delay = 0.35

    -- Reset timers
    self._private.manager = nil
    self._private.metadata_timer:stop()
    self._private.metadata_timer = nil
    self._private.position_timer:stop()
    self._private.position_timer = nil

    -- Reset default values
    self._private.last_position = -1
    self._private.last_length = -1
    self._private.last_player = nil
    self._private.last_title = ""
    self._private.last_artist = ""
    self._private.last_artUrl = ""
end

function playerctl:pause(player)
    player = player or self._private.manager.players[1]
    if player then
        player:pause()
    end
end

function playerctl:play(player)
    player = player or self._private.manager.players[1]
    if player then
        player:play()
    end
end

function playerctl:stop(player)
    player = player or self._private.manager.players[1]
    if player then
        player:stop()
    end
end

function playerctl:play_pause(player)
    player = player or self._private.manager.players[1]
    if player then
        player:play_pause()
    end
end

function playerctl:previous(player)
    player = player or self._private.manager.players[1]
    if player then
        player:previous()
    end
end

function playerctl:next(player)
    player = player or self._private.manager.players[1]
    if player then
        player:next()
    end
end

function playerctl:set_loop_status(loop_status, player)
    player = player or self._private.manager.players[1]
    if player then
        player:set_loop_status(loop_status)
    end
end

function playerctl:cycle_loop_status(player)
    player = player or self._private.manager.players[1]
    if player then
        if player.loop_status == "NONE" then
            player:set_loop_status("TRACK")
        elseif player.loop_status == "TRACK" then
            player:set_loop_status("PLAYLIST")
        elseif player.loop_status == "PLAYLIST" then
            player:set_loop_status("NONE")
        end
    end
end

function playerctl:set_position(position, player)
    player = player or self._private.manager.players[1]
    if player then
        player:set_position(position * 1000000)
    end
end

function playerctl:set_shuffle(shuffle, player)
    player = player or self._private.manager.players[1]
    if player then
        player:set_shuffle(shuffle)
    end
end

function playerctl:cycle_shuffle(player)
    player = player or self._private.manager.players[1]
    if player then
        player:set_shuffle(not player.shuffle)
    end
end

function playerctl:set_volume(volume, player)
    player = player or self._private.manager.players[1]
    if player then
        player:set_volume(volume)
    end
end

function playerctl:get_manager()
    return self._private.manager
end

function playerctl:get_active_player()
    return self._private.manager.players[1]
end

function playerctl:get_player_of_name(name)
    for _, player in ipairs(self._private.manager.players[1]) do
        if player.name == name then
            return player
        end
    end

    return nil
end

local function emit_metadata_signal(self, title, artist, artUrl, album, new, player_name)
    title = gstring.xml_escape(title)
    artist = gstring.xml_escape(artist)
    album = gstring.xml_escape(album)

    -- Spotify client doesn't report its art URL's correctly...
    if player_name == "spotify" then
        artUrl = artUrl:gsub("open.spotify.com", "i.scdn.co")
    end

    if artUrl ~= "" then
        local art_path = os.tmpname()
        helpers.filesystem.save_image_async_curl(artUrl, art_path, function()
            self:emit_signal("metadata", title, artist, art_path, album, new, player_name)
            capi.awesome.emit_signal("bling::playerctl::title_artist_album", title, artist, art_path, player_name)
        end)
    else
        capi.awesome.emit_signal("bling::playerctl::title_artist_album", title, artist, "", player_name)
        self:emit_signal("metadata", title, artist, "", album, new, player_name)
    end
end

local function metadata_cb(self, player, metadata)
    if self.update_on_activity then
        self._private.manager:move_player_to_top(player)
    end

    local data = metadata.value

    local title = data["xesam:title"] or ""
    local artist = data["xesam:artist"][1] or ""
    for i = 2, #data["xesam:artist"] do
        artist = artist .. ", " .. data["xesam:artist"][i]
    end
    local artUrl = data["mpris:artUrl"] or ""
    local album = data["xesam:album"] or ""

    if player == self._private.manager.players[1] then
        self._private.active_player = player

        -- Callback can be called even though values we care about haven't
        -- changed, so check to see if they have
        if
            player ~= self._private.last_player
            or title ~= self._private.last_title
            or artist ~= self._private.last_artist
            or artUrl ~= self._private.last_artUrl
        then
            if (title == "" and artist == "" and artUrl == "") then return end

            if self._private.metadata_timer ~= nil and self._private.metadata_timer.started then
                self._private.metadata_timer:stop()
            end

            self._private.metadata_timer = gtimer {
                timeout = self.debounce_delay,
                autostart = true,
                single_shot = true,
                callback = function()
                    emit_metadata_signal(self, title, artist, artUrl, album, true, player.player_name)
                end
            }

            -- Re-sync with position timer when track changes
            self._private.position_timer:again()
            self._private.last_player = player
            self._private.last_title = title
            self._private.last_artist = artist
            self._private.last_artUrl = artUrl
        end
    end
end

local function position_cb(self)
    local player = self._private.manager.players[1]
    if player then

        local position = player:get_position() / 1000000
        local length = (player.metadata.value["mpris:length"] or 0) / 1000000
        if position ~= self._private.last_position or length ~= self._private.last_length then
            capi.awesome.emit_signal("bling::playerctl::position", position, length, player.player_name)
            self:emit_signal("position", position, length, player.player_name)
            self._private.last_position = position
            self._private.last_length = length
        end
    end
end

local function playback_status_cb(self, player, status)
    if self.update_on_activity then
        self._private.manager:move_player_to_top(player)
    end

    if player == self._private.manager.players[1] then
        self._private.active_player = player

        -- Reported as PLAYING, PAUSED, or STOPPED
        if status == "PLAYING" then
            self:emit_signal("playback_status", true, player.player_name)
            capi.awesome.emit_signal("bling::playerctl::status", true, player.player_name)
        else
            self:emit_signal("playback_status", false, player.player_name)
            capi.awesome.emit_signal("bling::playerctl::status", false, player.player_name)
        end
    end
end

local function seeked_cb(self, player, position)
    if self.update_on_activity then
        self._private.manager:move_player_to_top(player)
    end

    if player == self._private.manager.players[1] then
        self._private.active_player = player
        self:emit_signal("seeked", position / 1000000, player.player_name)
    end
end

local function volume_cb(self, player, volume)
    if self.update_on_activity then
        self._private.manager:move_player_to_top(player)
    end

    if player == self._private.manager.players[1] then
        self._private.active_player = player
        self:emit_signal("volume", volume, player.player_name)
    end
end

local function loop_status_cb(self, player, loop_status)
    if self.update_on_activity then
        self._private.manager:move_player_to_top(player)
    end

    if player == self._private.manager.players[1] then
        self._private.active_player = player
        self:emit_signal("loop_status", loop_status:lower(), player.player_name)
    end
end

local function shuffle_cb(self, player, shuffle)
    if self.update_on_activity then
        self._private.manager:move_player_to_top(player)
    end

    if player == self._private.manager.players[1] then
        self._private.active_player = player
        self:emit_signal("shuffle", shuffle, player.player_name)
    end
end

local function exit_cb(self, player)
    if player == self._private.manager.players[1] then
        self:emit_signal("exit", player.player_name)
    end
end

-- Determine if player should be managed
local function name_is_selected(self, name)
    if self.ignore[name.name] then
        return false
    end

    if #self.priority > 0 then
        for _, arg in pairs(self.priority) do
            if arg == name.name or arg == "%any" then
                return true
            end
        end
        return false
    end

    return true
end

-- Create new player and connect it to callbacks
local function init_player(self, name)
    if name_is_selected(self, name) then
        local player = self._private.lgi_Playerctl.Player.new_from_name(name)
        self._private.manager:manage_player(player)
        player.on_metadata = function(player, metadata)
            metadata_cb(self, player, metadata)
        end
        player.on_playback_status = function(player, playback_status)
            playback_status_cb(self, player, playback_status)
        end
        player.on_seeked = function(player, position)
            seeked_cb(self, player, position)
        end
        player.on_volume = function(player, volume)
            volume_cb(self, player, volume)
        end
        player.on_loop_status = function(player, loop_status)
            loop_status_cb(self, player, loop_status)
        end
        player.on_shuffle = function(player, shuffle_status)
            shuffle_cb(self, player, shuffle_status)
        end
        player.on_exit = function(player, shuffle_status)
            exit_cb(self, player)
        end

        -- Start position timer if its not already running
        if not self._private.position_timer.started then
            self._private.position_timer:again()
        end
    end
end

-- Determine if a player name comes before or after another according to the
-- priority order
local function player_compare_name(self, name_a, name_b)
    local any_index = math.huge
    local a_match_index = nil
    local b_match_index = nil

    if name_a == name_b then
        return 0
    end

    for index, name in ipairs(self.priority) do
        if name == "%any" then
            any_index = (any_index == math.huge) and index or any_index
        elseif name == name_a then
            a_match_index = a_match_index or index
        elseif name == name_b then
            b_match_index = b_match_index or index
        end
    end

    if not a_match_index and not b_match_index then
        return 0
    elseif not a_match_index then
        return (b_match_index < any_index) and 1 or -1
    elseif not b_match_index then
        return (a_match_index < any_index) and -1 or 1
    elseif a_match_index == b_match_index then
        return 0
    else
        return (a_match_index < b_match_index) and -1 or 1
    end
end

-- Sorting function used by manager if a priority order is specified
local function player_compare(self, a, b)
    local player_a = self._private.lgi_Playerctl.Player(a)
    local player_b = self._private.lgi_Playerctl.Player(b)
    return player_compare_name(self, player_a.player_name, player_b.player_name)
end

local function get_current_player_info(self, player)
    local title = player:get_title() or ""
    local artist = player:get_artist() or ""
    local artUrl = player:print_metadata_prop("mpris:artUrl") or ""
    local album = player:get_album() or ""

    emit_metadata_signal(self, title, artist, artUrl, album, false, player.player_name)
    playback_status_cb(self, player, player.playback_status)
    volume_cb(self, player, player.volume)
    loop_status_cb(self, player, player.loop_status)
    shuffle_cb(self, player, player.shuffle)
end

local function start_manager(self)
    self._private.manager = self._private.lgi_Playerctl.PlayerManager()

    if #self.priority > 0 then
        self._private.manager:set_sort_func(function(a, b)
            return player_compare(self, a, b)
        end)
    end

    -- Timer to update track position at specified interval
    self._private.position_timer = gtimer {
        timeout = self.interval,
        callback = function()
            position_cb(self)
        end,
    }

    -- Manage existing players on startup
    for _, name in ipairs(self._private.manager.player_names) do
        init_player(self, name)
    end

    if self._private.manager.players[1] then
        get_current_player_info(self, self._private.manager.players[1])
    end

    local _self = self

    -- Callback to manage new players
    function self._private.manager:on_name_appeared(name)
        init_player(_self, name)
    end

    function self._private.manager:on_player_appeared(player)
        if player == self.players[1] then
            _self._private.active_player = player
        end
    end

    function self._private.manager:on_player_vanished(player)
        if #self.players == 0 then
            _self._private.metadata_timer:stop()
            _self._private.position_timer:stop()
            _self:emit_signal("no_players")
            capi.awesome.emit_signal("bling::playerctl::no_players")
        elseif player == _self._private.active_player then
            _self._private.active_player = self.players[1]
            get_current_player_info(_self, self.players[1])
        end
    end
end

local function parse_args(self, args)
    self.ignore = {}
    if type(args.ignore) == "string" then
        self.ignore[args.ignore] = true
    elseif type(args.ignore) == "table" then
        for _, name in pairs(args.ignore) do
            self.ignore[name] = true
        end
    end

    self.priority = {}
    if type(args.player) == "string" then
        self.priority[1] = args.player
    elseif type(args.player) == "table" then
        self.priority = args.player
    end
end

local function new(args)
    args = args or {}

    local ret = gobject{}
    gtable.crush(ret, playerctl, true)

    -- Grab settings from beautiful variables if not set explicitly
    args.ignore = args.ignore or beautiful.playerctl_ignore
    args.player = args.player or beautiful.playerctl_player
    ret.update_on_activity = args.update_on_activity or
                              beautiful.playerctl_update_on_activity or true
    ret.interval = args.interval or beautiful.playerctl_position_update_interval or 1
    ret.debounce_delay = args.debounce_delay or beautiful.playerctl_debounce_delay or 0.35
    parse_args(ret, args)

    ret._private = {}

    -- Metadata callback for title, artist, and album art
    ret._private.last_player = nil
    ret._private.last_title = ""
    ret._private.last_artist = ""
    ret._private.last_artUrl = ""

    -- Track position callback
    ret._private.last_position = -1
    ret._private.last_length = -1

    -- Grab playerctl library
    ret._private.lgi_Playerctl = require("lgi").Playerctl
    ret._private.manager = nil
    ret._private.metadata_timer = nil
    ret._private.position_timer = nil

    -- Ensure main event loop has started before starting player manager
    gtimer.delayed_call(function()
        start_manager(ret)
    end)

    return ret
end

function playerctl.mt:__call(...)
    return new(...)
end

return setmetatable(playerctl, playerctl.mt)
