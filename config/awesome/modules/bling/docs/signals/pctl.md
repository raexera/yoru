## 🎵 Playerctl <!-- {docsify-ignore} -->

This is a signal module in which you can connect to certain bling signals to grab playerctl info. Currently, this is what it supports:

- Song title and artist
- Album art (the path this module downloaded the art to)
- If playing or not
- Position
- Song length
- If there are no players on

This module relies on `playerctl` and `curl`. If you have this module disabled, you won't need those programs. With this module, you can create a widget like below without worrying about the backend.

![](https://user-images.githubusercontent.com/33443763/107377569-fa807900-6a9f-11eb-93c1-174c58eb7bf1.png)

*screenshot by [javacafe](https://github.com/JavaCafe01)*

### Usage

To enable: `playerctl = bling.signal.playerctl.lib/cli()`

To disable: `playerctl:disable()`

#### Playerctl_lib Signals

**Note**: When connecting to signals with the new `playerctl` module, the object itself is always given to you as the first parameter.

```lua
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
```

#### Playerctl_cli Signals

```lua
-- metadata
--      title (string)
--      artist  (string)
--      album_path (string)
--      album (string)
--      player_name (string)
-- position
--      interval_sec (number)
--      length_sec (number)
-- playback_status
--      playing (boolean)
-- volume
--      volume (number)
-- loop_status
--      loop_status (string)
-- shuffle
--      shuffle (bool)
-- no_players
--      (No parameters)
```

#### Playerctl Functions

With this library we also give the user a way to interact with Playerctl, such as playing, pausing, seeking, etc.

Here are the functions provided:

```lua
-- disable()
-- pause(player)
-- play(player)
-- stop(player)
-- play_pause(player)
-- previous(player)
-- next(player)
-- set_loop_status(loop_status, player)
-- cycle_loop_status(player)
-- set_position(position, player)
-- set_shuffle(shuffle, player)
-- cycle_shuffle(player)
-- set_volume(volume, player)
-- get_manager()
-- get_active_player()
-- get_player_of_name(name)
```

### Example Implementation

Lets say we have an imagebox. If I wanted to set the imagebox to show the album art, all I have to do is this:

```lua
local art = wibox.widget {
    image = "default_image.png",
    resize = true,
    forced_height = dpi(80),
    forced_width = dpi(80),
    widget = wibox.widget.imagebox
}

local name_widget = wibox.widget {
    markup = 'No players',
    align = 'center',
    valign = 'center',
    widget = wibox.widget.textbox
}

local title_widget = wibox.widget {
    markup = 'Nothing Playing',
    align = 'center',
    valign = 'center',
    widget = wibox.widget.textbox
}

local artist_widget = wibox.widget {
    markup = 'Nothing Playing',
    align = 'center',
    valign = 'center',
    widget = wibox.widget.textbox
}

-- Get Song Info
local playerctl = bling.signal.playerctl.lib()
playerctl:connect_signal("metadata",
                       function(_, title, artist, album_path, album, new, player_name)
    -- Set art widget
    art:set_image(gears.surface.load_uncached(album_path))

    -- Set player name, title and artist widgets
    name_widget:set_markup_silently(player_name)
    title_widget:set_markup_silently(title)
    artist_widget:set_markup_silently(artist)
end)
```

Thats all! You don't even have to worry about updating the widgets, the signals will handle that for you.

Here's another example in which you get a notification with the album art, title, and artist whenever the song changes.

```lua
local naughty = require("naughty")
local playerctl = bling.signal.playerctl.lib()

playerctl:connect_signal("metadata",
                       function(_, title, artist, album_path, album, new, player_name)
    if new == true then
        naughty.notify({title = title, text = artist, image = album_path})
    end
end)
```

We can also link a playerctl function to a button click!

```lua
local playerctl = bling.signal.playerctl.lib()
button:buttons(gears.table.join(
	awful.button({}, 1, function() 
		playerctl:play_pause()
	end)
))
```

### Theme Variables and Configuration

By default, this module will output signals from the most recently active player. If you wish to customize the behavior furthur, the following configuration options are available depending on the selected backend. Here is a summary of the two backends and which configuration options they support.

| Option              | playerctl_cli      | playerctl_lib      |
| ------------------- | ------------------ | ------------------ |
| ignore              | :heavy_check_mark: | :heavy_check_mark: |
| player              | :heavy_check_mark: | :heavy_check_mark: |
| update_on_activity  |                    | :heavy_check_mark: |
| interval            | :heavy_check_mark: | :heavy_check_mark: |
| debounce_delay      | :heavy_check_mark: | :heavy_check_mark: |

- `ignore`: This option is either a string with a single name or a table of strings containing names of players that will be ignored by this module. It is empty by default.

- `player`: This option is either a string with a single name or a table of strings containing names of players this module will emit signals for. It also acts as a way to prioritize certain players over others with players listed earlier in the table being preferred over players listed later. The special name `%any` can be used once to match any player not found in the list. It is empty by default.

- `update_on_activity`: This option is a boolean that, when true, will cause the module to output signals from the most recently active player while still adhering to the player priority specified with the `player` option. If `false`, the module will output signals from the player that started first, again, while still adhering to the player priority. It is `true` by default.

- `interval`: This option is a number specifying the update interval for fetching the player position. It is 1 by default.

- `debounce_delay`: This option is a number specifying the debounce timer interval. If a new metadata signal gets emitted before debounce_delay has passed, the last signal will be dropped.
This is to help with some players sending multiple signals. It is `0.35` by default.

These options can be set through a call to `bling.signal.playerctl.lib/cli()` or these theme variables:

```lua
theme.playerctl_ignore  = {}
theme.playerctl_player  = {}
theme.playerctl_update_on_activity = true
theme.playerctl_position_update_interval = 1
```

#### Example Configurations

```lua
-- Prioritize ncspot over all other players and ignore firefox players (e.g. YouTube and Twitch tabs) completely
playerctl = bling.signal.playerctl.lib {
    ignore = "firefox",
    player = {"ncspot", "%any"}
}

-- OR in your theme file:
-- Same config as above but with theme variables
theme.playerctl_ignore  = "firefox"
theme.playerctl_player  = {"ncspot", "%any"}

-- Prioritize vlc over all other players and deprioritize spotify
theme.playerctl_backend = "playerctl_lib"
theme.playerctl_player  = {"vlc", "%any", "spotify"}

-- Disable priority of most recently active players
theme.playerctl_update_on_activity = false

-- Only emit the position signal every 2 seconds
theme.playerctl_position_update_interval = 2
```
