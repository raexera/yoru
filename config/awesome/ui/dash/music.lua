-- Standard awesome library
local gears = require("gears")
local awful = require("awful")

-- Theme handling library
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

-- Widget library
local wibox = require("wibox")

-- Helpers
local helpers = require("helpers")


-- Music
----------

local music_text = wibox.widget{
    font = beautiful.font_name .. "medium 8",
    markup = helpers.colorize_text("Music", beautiful.xforeground .. "b3"),
    valign = "center",
    widget = wibox.widget.textbox
}

local music_art = wibox.widget {
    image = gears.filesystem.get_configuration_dir() .. "theme/assets/no_music.png",
    resize = true,
    widget = wibox.widget.imagebox
}

local music_art_container = wibox.widget {
    music_art,
    forced_height = dpi(120),
    forced_width = dpi(120),
    widget = wibox.container.background
}

local filter_color = {
    type = 'linear',
    from = {0, 0},
    to = {0, 120},
    stops = {{0, beautiful.dash_box_bg .. "cc"}, {1, beautiful.dash_box_bg}}
}

local music_art_filter = wibox.widget {
    {
        bg = filter_color,
        forced_height = dpi(120),
        forced_width = dpi(120),
        widget = wibox.container.background
    },
    direction = "east",
    widget = wibox.container.rotate
}

local music_artist = wibox.widget{
    font = beautiful.font_name .. "medium 12",
    markup = helpers.colorize_text("Nothing Playing", beautiful.xforeground .. "e6"),
    valign = "center",
    widget = wibox.widget.textbox
}

local music_title = wibox.widget{
    font = beautiful.font_name .. "medium 9",
    markup = helpers.colorize_text("Nothing Playing", beautiful.xforeground .. "b3"),
    valign = "center",
    widget = wibox.widget.textbox
}

local music_pos = wibox.widget{
    font = beautiful.font_name .. "medium 8",
    markup = helpers.colorize_text("- / -", beautiful.xforeground .. "66"),
    valign = "center",
    widget = wibox.widget.textbox
}

awesome.connect_signal("bling::playerctl::status", function(playing)
    if playing then
        music_text.markup = helpers.colorize_text("Now Playing", beautiful.xforeground .. "cc")
    else
        music_text.markup = helpers.colorize_text("Music", beautiful.xforeground .. "cc")
        music_artist.markup = helpers.colorize_text("Nothing Playing", beautiful.xforeground .. "e6")
        music_title.markup = helpers.colorize_text("Nothing Playing", beautiful.xforeground .. "b3")
    end
end)

awesome.connect_signal("bling::playerctl::title_artist_album", function(title_current, artist_current, art_path)

    music_art:set_image(gears.surface.load_uncached(art_path))

    music_title:set_markup_silently('<span foreground="' .. beautiful.xforeground .. 'b3">' .. title_current .. '</span>')
    music_artist:set_markup_silently('<span foreground="' .. beautiful.xforeground .. 'e6">' .. artist_current .. '</span>')
end)

awesome.connect_signal("bling::playerctl::position", function(pos, length)
    local pos_now = tostring(os.date("!%M:%S", math.floor(pos)))
    local pos_length = tostring(os.date("!%M:%S", math.floor(length)))
    local pos_markup = pos_now .. " / " .. pos_length

    music_pos.markup = helpers.colorize_text(pos_markup, beautiful.xforeground .. "66")
end)

local music = wibox.widget{
    {
        {
            {
                music_art_container,
                music_art_filter,
                layout = wibox.layout.stack
            },
            {
                {
                    music_text,
                    {
                        {
                            {
                                step_function = wibox.container.scroll
                                    .step_functions
                                    .waiting_nonlinear_back_and_forth,
                                speed = 50,
                                {
                                    widget = music_artist,
                                },
                                forced_width = dpi(180),
                                widget = wibox.container.scroll.horizontal
                            },
                            {
                                step_function = wibox.container.scroll
                                    .step_functions
                                    .waiting_nonlinear_back_and_forth,
                                speed = 50,
                                {
                                    widget = music_title,
                                },
                                forced_width = dpi(180),
                                widget = wibox.container.scroll.horizontal
                            },
                            layout = wibox.layout.fixed.vertical
                        },
                        bottom = dpi(15),
                        widget = wibox.container.margin
                    },
                    music_pos,
                    expand = "none",
                    layout = wibox.layout.align.vertical
                },
                top = dpi(9),
                bottom = dpi(9),
                left = dpi(10),
                right = dpi(10),
                widget = wibox.container.margin
            },
            layout = wibox.layout.stack
        },
        bg = beautiful.dash_box_bg,
        shape = helpers.rrect(dpi(5)),
        forced_width = dpi(200),
        forced_height = dpi(120),
        widget = wibox.container.background
    },
    margins = dpi(10),
    widget = wibox.container.margin
}

return music
