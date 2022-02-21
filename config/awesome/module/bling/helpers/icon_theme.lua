local Gio = require("lgi").Gio
local Gtk = require("lgi").Gtk
local gobject = require("gears.object")
local gtable = require("gears.table")
local helpers = require("helpers")
local setmetatable = setmetatable
local ipairs = ipairs

local icon_theme = { mt = {} }

function icon_theme:get_client_icon_path(client)
    local function find_icon(class)
        if self._private.client_icon_cache[class] ~= nil  then
            return self._private.client_icon_cache[class]
        end

        for _, app in ipairs(Gio.AppInfo.get_all()) do
            local id = Gio.AppInfo.get_id(app)
            if id:match(helpers.misc.case_insensitive_pattern(class)) then
                self._private.client_icon_cache[class] = self:get_gicon_path(Gio.AppInfo.get_icon(app))
                return self._private.client_icon_cache[class]
            end
        end

        return nil
    end

    local class = client.class
    if class == "jetbrains-studio" then
        class = "android-studio"
    end

    local icon = self:get_icon_path("gnome-window-manager")

    if class ~= nil then
        class = class:gsub("[%-]", "%%%0")
        icon = find_icon(class) or icon

        class = client.class
        class = class:gsub("[%-]", "")
        icon = find_icon(class) or icon

        class = client.class
        class = class:gsub("[%-]", ".")
        icon = find_icon(class) or icon

        class = client.class
        class = class:match("(.-)-") or class
        class = class:match("(.-)%.") or class
        class = class:match("(.-)%s+") or class
        class = class:gsub("[%-]", "%%%0")
        icon = find_icon(class) or icon
    end

    return icon
end

function icon_theme:choose_icon(icons_names)
    local icon_info = Gtk.IconTheme.choose_icon(self.gtk_theme, icons_names, self.icon_size, 0);
    if icon_info then
        local icon_path = Gtk.IconInfo.get_filename(icon_info)
        if icon_path then
            return icon_path
        end
    end

    return ""
end


function icon_theme:get_gicon_path(gicon)
    if gicon == nil then
        return ""
    end

    if self._private.icon_cache[gicon] ~= nil then
        return self._private.icon_cache[gicon]
    end

    local icon_info = Gtk.IconTheme.lookup_by_gicon(self.gtk_theme, gicon, self.icon_size, 0);
    if icon_info then
        local icon_path = Gtk.IconInfo.get_filename(icon_info)
        if icon_path then
            self._private.icon_cache[gicon] = icon_path
            return icon_path
        end
    end

    return ""
end

function icon_theme:get_icon_path(icon_name)
    if self._private.icon_cache[icon_name] ~= nil then
        return self._private.icon_cache[icon_name]
    end

    local icon_info = Gtk.IconTheme.lookup_icon(self.gtk_theme, icon_name, self.icon_size, 0);
    if icon_info then
        local icon_path = Gtk.IconInfo.get_filename(icon_info)
        if icon_path then
            self._private.icon_cache[icon_name] = icon_path
            return icon_path
        end
    end

    return ""
end

local function new(theme_name, icon_size)
    local ret = gobject{}
    gtable.crush(ret, icon_theme, true)

    ret._private = {}
    ret._private.client_icon_cache = {}
    ret._private.icon_cache = {}

    ret.name = theme_name or nil
    ret.icon_size = icon_size or 48

    if theme_name then
        ret.gtk_theme = Gtk.IconTheme.new()
        Gtk.IconTheme.set_custom_theme(ret.gtk_theme, theme_name);
    else
        ret.gtk_theme = Gtk.IconTheme.get_default()
    end

    return ret
end

function icon_theme.mt:__call(...)
    return new(...)
end

return setmetatable(icon_theme, icon_theme.mt)
