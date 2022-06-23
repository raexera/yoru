local lgi = require("lgi")
local Gio = lgi.Gio
local Gtk = lgi.require("Gtk", "3.0")
local gobject = require("gears.object")
local gtable = require("gears.table")
local setmetatable = setmetatable
local ipairs = ipairs

local icon_theme = { mt = {} }

local name_lookup =
{
    ["jetbrains-studio"] = "android-studio"
}

local function get_icon_by_pid_command(self, client, apps)
    local pid = client.pid
    if pid ~= nil then
        local handle = io.popen(string.format("ps -p %d -o comm=", pid))
        local pid_command = handle:read("*a"):gsub("^%s*(.-)%s*$", "%1")
        handle:close()

        for _, app in ipairs(apps) do
            local executable = app:get_executable()
            if executable and executable:find(pid_command, 1, true) then
                return self:get_gicon_path(app:get_icon())
            end
        end
    end
end

local function get_icon_by_icon_name(self, client, apps)
    local icon_name = client.icon_name and client.icon_name:lower() or nil
    if icon_name ~= nil then
        for _, app in ipairs(apps) do
            local name = app:get_name():lower()
            if name and name:find(icon_name, 1, true) then
                return self:get_gicon_path(app:get_icon())
            end
        end
    end
end

local function get_icon_by_class(self, client, apps)
    if client.class ~= nil then
        local class = name_lookup[client.class] or client.class:lower()

        -- Try to remove dashes
        local class_1 = class:gsub("[%-]", "")

        -- Try to replace dashes with dot
        local class_2 = class:gsub("[%-]", ".")

        -- Try to match only the first word
        local class_3 = class:match("(.-)-") or class
        class_3 = class_3:match("(.-)%.") or class_3
        class_3 = class_3:match("(.-)%s+") or class_3

        local possible_icon_names = { class, class_3, class_2, class_1 }
        for _, app in ipairs(apps) do
            local id = app:get_id():lower()
            for _, possible_icon_name in ipairs(possible_icon_names) do
                if id and id:find(possible_icon_name, 1, true) then
                    return self:get_gicon_path(app:get_icon())
                end
            end
        end
    end
end

function icon_theme:get_client_icon_path(client)
    local apps = Gio.AppInfo.get_all()

    return  get_icon_by_pid_command(self, client, apps) or
            get_icon_by_icon_name(self, client, apps) or
            get_icon_by_class(self, client, apps) or
            client.icon or
            self:choose_icon({"window", "window-manager", "xfwm4-default", "window_list" })
end

function icon_theme:choose_icon(icons_names)
    local icon_info = self.gtk_theme:choose_icon(icons_names, self.icon_size, 0);
    if icon_info then
        local icon_path = icon_info:get_filename()
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

    local icon_info = self.gtk_theme:lookup_by_gicon(gicon, self.icon_size, 0);
    if icon_info then
        local icon_path = icon_info:get_filename()
        if icon_path then
            return icon_path
        end
    end

    return ""
end

function icon_theme:get_icon_path(icon_name)
    local icon_info = self.gtk_theme:lookup_icon(icon_name, self.icon_size, 0)
    if icon_info then
        local icon_path = icon_info:get_filename()
        if icon_path then
            return icon_path
        end
    end

    return ""
end

local function new(theme_name, icon_size)
    local ret = gobject{}
    gtable.crush(ret, icon_theme, true)

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