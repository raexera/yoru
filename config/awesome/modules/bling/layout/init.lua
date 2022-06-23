local beautiful = require("beautiful")
local gears = require("gears")

local M = {}
local relative_lua_path = tostring(...)

local function get_layout_icon_path(name)
    local relative_icon_path = relative_lua_path
        :match("^.*bling"):gsub("%.", "/")
        .. "/icons/layouts/" .. name .. ".png"

    for p in package.path:gmatch('([^;]+)') do
        p = p:gsub("?.*", "")
        local absolute_icon_path = p .. relative_icon_path
        if gears.filesystem.file_readable(absolute_icon_path) then
            return absolute_icon_path
        end
    end
end

local function get_icon(icon_raw)
    if icon_raw ~= nil then
        return gears.color.recolor_image(icon_raw, beautiful.fg_normal)
    else
        return nil
    end
end

local layouts = {
    "mstab",
    "vertical",
    "horizontal",
    "centered",
    "equalarea",
    "deck"
}

for _, layout_name in ipairs(layouts) do
    local icon_raw = get_layout_icon_path(layout_name)
    if beautiful["layout_" .. layout_name] == nil then 
        beautiful["layout_" .. layout_name] = get_icon(icon_raw)
    end
    M[layout_name] = require(... .. "." .. layout_name)
end

return M
