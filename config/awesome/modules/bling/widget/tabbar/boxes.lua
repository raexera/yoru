local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")

local beautiful = require("beautiful")

local bg_normal = beautiful.tabbar_bg_normal or beautiful.bg_normal or "#ffffff"
local fg_normal = beautiful.tabbar_fg_normal or beautiful.fg_normal or "#000000"
local bg_focus = beautiful.tabbar_bg_focus or beautiful.bg_focus or "#000000"
local fg_focus = beautiful.tabbar_fg_focus or beautiful.fg_focus or "#ffffff"
local bg_focus_inactive = beautiful.tabbar_bg_focus_inactive or bg_focus
local fg_focus_inactive = beautiful.tabbar_fg_focus_inactive or fg_focus
local bg_normal_inactive = beautiful.tabbar_bg_normal_inactive or bg_normal
local fg_normal_inactive = beautiful.tabbar_fg_normal_inactive or fg_normal
local font = beautiful.tabbar_font or beautiful.font or "Hack 15"
local size = beautiful.tabbar_size or 40
local position = beautiful.tabbar_position or "bottom"

local function create(c, focused_bool, buttons, inactive_bool)
    local bg_temp = inactive_bool and bg_normal_inactive or bg_normal
    local fg_temp = inactive_bool and fg_normal_inactive or fg_normal
    if focused_bool then
        bg_temp = inactive_bool and bg_focus_inactive or bg_focus
        fg_temp = inactive_bool and fg_focus_inactive or fg_focus
    end
    local wid_temp = wibox.widget({
        {
            {
                awful.widget.clienticon(c),
                left = 10,
                right = 10,
                bottom = 10,
                top = 10,
                widget = wibox.container.margin(),
            },
            widget = wibox.container.place(),
        },
        buttons = buttons,
        bg = bg_temp,
        widget = wibox.container.background(),
    })
    return wid_temp
end

local layout = wibox.layout.fixed.horizontal
if position == "left" or position == "right" then
    layout = wibox.layout.fixed.vertical
end

return {
    layout = layout,
    create = create,
    position = position,
    size = size,
    bg_normal = bg_normal,
    bg_focus = bg_normal,
}
