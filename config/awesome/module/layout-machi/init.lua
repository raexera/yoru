local engine = require(... .. ".engine")
local layout = require(... .. ".layout")
local editor = require(... .. ".editor")
local switcher = require(... .. ".switcher")
local default_editor = editor.default_editor
local default_layout = layout.create{ name_func = default_name }
local gcolor = require("gears.color")
local beautiful = require("beautiful")

local icon_raw
local source = debug.getinfo(1, "S").source
if source:sub(1, 1) == "@" then
    icon_raw = source:match("^@(.-)[^/]+$") .. "icon.png"
end

local function get_icon()
    if icon_raw ~= nil then
        return gcolor.recolor_image(icon_raw, beautiful.fg_normal)
    else
        return nil
    end
end

return {
    engine = engine,
    layout = layout,
    editor = editor,
    switcher = switcher,
    default_editor = default_editor,
    default_layout = default_layout,
    icon_raw = icon_raw,
    get_icon = get_icon,
}
