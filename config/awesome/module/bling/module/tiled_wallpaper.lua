--[[
    This module makes use of cairo surfaces
    For documentation take a look at the C docs:
    https://www.cairographics.org/
    They can be applied to lua by changing the naming conventions
    and adjusting for the missing namespaces (and classes)
    for example:
    cairo_rectangle(cr, 1, 1, 1, 1) in C would be written as 
    cr:rectangle(1, 1, 1, 1) in lua
    and 
    cairo_fill(cr) in C would be written as 
    cr:fill() in lua
--]]

local cairo = require("lgi").cairo
local gears = require("gears")

function create_tiled_wallpaper(str, s, args_table)
    -- user input
    args_table = args_table or {}
    local fg = args_table.fg or "#ff0000"
    local bg = args_table.bg or "#00ffff"
    local offset_x = args_table.offset_x
    local offset_y = args_table.offset_y
    local font = args_table.font or "Hack"
    local font_size = tonumber(args_table.font_size) or 16
    local zickzack_bool = args_table.zickzack or false
    local padding = args_table.padding or 100

    -- create cairo image wallpaper
    local img = cairo.ImageSurface(cairo.Format.RGB24, padding, padding)
    cr = cairo.Context(img)

    cr:set_source(gears.color(bg))
    cr:paint()

    cr:set_source(gears.color(fg))

    cr:set_font_size(font_size)
    cr:select_font_face(font)

    if zickzack_bool then
        cr:set_source(gears.color(fg))
        cr:move_to(padding / 2 + font_size, padding / 2 + font_size)
        cr:show_text(str)
    end

    cr:set_source(gears.color(fg))
    cr:move_to(font_size, font_size)
    cr:show_text(str)

    -- tile cairo image
    gears.wallpaper.tiled(img, s, { x = offset_x, y = offset_y })
end

return create_tiled_wallpaper
