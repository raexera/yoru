---------------------------------------------------------------------------
-- High-level declarative function for setting your wallpaper.
--
--
-- An easy way to setup a complex wallpaper with slideshow, random, schedule, extensibility.
--
-- @usage
--   local wallpaper = require("wallpaper")
--   -- A silly example
--   wallpaper.setup {                             -- I want a wallpaper
--       change_timer = 500,                       -- changing every 5 minutes
--       set_function = wallpaper.setters.random,  -- in a random way
--       wallpaper = {"#abcdef",
--                    "~/Pictures",
--                    wallpaper.setters.awesome},  -- from this list (a color, a directory with pictures and the Awesome wallpaper)
--       recursive = false,                        -- do not read subfolders of "~/Pictures"
--       position = "centered",                    -- center it on the screen (for pictures)
--       scale = 2,                                -- 2 time bigger (for pictures)
--   }
--
-- @author Grumph
-- @copyright 2021 Grumph
--
---------------------------------------------------------------------------

local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local helpers = require(tostring(...):match(".*bling") .. ".helpers")

local setters = {}

--- Apply a wallpaper.
--
-- This function is a helper that will apply a wallpaper_object,
-- either using gears.wallpaper.set or gears.wallpaper.* higher level functions when applicable.
-- @param wallpaper_object A wallpaper object, either
--   a `pattern` (see `gears.wallpaper.set`)
--   a `surf` (see `gears.wallpaper.centered`)
--   a function that actually sets the wallpaper.
-- @tparam table args The argument table containing any of the arguments below.
-- @int[opt=nil] args.screen The screen to use (as used in `gears.wallpaper` functions)
-- @string[opt=nil or "centered"] args.position The `gears.wallpaper` position function to use.
--   Must be set when wallpaper is a file.
--   It can be `"centered"`, `"fit"`, `"tiled"` or `"maximized"`.
-- @string[opt=beautiful.bg_normal or "black"] args.background See `gears.wallpaper`.
-- @bool[opt=false] args.ignore_aspect See `gears.wallpaper`.
-- @tparam[opt={x=0,y=0}] table args.offset See `gears.wallpaper`.
-- @int[opt=1] args.scale See `gears.wallpaper`.
function apply(wallpaper_object, args)
    args.background = args.background or beautiful.bg_normal or "black"
    args.ignore_aspect = args.ignore_aspect or false -- false = keep aspect ratio
    args.offset = args.offset or { x = 0, y = 0 }
    args.scale = args.scale or 1
    local positions = {
        ["centered"] = function(s)
            gears.wallpaper.centered(
                wallpaper_object,
                s,
                args.background,
                args.scale
            )
        end,
        ["tiled"] = function(s)
            gears.wallpaper.tiled(wallpaper_object, s, args.offset)
        end,
        ["maximized"] = function(s)
            gears.wallpaper.maximized(
                wallpaper_object,
                s,
                args.ignore_aspect,
                args.offset
            )
        end,
        ["fit"] = function(s)
            gears.wallpaper.fit(wallpaper_object, s, args.background)
        end,
    }
    local call_func = nil
    if
        type(wallpaper_object) == "string"
        and gears.filesystem.file_readable(wallpaper_object)
    then
        -- path of an image file, we use a position function
        local p = args.position or "centered"
        call_func = positions[p]
    elseif type(wallpaper_object) == "function" then
        -- function
        wallpaper_object(args)
    elseif
        (not gears.color.ensure_pango_color(wallpaper_object, nil))
        and args.position
    then
        -- if the user sets a position function, wallpaper_object should be a cairo surface
        call_func = positions[args.position]
    else
        gears.wallpaper.set(wallpaper_object)
    end
    if call_func then
        call_func(args.screen)
    end
end

--- Converts `args.wallpaper` to a list of `wallpaper_objects` readable by `apply` function).
--
-- @tparam table args The argument table containing the argument below.
-- @param[opt=`beautiful.wallpaper_path` or `"black"`] args.wallpaper A wallpaper object.
--   It can be a color or a cairo pattern (what `gears.wallpaper.set` understands),
--   a cairo suface (set with gears.wallpaper.set if `args.position` is nil, or with
--   `gears.wallpaper` position functions, see `args.position`),
--   a function similar to args.set_function that will effectively set a wallpaper (usually
--   with `gears.wallpaper` functions),
--   a path to a file,
--   path to a directory containing images,
--   or a list with any of the previous choices.
-- @tparam[opt=`{"jpg", "jpeg", "png", "bmp"}`] table args.image_formats A list of
--   file extensions to filter when `args.wallpaper` is a directory.
-- @bool[opt=true] args.recursive Either to recurse or not when `args.wallpaper` is a directory.
-- @treturn table A list of `wallpaper_objects` (what `apply` can read).
-- @see apply
function prepare_list(args)
    args.image_formats = args.image_formats or { "jpg", "jpeg", "png", "bmp" }
    args.recursive = args.recursive or true

    local wallpapers = (args.wallpaper or beautiful.wallpaper_path or "black")
    local res = {}
    if type(wallpapers) ~= "table" then
        wallpapers = { wallpapers }
    end
    for _, w in ipairs(wallpapers) do
        -- w is either:
        --  - a directory path (string)
        --  - an image path or a color (string)
        --  - a cairo surface or a cairo pattern
        --  - a function for setting the wallpaper
        if type(w) == "string" and gears.filesystem.dir_readable(w) then
            local file_list = helpers.filesystem.list_directory_files(
                w,
                args.image_formats,
                args.recursive
            )
            for _, f in ipairs(file_list) do
                res[#res + 1] = w .. "/" .. f
            end
        else
            res[#res + 1] = w
        end
    end
    return res
end

local simple_index = 0
---  Set the next wallpaper in a list.
--
-- @tparam table args See `prepare_list` and `apply` arguments
-- @see apply
-- @see prepare_list
function setters.simple(args)
    local wallpapers = prepare_list(args)
    simple_index = (simple_index % #wallpapers) + 1
    if type(args.screen) == 'table' then
        for _,v in ipairs(args.screen) do
            args.screen = v
            apply(wallpapers[simple_index], args)
            args.screen = nil
        end
    else
        apply(wallpapers[simple_index], args)
    end
end

--- Set a random wallpaper from a list.
--
-- @tparam table args See `prepare_list` and `apply` arguments
-- @see apply
-- @see prepare_list
function setters.random(args)
    local wallpapers = prepare_list(args)
    if type(args.screen) == 'table' then
        for _,v in ipairs(args.screen) do
            args.screen = v
            apply(wallpapers[math.random(#wallpapers)], args)
            args.screen = nil
        end
    else
        apply(wallpapers[math.random(#wallpapers)], args)
    end
end

local simple_schedule_object = nil
--- A schedule setter.
--
-- This simple schedule setter was freely inspired by [dynamic-wallpaper](https://github.com/manilarome/awesome-glorious-widgets/blob/master/dynamic-wallpaper/init.lua).
-- @tparam table args The argument table containing any of the arguments below.
-- @tparam table args.wallpaper The schedule table, with the form
--     {
--      ["HH:MM:SS"] = wallpaper,
--      ["HH:MM:SS"] = wallpaper2,
--     }
--   The wallpapers definition can be anything the `schedule_set_function` can read
--   (what you would place in `args.wallpaper` for this function),
-- @tparam[opt=`setters.simple`] function args.wallpaper_set_function The set_function used by default
function setters.simple_schedule(args)
    local function update_wallpaper()
        local fake_args = gears.table.join(args, {
            wallpaper = args.wallpaper[simple_schedule_object.closest_lower_time],
        })
        simple_schedule_object.schedule_set_function(fake_args)
    end
    if not simple_schedule_object then
        simple_schedule_object = {}
        -- initialize the schedule object, so we don't do it for every call
        simple_schedule_object.schedule_set_function = args.schedule_set_function
            or setters.simple
        -- we get the sorted time keys
        simple_schedule_object.times = {}
        for k in pairs(args.wallpaper) do
            table.insert(simple_schedule_object.times, k)
        end
        table.sort(simple_schedule_object.times)
        -- now we get the closest time which is below current time (the current applicable period)
        local function update_timer()
            local current_time = os.date("%H:%M:%S")
            local next_time = simple_schedule_object.times[1]
            simple_schedule_object.closest_lower_time =
                simple_schedule_object.times[#simple_schedule_object.times]
            for _, k in ipairs(simple_schedule_object.times) do
                if k > current_time then
                    next_time = k
                    break
                end
                simple_schedule_object.closest_lower_time = k
            end
            simple_schedule_object.timer.timeout = helpers.time.time_diff(
                next_time,
                current_time
            )
            if simple_schedule_object.timer.timeout < 0 then
                -- the next_time is the day after, so we add 24 hours to the timer
                simple_schedule_object.timer.timeout = simple_schedule_object.timer.timeout
                    + 86400
            end
            simple_schedule_object.timer:again()
            update_wallpaper()
        end
        simple_schedule_object.timer = gears.timer({
            callback = update_timer,
        })
        update_timer()
    else
        -- if called again (usually when the change_timer is set), we just change the wallpaper depending on current parameters
        update_wallpaper()
    end
end

--- Set the AWESOME wallpaper.
--
-- @tparam table args The argument table containing the argument below.
--   @param[opt=`beautiful.bg_normal`] args.colors.bg The bg color.
--     If the default is used, the color is darkened if `beautiful.bg_normal` is light
--     or lightned if `beautiful.bg_normal` is dark.
--   @param[opt=`beautiful.fg_normal`] args.colors.fg The fg color.
--   @param[opt=`beautiful.fg_focus`] args.colors.alt_fg The alt_fg color.
--
-- see beautiful.theme_assets.wallpaper
function setters.awesome_wallpaper(args)
    local colors = {
        bg = beautiful.bg_normal,
        fg = beautiful.fg_normal,
        alt_fg = beautiful.bg_focus,
    }
    colors.bg = helpers.color.is_dark(beautiful.bg_normal)
            and helpers.color.lighten(colors.bg)
        or helpers.color.darken(colors.bg)
    if type(args.colors) == "table" then
        colors.bg = args.colors.bg or colors.bg
        colors.fg = args.colors.fg or colors.fg
        colors.alt_fg = args.colors.alt_fg or colors.alt_fg
    end
    -- Generate wallpaper:
    if not args.screen then
        for s in screen do
            gears.wallpaper.set(
                beautiful.theme_assets.wallpaper(
                    colors.bg,
                    colors.fg,
                    colors.alt_fg,
                    s
                )
            )
        end
    else
        gears.wallpaper.set(
            beautiful.theme_assets.wallpaper(
                colors.bg,
                colors.fg,
                colors.alt_fg,
                args.screen
            )
        )
    end
end

--- Setup a wallpaper.
--
-- @tparam table args Parameters for the wallpaper. It may also contain all parameters your `args.set_function` needs
-- @int[opt=nil] args.screen The screen to use (as used in `gears.wallpaper` functions)
-- @int[opt=nil] args.change_timer Time in seconds for wallpaper changes
-- @tparam[opt=`setters.awesome` or `setters.simple`] function args.set_function A function to set the wallpaper
--   It takes args as parameter (the same args as the setup function).
--   This function is called at `"request::wallpaper"` `screen` signals and at `args.change_timer` timeouts.
--   There is no obligation, but for consistency, the function should use `args.wallpaper` as a feeder.
--   If `args.wallpaper` is defined, the default function is `setters.simple`, else it will be `setters.awesome`.
--
-- @usage
--   local wallpaper = require("wallpaper")
--   wallpaper.setup {
--       change_timer = 631,  -- Prime number is better
--       set_function = wallpaper.setters.random,
--       -- parameters for the random setter
--       wallpaper = '/data/pictures/wallpapers',
--       position = "maximized",
--   }
--
-- @see apply
-- @see prepare_list
-- @see setters.simple
function setup(args)
    local config = args or {}
    config.set_function = config.set_function
        or (config.wallpaper and setters.simple or setters.awesome_wallpaper)
    local function set_wallpaper(s)
        if type(config.screen) ~= 'table' then
            if config.screen and s and config.screen ~= s then return end
            config.screen = s or config.screen
        end
        config.set_function(config)
    end

    if config.change_timer and config.change_timer > 0 then
        gears.timer({
            timeout = config.change_timer,
            call_now = false,
            autostart = true,
            callback = function()
                set_wallpaper()
            end,
        })
    end
    if awesome.version == "v4.3" or awesome.version == "4.3" then
        awful.screen.connect_for_each_screen(set_wallpaper)
    else
        screen.connect_signal("request::wallpaper", set_wallpaper)
    end
end

return {
    setup = setup,
    setters = setters,
    apply = apply,
    prepare_list = prepare_list,
}
