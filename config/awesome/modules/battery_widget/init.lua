---------------------------------------------------------------------------
-- A battery widget based on the UPower deamon.
--
-- @author Aire-One
-- @copyright 2020 Aire-One
---------------------------------------------------------------------------

local upower = require('lgi').require('UPowerGlib')

local gtable = require 'gears.table'
local gtimer = require 'gears.timer'
local wbase = require 'wibox.widget.base'

local setmetatable = setmetatable -- luacheck: ignore setmetatable

local battery_widget = {}
local mt = {}


--- Helper to get the path of all connected power devices.
-- @treturn table The list of all power devices path.
-- @staticfct battery_widget.list_devices
function battery_widget.list_devices()
    local ret = {}
    local devices = upower.Client():get_devices()

    for _,d in ipairs(devices) do
        table.insert(ret, d:get_object_path())
    end

    return ret
end

--- Helper function to get a device instance from its path.
-- @tparam string path The path of the device to get.
-- @treturn UPowerGlib.Device|nil The device if it was found, `nil` otherwise.
-- @staticfct battery_widget.get_device
function battery_widget.get_device(path)
    local devices = upower.Client():get_devices()

    for _,d in ipairs(devices) do
        if d:get_object_path() == path then
            return d
        end
    end

    return nil
end

--- Helper function to easily get the default BAT0 device path without.
-- @treturn string The BAT0 device path.
-- @staticfct battery_widget.get_BAT0_device_path
function battery_widget.get_BAT0_device_path()
    local bat0_path = '/org/freedesktop/UPower/devices/battery_BAT0'
    return bat0_path
end

--- Helper function to convert seconds into a human readable clock string.
--
-- This translates the given seconds parameter into a human readable string
-- following the notation `HH:MM` (where HH is the number of hours and MM the
-- number of minutes).
-- @tparam number seconds The umber of seconds to translate.
-- @treturn string The human readable generated clock string.
-- @staticfct battery_widget.to_clock
function battery_widget.to_clock(seconds)
    if seconds <= 0 then
        return '00:00';
    else
        local hours = string.format('%02.f', math.floor(seconds/3600));
        local mins = string.format('%02.f', math.floor(seconds/60 - hours*60));
        return hours .. ':' .. mins
    end
end


--- Gives the default widget to use if user didn't specify one.
-- The default widget used is an `empty_widget` instance.
-- @treturn widget The default widget to use.
local function default_template ()
    return wbase.empty_widget()
end


--- The device monitored by the widget.
-- @property device
-- @tparam UPowerGlib.Device device

--- Emited when the UPower device notify an update.
-- @signal upower::update
-- @tparam battery_widget widget The widget.
-- @tparam UPowerGlib.Device device The Upower device.


--- battery_widget constructor.
--
-- This function creates a new `battery_widget` instance. This widget watches
-- the `display_device` status and report.
-- @tparam table args The arguments table.
-- @tparam[opt] widget args.widget_template The widget template to use to
--   create the widget instance.
-- @tparam[opt] string args.device_path Path of the device to monitor.
-- @tparam[opt=false] boolean args.use_display_device Should the widget monitor
--   the _display device_?
-- @tparam[opt] boolean args.instant_update Call an update cycle right after the
--   widget creation.
-- @treturn battery_widget The battery_widget instance build.
-- @constructorfct battery_widget.new
function battery_widget.new (args)
    args = gtable.crush({
        widget_template = default_template(),
        device_path = '',
        use_display_device = false
    }, args or {})

    local widget = wbase.make_widget_from_value(args.widget_template)

    widget.device = args.use_display_device
        and upower.Client():get_display_device()
        or battery_widget.get_device(args.device_path)

    -- Attach signals:
    widget.device.on_notify = function (d)
        widget:emit_signal('upower::update', d)
    end

    -- Call an update cycle if the user asked to instan update the widget.
    if args.instant_update then
        gtimer.delayed_call(widget.emit_signal, widget, 'upower::update', widget.device)
    end

    return widget
end


function mt.__call(self, ...)
    return battery_widget.new(...)
end

return setmetatable(battery_widget, mt)
